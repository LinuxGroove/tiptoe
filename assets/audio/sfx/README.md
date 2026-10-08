# Sound effects

Twelve of these sounds were generated with Lemonade's ThinkSound model by `tools/lemonade/generate.py` (see `../GENERATED.md` for each one's prompt, seed and settings); they are marked (ThinkSound) below. The rest are synthesized for Tiptoe by `tools/sfx/make_sfx.py` (needs numpy and ffmpeg). `make_sfx.py` still knows how to build its own versions of the generated sounds, so rebuild synthesized ones by name, `python3 tools/sfx/make_sfx.py assets/audio/sfx --only doorbell,dog_whine`, rather than all at once, which would replace the generated ones. Everything else comes from Kenney's packs (see `KENNEY_PICKS.md`).

All of them are 44.1 kHz mono Ogg Vorbis peaking at about -3 dBFS, so set how loud each one plays in the game. Files ending in `_loop` loop seamlessly.

- `alarm_loop.ogg`: a burglar alarm: two-tone electronic siren over a bell rattle (1 s loop).
- `ambience_night_loop.ogg`: quiet night garden, crickets and a soft breeze (ThinkSound, 9.2 s loop).
- `breaker_off.ogg`: the house hum, a heavy fuse box breaker thunk, then the hum dies (ThinkSound).
- `breaker_on.ogg`: breaker thunk, then a low electrical hum (ThinkSound).
- `camera_alert.ogg`: two-beep alert from a security camera that spotted you.
- `camera_servo_loop.ogg`: quiet servo whirr of a security camera panning (1 s loop).
- `caper_done.ogg`: small happy glockenspiel run when a goal is done.
- `conveyor_loop.ogg`: a conveyor belt's rollers rattling along (1 s loop).
- `crowd_murmur_loop.ogg`: a room full of people chatting, too far off to make out (8 s loop).
- `dart_fire.ogg`: toy foam dart blaster "thwip" (trigger, spring, air).
- `dart_hit_soft.ogg`: soft foam dart bopping something.
- `dog_bark_1.ogg`: one bark from a medium sized dog (ThinkSound).
- `dog_bark_2.ogg`: one deeper, longer bark (ThinkSound).
- `dog_bark_3.ogg`: one short, high yap from a small dog (ThinkSound).
- `dog_sniff.ogg`: four quick dog sniffs (ThinkSound).
- `dog_whine.ogg`: short questioning dog whine that rises at the end. Kept synthesized: none of ThinkSound's whines rose at the end.
- `doorbell.ogg`: two-tone "ding-dong" chime doorbell. Kept synthesized: ThinkSound didn't make a clean two-tone chime.
- `fridge_hum_loop.ogg`: quiet fridge compressor hum for kitchens (ThinkSound, 4.5 s loop).
- `keypad_beep.ogg`: one key pressed on a door keypad.
- `keypad_ok.ogg`: two rising beeps and a lock clacking open: the right code.
- `keypad_wrong.ogg`: a low buzzy double honk: the wrong code.
- `laser_hum_loop.ogg`: thin electric buzz of a laser gate (1 s loop).
- `lead_hint.ogg`: soft, curious "hmm?" vibraphone bell for a new hint.
- `lock_open.ogg`: a lock cylinder turning and the bolt clacking open (ThinkSound).
- `lockpick_tick_1.ogg`: tiny metallic pin tick of a lock pick, lowest of four.
- `lockpick_tick_2.ogg`: lock pick pin tick, second pitch.
- `lockpick_tick_3.ogg`: lock pick pin tick, third pitch.
- `lockpick_tick_4.ogg`: lock pick pin tick, highest of four.
- `lost_them.ogg`: relieved, falling two-note sting when they lose sight of you.
- `machine_hum_loop.ogg`: a bottling line: motor drone, rhythmic clank, bottles chinking (2 s loop).
- `mumble_high_1.ogg`: high (woman's) gibberish voice, a statement.
- `mumble_high_2.ogg`: high gibberish voice, a question.
- `mumble_high_3.ogg`: high gibberish voice, cheery.
- `mumble_low_1.ogg`: low (man's) gibberish voice, a statement.
- `mumble_low_2.ogg`: low gibberish voice, a question.
- `mumble_low_3.ogg`: low gibberish voice, cheery.
- `noisemaker_rattle_loop.ogg`: wind-up clockwork tin toy clattering (ThinkSound, 2.7 s loop).
- `noisemaker_wind.ogg`: winding the toy's key, ratchet clicks (ThinkSound).
- `safe_dial_tick.ogg`: one detent click of a safe's combination dial.
- `safe_open.ogg`: heavy safe door bolts clunking back, then a short metallic creak.
- `server_hum_loop.ogg`: a lab full of computers: fans, coil whine, relay ticks (2 s loop).
- `slide_door.ogg`: a sliding door hissing and whirring open or shut.
- `snooze.ogg`: sleepy, wobbling slide down when someone is put to sleep.
- `snore_loop.ogg`: a dog snoring gently (ThinkSound, 6.6 s loop).
- `spotted.ogg`: short "!" sting, two quick rising plucks, when someone sees you.
- `suspicion_tick.ogg`: subtle rising blip while a suspicion meter fills.
