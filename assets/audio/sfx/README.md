# Synthesized sound effects

These sounds are synthesized for Tiptoe by `tools/sfx/make_sfx.py`, which generates them all again with `python3 tools/sfx/make_sfx.py assets/audio/sfx` (needs numpy and ffmpeg). They're 44.1 kHz mono Ogg Vorbis peaking at about -3 dBFS, so set how loud each one plays in the game. Files ending in `_loop` loop seamlessly. Everything else comes from Kenney's packs (see `KENNEY_PICKS.md`).

- `ambience_night_loop.ogg`: quiet night garden, a soft breeze and three crickets (8 s loop).
- `breaker_off.ogg`: fuse box breaker thunk, then the house hum flickers and dies (lights out).
- `breaker_on.ogg`: breaker thunk and a few sparks, then the hum swells back (lights on).
- `camera_alert.ogg`: two-beep alert from a security camera that spotted you.
- `camera_servo_loop.ogg`: quiet servo whirr of a security camera panning (1 s loop).
- `caper_done.ogg`: small happy glockenspiel run when a goal is done.
- `dart_fire.ogg`: toy foam dart blaster "thwip" (trigger, spring, air).
- `dart_hit_soft.ogg`: soft foam dart bopping something.
- `dog_bark_1.ogg`: cartoon "woof", medium pitch.
- `dog_bark_2.ogg`: cartoon "woof", lower and longer.
- `dog_bark_3.ogg`: cartoon "woof", higher and shorter.
- `dog_sniff.ogg`: four quick dog sniffs.
- `dog_whine.ogg`: short questioning dog whine that rises at the end.
- `doorbell.ogg`: two-tone "ding-dong" chime doorbell.
- `fridge_hum_loop.ogg`: quiet fridge compressor hum for kitchens (2 s loop).
- `lead_hint.ogg`: soft, curious "hmm?" vibraphone bell for a new hint.
- `lock_open.ogg`: lock cylinder turning past the pins and clacking open.
- `lockpick_tick_1.ogg`: tiny metallic pin tick of a lock pick, lowest of four.
- `lockpick_tick_2.ogg`: lock pick pin tick, second pitch.
- `lockpick_tick_3.ogg`: lock pick pin tick, third pitch.
- `lockpick_tick_4.ogg`: lock pick pin tick, highest of four.
- `lost_them.ogg`: relieved, falling two-note sting when they lose sight of you.
- `mumble_high_1.ogg`: high (woman's) gibberish voice, a statement.
- `mumble_high_2.ogg`: high gibberish voice, a question.
- `mumble_high_3.ogg`: high gibberish voice, cheery.
- `mumble_low_1.ogg`: low (man's) gibberish voice, a statement.
- `mumble_low_2.ogg`: low gibberish voice, a question.
- `mumble_low_3.ogg`: low gibberish voice, cheery.
- `noisemaker_rattle_loop.ogg`: wind-up clockwork tin toy clattering (0.8 s loop).
- `noisemaker_wind.ogg`: winding the toy's key, two twists of ratchet clicks.
- `safe_dial_tick.ogg`: one detent click of a safe's combination dial.
- `safe_open.ogg`: heavy safe door bolts clunking back, then a short metallic creak.
- `snooze.ogg`: sleepy, wobbling slide down when someone is put to sleep.
- `snore_loop.ogg`: gentle cartoon snore, a fluttery inhale then a whistle out (3 s loop).
- `spotted.ogg`: short "!" sting, two quick rising plucks, when someone sees you.
- `suspicion_tick.ogg`: subtle rising blip while a suspicion meter fills.
