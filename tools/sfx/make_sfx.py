#!/usr/bin/env python3
"""Synthesizes Tiptoe's procedural sound effects.

    python3 tools/sfx/make_sfx.py <out_dir> [--wav <dir>] [--only name,name]

Every sound is built here from oscillators, noise, filters and envelopes (no
samples), with fixed random seeds, so the files can be made again exactly.
Each sound is rendered at 44.1 kHz mono, peak-normalised to about -3 dBFS,
written as a WAV in a temporary folder (or --wav) and encoded to Ogg Vorbis
with ffmpeg (-q:a 5). Names ending in _loop are built to loop seamlessly:
every oscillator runs a whole number of cycles, noise is filtered circularly
and events wrap around the end. Loops are encoded at -q:a 7, because at 5
the encoder's noise differs enough between a smooth loop's end and its start
to leave a faint tick at the seam (the fridge hum showed it).

Needs numpy and ffmpeg (with libvorbis).
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import wave
import zlib
from functools import lru_cache

import numpy as np

SR = 44100
TAU = 2 * np.pi
PEAK = 10 ** (-3 / 20)


# ---------------------------------------------------------------------------
# Building blocks

def secs(seconds):
    return int(round(seconds * SR))


def timeline(seconds):
    return np.arange(secs(seconds)) / SR


def rng_for(name):
    """A random generator seeded from the sound's name, so every sound is repeatable."""
    return np.random.default_rng(zlib.crc32(name.encode()))


def env_ar(t, attack, tau, start=0.0):
    """Linear attack then exponential decay, silent before start."""
    u = t - start
    rise = np.clip(u / attack, 0, 1) if attack > 0 else 1.0
    return rise * np.exp(-np.maximum(u - attack, 0) / tau) * (u >= 0)


def bump(t, start, length, power=1.0):
    """A raised-sine swell from start to start + length, zero outside it."""
    p = np.clip((t - start) / length, 0, 1)
    return np.sin(np.pi * p) ** power


def curve(t, times, values):
    """Piecewise-linear breakpoint curve."""
    return np.interp(t, times, values)


def phase_of(freq):
    """Running phase of an oscillator whose frequency (Hz) changes per sample."""
    return TAU * (np.cumsum(freq) - freq[0]) / SR


def modes(t, freqs, amps, taus, start=0.0):
    """Struck resonances: decaying sines that start at zero phase (no click)."""
    u = np.maximum(t - start, 0)
    out = np.zeros_like(t)
    for f, a, tau in zip(freqs, amps, taus):
        out += a * np.sin(TAU * f * u) * np.exp(-u / tau)
    return out * (t >= start)


def place(buf, x, at, wrap=False):
    """Mixes x into buf at time `at`; with wrap, anything past the end comes round to the start."""
    i = secs(at)
    if wrap:
        np.add.at(buf, (i + np.arange(len(x))) % len(buf), x)
    else:
        j = min(len(buf), i + len(x))
        if j > i:
            buf[i:j] += x[:j - i]
    return buf


def convolve(x, ir, circular=False):
    """FFT convolution. Circular convolution keeps a loop seamless."""
    if circular:
        n = len(x)
        folded = np.zeros(n)
        np.add.at(folded, np.arange(len(ir)) % n, ir)
        return np.fft.irfft(np.fft.rfft(x) * np.fft.rfft(folded), n)
    n = len(x) + len(ir) - 1
    nfft = 1 << (n - 1).bit_length()
    return np.fft.irfft(np.fft.rfft(x, nfft) * np.fft.rfft(ir, nfft), nfft)[:len(x)]


@lru_cache(maxsize=None)
def _biquad_ir(kind, f, q):
    """Impulse response of an RBJ-cookbook biquad (lowpass, highpass or 0 dB-peak bandpass)."""
    w = TAU * f / SR
    cw, alpha = np.cos(w), np.sin(w) / (2 * q)
    if kind == "lp":
        b = [(1 - cw) / 2, 1 - cw, (1 - cw) / 2]
    elif kind == "hp":
        b = [(1 + cw) / 2, -(1 + cw), (1 + cw) / 2]
    else:
        b = [alpha, 0.0, -alpha]
    a0, a1, a2 = 1 + alpha, -2 * cw, 1 - alpha
    b0, b1, b2 = (v / a0 for v in b)
    a1, a2 = a1 / a0, a2 / a0
    n = min(2 * SR, int(12 * q * SR / (np.pi * max(f, 20))) + 1024)
    y = [0.0] * n
    x1 = x2 = y1 = y2 = 0.0
    for i in range(n):
        x0 = 1.0 if i == 0 else 0.0
        y0 = b0 * x0 + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        y[i] = y0
        x2, x1, y2, y1 = x1, x0, y1, y0
    return np.array(y)


def lowpass(x, f, q=0.707, circular=False):
    return convolve(x, _biquad_ir("lp", float(f), float(q)), circular)


def highpass(x, f, q=0.707, circular=False):
    return convolve(x, _biquad_ir("hp", float(f), float(q)), circular)


def bandpass(x, f, q=1.0, circular=False):
    return convolve(x, _biquad_ir("bp", float(f), float(q)), circular)


def svf(x, fc, q, mode="bp"):
    """State-variable filter whose cutoff can move every sample (for sweeps and moving formants)."""
    fc = np.broadcast_to(np.asarray(fc, dtype=float), x.shape)
    g = np.tan(np.pi * np.clip(fc, 20, SR * 0.45) / SR)
    k = 1 / q
    a1 = 1 / (1 + g * (g + k))
    a2, a3 = g * a1, g * g * a1
    ic1 = ic2 = 0.0
    out = [0.0] * len(x)
    want_bp = mode == "bp"
    for i, (v0, c1, c2, c3) in enumerate(zip(x.tolist(), a1.tolist(), a2.tolist(), a3.tolist())):
        v3 = v0 - ic2
        v1 = c1 * ic1 + c2 * v3
        v2 = ic2 + c2 * ic1 + c3 * v3
        ic1, ic2 = 2 * v1 - ic1, 2 * v2 - ic2
        out[i] = k * v1 if want_bp else v2
    return np.array(out)


def smooth(x, seconds):
    """Hann-window moving average (centred), for gliding pitch, formant and level targets."""
    n = max(3, int(seconds * SR) | 1)
    kernel = np.hanning(n)
    kernel /= kernel.sum()
    padded = np.pad(x, n, mode="edge")
    return convolve(padded, kernel)[n + n // 2:n + n // 2 + len(x)]


def wobble(rng, n, seconds):
    """Slow random wander with unit spread, for jitter and drift."""
    w = smooth(rng.standard_normal(n), seconds)
    return w / (w.std() + 1e-12)


def loop_noise(rng, n, shape):
    """Noise of length n shaped in the frequency domain by shape(freqs); periodic, so it loops."""
    spectrum = np.fft.rfft(rng.standard_normal(n)) * shape(np.fft.rfftfreq(n, 1 / SR))
    y = np.fft.irfft(spectrum, n)
    return y / (y.std() + 1e-12)


def lp_mag(f, fc, order=2):
    return 1 / np.sqrt(1 + (f / fc) ** (2 * order))


def hp_mag(f, fc, order=2):
    return 1 / np.sqrt(1 + (fc / np.maximum(f, 1e-3)) ** (2 * order))


def click(rng, t, start, decay=0.001, hp=3000):
    """A tiny bright noise tick (the contact of metal or plastic)."""
    return highpass(rng.standard_normal(len(t)) * env_ar(t, 0.0002, decay, start), hp)


def formant_voice(f0, formants, bandwidths, amp, weights=(1.0, 0.5, 0.25),
                  tilt=1.0, fmax=5000.0, sub=0.0):
    """Additive voiced sound: harmonics of a gliding f0 shaped by moving formant peaks.

    formants is a list of per-sample formant frequency tracks; sub adds the
    harmonics of f0/2 at that level for a rough, period-doubled growl. The
    result is scaled by the harmonics' total gain, so the loudness follows amp
    instead of jumping when a harmonic lands on a formant.
    """
    phase = phase_of(f0)
    step = 0.5 if sub else 1.0
    out = np.zeros_like(f0)
    power = np.zeros_like(f0)
    for k in range(1, int(fmax / (f0.min() * step)) + 1):
        h = k * step
        fk = h * f0
        gain = 0.02 + sum(w / (1 + ((fk - F) / (0.5 * B)) ** 2)
                          for F, B, w in zip(formants, bandwidths, weights))
        gain = gain * h ** -tilt * np.clip((fmax - fk) / 600, 0, 1)
        if sub and k % 2:
            gain = gain * sub
        out += gain * np.sin(h * phase)
        power += gain * gain
    return out / np.sqrt(power) * amp


# ---------------------------------------------------------------------------
# Instruments shared by several sounds

def chime_bar(t, f, start, tau):
    """A doorbell tone bar: warm fundamental with a slow beat, faint bar overtones."""
    ratios = [1.0, 1.0013, 2.0, 2.756, 5.404]
    amps = [1.0, 0.35, 0.10, 0.08, 0.025]
    taus = [tau, tau * 1.1, tau * 0.5, tau * 0.2, tau * 0.08]
    tone = modes(t, [f * r for r in ratios], amps, taus, start)
    return tone * np.clip((t - start) / 0.003, 0, 1)


def pluck(t, f, start, tau, partials=14, position=0.2):
    """A plucked string: harmonics that die faster the higher they are."""
    u = np.maximum(t - start, 0)
    out = np.zeros_like(t)
    for k in range(1, partials + 1):
        fk = k * f * np.sqrt(1 + 0.0002 * k * k)
        if fk > 16000:
            break
        a = abs(np.sin(np.pi * k * position)) / k ** 1.1
        out += a * np.sin(TAU * fk * u) * np.exp(-u * (1 + 0.6 * (k - 1)) / tau)
    return out * np.clip(u / 0.0015, 0, 1) * (t >= start)


def mallet(t, f, start, tau):
    """A soft marimba-like bar: fundamental plus a tuned fourth partial."""
    tone = modes(t, [f, 3.93 * f, 9.2 * f], [1.0, 0.22, 0.04], [tau, tau / 4, tau / 12], start)
    return tone * np.clip((t - start) / 0.003, 0, 1)


def glock(t, f, start, tau):
    """A glockenspiel bar with a soft sine an octave below for warmth."""
    bar = modes(t, [f, 2.76 * f, 5.40 * f], [1.0, 0.3, 0.1], [tau, tau / 3, tau / 8], start)
    body = 0.3 * modes(t, [f / 2], [1.0], [tau * 0.8], start)
    return (bar + body) * np.clip((t - start) / 0.002, 0, 1)


def creak(rng, t, start, length, rate0, rate1, freqs, q=20.0):
    """A hinge creak: a speeding-up stick-slip pulse train ringing a few resonances."""
    pulses = np.zeros_like(t)
    at = start
    while at < start + length:
        p = (at - start) / length
        i = secs(at)
        if i < len(t):
            pulses[i] += np.sin(np.pi * p) ** 0.7 * rng.uniform(0.55, 1.0)
        at += 1 / (rate0 + (rate1 - rate0) * p) * (1 + rng.uniform(-0.18, 0.18))
    ir_t = timeline(0.12)
    ir = modes(ir_t, freqs, rng.uniform(0.5, 1.0, len(freqs)), [q / (np.pi * f) for f in freqs])
    return convolve(pulses, ir)


def breaker_thunk(rng, t, start):
    """A big breaker lever: spring snap, then the heavy contact thud in a metal box."""
    snap = 0.5 * click(rng, t, start, 0.002, 2500) + modes(t, [2300, 3700], [0.4, 0.25], [0.006, 0.004], start)
    hit = start + 0.012
    u = np.maximum(t - hit, 0)
    thud = np.sin(phase_of(60 + 45 * np.exp(-u / 0.03))) * env_ar(t, 0.001, 0.09, hit)
    knock = modes(t, [240, 410, 690], [0.6, 0.4, 0.25], [0.05, 0.035, 0.02], hit)
    box = modes(t, [180, 310, 520, 1040], [0.2, 0.15, 0.12, 0.06], [0.15, 0.12, 0.09, 0.05], hit)
    grit = 0.5 * lowpass(rng.standard_normal(len(t)) * env_ar(t, 0.0005, 0.012, hit), 1500)
    return snap + thud + knock + box + grit


def mains_hum(rng, f0, level):
    """A buzzy 60 Hz transformer hum following a pitch track and a level track."""
    phase = phase_of(f0)
    weights = [0.5, 1.0, 0.45, 0.6, 0.25, 0.35, 0.15, 0.2, 0.08, 0.1, 0.05, 0.06]
    hum = sum(w * np.sin((k + 1) * phase + rng.uniform(0, TAU)) for k, w in enumerate(weights))
    hum = np.tanh(1.8 * hum / np.abs(hum).max())
    return lowpass(hum, 2500) * level


# ---------------------------------------------------------------------------
# The sounds (one function each)

def doorbell(rng):
    """Two-tone ding-dong (E5 then C5) of a chime doorbell."""
    t = timeline(1.6)
    out = chime_bar(t, 659.26, 0.0, 0.5) + chime_bar(t, 523.25, 0.48, 0.48)
    for start in (0.0, 0.48):
        out += 0.12 * lowpass(rng.standard_normal(len(t)) * env_ar(t, 0.0005, 0.006, start), 2500)
    return out


def lockpick_tick(rng, index):
    """A tiny metallic tick of a pick lifting a pin (four pitches)."""
    pitch = [0.82, 1.0, 1.17, 1.36][index]
    t = timeline([0.07, 0.08, 0.09, 0.1][index])
    base = np.array([2900, 4650, 6900, 9100]) * pitch * (1 + rng.uniform(-0.02, 0.02, 4))
    ring = modes(t, base, [1.0, 0.6, 0.35, 0.2], [0.012, 0.008, 0.005, 0.003], 0.002)
    spring = modes(t, [1300 * pitch], [0.15], [0.02], 0.004)
    return ring + spring + 0.5 * click(rng, t, 0.002, 0.0012)


def lock_open(rng):
    """The cylinder turns past a few pins, then the bolt clacks open."""
    t = timeline(0.5)
    grit = np.abs(wobble(rng, len(t), 0.004))
    turn = bandpass(rng.standard_normal(len(t)), 2800, 1.2) * grit * 0.2 * curve(t, [0, 0.02, 0.27, 0.29], [0, 0.6, 1, 0])
    for at in (0.07, 0.14, 0.21):
        turn += modes(t, [3200, 5100], [0.35, 0.2], [0.004, 0.003], at)
    clack = modes(t, [1250, 2080, 3350, 5200], [1.0, 0.7, 0.45, 0.25], [0.05, 0.035, 0.02, 0.012], 0.29)
    clack += modes(t, [150], [0.8], [0.03], 0.29) + 0.6 * click(rng, t, 0.29, 0.0015, 2000)
    settle = modes(t, [1900, 3100], [0.3, 0.2], [0.02, 0.012], 0.37)
    return turn + clack + settle


def safe_dial_tick(rng):
    """One detent click of a safe's combination dial."""
    t = timeline(0.06)
    tick = modes(t, [1850, 3300, 5200], [1.0, 0.5, 0.3], [0.012, 0.007, 0.004], 0.001)
    body = modes(t, [620], [0.5], [0.015], 0.001)
    return tick + body + 0.4 * click(rng, t, 0.001, 0.001)


def safe_open(rng):
    """A heavy safe door: bolts clunk back, then the hinge gives a short metallic creak."""
    t = timeline(1.0)
    noise = rng.standard_normal(len(t))
    clunk = modes(t, [68, 110], [1.0, 0.5], [0.12, 0.08])
    clunk += modes(t, [212, 347, 523, 791, 1134, 1660], [0.6, 0.5, 0.4, 0.3, 0.2, 0.12],
                   [0.3, 0.25, 0.18, 0.12, 0.08, 0.05])
    clunk += 0.8 * lowpass(noise * env_ar(t, 0.001, 0.02), 900)
    clunk += modes(t, [260, 610, 980], [0.3, 0.25, 0.2], [0.1, 0.08, 0.05], 0.12)
    hinge = creak(rng, t, 0.32, 0.6, 70, 170, [520, 1180, 1960, 2850], q=22)
    hinge *= 0.35 / (np.abs(hinge).max() + 1e-12)
    return clunk * np.clip(t / 0.002, 0, 1) + hinge


def breaker_off(rng):
    """Breaker thunk, then the hum of the house flickers and dies away."""
    t = timeline(1.5)
    u = np.maximum(t - 0.02, 0)
    flicker = 1 - 0.5 * np.clip(u / 0.9, 0, 1) * (wobble(rng, len(t), 0.02) > 0.3)
    level = np.clip(u / 0.015, 0, 1) * np.exp(-u / 0.45) * smooth(flicker, 0.008) * (t >= 0.02)
    f0 = 60 * (1 - 0.18 * (1 - np.exp(-u / 0.5)))
    thunk = breaker_thunk(rng, t, 0.0)
    return thunk / np.abs(thunk).max() + 0.45 * mains_hum(rng, f0, level)


def breaker_on(rng):
    """Breaker thunk, a couple of sparks, then the hum stutters and swells back."""
    t = timeline(1.2)
    u = np.maximum(t - 0.03, 0)
    stutter = 1 - 0.6 * (1 - np.clip(u / 0.3, 0, 1)) * (wobble(rng, len(t), 0.015) > 0)
    level = (1 - np.exp(-u / 0.25)) * smooth(stutter, 0.006) * curve(t, [0, 0.9, 1.2], [1, 1, 0])
    f0 = 60 * (0.88 + 0.12 * (1 - np.exp(-u / 0.15)))
    sparks = sum(click(rng, t, at, 0.0015, 1500) * rng.uniform(0.15, 0.3) for at in (0.035, 0.06, 0.1, 0.13))
    thunk = breaker_thunk(rng, t, 0.0)
    return thunk / np.abs(thunk).max() + sparks + 0.45 * mains_hum(rng, f0, level)


def camera_servo_loop(rng):
    """A smooth little servo whirr (1 s loop; every frequency is a whole number of Hz)."""
    t = timeline(1.0)
    phase = TAU * 560 * t + 3.0 * np.sin(TAU * 2 * t)
    whine = (np.sin(phase) + 0.35 * np.sin(2 * phase) + 0.15 * np.sin(3 * phase)) * (1 + 0.15 * np.sin(TAU * 23 * t))
    motor = 0.3 * np.sin(TAU * 140 * t + 0.75 * np.sin(TAU * 2 * t))
    hiss = 0.07 * loop_noise(rng, len(t), lambda f: hp_mag(f, 900, 3) * lp_mag(f, 3000, 4)) * (1 + 0.3 * np.sin(TAU * 6 * t))
    return whine * 0.5 + motor + hiss


def camera_alert(rng):
    """Beep-beep: a camera has spotted you."""
    t = timeline(0.6)
    out = np.zeros_like(t)
    for start in (0.0, 0.2):
        u = t - start
        gate = np.clip(u / 0.003, 0, 1) * np.where(u < 0.12, 1.0, np.exp(-np.maximum(u - 0.12, 0) / 0.02)) * (u >= 0)
        square = sum(np.sin(TAU * k * 1975 * np.maximum(u, 0)) / k * (0.5 ** k) for k in (1, 3, 5))
        out += square * gate
    return lowpass(out, 5000)


def tin_hit(rng, clapper, accent):
    """One clatter of the wind-up toy's tin clapper."""
    t = timeline(0.09)
    freqs = np.array(clapper) * (1 + rng.uniform(-0.03, 0.03, len(clapper)))
    ring = modes(t, freqs, [1.0, 0.7, 0.5, 0.3], [0.035, 0.028, 0.02, 0.012])
    body = modes(t, [620 * rng.uniform(0.97, 1.03)], [0.4], [0.02])
    return accent * (ring + body + 0.4 * click(rng, t, 0.0, 0.002, 2000))


def noisemaker_rattle_loop(rng):
    """A clockwork tin toy clattering away (0.8 s loop, 12 hits that wrap round the seam)."""
    n = secs(0.8)
    out = np.zeros(n)
    clappers = ([1450, 2380, 3720, 5150], [1720, 2810, 4300, 6100])
    for i in range(12):
        accent = (1.0 if i % 4 == 0 else 0.75) * rng.uniform(0.8, 1.0)
        place(out, tin_hit(rng, clappers[i % 2], accent), i * 0.8 / 12 + rng.uniform(-0.004, 0.004), wrap=True)
    tick_t = timeline(0.02)
    for i in range(48):
        place(out, 0.12 * modes(tick_t, [5200], [1.0], [0.002]), i * 0.8 / 48 + 0.011, wrap=True)
    out += 0.05 * loop_noise(rng, n, lambda f: hp_mag(f, 400) * lp_mag(f, 2000))
    return out


def ratchet_click(rng, pitch):
    """One ratchet tooth of the winding key."""
    t = timeline(0.05)
    tooth = modes(t, np.array([2600, 4100, 6300]) * pitch, [1.0, 0.6, 0.3], [0.01, 0.007, 0.004])
    body = modes(t, [850 * pitch, 1500 * pitch], [0.4, 0.25], [0.015, 0.01])
    return tooth + body + 0.5 * click(rng, t, 0.0, 0.0008)


def noisemaker_wind(rng):
    """Two twists of the toy's winding key: ratchet clicks that tighten as the spring winds."""
    t = timeline(0.7)
    out = np.zeros_like(t)
    for start, spacing, p0 in ((0.02, 0.048, 1.0), (0.37, 0.046, 1.04)):
        for i in range(6):
            place(out, ratchet_click(rng, p0 + 0.015 * i) * rng.uniform(0.8, 1.0), start + i * spacing)
        out += 0.06 * bandpass(rng.standard_normal(len(t)), 3000, 0.8) * bump(t, start - 0.01, 6 * spacing)
    return out


def dart_fire(rng):
    """Toy foam dart blaster: trigger click, spring boing and an airy thwip."""
    t = timeline(0.3)
    trigger = modes(t, [2800, 4100], [0.3, 0.2], [0.005, 0.004]) + 0.3 * click(rng, t, 0.0, 0.0008)
    u = np.maximum(t - 0.005, 0)
    spring = 0.25 * np.sin(phase_of(250 + 40 * np.exp(-u / 0.03))) * env_ar(t, 0.002, 0.06, 0.005)
    sweep = 700 + 2800 * np.exp(-np.maximum(t - 0.01, 0) / 0.04)
    air = svf(rng.standard_normal(len(t)), sweep, 6.0) * env_ar(t, 0.004, 0.05, 0.01)
    whistle = 0.45 * np.sin(phase_of(900 + 1100 * np.exp(-np.maximum(t - 0.01, 0) / 0.03))) * env_ar(t, 0.003, 0.03, 0.01)
    pop = modes(t, [150], [0.4], [0.015], 0.012)
    return trigger + spring + air + whistle + pop


def dart_hit_soft(rng):
    """A foam dart bopping something: a soft puff and thump."""
    t = timeline(0.15)
    puff = svf(rng.standard_normal(len(t)), 600 + 1400 * np.exp(-t / 0.02), 0.7, "lp") * env_ar(t, 0.001, 0.018)
    thump = np.sin(phase_of(120 + 60 * np.exp(-t / 0.015))) * env_ar(t, 0.001, 0.025)
    squeak = 0.12 * modes(t, [640], [1.0], [0.01], 0.002)
    return puff + 0.7 * thump + squeak


def snooze(rng):
    """A sleepy, wobbling slide down: someone dozes off."""
    t = timeline(1.0)
    p = t / t[-1]
    lfo = np.sin(phase_of(7 - 4 * p))
    f = 640 * 2 ** (-1.5 * p ** 0.9) * (1 + 0.045 * lfo * (0.4 + 0.6 * p))
    ph = phase_of(f)
    voice = np.sin(ph) + 0.25 * np.sin(2 * ph) + 0.08 * np.sin(3 * ph)
    lower = 0.35 * np.sin(phase_of(f * 0.749))
    breath = 0.03 * bandpass(rng.standard_normal(len(t)), 900, 0.8)
    level = np.clip(t / 0.04, 0, 1) * curve(t, [0, 0.55, 1.0], [1, 1, 0]) ** 1.5 * (1 + 0.25 * lfo)
    return (voice + lower + breath) * level


def suspicion_tick(rng):
    """A subtle rising blip, played while a suspicion meter fills."""
    t = timeline(0.08)
    f = 1150 + 450 * (1 - np.exp(-t / 0.012))
    ph = phase_of(f)
    return (np.sin(ph) + 0.2 * np.sin(2 * ph)) * env_ar(t, 0.0015, 0.018) + 0.15 * click(rng, t, 0.0, 0.001, 4000)


def spotted(rng):
    """The "!" sting: two quick rising plucks (D5 then A5)."""
    t = timeline(0.6)
    return pluck(t, 587.33, 0.0, 0.18) + 1.25 * pluck(t, 880.0, 0.085, 0.35) + 0.25 * pluck(t, 1760.0, 0.085, 0.2)


def lost_them(rng):
    """A relieved falling fifth (G5 to C5) on soft mallets."""
    t = timeline(0.7)
    return 0.8 * mallet(t, 783.99, 0.0, 0.3) + mallet(t, 523.25, 0.2, 0.42) + 0.3 * mallet(t, 261.63, 0.2, 0.4)


def caper_done(rng):
    """A little happy glockenspiel run up C major: goal complete."""
    t = timeline(0.8)
    notes = ((1046.5, 0.0, 0.25, 0.7), (1318.5, 0.07, 0.25, 0.75), (1568.0, 0.14, 0.25, 0.8), (2093.0, 0.21, 0.45, 1.0))
    return sum(gain * glock(t, f, start, tau) for f, start, tau, gain in notes)


def lead_hint(rng):
    """A soft vibraphone "hmm?": G5, then C6 that bends up into place."""
    t = timeline(0.6)
    tremolo = 1 + 0.25 * np.sin(TAU * 6 * t)
    first = modes(t, [784.0, 3136.0], [1.0, 0.15], [0.3, 0.06], 0.0) * np.clip(t / 0.006, 0, 1)
    u = np.maximum(t - 0.15, 0)
    f = 1046.5 - 58 * np.exp(-u / 0.035)
    ph = phase_of(f)
    second = (np.sin(ph) + 0.15 * np.sin(4 * ph)) * env_ar(t, 0.008, 0.3, 0.15)
    return (0.9 * first + 0.8 * second) * tremolo


# --- Gibberish voices -------------------------------------------------------

VOWELS = {
    "low": {"a": (730, 1090, 2440), "e": (530, 1840, 2480), "i": (300, 2200, 2950),
            "o": (570, 840, 2410), "u": (320, 900, 2250)},
    "high": {"a": (850, 1220, 2810), "e": (610, 2330, 2990), "i": (330, 2750, 3300),
             "o": (590, 920, 2710), "u": (380, 1000, 2670)},
}
VOICES = {
    "low": dict(f0=120.0, nasal=(270, 1050, 2350), bw=(100, 130, 200), scale=1.0, breath=0.02, fmax=5000.0),
    "high": dict(f0=228.0, nasal=(310, 1250, 2750), bw=(140, 170, 240), scale=1.15, breath=0.035, fmax=5500.0),
}
# Onsets: voiced ones shape the formants and level, unvoiced ones add a noise burst.
CONSONANTS = {
    "m": dict(kind="nasal", dur=0.045, amp=0.45),
    "n": dict(kind="nasal", dur=0.04, amp=0.45),
    "b": dict(kind="stop", dur=0.035, amp=0.12, locus=(250, 800, 2200), burst=(900, 0.8)),
    "d": dict(kind="stop", dur=0.03, amp=0.12, locus=(250, 1700, 2600), burst=(3000, 1.0)),
    "w": dict(kind="glide", dur=0.045, amp=0.6, locus=(300, 700, 2200)),
    "l": dict(kind="glide", dur=0.04, amp=0.6, locus=(350, 1100, 2700)),
    "y": dict(kind="glide", dur=0.04, amp=0.6, locus=(280, 2200, 2900)),
    "r": dict(kind="glide", dur=0.04, amp=0.55, locus=(330, 1250, 1700)),
    "h": dict(kind="noise", dur=0.05, level=0.07, band=(1600, 0.6)),
    "t": dict(kind="noise", dur=0.03, level=0.16, band=(4200, 1.2)),
    "k": dict(kind="noise", dur=0.035, level=0.16, band=(2000, 1.5)),
    "p": dict(kind="noise", dur=0.03, level=0.12, band=(1000, 0.7)),
}
# Intonation: (start, end) pitch multipliers for a syllable's vowel, from phrase
# position p (0..1), whether it is stressed and whether it is the last one.
INTONATION = {
    "statement": lambda p, s, last: (0.98, 0.8) if last else ((1.1 - 0.2 * p) * (1.2 if s else 1), (1.06 - 0.2 * p) * (1.12 if s else 1)),
    "question": lambda p, s, last: (1.0, 1.5) if last else ((1.02 - 0.08 * p) * (1.15 if s else 1), (0.98 - 0.08 * p) * (1.1 if s else 1)),
    "cheery": lambda p, s, last: (1.15, 0.95) if last else ((1.3 - 0.25 * p) * (1.2 if s else 1), (1.22 - 0.25 * p) * (1.1 if s else 1)),
}


def babble(rng, voice_name, text, intonation):
    """Friendly gibberish speech: syllables like "ba NA do | me ri ka" ("|" is a word gap, CAPS are stressed)."""
    voice, vowels = VOICES[voice_name], VOWELS[voice_name]
    words = text.split()
    sylls = [w for w in words if w != "|"]
    # Lay the syllables out in time.
    layout, at, index = [], 0.04, 0
    for w in words:
        if w == "|":
            at += 0.07
            continue
        cons, vowel = w[:-1].lower(), w[-1].lower()
        last = index == len(sylls) - 1
        vdur = rng.uniform(0.085, 0.12) * (1.35 if w.isupper() else 1) * (1.6 if last else 1)
        cdur = CONSONANTS[cons]["dur"] if cons else 0.0
        layout.append(dict(cons=cons, vowel=vowel, at=at, cdur=cdur, vdur=vdur, stress=w.isupper(),
                           last=last, p=index / max(1, len(sylls) - 1)))
        at += cdur + vdur
        index += 1
    t = timeline(at + 0.1)
    n = len(t)
    F = np.tile(np.array(vowels["e"], dtype=float)[:, None], (1, n))
    amp = np.zeros(n)
    pitch = np.full(n, np.nan)
    noise_track = np.zeros(n)
    for s in layout:
        c0, v0, v1 = secs(s["at"]), secs(s["at"] + s["cdur"]), secs(s["at"] + s["cdur"] + s["vdur"])
        target = np.array(vowels[s["vowel"]], dtype=float)
        a, b = INTONATION[intonation](s["p"], s["stress"], s["last"])
        pitch[c0:v1] = np.concatenate([np.full(v0 - c0, a), np.linspace(a, b, v1 - v0)])
        F[:, v0:v1] = target[:, None]
        p = np.linspace(0, 1, v1 - v0)
        fade = 0.7 if s["last"] else 0.35
        amp[v0:v1] = (1 - fade * p ** 1.3) * rng.uniform(0.8, 1.0) * (1.15 if s["stress"] else 1.0)
        if s["cons"]:
            c = CONSONANTS[s["cons"]]
            if c["kind"] == "nasal":
                F[:, c0:v0] = np.array(voice["nasal"], dtype=float)[:, None]
                amp[c0:v0] = c["amp"]
            elif c["kind"] in ("stop", "glide"):
                F[:, c0:v0] = (np.array(c["locus"], dtype=float) * voice["scale"])[:, None]
                amp[c0:v0] = c["amp"]
                if c["kind"] == "stop":
                    seg = timeline(0.03)
                    burst = bandpass(rng.standard_normal(len(seg)), *c["burst"]) * env_ar(seg, 0.001, 0.006)
                    place(noise_track, 0.08 * burst, s["at"] + s["cdur"] - 0.004)
            else:
                F[:, c0:v0] = target[:, None]
                seg = timeline(c["dur"])
                shape = env_ar(seg, 0.002, 0.012) if s["cons"] in "tkp" else bump(seg, 0, c["dur"])
                burst = bandpass(rng.standard_normal(len(seg)), *c["band"]) * shape
                place(noise_track, c["level"] * burst / (np.abs(burst).max() + 1e-12), s["at"])
    # Fill pitch through the word gaps, then glide everything.
    idx = np.where(np.isnan(pitch), 0, np.arange(n))
    np.maximum.accumulate(idx, out=idx)
    pitch = np.where(np.isnan(pitch[idx]), pitch[~np.isnan(pitch)][0], pitch[idx])
    f0 = voice["f0"] * smooth(pitch, 0.05)
    f0 *= 1 + 0.012 * np.sin(TAU * 5.2 * t) + 0.01 * wobble(rng, n, 0.03)
    formants = [smooth(F[i], 0.03) for i in range(3)]
    level = smooth(amp, 0.012)
    voiced = formant_voice(f0, formants, voice["bw"], level, fmax=voice["fmax"])
    voiced /= np.abs(voiced).max()
    breath = voice["breath"] * bandpass(rng.standard_normal(n), 3000, 0.7) * level
    return voiced + breath + noise_track


MUMBLES = {
    "mumble_low_1": ("low", "ba NA do | me ri ka", "statement"),
    "mumble_low_2": ("low", "wo da | LI ne ma", "question"),
    "mumble_low_3": ("low", "O ho | ma bi TO la", "cheery"),
    "mumble_high_1": ("high", "mi NA lo | ye ba", "statement"),
    "mumble_high_2": ("high", "da wi ME | no la ni", "question"),
    "mumble_high_3": ("high", "YA | lu mi BE do na", "cheery"),
}


def snore_loop(rng):
    """A cartoon snore: a fluttering inhale, a pause, then a whistle out (3 s loop)."""
    t = timeline(3.0)
    n = len(t)
    # Inhale: noise pulsed by the fluttering soft palate, through throaty resonances.
    p_in = np.clip((t - 0.15) / 1.25, 0, 1)
    flutter = (0.5 + 0.5 * np.cos(phase_of(26 + 6 * p_in))) ** 6
    rasp = rng.standard_normal(n) * (0.3 + flutter) + 2 * flutter
    rasp = lowpass(rasp, 1200, circular=True)
    rasp = bandpass(rasp, 450, 2.0, circular=True) + 0.6 * bandpass(rasp, 900, 3.0, circular=True)
    inhale = rasp / np.abs(rasp).max() * bump(t, 0.15, 1.25, 1.2)
    # Exhale: a little rising-and-falling whistle with breath.
    p_out = np.clip((t - 1.65) / 1.0, 0, 1)
    f = (900 + 600 * np.sin(np.pi * p_out ** 0.7)) * (1 + 0.015 * np.sin(TAU * 5 * t))
    whistle = np.sin(phase_of(f)) + 0.1 * np.sin(2 * phase_of(f))
    air = 0.25 * bandpass(rng.standard_normal(n), 1200, 1.5, circular=True) + 0.15 * lowpass(rng.standard_normal(n), 600, circular=True)
    exhale = (0.5 * whistle + air) * bump(t, 1.65, 1.0, 1.5)
    return inhale + exhale


def dog_bark(rng, peak, length):
    """A cartoon "woof": a 'w' that opens to 'ah' and closes, rough voice plus breathy noise."""
    t = timeline(length + 0.12)
    u = np.maximum(t - 0.01, 0)
    rise = 1 - np.exp(-u / 0.018)
    fall = np.clip((u - 0.05) / (length - 0.05), 0, 1)
    f0 = peak * (0.68 + 0.32 * rise) * (1 - 0.38 * fall) * (1 + 0.03 * wobble(rng, len(t), 0.006))
    marks = [0, 0.03, length * 0.7, length]
    formants = [curve(u, marks, [380, 820, 700, 450]), curve(u, marks, [850, 1400, 1250, 900]),
                curve(u, marks, [2300, 2700, 2600, 2400])]
    level = curve(u, [0, 0.008, 0.08, length], [0, 1, 0.85, 0.12]) * np.exp(-np.maximum(u - length, 0) / 0.02) * (t >= 0.01)
    voiced = formant_voice(f0, formants, (120, 150, 200), level, weights=(1.0, 0.7, 0.35), tilt=0.8, fmax=6000.0, sub=0.35)
    voiced /= np.abs(voiced).max()
    pulse = 0.6 + 0.4 * np.cos(phase_of(f0))
    breath = rng.standard_normal(len(t)) * level * pulse
    rough = sum(w * svf(breath, F, 4.0) for F, w in zip(formants, (1.0, 0.7, 0.4)))
    x = voiced + 0.5 * rough / (np.abs(rough).max() + 1e-12)
    x = lowpass(lowpass(np.tanh(1.8 * x) / np.tanh(1.8), 4500), 4500)
    huff = 0.08 * bandpass(rng.standard_normal(len(t)), 1800, 0.8) * bump(t, length * 0.75, 0.12)
    return x + huff + modes(t, [150], [0.3], [0.03], 0.01)


def dog_whine(rng):
    """A short questioning whine: "hnn-nn?" rising at the end."""
    t = timeline(0.8)
    f0 = curve(t, [0, 0.15, 0.3, 0.5, 0.75, 0.8], [700, 950, 880, 820, 1250, 1250])
    f0 = smooth(f0, 0.04) * (1 + 0.012 * np.sin(TAU * 6 * t) + 0.008 * wobble(rng, len(t), 0.02))
    level = curve(t, [0, 0.05, 0.4, 0.46, 0.52, 0.72, 0.8], [0, 1, 0.9, 0.5, 0.9, 0.8, 0])
    tone = formant_voice(f0, [900.0, 2200.0, 3200.0], (300, 400, 500), smooth(level, 0.01), tilt=1.4, fmax=6000.0)
    tone /= np.abs(tone).max()
    breath = 0.05 * bandpass(rng.standard_normal(len(t)), 2500, 1.0) * level
    return tone + breath


def dog_sniff(rng):
    """Four quick sniffs, the last a little longer."""
    t = timeline(0.7)
    out = np.zeros_like(t)
    for at, length, gain in ((0.02, 0.08, 0.8), (0.15, 0.08, 1.0), (0.28, 0.09, 0.85), (0.45, 0.14, 1.0)):
        seg = timeline(length)
        noise = rng.standard_normal(len(seg))
        sniff = svf(noise, 2500 + 1300 * seg / length, 1.2) + 0.5 * bandpass(noise, 1200, 2.0)
        place(out, gain * highpass(sniff, 400) * env_ar(seg, 0.012, length / 3), at)
    return out


def ambience_night_loop(rng):
    """A quiet night garden: a soft breeze and three crickets (8 s loop)."""
    t = timeline(8.0)
    n = len(t)

    def lfo(*parts):  # slow swells with whole numbers of cycles per loop
        return sum(a * np.sin(TAU * k * t / 8.0 + rng.uniform(0, TAU)) for k, a in parts)

    low = loop_noise(rng, n, lambda f: hp_mag(f, 60) * lp_mag(f, 600) / np.sqrt(np.maximum(f, 20)))
    high = loop_noise(rng, n, lambda f: hp_mag(f, 500) * lp_mag(f, 2500) / np.sqrt(np.maximum(f, 20)))
    breeze = 0.08 * low * (0.6 + lfo((1, 0.25), (2, 0.12), (5, 0.06)))
    breeze += 0.05 * high * np.clip(0.45 + lfo((1, 0.3), (3, 0.15), (4, 0.1)), 0.05, None) ** 2
    crickets = np.zeros(n)
    for carrier, chirps, pulses, spacing, gain in ((4600, 14, 3, 0.028, 0.25), (4150, 11, 4, 0.024, 0.15), (3700, 19, 2, 0.03, 0.07)):
        offset = rng.uniform(0, 8.0 / chirps)
        for c in range(chirps):
            amp = gain * rng.uniform(0.8, 1.2)
            start = offset + c * 8.0 / chirps + rng.uniform(-0.008, 0.008)
            for p in range(pulses):
                seg = timeline(0.014)
                ph = phase_of(carrier * (1 - 0.01 * seg / 0.014))
                pulse = (np.sin(ph) + 0.1 * np.sin(2 * ph)) * np.hanning(len(seg)) * amp
                place(crickets, pulse, start + p * spacing, wrap=True)
    distant = lowpass(crickets, 6000, circular=True)
    return breeze + distant


def fridge_hum_loop(rng):
    """A kitchen fridge compressor: mains hum, a faint whine and fan air (2 s loop)."""
    t = timeline(2.0)
    weights = {60: 0.4, 120: 1.0, 180: 0.35, 240: 0.5, 300: 0.2, 360: 0.25, 480: 0.1, 600: 0.06}
    hum = sum(w * np.sin(TAU * f * t + rng.uniform(0, TAU)) for f, w in weights.items())
    hum *= 1 + 0.1 * np.sin(TAU * 0.5 * t) + 0.05 * np.sin(TAU * 1.0 * t + 1.0)
    whine = 0.03 * np.sin(TAU * 1500 * t) * (1 + 0.5 * np.sin(TAU * 1.5 * t))
    fan = 0.08 * loop_noise(rng, len(t), lambda f: hp_mag(f, 80) * lp_mag(f, 900, 3) / np.sqrt(np.maximum(f, 20)))
    return hum + whine + fan


# ---------------------------------------------------------------------------
# The catalogue: name -> (builder, loops?)

def catalogue():
    sounds = {
        "doorbell": (doorbell, False),
        "lock_open": (lock_open, False),
        "safe_dial_tick": (safe_dial_tick, False),
        "safe_open": (safe_open, False),
        "breaker_off": (breaker_off, False),
        "breaker_on": (breaker_on, False),
        "camera_servo_loop": (camera_servo_loop, True),
        "camera_alert": (camera_alert, False),
        "noisemaker_rattle_loop": (noisemaker_rattle_loop, True),
        "noisemaker_wind": (noisemaker_wind, False),
        "dart_fire": (dart_fire, False),
        "dart_hit_soft": (dart_hit_soft, False),
        "snooze": (snooze, False),
        "suspicion_tick": (suspicion_tick, False),
        "spotted": (spotted, False),
        "lost_them": (lost_them, False),
        "caper_done": (caper_done, False),
        "lead_hint": (lead_hint, False),
        "snore_loop": (snore_loop, True),
        "dog_whine": (dog_whine, False),
        "dog_sniff": (dog_sniff, False),
        "ambience_night_loop": (ambience_night_loop, True),
        "fridge_hum_loop": (fridge_hum_loop, True),
    }
    for i in range(4):
        sounds[f"lockpick_tick_{i + 1}"] = (lambda rng, i=i: lockpick_tick(rng, i), False)
    for name, (voice, text, intonation) in MUMBLES.items():
        sounds[name] = (lambda rng, v=voice, x=text, o=intonation: babble(rng, v, x, o), False)
    for i, (peak, length) in enumerate(((430, 0.24), (380, 0.28), (500, 0.2))):
        sounds[f"dog_bark_{i + 1}"] = (lambda rng, p=peak, l=length: dog_bark(rng, p, l), False)
    return dict(sorted(sounds.items()))


def finish(x, loop):
    """Removes rumble and DC, fades one-shots in and out, and normalises the peak to -3 dBFS."""
    x = highpass(x, 25, circular=loop)
    if not loop:
        n_in, n_out = secs(0.0015), min(secs(0.015), len(x) // 8)
        x[:n_in] *= 0.5 - 0.5 * np.cos(np.linspace(0, np.pi, n_in))
        x[-n_out:] *= 0.5 + 0.5 * np.cos(np.linspace(0, np.pi, n_out))
    return x * (PEAK / np.abs(x).max())


def write_wav(path, x):
    pcm = np.clip(np.round(x * 32767), -32768, 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("out_dir", help="where the .ogg files go")
    parser.add_argument("--wav", help="also keep the WAVs in this folder")
    parser.add_argument("--only", help="comma-separated names to build")
    args = parser.parse_args()
    ffmpeg = shutil.which("ffmpeg") or "/usr/bin/ffmpeg"
    sounds = catalogue()
    names = args.only.split(",") if args.only else list(sounds)
    unknown = [n for n in names if n not in sounds]
    if unknown:
        sys.exit(f"unknown sounds: {', '.join(unknown)}")
    os.makedirs(args.out_dir, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        wav_dir = args.wav or tmp
        os.makedirs(wav_dir, exist_ok=True)
        for name in names:
            build, loop = sounds[name]
            x = finish(build(rng_for(name)).astype(float), loop)
            wav = os.path.join(wav_dir, name + ".wav")
            write_wav(wav, x)
            subprocess.run([ffmpeg, "-v", "error", "-y", "-i", wav, "-c:a", "libvorbis", "-q:a", "7" if loop else "5",
                            "-fflags", "+bitexact", "-flags:a", "+bitexact",
                            os.path.join(args.out_dir, name + ".ogg")], check=True)
            print(f"{name:24s} {len(x) / SR:5.2f} s{'  loop' if loop else ''}")


if __name__ == "__main__":
    main()
