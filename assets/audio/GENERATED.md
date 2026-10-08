# Generated audio

Made with [Lemonade](https://lemonade-server.ai) 2026.41.0 by `tools/lemonade/generate.py` from `tools/lemonade/audio.json`; `tools/lemonade/generated.json` has the full record, including every take's numbers. Released as CC0, like the rest of Tiptoe's own audio. Make them again with

```sh
python3 tools/lemonade/generate.py --force [--only music|voices|sfx] [name ...]
```

Every file is 44.1 kHz Ogg Vorbis (music stereo, the rest mono), trimmed of silence and peaking at about -3 dBFS. Loops were cut where their end matches their start and crossfaded there. Music and sounds were made in several takes (seeds counting up from the first); the take kept is the one whose length, loudness, ending and loop seam fit best (for sounds, also how many separate sounds it has and how quiet its background is) unless the table says it was picked by hand. The other takes were not kept.

## Music

Model `ACE-Step-Music` (`Serveurperso/ACE-Step-1.5-GGUF:acestep-v15-xl-sft-Q8_0.gguf`). Instrumental (no lyrics), the server's default steps.

| File | Prompt | Seed | Takes | Length | Settings |
|---|---|---|---|---|---|
| `assets/audio/music/title.ogg` | playful sneaky cat burglar caper theme, pizzicato strings, upright bass walking line, brushed jazz drums, muted trumpet melody, celesta, mischievous and warm, cartoon heist, 100 bpm, instrumental | 60498 | 3 | 84.2 s | asked for 108 s; loop 10.60 to 94.83 s of the take, 1.5 s crossfade; -15.5 LUFS |
| `assets/audio/music/night.ogg` | quiet tiptoe sneaking music at night, soft pizzicato strings, low upright bass, gentle brushed snare, light vibraphone, sparse and calm, suburban night, cartoon stealth, 80 bpm, instrumental, no drums fills, loopable | 97225 | 3 | 118.7 s | asked for 144 s; loop 15.78 to 134.43 s of the take, 1.5 s crossfade; -16.1 LUFS |
| `assets/audio/music/chase.ogg` | frantic comedic chase music, fast pizzicato strings, staccato brass stabs, xylophone runs, driving brushed drums, slapstick cartoon pursuit, 150 bpm, instrumental, loopable | 41714 | 3 | 59.4 s | asked for 72 s; loop 6.70 to 66.13 s of the take, 1.5 s crossfade; -15.8 LUFS |
| `assets/audio/music/escaped.ogg` | short triumphant cheeky jazz fanfare, muted trumpet, clarinet trill, upright bass, cymbal swell, cartoon heist success sting, instrumental | 36137 | 3 | 13.1 s | asked for 15 s; -15.9 LUFS |
| `assets/audio/music/night_over.ogg` | short sad trombone and tuba comedic sting, deflated cartoon failure, gentle and funny, instrumental | 17048 | 3 | 9.6 s | asked for 15 s; -16.2 LUFS |

## Voices

Model `kokoro-v1` (`mikkoph/kokoro-onnx`). One take each (Kokoro has no seed; the same text, voice and speed always give the same line).

- `low`: Ted, a cheerful, slightly dozy dad in his fifties. Kokoro voice `bm_george`, speed 1.0.
- `high`: Maggie, a brisk, sharp-eared mum in her fifties. Kokoro voice `bf_emma`, speed 1.05.

| File | Text | Voice | Length |
|---|---|---|---|
| `assets/audio/voice/low/hm.ogg` | Hm? (read as "Hmm?") | `bm_george` | 0.6 s |
| `assets/audio/voice/low/what_was_that.ogg` | What was that? | `bm_george` | 1.1 s |
| `assets/audio/voice/low/hello.ogg` | Hello? | `bm_george` | 0.9 s |
| `assets/audio/voice/low/hm_whos_there.ogg` | Hm? Who's there? (read as "Hmm? Who's there?") | `bm_george` | 1.3 s |
| `assets/audio/voice/low/biscuit_what_is_it.ogg` | Biscuit? What is it? | `bm_george` | 1.5 s |
| `assets/audio/voice/low/whats_going_on.ogg` | What's going on? | `bm_george` | 1.2 s |
| `assets/audio/voice/low/hey_you.ogg` | Hey! You! | `bm_george` | 1.0 s |
| `assets/audio/voice/low/oi_stop_right_there.ogg` | Oi! Stop right there! | `bm_george` | 1.7 s |
| `assets/audio/voice/low/burglar.ogg` | Burglar! | `bm_george` | 0.8 s |
| `assets/audio/voice/low/where_did_they_go.ogg` | Where did they go? | `bm_george` | 1.4 s |
| `assets/audio/voice/low/i_know_youre_here.ogg` | I know you're here! | `bm_george` | 1.4 s |
| `assets/audio/voice/low/there_light.ogg` | There. Light! | `bm_george` | 1.1 s |
| `assets/audio/voice/low/must_be_the_wind.ogg` | Must be the wind. | `bm_george` | 1.3 s |
| `assets/audio/voice/low/just_the_house_settling.ogg` | Just the house settling. | `bm_george` | 1.6 s |
| `assets/audio/voice/low/im_hearing_things.ogg` | I'm hearing things. | `bm_george` | 1.4 s |
| `assets/audio/voice/low/got_you_out_you_go.ogg` | Got you! Out you go. | `bm_george` | 1.6 s |
| `assets/audio/voice/low/coming.ogg` | Coming! | `bm_george` | 0.7 s |
| `assets/audio/voice/low/whos_that_at_this_hour.ogg` | Who's that at this hour? | `bm_george` | 1.8 s |
| `assets/audio/voice/low/hello_kids.ogg` | Hello? ...Kids. | `bm_george` | 1.2 s |
| `assets/audio/voice/low/nobody_there_odd.ogg` | Nobody there. Odd. | `bm_george` | 1.7 s |
| `assets/audio/voice/low/not_again.ogg` | Not again! | `bm_george` | 1.0 s |
| `assets/audio/voice/low/wheres_the_cheese.ogg` | Where's the cheese? | `bm_george` | 1.3 s |
| `assets/audio/voice/low/hello_dave_about_the_fuse_box.ogg` | Hello, Dave? About the fuse box... | `bm_george` | 2.7 s |
| `assets/audio/voice/low/pizza_come_in_come_in_ill_find_my_wallet.ogg` | Pizza! Come in, come in, I'll find my wallet. | `bm_george` | 3.2 s |
| `assets/audio/voice/low/wheres_the_pizza_then.ogg` | Where's the pizza, then? | `bm_george` | 1.9 s |
| `assets/audio/voice/high/hm.ogg` | Hm? (read as "Hmm?") | `bf_emma` | 0.6 s |
| `assets/audio/voice/high/what_was_that.ogg` | What was that? | `bf_emma` | 1.0 s |
| `assets/audio/voice/high/hello.ogg` | Hello? | `bf_emma` | 0.9 s |
| `assets/audio/voice/high/hm_whos_there.ogg` | Hm? Who's there? (read as "Hmm? Who's there?") | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/biscuit_what_is_it.ogg` | Biscuit? What is it? | `bf_emma` | 1.3 s |
| `assets/audio/voice/high/whats_going_on.ogg` | What's going on? | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/hey_you.ogg` | Hey! You! | `bf_emma` | 1.2 s |
| `assets/audio/voice/high/oi_stop_right_there.ogg` | Oi! Stop right there! | `bf_emma` | 1.4 s |
| `assets/audio/voice/high/burglar.ogg` | Burglar! | `bf_emma` | 0.9 s |
| `assets/audio/voice/high/where_did_they_go.ogg` | Where did they go? | `bf_emma` | 1.2 s |
| `assets/audio/voice/high/i_know_youre_here.ogg` | I know you're here! | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/must_be_the_wind.ogg` | Must be the wind. | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/just_the_house_settling.ogg` | Just the house settling. | `bf_emma` | 1.4 s |
| `assets/audio/voice/high/im_hearing_things.ogg` | I'm hearing things. | `bf_emma` | 1.2 s |
| `assets/audio/voice/high/got_you_out_you_go.ogg` | Got you! Out you go. | `bf_emma` | 1.3 s |
| `assets/audio/voice/high/lovely_trophy_shame_about_the_bakery.ogg` | Lovely trophy. Shame about the bakery. | `bf_emma` | 2.2 s |

## Sound effects

Model `ThinkSound-SFX` (`ilintar/thinksound-gguf`). The server's default steps and guidance. These replace synthesized sounds of the same names (see `sfx/README.md`).

| File | Prompt | Seed | Takes | Length | Settings |
|---|---|---|---|---|---|
| `assets/audio/sfx/dog_bark_1.ogg` | a medium sized friendly dog barking once, indoors, close | 77984 | 6 | 0.53 s | asked for 2 s; kept 1 sound of the take |
| `assets/audio/sfx/dog_bark_2.ogg` | a dog giving one deep, longer bark, indoors | 44849 | 6 | 0.57 s | asked for 2 s; kept 1 sound of the take; take picked by hand: the lowest (about 450 Hz) and longest of the six barks |
| `assets/audio/sfx/dog_bark_3.ogg` | a small excited dog yapping once, short and high | 91710 | 6 | 0.42 s | asked for 2 s; kept 1 sound of the take; take picked by hand: the highest (about 850 Hz) and brightest of the six barks |
| `assets/audio/sfx/dog_sniff.ogg` | a dog sniffing the floor four times quickly | 15120 | 6 | 1.40 s | asked for 2 s; kept 4 sounds of the take |
| `assets/audio/sfx/snore_loop.ogg` | a dog snoring gently while asleep, steady breathing, loopable | 1090 | 6 | 6.64 s | asked for 10 s; loop 0.99 to 7.63 s of the take, 0.50 s crossfade |
| `assets/audio/sfx/ambience_night_loop.ogg` | quiet suburban garden at night, crickets, a soft breeze in leaves, distant faint traffic, loopable | 27394 | 6 | 9.20 s | asked for 12 s; loop 0.83 to 10.03 s of the take, 0.50 s crossfade |
| `assets/audio/sfx/fridge_hum_loop.ogg` | a quiet kitchen fridge compressor humming, steady, loopable | 42206 | 6 | 4.53 s | asked for 8 s; loop 0.75 to 5.28 s of the take, 0.50 s crossfade |
| `assets/audio/sfx/noisemaker_rattle_loop.ogg` | a wind up clockwork tin toy clattering and rattling on a wooden floor, loopable | 88926 | 6 | 2.69 s | asked for 4 s; loop 0.50 to 3.19 s of the take, 0.50 s crossfade |
| `assets/audio/sfx/noisemaker_wind.ogg` | winding the key of a small clockwork toy, ratchet clicks | 76001 | 6 | 1.96 s | asked for 2 s |
| `assets/audio/sfx/lock_open.ogg` | a door lock cylinder turning and the bolt clacking open | 75580 | 6 | 1.94 s | asked for 2 s |
| `assets/audio/sfx/breaker_off.ogg` | flipping a fuse box breaker switch off with a heavy thunk, electrical hum dies | 86134 | 6 | 1.77 s | asked for 3 s |
| `assets/audio/sfx/breaker_on.ogg` | flipping a fuse box breaker switch on with a thunk, electrical hum starts | 57115 | 6 | 3.02 s | asked for 3 s |

Kept synthesized (ThinkSound's takes were worse):

- `assets/audio/sfx/dog_whine.ogg`: ThinkSound's whines were steady tones; none of 24 takes rose clearly at the end, which is what makes it sound like a question.
- `assets/audio/sfx/doorbell.ogg`: none of 24 takes (this prompt and a more explicit one) was a clean two-tone chime: most held one tone, or rang several, or began mid-note.
