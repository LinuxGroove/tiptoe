# Generated audio

Made with [Lemonade](https://lemonade-server.ai) 2026.42.0 by `tools/lemonade/generate.py` from `tools/lemonade/audio.json`; `tools/lemonade/generated.json` has the full record, including every take's numbers. Released as CC0, like the rest of Tiptoe's own audio. Make them again with

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
| `assets/audio/music/night_market.ogg` | sneaky late night corner shop music, muzak gone quiet, soft electric piano, pizzicato strings, walking upright bass, brushed snare, fluorescent hum mood, cartoon stealth, 85 bpm, instrumental, loopable | 44809 | 3 | 119.7 s | asked for 144 s; loop 17.28 to 136.99 s of the take, 1.5 s crossfade; -16.7 LUFS |
| `assets/audio/music/night_bottling.ogg` | sneaky industrial factory night music, plucked bass, mallet percussion like clinking bottles, soft clockwork ticks, muted trumpet, steady machine rhythm, cartoon stealth, 95 bpm, instrumental, loopable | 26388 | 3 | 123.6 s | asked for 144 s; loop 13.29 to 136.86 s of the take, 1.5 s crossfade; -18.8 LUFS |
| `assets/audio/music/night_town_hall.ogg` | sneaky small town council meeting music, pizzicato strings, bassoon and clarinet melody, gentle snare brushes, a little pompous brass, cartoon stealth, 85 bpm, instrumental, loopable | 52992 | 3 | 119.2 s | asked for 144 s; loop 6.52 to 125.69 s of the take, 1.5 s crossfade; -15.1 LUFS |
| `assets/audio/music/night_museum.ogg` | sneaky gala party heist music, elegant string quartet waltz played on tiptoe, harp, soft vibraphone, upright bass, cartoon stealth, 90 bpm, instrumental, loopable | 89888 | 3 | 125.6 s | asked for 144 s; loop 14.88 to 140.44 s of the take, 1.5 s crossfade; -16.5 LUFS |
| `assets/audio/music/night_labs.ogg` | sneaky science laboratory night music, soft analog synth arpeggios, theremin hints, pizzicato strings, upright bass, light electronic beat, cartoon spy, 95 bpm, instrumental, loopable | 77119 | 3 | 121.1 s | asked for 144 s; loop 16.70 to 137.83 s of the take, 1.5 s crossfade; -17.2 LUFS |
| `assets/audio/music/night_manor.ogg` | sneaky grand manor heist finale music, dark harpsichord, pizzicato strings, low brass, upright bass, tense but playful, cartoon heist, 90 bpm, instrumental, loopable | 54324 | 3 | 117.1 s | asked for 144 s; loop 17.76 to 134.82 s of the take, 1.5 s crossfade; -16.6 LUFS |
| `assets/audio/sfx/quartet_loop.ogg` | polite string quartet playing light elegant background music at a fancy gala party, violin, viola, cello, gentle waltz, 90 bpm, instrumental, loopable | 79618 | 3 | 59.7 s | asked for 72 s; loop 7.12 to 66.79 s of the take, 1.5 s crossfade; -16.4 LUFS |

## Voices

Model `kokoro-v1` (`mikkoph/kokoro-onnx`). One take each (Kokoro has no seed; the same text, voice and speed always give the same line).

- `low`: Ted, a cheerful, slightly dozy dad in his fifties. Kokoro voice `bm_george`, speed 1.0.
- `high`: Maggie, a brisk, sharp-eared mum in her fifties. Kokoro voice `bf_emma`, speed 1.05.
- `market_dev`: Dev, the night clerk: a laid-back, chatty young man who talks to himself while he stacks shelves. Kokoro voice `am_michael`, speed 1.0.
- `market_pruitt`: Mrs Pruitt, Augustus Hoard's rent collector: prim, sharp and penny-pinching, in her fifties. Kokoro voice `af_sarah`, speed 1.0.
- `bottling_foreman`: Mr Platt, the night foreman: a gruff, fussy Northern English man in his fifties, proud of his line. Kokoro voice `bm_lewis`, speed 1.0.
- `bottling_rosa`: Rosa, a line worker: quick, sensible and dry, in her thirties, fond of her tea. Kokoro voice `af_nicole`, speed 1.05.
- `bottling_eddie`: Eddie, a line worker: young, cheerful and a bit dozy. Kokoro voice `am_eric`, speed 1.0.
- `town_hall_mayor`: Mayor Prudence Plum: a brisk, decent, slightly frazzled woman in her fifties, chairing a rowdy meeting. Kokoro voice `bf_isabella`, speed 1.0.
- `town_hall_clerk`: Dennis Dobbs, clerk to the council: a fussy, forgetful, very proper young man. Kokoro voice `bm_daniel`, speed 1.05.
- `town_hall_caretaker`: Stanley, the town hall caretaker: a slow, gruff, kindly old man who has seen it all. Kokoro voice `am_adam`, speed 0.95.
- `hoard`: Augustus Hoard: a pompous, oily rich man in his sixties, pleased with himself. Kokoro voice `am_onyx`, speed 0.95.
- `museum_head_waiter`: Mr Pring, the head waiter: prim, fussy and very proper. Kokoro voice `bm_fable`, speed 1.0.
- `museum_curator`: Miss Finch, the curator: clever, flustered and quietly ashamed of her boss. Kokoro voice `bf_alice`, speed 1.05.
- `museum_guard`: Ron, the museum guard: big, kind and fond of sausage rolls. Kokoro voice `am_liam`, speed 1.0.
- `museum_guest_a`: Mrs Fairweather, a guest: a bright, chatty gossip who knows everything. Kokoro voice `af_bella`, speed 1.05.
- `museum_guest_b`: Mr Ashby, a guest: a dry, amused old gentleman. Kokoro voice `am_echo`, speed 1.0.
- `museum_crumb`: Lady Crumb, a guest: grand, nosy and delighted by scandal. Kokoro voice `af_heart`, speed 1.0.
- `museum_snapper`: Snapper, the photographer: upbeat and bossy with a camera. Kokoro voice `am_puck`, speed 1.1.
- `museum_violinist`: The violinist in the string quartet: polite and a bit bored. Kokoro voice `af_sky`, speed 1.0.
- `museum_cellist`: The cellist in the string quartet: cheerful, secretly loves sea shanties. Kokoro voice `bm_lewis`, speed 1.0.
- `museum_cook`: The cook: harassed, run off her feet, dreaming of a break. Kokoro voice `af_nicole`, speed 1.05.
- `labs_guard_a`: Briggs, a cheerful, chatty night guard in his thirties who loves a quiet night. Kokoro voice `am_puck`, speed 1.0.
- `labs_guard_b`: Rook, a dry, bored night guard in her forties who has seen it all. Kokoro voice `af_river`, speed 0.95.
- `labs_scientist`: Dr Lily Fenwick, a brilliant, scatterbrained scientist working late, who talks to herself. Kokoro voice `bf_lily`, speed 1.05.
- `labs_officer`: Officer Marsh, a sharp, no-nonsense security officer who loves her tea break. Kokoro voice `af_sky`, speed 1.0.
- `manor_pell`: Pell, Hoard's butler: a dry, weary, very proper old manservant. Kokoro voice `am_fenrir`, speed 0.95.
- `manor_guard_a`: Ogden, a night guard at the manor: big, slow, friendly and easily bored. Kokoro voice `am_adam`, speed 1.0.
- `manor_guard_b`: Hattie, a night guard at the manor: brisk, chatty and a little nosy. Kokoro voice `af_kore`, speed 1.05.

| File | Text | Voice | Length |
|---|---|---|---|
| `assets/audio/voice/low/hm.ogg` | Hm? (read as "Hmm?") | `bm_george` | 0.6 s |
| `assets/audio/voice/low/what_was_that.ogg` | What was that? | `bm_george` | 1.1 s |
| `assets/audio/voice/low/hello.ogg` | Hello? | `bm_george` | 0.9 s |
| `assets/audio/voice/low/hm_whos_there.ogg` | Hm? Who's there? (read as "Hmm? Who's there?") | `bm_george` | 1.3 s |
| `assets/audio/voice/low/hey_you.ogg` | Hey! You! | `bm_george` | 1.0 s |
| `assets/audio/voice/low/oi_stop_right_there.ogg` | Oi! Stop right there! | `bm_george` | 1.7 s |
| `assets/audio/voice/low/burglar.ogg` | Burglar! | `bm_george` | 0.8 s |
| `assets/audio/voice/low/whats_going_on.ogg` | What's going on? | `bm_george` | 1.2 s |
| `assets/audio/voice/low/where_did_they_go.ogg` | Where did they go? | `bm_george` | 1.4 s |
| `assets/audio/voice/low/i_know_youre_here.ogg` | I know you're here! | `bm_george` | 1.4 s |
| `assets/audio/voice/low/must_be_the_wind.ogg` | Must be the wind. | `bm_george` | 1.3 s |
| `assets/audio/voice/low/just_the_house_settling.ogg` | Just the house settling. | `bm_george` | 1.6 s |
| `assets/audio/voice/low/im_hearing_things.ogg` | I'm hearing things. | `bm_george` | 1.4 s |
| `assets/audio/voice/low/got_you_out_you_go.ogg` | Got you! Out you go. | `bm_george` | 1.6 s |
| `assets/audio/voice/low/coming.ogg` | Coming! | `bm_george` | 0.7 s |
| `assets/audio/voice/low/whos_that_at_this_hour.ogg` | Who's that at this hour? | `bm_george` | 1.8 s |
| `assets/audio/voice/low/hello_kids.ogg` | Hello? ...Kids. | `bm_george` | 1.2 s |
| `assets/audio/voice/low/nobody_there_odd.ogg` | Nobody there. Odd. | `bm_george` | 1.7 s |
| `assets/audio/voice/low/not_again.ogg` | Not again! | `bm_george` | 1.0 s |
| `assets/audio/voice/low/there_light.ogg` | There. Light! | `bm_george` | 1.1 s |
| `assets/audio/voice/low/biscuit_what_is_it.ogg` | Biscuit? What is it? | `bm_george` | 1.5 s |
| `assets/audio/voice/low/wha_must_have_dozed_off.ogg` | Wha...? Must have dozed off. | `bm_george` | 1.9 s |
| `assets/audio/voice/low/wheres_the_cheese.ogg` | Where's the cheese? | `bm_george` | 1.3 s |
| `assets/audio/voice/low/hello_dave_about_the_fuse_box.ogg` | Hello, Dave? About the fuse box... | `bm_george` | 2.7 s |
| `assets/audio/voice/low/wheres_the_pizza_then.ogg` | Where's the pizza, then? | `bm_george` | 1.9 s |
| `assets/audio/voice/low/pizza_come_in_come_in_ill_find_my_wallet.ogg` | Pizza! Come in, come in, I'll find my wallet. | `bm_george` | 3.2 s |
| `assets/audio/voice/high/hm.ogg` | Hm? (read as "Hmm?") | `bf_emma` | 0.6 s |
| `assets/audio/voice/high/what_was_that.ogg` | What was that? | `bf_emma` | 1.0 s |
| `assets/audio/voice/high/hello.ogg` | Hello? | `bf_emma` | 0.9 s |
| `assets/audio/voice/high/hm_whos_there.ogg` | Hm? Who's there? (read as "Hmm? Who's there?") | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/hey_you.ogg` | Hey! You! | `bf_emma` | 1.2 s |
| `assets/audio/voice/high/oi_stop_right_there.ogg` | Oi! Stop right there! | `bf_emma` | 1.4 s |
| `assets/audio/voice/high/burglar.ogg` | Burglar! | `bf_emma` | 0.9 s |
| `assets/audio/voice/high/whats_going_on.ogg` | What's going on? | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/where_did_they_go.ogg` | Where did they go? | `bf_emma` | 1.2 s |
| `assets/audio/voice/high/i_know_youre_here.ogg` | I know you're here! | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/must_be_the_wind.ogg` | Must be the wind. | `bf_emma` | 1.1 s |
| `assets/audio/voice/high/just_the_house_settling.ogg` | Just the house settling. | `bf_emma` | 1.4 s |
| `assets/audio/voice/high/im_hearing_things.ogg` | I'm hearing things. | `bf_emma` | 1.2 s |
| `assets/audio/voice/high/got_you_out_you_go.ogg` | Got you! Out you go. | `bf_emma` | 1.3 s |
| `assets/audio/voice/high/biscuit_what_is_it.ogg` | Biscuit? What is it? | `bf_emma` | 1.3 s |
| `assets/audio/voice/high/wha_must_have_dozed_off.ogg` | Wha...? Must have dozed off. | `bf_emma` | 1.5 s |
| `assets/audio/voice/high/lovely_trophy_shame_about_the_bakery.ogg` | Lovely trophy. Shame about the bakery. | `bf_emma` | 2.2 s |
| `assets/audio/voice/market_dev/hello_were_closed.ogg` | Hello? We're closed! | `am_michael` | 1.2 s |
| `assets/audio/voice/market_dev/is_someone_there.ogg` | Is someone there? | `am_michael` | 1.1 s |
| `assets/audio/voice/market_dev/was_that_a_rat.ogg` | Was that a rat? | `am_michael` | 1.0 s |
| `assets/audio/voice/market_dev/hm_whos_that.ogg` | Hm? Who's that? (read as "Hmm? Who's that?") | `am_michael` | 1.0 s |
| `assets/audio/voice/market_dev/hey_were_closed.ogg` | Hey! We're closed! | `am_michael` | 1.1 s |
| `assets/audio/voice/market_dev/oi_shoplifter.ogg` | Oi! Shoplifter! | `am_michael` | 1.1 s |
| `assets/audio/voice/market_dev/whats_going_on.ogg` | What's going on? | `am_michael` | 1.1 s |
| `assets/audio/voice/market_dev/whered_they_go.ogg` | Where'd they go? | `am_michael` | 1.0 s |
| `assets/audio/voice/market_dev/probably_a_rat_hope_its_a_rat.ogg` | Probably a rat. Hope it's a rat. | `am_michael` | 2.0 s |
| `assets/audio/voice/market_dev/just_the_freezers_humming.ogg` | Just the freezers humming. | `am_michael` | 1.4 s |
| `assets/audio/voice/market_dev/gotcha_out_you_go_were_closed.ogg` | Gotcha! Out you go, we're closed. | `am_michael` | 2.1 s |
| `assets/audio/voice/market_dev/delivery_at_this_hour.ogg` | Delivery? At this hour? | `am_michael` | 1.5 s |
| `assets/audio/voice/market_dev/nobody_again.ogg` | Nobody. Again. | `am_michael` | 1.2 s |
| `assets/audio/voice/market_dev/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `am_michael` | 1.5 s |
| `assets/audio/voice/market_dev/wha_was_i_asleep_on_shift.ogg` | Wha...? Was I asleep on shift? | `am_michael` | 1.8 s |
| `assets/audio/voice/market_dev/peas_more_peas_why_is_it_always_peas.ogg` | Peas. More peas. Why is it always peas? | `am_michael` | 2.9 s |
| `assets/audio/voice/market_dev/right_beans.ogg` | Right. Beans. | `am_michael` | 1.0 s |
| `assets/audio/voice/market_dev/nobody_ever_buys_the_pickled_eggs.ogg` | Nobody ever buys the pickled eggs. | `am_michael` | 2.3 s |
| `assets/audio/voice/market_dev/who_puts_the_soup_in_alphabetical_order_me_i_do.ogg` | Who puts the soup in alphabetical order? Me. I do. | `am_michael` | 3.3 s |
| `assets/audio/voice/market_dev/office_codes_oh_four_one_two_now_who_picks_these.ogg` | Office code's oh-four-one-two now. Who picks these? | `am_michael` | 3.2 s |
| `assets/audio/voice/market_dev/bins_living_the_dream.ogg` | Bins. Living the dream. | `am_michael` | 1.5 s |
| `assets/audio/voice/market_dev/evening_didnt_know_you_were_on_tonight.ogg` | Evening! Didn't know you were on tonight. | `am_michael` | 2.0 s |
| `assets/audio/voice/market_dev/oh_the_new_starter_come_in_come_in_stock_rooms_t.ogg` | Oh! The new starter? Come in, come in. Stock room's through there. | `am_michael` | 3.3 s |
| `assets/audio/voice/market_dev/thank_you_for_recycling_youre_welcome_machine.ogg` | Thank you for recycling. You're welcome, machine. | `am_michael` | 2.9 s |
| `assets/audio/voice/market_pruitt/dev_is_that_you.ogg` | Dev? Is that you? | `af_sarah` | 1.1 s |
| `assets/audio/voice/market_pruitt/whos_there.ogg` | Who's there? | `af_sarah` | 0.8 s |
| `assets/audio/voice/market_pruitt/whos_that.ogg` | Who's that? | `af_sarah` | 0.8 s |
| `assets/audio/voice/market_pruitt/thief_stop_right_there.ogg` | Thief! Stop right there! | `af_sarah` | 1.4 s |
| `assets/audio/voice/market_pruitt/i_knew_it_a_burglar.ogg` | I knew it! A burglar! | `af_sarah` | 1.4 s |
| `assets/audio/voice/market_pruitt/dev_what_is_going_on.ogg` | Dev! What is going on? | `af_sarah` | 1.4 s |
| `assets/audio/voice/market_pruitt/where_have_they_got_to.ogg` | Where have they got to? | `af_sarah` | 1.2 s |
| `assets/audio/voice/market_pruitt/hmph_rats.ogg` | Hmph. Rats. (read as "Humph. Rats.") | `af_sarah` | 0.9 s |
| `assets/audio/voice/market_pruitt/devs_been_at_the_pickled_eggs_again.ogg` | Dev's been at the pickled eggs again. | `af_sarah` | 1.8 s |
| `assets/audio/voice/market_pruitt/caught_you_mr_hoard_will_hear_about_this.ogg` | Caught you! Mr Hoard will hear about this. | `af_sarah` | 2.3 s |
| `assets/audio/voice/market_pruitt/not_again_that_breaker.ogg` | Not again! That breaker! | `af_sarah` | 1.5 s |
| `assets/audio/voice/market_pruitt/there_and_stay_on.ogg` | There. And stay on. | `af_sarah` | 1.1 s |
| `assets/audio/voice/market_pruitt/the_alarm_someones_on_camera.ogg` | The alarm! Someone's on camera! | `af_sarah` | 1.8 s |
| `assets/audio/voice/market_pruitt/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `af_sarah` | 1.5 s |
| `assets/audio/voice/market_pruitt/hm_i_was_only_resting_my_eyes.ogg` | Hm? I was only resting my eyes. (read as "Hmm? I was only resting my eyes.") | `af_sarah` | 1.9 s |
| `assets/audio/voice/market_pruitt/twenty_forty_sixty_mr_hoard_wants_every_penny.ogg` | Twenty, forty, sixty... Mr Hoard wants every penny. | `af_sarah` | 3.3 s |
| `assets/audio/voice/market_pruitt/camera_twos_fuzzy_again_cheap_things.ogg` | Camera two's fuzzy again. Cheap things. | `af_sarah` | 2.4 s |
| `assets/audio/voice/market_pruitt/short_by_fifty_pence_typical.ogg` | Short by fifty pence. Typical. | `af_sarah` | 1.9 s |
| `assets/audio/voice/market_pruitt/the_bakerys_rent_goes_up_again_lovely.ogg` | The bakery's rent goes up again. Lovely. | `af_sarah` | 2.6 s |
| `assets/audio/voice/market_pruitt/back_door_locked_good.ogg` | Back door. Locked. Good. | `af_sarah` | 1.3 s |
| `assets/audio/voice/market_pruitt/whos_that_knocking.ogg` | Who's that knocking? | `af_sarah` | 1.1 s |
| `assets/audio/voice/market_pruitt/the_tills_short_again_honestly_ill_count_it_myse.ogg` | The till's short again? Honestly. I'll count it myself. | `af_sarah` | 3.0 s |
| `assets/audio/voice/market_pruitt/hm_dev_if_thats_you_it_isnt_funny.ogg` | Hm. Dev, if that's you, it isn't funny. (read as "Hmm. Dev, if that's you, it isn't funny.") | `af_sarah` | 2.0 s |
| `assets/audio/voice/market_pruitt/who_switched_the_cameras_off_honestly.ogg` | Who switched the cameras off? Honestly. | `af_sarah` | 1.9 s |
| `assets/audio/voice/bottling_foreman/hm_whos_that.ogg` | Hm? Who's that? (read as "Hmm? Who's that?") | `bm_lewis` | 1.1 s |
| `assets/audio/voice/bottling_foreman/whats_that_racket.ogg` | What's that racket? | `bm_lewis` | 1.2 s |
| `assets/audio/voice/bottling_foreman/whos_down_there.ogg` | Who's down there? | `bm_lewis` | 1.1 s |
| `assets/audio/voice/bottling_foreman/oi_youre_not_on_my_shift.ogg` | Oi! You're not on my shift! | `bm_lewis` | 1.7 s |
| `assets/audio/voice/bottling_foreman/burglar_on_my_floor.ogg` | Burglar! On my floor! | `bm_lewis` | 1.6 s |
| `assets/audio/voice/bottling_foreman/whats_going_on_down_there.ogg` | What's going on down there? | `bm_lewis` | 1.6 s |
| `assets/audio/voice/bottling_foreman/come_out_i_know_youre_here.ogg` | Come out, I know you're here! | `bm_lewis` | 1.6 s |
| `assets/audio/voice/bottling_foreman/nobody_back_to_work.ogg` | Nobody. Back to work. | `bm_lewis` | 1.6 s |
| `assets/audio/voice/bottling_foreman/must_be_the_pipes.ogg` | Must be the pipes. | `bm_lewis` | 1.2 s |
| `assets/audio/voice/bottling_foreman/out_and_stay_out.ogg` | Out! And stay out! | `bm_lewis` | 1.3 s |
| `assets/audio/voice/bottling_foreman/not_the_fuses_again.ogg` | Not the fuses again! | `bm_lewis` | 1.5 s |
| `assets/audio/voice/bottling_foreman/powers_back_get_that_line_moving.ogg` | Power's back. Get that line moving! | `bm_lewis` | 2.2 s |
| `assets/audio/voice/bottling_foreman/whos_been_at_my_line.ogg` | Who's been at my line? | `bm_lewis` | 1.6 s |
| `assets/audio/voice/bottling_foreman/wha_i_was_checking_my_eyelids.ogg` | Wha...? I was checking my eyelids. | `bm_lewis` | 2.0 s |
| `assets/audio/voice/bottling_foreman/yes_mr_hoard_ticking_along_nicely_mr_hoard.ogg` | Yes, Mr Hoard. Ticking along nicely, Mr Hoard. | `bm_lewis` | 3.5 s |
| `assets/audio/voice/bottling_foreman/keep_it_moving_rosa.ogg` | Keep it moving, Rosa. | `bm_lewis` | 1.6 s |
| `assets/audio/voice/bottling_foreman/lovely_bit_of_brass_that.ogg` | Lovely bit of brass, that. | `bm_lewis` | 1.8 s |
| `assets/audio/voice/bottling_foreman/mind_those_crates_eddie.ogg` | Mind those crates, Eddie. | `bm_lewis` | 1.7 s |
| `assets/audio/voice/bottling_foreman/nobody_touches_my_lever.ogg` | Nobody touches my lever. | `bm_lewis` | 2.0 s |
| `assets/audio/voice/bottling_foreman/tea_on_my_shift.ogg` | Tea? On my shift? | `bm_lewis` | 1.4 s |
| `assets/audio/voice/bottling_foreman/who_stopped_my_line.ogg` | Who stopped my line? | `bm_lewis` | 1.3 s |
| `assets/audio/voice/bottling_foreman/there_back_to_work_all_of_you.ogg` | There. Back to work, all of you. | `bm_lewis` | 1.9 s |
| `assets/audio/voice/bottling_foreman/what_was_that_crash.ogg` | What was that crash?! | `bm_lewis` | 1.2 s |
| `assets/audio/voice/bottling_foreman/whos_been_at_my_lever.ogg` | Who's been at my lever? | `bm_lewis` | 1.7 s |
| `assets/audio/voice/bottling_foreman/the_drive_cogs_gone_weve_been_robbed.ogg` | The drive cog's gone! We've been robbed! | `bm_lewis` | 2.5 s |
| `assets/audio/voice/bottling_rosa/eddie_is_that_you.ogg` | Eddie? Is that you? | `af_nicole` | 1.2 s |
| `assets/audio/voice/bottling_rosa/hello.ogg` | Hello? | `af_nicole` | 0.7 s |
| `assets/audio/voice/bottling_rosa/whos_there.ogg` | Who's there? | `af_nicole` | 0.9 s |
| `assets/audio/voice/bottling_rosa/hey_stop.ogg` | Hey! Stop! | `af_nicole` | 1.0 s |
| `assets/audio/voice/bottling_rosa/mr_platt_burglar.ogg` | Mr Platt! Burglar! | `af_nicole` | 1.3 s |
| `assets/audio/voice/bottling_rosa/whats_happening.ogg` | What's happening? | `af_nicole` | 1.0 s |
| `assets/audio/voice/bottling_rosa/whered_they_go.ogg` | Where'd they go? | `af_nicole` | 1.0 s |
| `assets/audio/voice/bottling_rosa/just_the_machines.ogg` | Just the machines. | `af_nicole` | 1.2 s |
| `assets/audio/voice/bottling_rosa/i_need_a_cup_of_tea.ogg` | I need a cup of tea. | `af_nicole` | 1.4 s |
| `assets/audio/voice/bottling_rosa/got_you_off_you_go.ogg` | Got you! Off you go. | `af_nicole` | 1.5 s |
| `assets/audio/voice/bottling_rosa/thats_the_alarm.ogg` | That's the alarm! | `af_nicole` | 1.1 s |
| `assets/audio/voice/bottling_rosa/what_was_that.ogg` | What was that? | `af_nicole` | 0.9 s |
| `assets/audio/voice/bottling_rosa/oh_i_must_have_nodded_off.ogg` | Oh! I must have nodded off. | `af_nicole` | 1.9 s |
| `assets/audio/voice/bottling_rosa/fillers_running_hot_again.ogg` | Filler's running hot again. | `af_nicole` | 1.8 s |
| `assets/audio/voice/bottling_rosa/kettle_on_eddie.ogg` | Kettle on, Eddie? | `af_nicole` | 1.2 s |
| `assets/audio/voice/bottling_rosa/ooh_kettles_on.ogg` | Ooh, kettle's on! | `af_nicole` | 1.2 s |
| `assets/audio/voice/bottling_rosa/lines_stopped_ill_see_to_it.ogg` | Line's stopped. I'll see to it. | `af_nicole` | 2.4 s |
| `assets/audio/voice/bottling_rosa/there_she_goes.ogg` | There she goes. | `af_nicole` | 1.0 s |
| `assets/audio/voice/bottling_rosa/what_on_earth_was_that.ogg` | What on earth was that? | `af_nicole` | 1.6 s |
| `assets/audio/voice/bottling_rosa/the_drive_cogs_gone_weve_been_robbed.ogg` | The drive cog's gone! We've been robbed! | `af_nicole` | 3.0 s |
| `assets/audio/voice/bottling_eddie/wassat.ogg` | Wassat? | `am_eric` | 0.8 s |
| `assets/audio/voice/bottling_eddie/rosa.ogg` | Rosa? | `am_eric` | 0.8 s |
| `assets/audio/voice/bottling_eddie/er_hello.ogg` | Er... hello? | `am_eric` | 0.8 s |
| `assets/audio/voice/bottling_eddie/oi_who_are_you.ogg` | Oi! Who are you? | `am_eric` | 1.1 s |
| `assets/audio/voice/bottling_eddie/burglar_rosa.ogg` | Burglar! Rosa! | `am_eric` | 1.1 s |
| `assets/audio/voice/bottling_eddie/whats_up.ogg` | What's up? | `am_eric` | 0.8 s |
| `assets/audio/voice/bottling_eddie/they_were_just_here.ogg` | They were just here... | `am_eric` | 1.0 s |
| `assets/audio/voice/bottling_eddie/probably_a_rat.ogg` | Probably a rat. | `am_eric` | 1.1 s |
| `assets/audio/voice/bottling_eddie/nothing_nice.ogg` | Nothing. Nice. | `am_eric` | 1.0 s |
| `assets/audio/voice/bottling_eddie/got_you_sorry_out_you_go.ogg` | Got you! Sorry. Out you go. | `am_eric` | 1.7 s |
| `assets/audio/voice/bottling_eddie/alarm_alarm.ogg` | Alarm! Alarm! | `am_eric` | 1.1 s |
| `assets/audio/voice/bottling_eddie/what_was_that.ogg` | What was that? | `am_eric` | 0.9 s |
| `assets/audio/voice/bottling_eddie/wha_i_wasnt_asleep.ogg` | Wha...? I wasn't asleep. | `am_eric` | 1.4 s |
| `assets/audio/voice/bottling_eddie/empties_on_empties_on.ogg` | Empties on. Empties on. | `am_eric` | 1.6 s |
| `assets/audio/voice/bottling_eddie/just_resting_my_eyes.ogg` | Just resting my eyes. | `am_eric` | 1.5 s |
| `assets/audio/voice/bottling_eddie/tea_lovely.ogg` | Tea! Lovely. | `am_eric` | 0.8 s |
| `assets/audio/voice/bottling_eddie/lines_stopped_ill_do_it_then.ogg` | Line's stopped! ...I'll do it then. | `am_eric` | 1.7 s |
| `assets/audio/voice/bottling_eddie/and_were_off.ogg` | And we're off. | `am_eric` | 0.8 s |
| `assets/audio/voice/bottling_eddie/was_that_the_crane.ogg` | Was that the crane?! | `am_eric` | 1.1 s |
| `assets/audio/voice/bottling_eddie/the_drive_cogs_gone_weve_been_robbed.ogg` | The drive cog's gone! We've been robbed! | `am_eric` | 2.0 s |
| `assets/audio/voice/town_hall_mayor/hm_whos_that.ogg` | Hm? Who's that? (read as "Hmm? Who's that?") | `bf_isabella` | 1.1 s |
| `assets/audio/voice/town_hall_mayor/is_somebody_there.ogg` | Is somebody there? | `bf_isabella` | 1.2 s |
| `assets/audio/voice/town_hall_mayor/excuse_me_can_i_help_you.ogg` | Excuse me? Can I help you? | `bf_isabella` | 1.7 s |
| `assets/audio/voice/town_hall_mayor/you_stop_right_there.ogg` | You! Stop right there! | `bf_isabella` | 1.3 s |
| `assets/audio/voice/town_hall_mayor/stop_thief.ogg` | Stop! Thief! | `bf_isabella` | 1.1 s |
| `assets/audio/voice/town_hall_mayor/whats_all_the_fuss.ogg` | What's all the fuss? | `bf_isabella` | 1.2 s |
| `assets/audio/voice/town_hall_mayor/where_did_they_go.ogg` | Where did they go? | `bf_isabella` | 1.2 s |
| `assets/audio/voice/town_hall_mayor/back_to_the_meeting_then.ogg` | Back to the meeting, then. | `bf_isabella` | 1.5 s |
| `assets/audio/voice/town_hall_mayor/im_seeing_burglars_everywhere_tonight.ogg` | I'm seeing burglars everywhere tonight. | `bf_isabella` | 2.2 s |
| `assets/audio/voice/town_hall_mayor/got_you_out_you_go_and_dont_come_back.ogg` | Got you. Out you go, and don't come back. | `bf_isabella` | 2.3 s |
| `assets/audio/voice/town_hall_mayor/what_on_earth_is_that.ogg` | What on earth is that? | `bf_isabella` | 1.4 s |
| `assets/audio/voice/town_hall_mayor/goodness_did_i_nod_off.ogg` | Goodness. Did I nod off? | `bf_isabella` | 1.5 s |
| `assets/audio/voice/town_hall_mayor/order_order_lets_hear_mr_hoard_out.ogg` | Order, order! Let's hear Mr Hoard out. | `bf_isabella` | 2.4 s |
| `assets/audio/voice/town_hall_mayor/the_vote_is_at_ten_oclock_ill_fetch_the_charter.ogg` | The vote is at ten o'clock. I'll fetch the charter myself. | `bf_isabella` | 3.5 s |
| `assets/audio/voice/town_hall_mayor/dobbs_remind_me_my_strongbox_keys_in_my_red_coat.ogg` | Dobbs, remind me. My strongbox key's in my red coat, isn't it? | `bf_isabella` | 3.9 s |
| `assets/audio/voice/town_hall_mayor/glasses_glasses_and_theres_my_key_still_in_the_p.ogg` | Glasses, glasses... and there's my key, still in the pocket. | `bf_isabella` | 3.4 s |
| `assets/audio/voice/town_hall_mayor/mrs_dunn_please_sit_down.ogg` | Mrs Dunn, please sit down. | `bf_isabella` | 1.9 s |
| `assets/audio/voice/town_hall_mayor/ten_oclock_ill_fetch_the_charter_for_the_vote.ogg` | Ten o'clock. I'll fetch the charter for the vote. | `bf_isabella` | 2.7 s |
| `assets/audio/voice/town_hall_mayor/now_then_the_charter.ogg` | Now then. The charter. | `bf_isabella` | 1.5 s |
| `assets/audio/voice/town_hall_mayor/here_it_is_the_town_charter_lets_vote.ogg` | Here it is: the town charter. Let's vote. | `bf_isabella` | 2.5 s |
| `assets/audio/voice/town_hall_mayor/the_charter_its_gone_somebodys_taken_the_charter.ogg` | The charter! It's gone! Somebody's taken the charter! | `bf_isabella` | 3.1 s |
| `assets/audio/voice/town_hall_mayor/the_votes_off_everyone_somebodys_pinched_the_cha.ogg` | The vote's off, everyone. Somebody's pinched the charter. | `bf_isabella` | 3.2 s |
| `assets/audio/voice/town_hall_mayor/one_minute_to_the_vote_everyone.ogg` | One minute to the vote, everyone. | `bf_isabella` | 1.9 s |
| `assets/audio/voice/town_hall_mayor/nobody_panic_stanley_the_fuses.ogg` | Nobody panic! Stanley, the fuses! | `bf_isabella` | 2.2 s |
| `assets/audio/voice/town_hall_mayor/whos_ringing_the_bell_stanley_go_and_look.ogg` | Who's ringing the bell? Stanley, go and look! | `bf_isabella` | 2.3 s |
| `assets/audio/voice/town_hall_mayor/vote_no_hm_maybe_i_will.ogg` | Vote no? Hm. Maybe I will. (read as "Vote no? Hmm. Maybe I will.") | `bf_isabella` | 1.8 s |
| `assets/audio/voice/town_hall_mayor/is_that_a_mop_in_my_chamber.ogg` | Is that a mop? In my chamber? | `bf_isabella` | 1.9 s |
| `assets/audio/voice/town_hall_mayor/point_of_order_can_we_please_just_vote.ogg` | Point of order! Can we please just vote? | `bf_isabella` | 2.3 s |
| `assets/audio/voice/town_hall_mayor/did_you_hear_that.ogg` | Did you hear that? | `bf_isabella` | 1.1 s |
| `assets/audio/voice/town_hall_mayor/what_was_that.ogg` | What was that? | `bf_isabella` | 1.1 s |
| `assets/audio/voice/town_hall_mayor/im_sorry_have_we_met.ogg` | I'm sorry, have we met? | `bf_isabella` | 1.5 s |
| `assets/audio/voice/town_hall_mayor/are_you_with_the_caterers.ogg` | Are you with the caterers? | `bf_isabella` | 1.5 s |
| `assets/audio/voice/town_hall_mayor/a_burglar_in_a_museum.ogg` | A burglar! In a museum! | `bf_isabella` | 1.6 s |
| `assets/audio/voice/town_hall_mayor/help_thief.ogg` | Help! Thief! | `bf_isabella` | 1.0 s |
| `assets/audio/voice/town_hall_mayor/whats_going_on.ogg` | What's going on? | `bf_isabella` | 1.1 s |
| `assets/audio/voice/town_hall_mayor/probably_a_waiter.ogg` | Probably a waiter. | `bf_isabella` | 1.3 s |
| `assets/audio/voice/town_hall_mayor/must_have_been_the_mayor.ogg` | Must have been the Mayor. | `bf_isabella` | 1.3 s |
| `assets/audio/voice/town_hall_mayor/got_you_somebody_fetch_ron.ogg` | Got you! Somebody fetch Ron! | `bf_isabella` | 1.8 s |
| `assets/audio/voice/town_hall_mayor/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `bf_isabella` | 1.7 s |
| `assets/audio/voice/town_hall_mayor/oh_i_must_have_nodded_off_lovely_party.ogg` | Oh! I must have nodded off. Lovely party. | `bf_isabella` | 2.6 s |
| `assets/audio/voice/town_hall_mayor/shed_lose_her_head_if_it_wasnt_on_a_plinth.ogg` | She'd lose her head if it wasn't on a plinth. | `bf_isabella` | 2.1 s |
| `assets/audio/voice/town_hall_mayor/well_nobody_comes_in_through_the_roof_do_they.ogg` | Well, nobody comes in through the roof, do they? | `bf_isabella` | 2.4 s |
| `assets/audio/voice/town_hall_mayor/even_the_guard_leaves_his_desk_for_it_hoard_want.ogg` | Even the guard leaves his desk for it. Hoard wants him in the photo. | `bf_isabella` | 3.5 s |
| `assets/audio/voice/town_hall_mayor/a_drink_dont_mind_if_i_do.ogg` | A drink? Don't mind if I do. | `bf_isabella` | 1.9 s |
| `assets/audio/voice/town_hall_mayor/cheers_dont_tell_hoard_im_here.ogg` | Cheers! Don't tell Hoard I'm here. | `bf_isabella` | 1.9 s |
| `assets/audio/voice/town_hall_mayor/ooh_is_this_part_of_the_show.ogg` | Ooh! Is this part of the show? | `bf_isabella` | 1.7 s |
| `assets/audio/voice/town_hall_clerk/hello.ogg` | Hello? | `bm_daniel` | 0.8 s |
| `assets/audio/voice/town_hall_clerk/is_that_you_stanley.ogg` | Is that you, Stanley? | `bm_daniel` | 1.5 s |
| `assets/audio/voice/town_hall_clerk/sorry_are_you_meant_to_be_back_here.ogg` | Sorry, are you meant to be back here? | `bm_daniel` | 2.0 s |
| `assets/audio/voice/town_hall_clerk/hang_on_im_the_only_clerk_here.ogg` | Hang on. I'm the only clerk here. | `bm_daniel` | 2.1 s |
| `assets/audio/voice/town_hall_clerk/oi_thats_council_property.ogg` | Oi! That's council property! | `bm_daniel` | 1.8 s |
| `assets/audio/voice/town_hall_clerk/stop_burglar.ogg` | Stop! Burglar! | `bm_daniel` | 1.2 s |
| `assets/audio/voice/town_hall_clerk/whats_going_on.ogg` | What's going on? | `bm_daniel` | 1.2 s |
| `assets/audio/voice/town_hall_clerk/where_did_they_go_ill_make_a_note.ogg` | Where did they go? I'll make a note. | `bm_daniel` | 1.9 s |
| `assets/audio/voice/town_hall_clerk/must_have_been_a_draught.ogg` | Must have been a draught. | `bm_daniel` | 1.5 s |
| `assets/audio/voice/town_hall_clerk/ill_put_it_in_the_minutes.ogg` | I'll put it in the minutes. | `bm_daniel` | 1.5 s |
| `assets/audio/voice/town_hall_clerk/right_out_and_im_writing_this_down.ogg` | Right. Out. And I'm writing this down. | `bm_daniel` | 2.1 s |
| `assets/audio/voice/town_hall_clerk/the_charter_somebody_check_the_charter.ogg` | The charter! Somebody check the charter! | `bm_daniel` | 2.3 s |
| `assets/audio/voice/town_hall_clerk/wha_i_was_resting_my_eyes.ogg` | Wha...? I was resting my eyes. | `bm_daniel` | 1.9 s |
| `assets/audio/voice/town_hall_clerk/minute_forty_three_mr_hoard_is_still_talking.ogg` | Minute forty-three: Mr Hoard is still talking. | `bm_daniel` | 2.6 s |
| `assets/audio/voice/town_hall_clerk/now_where_did_i_put_the_stapler.ogg` | Now, where did I put the stapler? | `bm_daniel` | 1.9 s |
| `assets/audio/voice/town_hall_clerk/minutes_from_1846_theyre_in_here_somewhere.ogg` | Minutes from 1846... they're in here somewhere. | `bm_daniel` | 4.1 s |
| `assets/audio/voice/town_hall_clerk/who_keeps_borrowing_the_spare_lanyard.ogg` | Who keeps borrowing the spare lanyard? | `bm_daniel` | 2.1 s |
| `assets/audio/voice/town_hall_caretaker/whos_that.ogg` | Who's that? | `am_adam` | 0.8 s |
| `assets/audio/voice/town_hall_caretaker/hello_somebody_there.ogg` | Hello? Somebody there? | `am_adam` | 1.4 s |
| `assets/audio/voice/town_hall_caretaker/oi_whos_that_skulking_about.ogg` | Oi. Who's that skulking about? | `am_adam` | 1.7 s |
| `assets/audio/voice/town_hall_caretaker/got_a_burglar_stop.ogg` | Got a burglar! Stop! | `am_adam` | 1.3 s |
| `assets/audio/voice/town_hall_caretaker/oi_you.ogg` | Oi! You! | `am_adam` | 0.8 s |
| `assets/audio/voice/town_hall_caretaker/whats_all_the_shouting.ogg` | What's all the shouting? | `am_adam` | 1.3 s |
| `assets/audio/voice/town_hall_caretaker/slippery_one.ogg` | Slippery one. | `am_adam` | 0.9 s |
| `assets/audio/voice/town_hall_caretaker/pigeons_again.ogg` | Pigeons again. | `am_adam` | 1.1 s |
| `assets/audio/voice/town_hall_caretaker/just_the_pipes.ogg` | Just the pipes. | `am_adam` | 1.1 s |
| `assets/audio/voice/town_hall_caretaker/gotcha_out_the_front_sunshine.ogg` | Gotcha. Out the front, sunshine. | `am_adam` | 1.9 s |
| `assets/audio/voice/town_hall_caretaker/not_the_fuses_again.ogg` | Not the fuses again! | `am_adam` | 1.3 s |
| `assets/audio/voice/town_hall_caretaker/there_let_there_be_light.ogg` | There. Let there be light. | `am_adam` | 1.3 s |
| `assets/audio/voice/town_hall_caretaker/whats_all_that_racket.ogg` | What's all that racket? | `am_adam` | 1.3 s |
| `assets/audio/voice/town_hall_caretaker/eh_mustve_dropped_off.ogg` | Eh? Must've dropped off. | `am_adam` | 1.5 s |
| `assets/audio/voice/town_hall_caretaker/right_rounds.ogg` | Right. Rounds. | `am_adam` | 1.0 s |
| `assets/audio/voice/town_hall_caretaker/who_parks_like_that_oh_mr_hoard.ogg` | Who parks like that? Oh. Mr Hoard. | `am_adam` | 2.2 s |
| `assets/audio/voice/town_hall_caretaker/nobodys_touched_the_bell_rope_good.ogg` | Nobody's touched the bell rope. Good. | `am_adam` | 2.0 s |
| `assets/audio/voice/town_hall_caretaker/mind_the_floor_its_just_been_mopped.ogg` | Mind the floor, it's just been mopped. | `am_adam` | 2.0 s |
| `assets/audio/voice/town_hall_caretaker/somebodys_left_the_lights_on_again.ogg` | Somebody's left the lights on again. | `am_adam` | 1.9 s |
| `assets/audio/voice/town_hall_caretaker/whos_that_at_my_bell.ogg` | Who's that at my bell? | `am_adam` | 1.3 s |
| `assets/audio/voice/town_hall_caretaker/wheres_my_mop_got_to.ogg` | Where's my mop got to? | `am_adam` | 1.4 s |
| `assets/audio/voice/hoard/hm_whos_skulking_there.ogg` | Hm? Who's skulking there? (read as "Hmm? Who's skulking there?") | `am_onyx` | 1.9 s |
| `assets/audio/voice/hoard/you_there_do_i_know_you.ogg` | You there! Do I know you? | `am_onyx` | 1.5 s |
| `assets/audio/voice/hoard/a_thief_somebody_grab_them.ogg` | A thief! Somebody grab them! | `am_onyx` | 2.0 s |
| `assets/audio/voice/hoard/whats_all_this.ogg` | What's all this? | `am_onyx` | 1.1 s |
| `assets/audio/voice/hoard/slippery_little.ogg` | Slippery little... | `am_onyx` | 1.1 s |
| `assets/audio/voice/hoard/nobody_excellent_where_was_i.ogg` | Nobody. Excellent. Where was I? | `am_onyx` | 2.1 s |
| `assets/audio/voice/hoard/got_you_out_out.ogg` | Got you! Out, out! | `am_onyx` | 1.4 s |
| `assets/audio/voice/hoard/who_dares_oh_i_dozed.ogg` | Who dares... oh. I dozed. | `am_onyx` | 1.8 s |
| `assets/audio/voice/hoard/do_get_on_with_it_prudence.ogg` | Do get on with it, Prudence. | `am_onyx` | 1.9 s |
| `assets/audio/voice/hoard/friends_neighbours_imagine_a_car_park_where_that.ogg` | Friends! Neighbours! Imagine a car park where that soggy green is now! | `am_onyx` | 3.9 s |
| `assets/audio/voice/hoard/forty_spaces_forty_all_of_them_reserved_for_me.ogg` | Forty spaces! Forty! All of them reserved. For me. | `am_onyx` | 3.2 s |
| `assets/audio/voice/hoard/the_charter_says_for_ever_but_what_is_for_ever_r.ogg` | The charter says for ever. But what is for ever, really? | `am_onyx` | 2.9 s |
| `assets/audio/voice/hoard/two_hundred_grams_of_butter_two_hundred_grams_of.ogg` | Two hundred grams of butter, two hundred grams of sugar... what? | `am_onyx` | 3.5 s |
| `assets/audio/voice/hoard/bake_for_twenty_minutes_until_golden_who_gave_me.ogg` | Bake for twenty minutes until golden? Who gave me a recipe? | `am_onyx` | 3.4 s |
| `assets/audio/voice/hoard/jam_in_the_middle_not_cream_this_isnt_my_speech.ogg` | Jam in the middle. Not cream. This isn't my speech! | `am_onyx` | 3.2 s |
| `assets/audio/voice/hoard/at_last_lets_get_this_over_with.ogg` | At last. Let's get this over with. | `am_onyx` | 2.1 s |
| `assets/audio/voice/hoard/is_this_a_joke_who_turned_out_the_lights.ogg` | Is this a joke? Who turned out the lights? | `am_onyx` | 2.4 s |
| `assets/audio/voice/hoard/a_bell_at_this_hour.ogg` | A bell? At this hour? | `am_onyx` | 1.5 s |
| `assets/audio/voice/hoard/hm_whos_that.ogg` | Hm? Who's that? (read as "Hmm? Who's that?") | `am_onyx` | 1.1 s |
| `assets/audio/voice/hoard/who_invited_you.ogg` | Who invited you? | `am_onyx` | 1.5 s |
| `assets/audio/voice/hoard/security_ron_a_burglar.ogg` | Security! Ron! A burglar! | `am_onyx` | 2.1 s |
| `assets/audio/voice/hoard/whats_all_the_fuss.ogg` | What's all the fuss? | `am_onyx` | 1.4 s |
| `assets/audio/voice/hoard/ron_find_them.ogg` | Ron! Find them! | `am_onyx` | 1.5 s |
| `assets/audio/voice/hoard/probably_the_mayor_she_wanders.ogg` | Probably the Mayor. She wanders. | `am_onyx` | 1.9 s |
| `assets/audio/voice/hoard/got_you_ron_show_them_out.ogg` | Got you! Ron, show them out. | `am_onyx` | 1.9 s |
| `assets/audio/voice/hoard/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `am_onyx` | 1.8 s |
| `assets/audio/voice/hoard/wha_rich_men_need_their_rest.ogg` | Wha...? Rich men need their rest. | `am_onyx` | 1.9 s |
| `assets/audio/voice/hoard/marvellous_isnt_it_all_mine.ogg` | Marvellous, isn't it? All mine. | `am_onyx` | 2.0 s |
| `assets/audio/voice/hoard/and_there_he_is_the_founder_much_happier_here.ogg` | And there he is. The founder. Much happier here. | `am_onyx` | 2.6 s |
| `assets/audio/voice/hoard/do_try_the_vol_au_vents_i_paid_for_them_eventual.ogg` | Do try the vol-au-vents. I paid for them. Eventually. | `am_onyx` | 3.3 s |
| `assets/audio/voice/hoard/that_cannon_was_just_lying_on_the_beach_finders.ogg` | That cannon was just lying on the beach. Finders keepers. | `am_onyx` | 3.7 s |
| `assets/audio/voice/hoard/the_castles_from_the_library_they_had_far_too_ma.ogg` | The castle's from the library. They had far too many books anyway. | `am_onyx` | 3.6 s |
| `assets/audio/voice/hoard/friends_neighbours_people_who_owe_me_money.ogg` | Friends! Neighbours! People who owe me money! | `am_onyx` | 2.4 s |
| `assets/audio/voice/hoard/welcome_to_the_hoard_museum_of_local_heritage.ogg` | Welcome to the Hoard Museum of Local Heritage. | `am_onyx` | 2.9 s |
| `assets/audio/voice/hoard/everything_you_see_was_given_freely_more_or_less.ogg` | Everything you see was given freely. More or less. | `am_onyx` | 3.0 s |
| `assets/audio/voice/hoard/and_through_that_arch_the_founder_himself_safe_a.ogg` | And through that arch, the founder himself. Safe at last. | `am_onyx` | 3.2 s |
| `assets/audio/voice/hoard/to_kettleford_and_to_me.ogg` | To Kettleford! And to me! | `am_onyx` | 1.7 s |
| `assets/audio/voice/hoard/everyone_into_the_hall_toast_time.ogg` | Everyone! Into the hall! Toast time! | `am_onyx` | 2.2 s |
| `assets/audio/voice/hoard/the_gong_thats_my_cue.ogg` | The gong! That's my cue! | `am_onyx` | 2.1 s |
| `assets/audio/voice/hoard/cheese.ogg` | Cheese! | `am_onyx` | 0.8 s |
| `assets/audio/voice/hoard/champagne_mine_i_assume_everything_is.ogg` | Champagne? Mine, I assume. Everything is. | `am_onyx` | 2.4 s |
| `assets/audio/voice/hoard/who_turned_the_lights_out_ron.ogg` | Who turned the lights out? Ron! | `am_onyx` | 2.2 s |
| `assets/audio/voice/hoard/whos_there.ogg` | Who's there? | `am_onyx` | 0.9 s |
| `assets/audio/voice/hoard/pell_is_that_you.ogg` | Pell? Is that you? | `am_onyx` | 1.4 s |
| `assets/audio/voice/hoard/what_was_that.ogg` | What was that? | `am_onyx` | 1.1 s |
| `assets/audio/voice/hoard/a_burglar_in_my_house.ogg` | A burglar! In MY house! | `am_onyx` | 1.7 s |
| `assets/audio/voice/hoard/guards_guards.ogg` | Guards! Guards! | `am_onyx` | 1.3 s |
| `assets/audio/voice/hoard/stop_thief.ogg` | Stop, thief! | `am_onyx` | 1.1 s |
| `assets/audio/voice/hoard/whats_all_this_racket.ogg` | What's all this racket? | `am_onyx` | 1.4 s |
| `assets/audio/voice/hoard/come_out_i_know_youre_here.ogg` | Come out! I know you're here! | `am_onyx` | 1.7 s |
| `assets/audio/voice/hoard/where_did_they_go.ogg` | Where did they go? | `am_onyx` | 1.2 s |
| `assets/audio/voice/hoard/hmph_nerves.ogg` | Hmph. Nerves. (read as "Humph. Nerves.") | `am_onyx` | 1.1 s |
| `assets/audio/voice/hoard/pells_been_at_the_brandy_again.ogg` | Pell's been at the brandy again. | `am_onyx` | 2.0 s |
| `assets/audio/voice/hoard/got_you_out_out.ogg` | Got you! Out! OUT! | `am_onyx` | 1.4 s |
| `assets/audio/voice/hoard/duke_hush.ogg` | Duke! Hush! | `am_onyx` | 1.0 s |
| `assets/audio/voice/hoard/wha_i_was_resting_my_eyes.ogg` | Wha...? I was resting my eyes. | `am_onyx` | 2.2 s |
| `assets/audio/voice/hoard/pell_more_pudding.ogg` | Pell! More pudding! | `am_onyx` | 1.3 s |
| `assets/audio/voice/hoard/other_peoples_books_my_favourite_kind.ogg` | Other people's books. My favourite kind. | `am_onyx` | 2.5 s |
| `assets/audio/voice/hoard/hello_my_lovelies_all_mine.ogg` | Hello, my lovelies. All mine. | `am_onyx` | 2.0 s |
| `assets/audio/voice/hoard/bedtime_for_the_richest_man_in_kettleford.ogg` | Bedtime for the richest man in Kettleford. | `am_onyx` | 2.6 s |
| `assets/audio/voice/hoard/cant_sleep_a_midnight_snack_i_think.ogg` | Can't sleep. A midnight snack, I think. | `am_onyx` | 2.7 s |
| `assets/audio/voice/hoard/my_key_wheres_my_key_pell.ogg` | My key! Where's my key? PELL! | `am_onyx` | 2.0 s |
| `assets/audio/voice/museum_head_waiter/was_that_a_tray_who_dropped_a_tray.ogg` | Was that a tray? Who dropped a tray? | `bm_fable` | 2.6 s |
| `assets/audio/voice/museum_head_waiter/and_who_might_you_be.ogg` | And who might you be? | `bm_fable` | 1.8 s |
| `assets/audio/voice/museum_head_waiter/youre_not_one_of_mine_ron.ogg` | You're not one of mine! Ron! | `bm_fable` | 2.2 s |
| `assets/audio/voice/museum_head_waiter/whats_the_commotion.ogg` | What's the commotion? | `bm_fable` | 1.7 s |
| `assets/audio/voice/museum_head_waiter/wheres_that_scoundrel_got_to.ogg` | Where's that scoundrel got to? | `bm_fable` | 2.4 s |
| `assets/audio/voice/museum_head_waiter/back_to_work_everyone.ogg` | Back to work, everyone. | `bm_fable` | 1.9 s |
| `assets/audio/voice/museum_head_waiter/out_now_and_give_back_the_jacket.ogg` | Out. Now. And give back the jacket. | `bm_fable` | 2.7 s |
| `assets/audio/voice/museum_head_waiter/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `bm_fable` | 2.1 s |
| `assets/audio/voice/museum_head_waiter/im_awake_the_canap_s_are_fine.ogg` | I'm awake! The canapés are fine! | `bm_fable` | 2.0 s |
| `assets/audio/voice/museum_head_waiter/trays_up_chins_up.ogg` | Trays up, chins up. | `bm_fable` | 2.0 s |
| `assets/audio/voice/museum_head_waiter/mind_the_trebuchet_with_that_tray.ogg` | Mind the trebuchet with that tray. | `bm_fable` | 2.4 s |
| `assets/audio/voice/museum_head_waiter/whos_been_at_the_vol_au_vents.ogg` | Who's been at the vol-au-vents? | `bm_fable` | 2.2 s |
| `assets/audio/voice/museum_head_waiter/you_there_wheres_your_tray.ogg` | You there! Where's your tray? | `bm_fable` | 2.0 s |
| `assets/audio/voice/museum_head_waiter/idle_hands_get_a_tray_from_the_kitchen.ogg` | Idle hands! Get a tray from the kitchen. | `bm_fable` | 3.0 s |
| `assets/audio/voice/museum_curator/did_something_just_fall_over.ogg` | Did something just fall over? | `bf_alice` | 1.8 s |
| `assets/audio/voice/museum_curator/excuse_me_can_i_help_you.ogg` | Excuse me, can I help you? | `bf_alice` | 1.7 s |
| `assets/audio/voice/museum_curator/thief_someone_call_ron.ogg` | Thief! Someone call Ron! | `bf_alice` | 1.7 s |
| `assets/audio/voice/museum_curator/whats_going_on.ogg` | What's going on? | `bf_alice` | 1.2 s |
| `assets/audio/voice/museum_curator/they_went_that_way_i_think.ogg` | They went that way! I think. | `bf_alice` | 1.8 s |
| `assets/audio/voice/museum_curator/i_need_a_sit_down.ogg` | I need a sit down. | `bf_alice` | 1.4 s |
| `assets/audio/voice/museum_curator/caught_you_out_you_go.ogg` | Caught you! Out you go. | `bf_alice` | 1.5 s |
| `assets/audio/voice/museum_curator/the_alarm_my_exhibits.ogg` | The alarm! My exhibits! | `bf_alice` | 1.6 s |
| `assets/audio/voice/museum_curator/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `bf_alice` | 1.8 s |
| `assets/audio/voice/museum_curator/oh_was_i_asleep_how_embarrassing.ogg` | Oh! Was I asleep? How embarrassing. | `bf_alice` | 2.1 s |
| `assets/audio/voice/museum_curator/please_dont_touch_the_trebuchet.ogg` | Please don't touch the trebuchet. | `bf_alice` | 1.9 s |
| `assets/audio/voice/museum_curator/the_founder_on_loan_indefinitely.ogg` | The founder. On loan. Indefinitely. | `bf_alice` | 2.2 s |
| `assets/audio/voice/museum_curator/the_stone_head_from_the_village_green_dont_ask.ogg` | The Stone Head. From the village green. Don't ask. | `bf_alice` | 2.9 s |
| `assets/audio/voice/museum_curator/now_where_did_i_put_my_keys.ogg` | Now where did I put my keys? | `bf_alice` | 1.9 s |
| `assets/audio/voice/museum_curator/oh_thank_you_i_need_this.ogg` | Oh, thank you. I need this. | `bf_alice` | 1.8 s |
| `assets/audio/voice/museum_guard/what_was_that.ogg` | What was that? | `am_liam` | 1.1 s |
| `assets/audio/voice/museum_guard/hello_whos_that.ogg` | Hello? Who's that? | `am_liam` | 1.3 s |
| `assets/audio/voice/museum_guard/oi_stop_museum_security.ogg` | Oi! Stop! Museum security! | `am_liam` | 1.9 s |
| `assets/audio/voice/museum_guard/whats_going_on.ogg` | What's going on? | `am_liam` | 1.2 s |
| `assets/audio/voice/museum_guard/come_out_i_know_youre_here.ogg` | Come out, I know you're here. | `am_liam` | 1.6 s |
| `assets/audio/voice/museum_guard/mustve_been_a_guest_they_all_look_the_same_in_a.ogg` | Must've been a guest. They all look the same in a bow tie. | `am_liam` | 2.9 s |
| `assets/audio/voice/museum_guard/got_you_out_you_go_sunshine.ogg` | Got you! Out you go, sunshine. | `am_liam` | 1.9 s |
| `assets/audio/voice/museum_guard/not_the_fuses_again.ogg` | Not the fuses again! | `am_liam` | 1.5 s |
| `assets/audio/voice/museum_guard/there_lights.ogg` | There. Lights! | `am_liam` | 1.0 s |
| `assets/audio/voice/museum_guard/the_alarm_the_statue.ogg` | The alarm! The statue! | `am_liam` | 1.6 s |
| `assets/audio/voice/museum_guard/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `am_liam` | 1.7 s |
| `assets/audio/voice/museum_guard/wha_i_was_just_resting_my_eyes.ogg` | Wha...? I was just resting my eyes. | `am_liam` | 2.0 s |
| `assets/audio/voice/museum_guard/quiet_night_lovely.ogg` | Quiet night. Lovely. | `am_liam` | 1.4 s |
| `assets/audio/voice/museum_guard/still_there_good.ogg` | Still there. Good. | `am_liam` | 1.3 s |
| `assets/audio/voice/museum_guard/any_sausage_rolls_going_spare.ogg` | Any sausage rolls going spare? | `am_liam` | 2.0 s |
| `assets/audio/voice/museum_guest_a/did_you_hear_that.ogg` | Did you hear that? | `af_bella` | 0.9 s |
| `assets/audio/voice/museum_guest_a/what_was_that.ogg` | What was that? | `af_bella` | 0.7 s |
| `assets/audio/voice/museum_guest_a/im_sorry_have_we_met.ogg` | I'm sorry, have we met? | `af_bella` | 1.5 s |
| `assets/audio/voice/museum_guest_a/are_you_with_the_caterers.ogg` | Are you with the caterers? | `af_bella` | 1.2 s |
| `assets/audio/voice/museum_guest_a/a_burglar_in_a_museum.ogg` | A burglar! In a museum! | `af_bella` | 1.5 s |
| `assets/audio/voice/museum_guest_a/help_thief.ogg` | Help! Thief! | `af_bella` | 0.9 s |
| `assets/audio/voice/museum_guest_a/whats_going_on.ogg` | What's going on? | `af_bella` | 0.8 s |
| `assets/audio/voice/museum_guest_a/where_did_they_go.ogg` | Where did they go? | `af_bella` | 0.8 s |
| `assets/audio/voice/museum_guest_a/probably_a_waiter.ogg` | Probably a waiter. | `af_bella` | 1.0 s |
| `assets/audio/voice/museum_guest_a/must_have_been_the_mayor.ogg` | Must have been the Mayor. | `af_bella` | 1.1 s |
| `assets/audio/voice/museum_guest_a/got_you_somebody_fetch_ron.ogg` | Got you! Somebody fetch Ron! | `af_bella` | 1.8 s |
| `assets/audio/voice/museum_guest_a/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `af_bella` | 1.4 s |
| `assets/audio/voice/museum_guest_a/oh_i_must_have_nodded_off_lovely_party.ogg` | Oh! I must have nodded off. Lovely party. | `af_bella` | 2.4 s |
| `assets/audio/voice/museum_guest_a/did_you_see_the_guard_tap_in_his_door_code_oh_ni.ogg` | Did you see the guard tap in his door code? Oh nine one two. | `af_bella` | 3.4 s |
| `assets/audio/voice/museum_guest_a/i_havent_seen_a_waiter_in_ages_im_parched.ogg` | I haven't seen a waiter in ages. I'm parched. | `af_bella` | 2.6 s |
| `assets/audio/voice/museum_guest_a/hoard_showed_me_the_cameras_the_pirate_gallery_o.ogg` | Hoard showed me the cameras. The pirate gallery one's been broken for weeks. | `af_bella` | 4.1 s |
| `assets/audio/voice/museum_guest_a/ooh_waiter_over_here.ogg` | Ooh, waiter! Over here! | `af_bella` | 1.4 s |
| `assets/audio/voice/museum_guest_a/oh_lovely_thank_you.ogg` | Oh, lovely. Thank you! | `af_bella` | 1.4 s |
| `assets/audio/voice/museum_guest_a/ooh_is_this_part_of_the_show.ogg` | Ooh! Is this part of the show? | `af_bella` | 1.6 s |
| `assets/audio/voice/museum_guest_b/did_you_hear_that.ogg` | Did you hear that? | `am_echo` | 1.3 s |
| `assets/audio/voice/museum_guest_b/what_was_that.ogg` | What was that? | `am_echo` | 1.1 s |
| `assets/audio/voice/museum_guest_b/im_sorry_have_we_met.ogg` | I'm sorry, have we met? | `am_echo` | 1.7 s |
| `assets/audio/voice/museum_guest_b/are_you_with_the_caterers.ogg` | Are you with the caterers? | `am_echo` | 1.7 s |
| `assets/audio/voice/museum_guest_b/a_burglar_in_a_museum.ogg` | A burglar! In a museum! | `am_echo` | 1.8 s |
| `assets/audio/voice/museum_guest_b/help_thief.ogg` | Help! Thief! | `am_echo` | 1.1 s |
| `assets/audio/voice/museum_guest_b/whats_going_on.ogg` | What's going on? | `am_echo` | 1.2 s |
| `assets/audio/voice/museum_guest_b/where_did_they_go.ogg` | Where did they go? | `am_echo` | 1.2 s |
| `assets/audio/voice/museum_guest_b/probably_a_waiter.ogg` | Probably a waiter. | `am_echo` | 1.3 s |
| `assets/audio/voice/museum_guest_b/must_have_been_the_mayor.ogg` | Must have been the Mayor. | `am_echo` | 1.5 s |
| `assets/audio/voice/museum_guest_b/got_you_somebody_fetch_ron.ogg` | Got you! Somebody fetch Ron! | `am_echo` | 2.0 s |
| `assets/audio/voice/museum_guest_b/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `am_echo` | 1.8 s |
| `assets/audio/voice/museum_guest_b/oh_i_must_have_nodded_off_lovely_party.ogg` | Oh! I must have nodded off. Lovely party. | `am_echo` | 2.8 s |
| `assets/audio/voice/museum_guest_b/his_birthday_he_told_me_ninth_of_december_bless.ogg` | His birthday, he told me. Ninth of December. Bless him. | `am_echo` | 3.4 s |
| `assets/audio/voice/museum_guest_b/the_caterers_two_short_tonight_anyone_in_a_jacke.ogg` | The caterer's two short tonight. Anyone in a jacket with a tray would do. | `am_echo` | 4.2 s |
| `assets/audio/voice/museum_guest_b/and_he_wont_pay_to_fix_it_typical.ogg` | And he won't pay to fix it. Typical. | `am_echo` | 2.3 s |
| `assets/audio/voice/museum_guest_b/is_that_champagne_splendid.ogg` | Is that champagne? Splendid. | `am_echo` | 2.0 s |
| `assets/audio/voice/museum_guest_b/much_obliged.ogg` | Much obliged. | `am_echo` | 1.2 s |
| `assets/audio/voice/museum_guest_b/ooh_is_this_part_of_the_show.ogg` | Ooh! Is this part of the show? | `am_echo` | 1.9 s |
| `assets/audio/voice/museum_crumb/did_you_hear_that.ogg` | Did you hear that? | `af_heart` | 0.9 s |
| `assets/audio/voice/museum_crumb/what_was_that.ogg` | What was that? | `af_heart` | 0.8 s |
| `assets/audio/voice/museum_crumb/im_sorry_have_we_met.ogg` | I'm sorry, have we met? | `af_heart` | 1.4 s |
| `assets/audio/voice/museum_crumb/are_you_with_the_caterers.ogg` | Are you with the caterers? | `af_heart` | 1.4 s |
| `assets/audio/voice/museum_crumb/a_burglar_in_a_museum.ogg` | A burglar! In a museum! | `af_heart` | 1.4 s |
| `assets/audio/voice/museum_crumb/help_thief.ogg` | Help! Thief! | `af_heart` | 0.9 s |
| `assets/audio/voice/museum_crumb/whats_going_on.ogg` | What's going on? | `af_heart` | 1.0 s |
| `assets/audio/voice/museum_crumb/where_did_they_go.ogg` | Where did they go? | `af_heart` | 1.0 s |
| `assets/audio/voice/museum_crumb/probably_a_waiter.ogg` | Probably a waiter. | `af_heart` | 1.1 s |
| `assets/audio/voice/museum_crumb/must_have_been_the_mayor.ogg` | Must have been the Mayor. | `af_heart` | 1.2 s |
| `assets/audio/voice/museum_crumb/got_you_somebody_fetch_ron.ogg` | Got you! Somebody fetch Ron! | `af_heart` | 1.8 s |
| `assets/audio/voice/museum_crumb/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `af_heart` | 1.5 s |
| `assets/audio/voice/museum_crumb/oh_i_must_have_nodded_off_lovely_party.ogg` | Oh! I must have nodded off. Lovely party. | `af_heart` | 2.5 s |
| `assets/audio/voice/museum_crumb/the_curator_left_her_handbag_in_the_cloakroom_ke.ogg` | The curator left her handbag in the cloakroom. Keys and all! | `af_heart` | 3.3 s |
| `assets/audio/voice/museum_crumb/they_say_the_skylight_over_the_statue_doesnt_eve.ogg` | They say the skylight over the statue doesn't even lock. | `af_heart` | 3.2 s |
| `assets/audio/voice/museum_crumb/hoards_toast_is_the_big_moment_everyone_has_to_b.ogg` | Hoard's toast is the big moment. Everyone has to be in the hall. | `af_heart` | 3.6 s |
| `assets/audio/voice/museum_crumb/waiter_bring_that_tray_here_at_once.ogg` | Waiter! Bring that tray here at once. | `af_heart` | 2.0 s |
| `assets/audio/voice/museum_crumb/how_kind_thank_you.ogg` | How kind. Thank you. | `af_heart` | 1.3 s |
| `assets/audio/voice/museum_crumb/ooh_is_this_part_of_the_show.ogg` | Ooh! Is this part of the show? | `af_heart` | 1.5 s |
| `assets/audio/voice/museum_snapper/did_you_hear_that.ogg` | Did you hear that? | `am_puck` | 0.8 s |
| `assets/audio/voice/museum_snapper/what_was_that.ogg` | What was that? | `am_puck` | 0.8 s |
| `assets/audio/voice/museum_snapper/im_sorry_have_we_met.ogg` | I'm sorry, have we met? | `am_puck` | 1.1 s |
| `assets/audio/voice/museum_snapper/are_you_with_the_caterers.ogg` | Are you with the caterers? | `am_puck` | 1.1 s |
| `assets/audio/voice/museum_snapper/a_burglar_in_a_museum.ogg` | A burglar! In a museum! | `am_puck` | 1.2 s |
| `assets/audio/voice/museum_snapper/help_thief.ogg` | Help! Thief! | `am_puck` | 0.8 s |
| `assets/audio/voice/museum_snapper/whats_going_on.ogg` | What's going on? | `am_puck` | 0.8 s |
| `assets/audio/voice/museum_snapper/where_did_they_go.ogg` | Where did they go? | `am_puck` | 0.8 s |
| `assets/audio/voice/museum_snapper/probably_a_waiter.ogg` | Probably a waiter. | `am_puck` | 0.9 s |
| `assets/audio/voice/museum_snapper/must_have_been_the_mayor.ogg` | Must have been the Mayor. | `am_puck` | 0.9 s |
| `assets/audio/voice/museum_snapper/got_you_somebody_fetch_ron.ogg` | Got you! Somebody fetch Ron! | `am_puck` | 1.4 s |
| `assets/audio/voice/museum_snapper/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `am_puck` | 1.2 s |
| `assets/audio/voice/museum_snapper/oh_i_must_have_nodded_off_lovely_party.ogg` | Oh! I must have nodded off. Lovely party. | `am_puck` | 1.8 s |
| `assets/audio/voice/museum_snapper/smile_everyone.ogg` | Smile, everyone! | `am_puck` | 1.0 s |
| `assets/audio/voice/museum_snapper/lovely_one_more.ogg` | Lovely. One more. | `am_puck` | 0.9 s |
| `assets/audio/voice/museum_snapper/say_cheese.ogg` | Say cheese! | `am_puck` | 0.8 s |
| `assets/audio/voice/museum_snapper/everybody_look_up_at_mr_hoard.ogg` | Everybody look up at Mr Hoard! | `am_puck` | 1.6 s |
| `assets/audio/voice/museum_snapper/over_here_waiter.ogg` | Over here, waiter! | `am_puck` | 0.9 s |
| `assets/audio/voice/museum_snapper/ta_very_much.ogg` | Ta very much. | `am_puck` | 0.9 s |
| `assets/audio/voice/museum_snapper/ooh_is_this_part_of_the_show.ogg` | Ooh! Is this part of the show? | `am_puck` | 1.2 s |
| `assets/audio/voice/museum_violinist/did_you_hear_that.ogg` | Did you hear that? | `af_sky` | 1.2 s |
| `assets/audio/voice/museum_violinist/what_was_that.ogg` | What was that? | `af_sky` | 1.0 s |
| `assets/audio/voice/museum_violinist/im_sorry_have_we_met.ogg` | I'm sorry, have we met? | `af_sky` | 1.6 s |
| `assets/audio/voice/museum_violinist/are_you_with_the_caterers.ogg` | Are you with the caterers? | `af_sky` | 1.6 s |
| `assets/audio/voice/museum_violinist/a_burglar_in_a_museum.ogg` | A burglar! In a museum! | `af_sky` | 1.5 s |
| `assets/audio/voice/museum_violinist/help_thief.ogg` | Help! Thief! | `af_sky` | 1.0 s |
| `assets/audio/voice/museum_violinist/whats_going_on.ogg` | What's going on? | `af_sky` | 1.2 s |
| `assets/audio/voice/museum_violinist/where_did_they_go.ogg` | Where did they go? | `af_sky` | 1.2 s |
| `assets/audio/voice/museum_violinist/probably_a_waiter.ogg` | Probably a waiter. | `af_sky` | 1.3 s |
| `assets/audio/voice/museum_violinist/must_have_been_the_mayor.ogg` | Must have been the Mayor. | `af_sky` | 1.3 s |
| `assets/audio/voice/museum_violinist/got_you_somebody_fetch_ron.ogg` | Got you! Somebody fetch Ron! | `af_sky` | 1.9 s |
| `assets/audio/voice/museum_violinist/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `af_sky` | 1.6 s |
| `assets/audio/voice/museum_violinist/oh_i_must_have_nodded_off_lovely_party.ogg` | Oh! I must have nodded off. Lovely party. | `af_sky` | 2.6 s |
| `assets/audio/voice/museum_violinist/a_sea_shanty_at_a_gala.ogg` | A sea shanty? At a gala? | `af_sky` | 1.8 s |
| `assets/audio/voice/museum_cellist/did_you_hear_that.ogg` | Did you hear that? | `bm_lewis` | 1.1 s |
| `assets/audio/voice/museum_cellist/what_was_that.ogg` | What was that? | `bm_lewis` | 1.1 s |
| `assets/audio/voice/museum_cellist/im_sorry_have_we_met.ogg` | I'm sorry, have we met? | `bm_lewis` | 1.6 s |
| `assets/audio/voice/museum_cellist/are_you_with_the_caterers.ogg` | Are you with the caterers? | `bm_lewis` | 1.6 s |
| `assets/audio/voice/museum_cellist/a_burglar_in_a_museum.ogg` | A burglar! In a museum! | `bm_lewis` | 1.7 s |
| `assets/audio/voice/museum_cellist/help_thief.ogg` | Help! Thief! | `bm_lewis` | 0.9 s |
| `assets/audio/voice/museum_cellist/whats_going_on.ogg` | What's going on? | `bm_lewis` | 1.1 s |
| `assets/audio/voice/museum_cellist/where_did_they_go.ogg` | Where did they go? | `bm_lewis` | 1.2 s |
| `assets/audio/voice/museum_cellist/probably_a_waiter.ogg` | Probably a waiter. | `bm_lewis` | 1.2 s |
| `assets/audio/voice/museum_cellist/must_have_been_the_mayor.ogg` | Must have been the Mayor. | `bm_lewis` | 1.3 s |
| `assets/audio/voice/museum_cellist/got_you_somebody_fetch_ron.ogg` | Got you! Somebody fetch Ron! | `bm_lewis` | 1.8 s |
| `assets/audio/voice/museum_cellist/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `bm_lewis` | 1.7 s |
| `assets/audio/voice/museum_cellist/oh_i_must_have_nodded_off_lovely_party.ogg` | Oh! I must have nodded off. Lovely party. | `bm_lewis` | 2.8 s |
| `assets/audio/voice/museum_cellist/ooh_i_love_this_one.ogg` | Ooh, I love this one! | `bm_lewis` | 1.4 s |
| `assets/audio/voice/museum_cook/whos_banging_about.ogg` | Who's banging about? | `af_nicole` | 1.3 s |
| `assets/audio/voice/museum_cook/oi_no_guests_in_my_kitchen.ogg` | Oi! No guests in my kitchen! | `af_nicole` | 2.1 s |
| `assets/audio/voice/museum_cook/out_of_my_kitchen_thief.ogg` | Out of my kitchen! Thief! | `af_nicole` | 1.6 s |
| `assets/audio/voice/museum_cook/whats_going_on.ogg` | What's going on? | `af_nicole` | 1.1 s |
| `assets/audio/voice/museum_cook/where_did_they_go.ogg` | Where did they go? | `af_nicole` | 1.1 s |
| `assets/audio/voice/museum_cook/i_know_youre_here.ogg` | I know you're here! | `af_nicole` | 1.1 s |
| `assets/audio/voice/museum_cook/back_to_the_vol_au_vents.ogg` | Back to the vol-au-vents. | `af_nicole` | 1.6 s |
| `assets/audio/voice/museum_cook/got_you_out_you_go.ogg` | Got you! Out you go. | `af_nicole` | 1.5 s |
| `assets/audio/voice/museum_cook/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `af_nicole` | 1.7 s |
| `assets/audio/voice/museum_cook/wha_must_have_dozed_off.ogg` | Wha...? Must have dozed off. | `af_nicole` | 1.7 s |
| `assets/audio/voice/museum_cook/who_wants_more_vol_au_vents.ogg` | Who wants more vol-au-vents? | `af_nicole` | 1.7 s |
| `assets/audio/voice/museum_cook/five_minutes_just_five_minutes.ogg` | Five minutes. Just five minutes. | `af_nicole` | 2.4 s |
| `assets/audio/voice/labs_guard_a/hm.ogg` | Hm? (read as "Hmm?") | `am_puck` | 0.5 s |
| `assets/audio/voice/labs_guard_a/what_was_that.ogg` | What was that? | `am_puck` | 0.8 s |
| `assets/audio/voice/labs_guard_a/hello.ogg` | Hello? | `am_puck` | 0.6 s |
| `assets/audio/voice/labs_guard_a/hm_whos_there.ogg` | Hm? Who's there? (read as "Hmm? Who's there?") | `am_puck` | 0.8 s |
| `assets/audio/voice/labs_guard_a/oi_the_labs_closed.ogg` | Oi! The lab's closed! | `am_puck` | 1.1 s |
| `assets/audio/voice/labs_guard_a/stop_right_there.ogg` | Stop right there! | `am_puck` | 0.9 s |
| `assets/audio/voice/labs_guard_a/intruder.ogg` | Intruder! | `am_puck` | 0.7 s |
| `assets/audio/voice/labs_guard_a/whats_going_on.ogg` | What's going on? | `am_puck` | 0.8 s |
| `assets/audio/voice/labs_guard_a/whered_they_go.ogg` | Where'd they go? | `am_puck` | 0.8 s |
| `assets/audio/voice/labs_guard_a/i_know_youre_in_here.ogg` | I know you're in here. | `am_puck` | 0.9 s |
| `assets/audio/voice/labs_guard_a/must_be_the_air_con.ogg` | Must be the air con. | `am_puck` | 1.1 s |
| `assets/audio/voice/labs_guard_a/just_the_building_settling.ogg` | Just the building settling. | `am_puck` | 1.3 s |
| `assets/audio/voice/labs_guard_a/pigeons_probably.ogg` | Pigeons, probably. | `am_puck` | 1.1 s |
| `assets/audio/voice/labs_guard_a/out_you_go_visiting_hours_are_over.ogg` | Out you go. Visiting hours are over. | `am_puck` | 1.9 s |
| `assets/audio/voice/labs_guard_a/lights_hang_on_ill_get_the_breaker.ogg` | Lights! Hang on, I'll get the breaker. | `am_puck` | 1.7 s |
| `assets/audio/voice/labs_guard_a/there_let_there_be_light.ogg` | There. Let there be light. | `am_puck` | 1.1 s |
| `assets/audio/voice/labs_guard_a/the_alarm_im_on_it.ogg` | The alarm! I'm on it! | `am_puck` | 1.2 s |
| `assets/audio/voice/labs_guard_a/someones_in.ogg` | Someone's in! | `am_puck` | 0.7 s |
| `assets/audio/voice/labs_guard_a/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `am_puck` | 1.3 s |
| `assets/audio/voice/labs_guard_a/wha_was_i_asleep_dont_tell_marsh.ogg` | Wha...? Was I asleep? Don't tell Marsh. | `am_puck` | 1.8 s |
| `assets/audio/voice/labs_guard_a/quiet_night_love_a_quiet_night.ogg` | Quiet night. Love a quiet night. | `am_puck` | 1.6 s |
| `assets/audio/voice/labs_guard_a/still_there_still_a_rocket.ogg` | Still there. Still a rocket. | `am_puck` | 1.3 s |
| `assets/audio/voice/labs_guard_a/anything_on_the_cameras_marsh.ogg` | Anything on the cameras, Marsh? | `am_puck` | 1.5 s |
| `assets/audio/voice/labs_guard_a/ooh_someone_made_coffee_dont_mind_if_i_do.ogg` | Ooh, someone made coffee. Don't mind if I do. | `am_puck` | 2.2 s |
| `assets/audio/voice/labs_guard_b/hm.ogg` | Hm? (read as "Hmm?") | `af_river` | 0.7 s |
| `assets/audio/voice/labs_guard_b/what_was_that.ogg` | What was that? | `af_river` | 1.1 s |
| `assets/audio/voice/labs_guard_b/hello.ogg` | Hello? | `af_river` | 0.9 s |
| `assets/audio/voice/labs_guard_b/hm_whos_there.ogg` | Hm? Who's there? (read as "Hmm? Who's there?") | `af_river` | 1.2 s |
| `assets/audio/voice/labs_guard_b/hey_you.ogg` | Hey! You! | `af_river` | 1.1 s |
| `assets/audio/voice/labs_guard_b/oh_for_stop.ogg` | Oh, for... stop! | `af_river` | 1.3 s |
| `assets/audio/voice/labs_guard_b/intruder.ogg` | Intruder! | `af_river` | 1.0 s |
| `assets/audio/voice/labs_guard_b/whats_going_on.ogg` | What's going on? | `af_river` | 1.3 s |
| `assets/audio/voice/labs_guard_b/whered_they_go.ogg` | Where'd they go? | `af_river` | 1.2 s |
| `assets/audio/voice/labs_guard_b/i_know_youre_in_here.ogg` | I know you're in here. | `af_river` | 1.3 s |
| `assets/audio/voice/labs_guard_b/must_be_the_air_con.ogg` | Must be the air con. | `af_river` | 1.4 s |
| `assets/audio/voice/labs_guard_b/just_the_building_settling.ogg` | Just the building settling. | `af_river` | 1.6 s |
| `assets/audio/voice/labs_guard_b/pigeons_probably.ogg` | Pigeons, probably. | `af_river` | 1.5 s |
| `assets/audio/voice/labs_guard_b/out_you_go_visiting_hours_are_over.ogg` | Out you go. Visiting hours are over. | `af_river` | 2.3 s |
| `assets/audio/voice/labs_guard_b/the_alarm_im_on_it.ogg` | The alarm! I'm on it! | `af_river` | 1.6 s |
| `assets/audio/voice/labs_guard_b/someones_in.ogg` | Someone's in! | `af_river` | 1.1 s |
| `assets/audio/voice/labs_guard_b/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `af_river` | 1.8 s |
| `assets/audio/voice/labs_guard_b/mm_i_was_resting_my_eyes.ogg` | Mm? I was resting my eyes. | `af_river` | 2.1 s |
| `assets/audio/voice/labs_guard_b/car_parks_empty_like_my_social_life.ogg` | Car park's empty. Like my social life. | `af_river` | 2.5 s |
| `assets/audio/voice/labs_guard_b/goods_in_goods_still_in.ogg` | Goods in. Goods still in. | `af_river` | 1.8 s |
| `assets/audio/voice/labs_guard_b/pigeons_again.ogg` | Pigeons again? | `af_river` | 1.3 s |
| `assets/audio/voice/labs_scientist/hello_briggs_is_that_you.ogg` | Hello? Briggs, is that you? | `bf_lily` | 1.9 s |
| `assets/audio/voice/labs_scientist/what_was_that.ogg` | What was that? | `bf_lily` | 1.2 s |
| `assets/audio/voice/labs_scientist/hm.ogg` | Hm? (read as "Hmm?") | `bf_lily` | 0.8 s |
| `assets/audio/voice/labs_scientist/whos_that_youre_not_on_my_team.ogg` | Who's that? You're not on my team. | `bf_lily` | 2.1 s |
| `assets/audio/voice/labs_scientist/security_someones_in_the_labs.ogg` | Security! Someone's in the labs! | `bf_lily` | 2.2 s |
| `assets/audio/voice/labs_scientist/who_are_you.ogg` | Who are you? | `bf_lily` | 1.2 s |
| `assets/audio/voice/labs_scientist/whats_all_the_fuss.ogg` | What's all the fuss? | `bf_lily` | 1.4 s |
| `assets/audio/voice/labs_scientist/where_did_they_go.ogg` | Where did they go? | `bf_lily` | 1.5 s |
| `assets/audio/voice/labs_scientist/im_imagining_things_too_much_coffee.ogg` | I'm imagining things. Too much coffee. | `bf_lily` | 2.4 s |
| `assets/audio/voice/labs_scientist/probably_the_centrifuge.ogg` | Probably the centrifuge. | `bf_lily` | 1.8 s |
| `assets/audio/voice/labs_scientist/right_out_this_is_a_laboratory.ogg` | Right. Out. This is a laboratory. | `bf_lily` | 2.1 s |
| `assets/audio/voice/labs_scientist/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `bf_lily` | 1.9 s |
| `assets/audio/voice/labs_scientist/oh_did_i_fall_asleep_in_the_lab_again.ogg` | Oh! Did I fall asleep in the lab again? | `bf_lily` | 2.4 s |
| `assets/audio/voice/labs_scientist/if_mr_hoard_says_improve_one_more_time.ogg` | If Mr Hoard says "improve" one more time... | `bf_lily` | 2.7 s |
| `assets/audio/voice/labs_scientist/one_nine_five_seven_sputnik_year_server_room_don.ogg` | One, nine, five, seven. Sputnik year. Server room. Don't forget, Lily. | `bf_lily` | 3.8 s |
| `assets/audio/voice/labs_scientist/coffee_then_science_then_more_coffee.ogg` | Coffee. Then science. Then more coffee. | `bf_lily` | 2.1 s |
| `assets/audio/voice/labs_scientist/clean_rooms_clean_good_clean_room.ogg` | Clean room's clean. Good clean room. | `bf_lily` | 2.2 s |
| `assets/audio/voice/labs_scientist/ooh_someone_made_coffee_dont_mind_if_i_do.ogg` | Ooh, someone made coffee. Don't mind if I do. | `bf_lily` | 2.6 s |
| `assets/audio/voice/labs_officer/hm_whos_there.ogg` | Hm? Who's there? (read as "Hmm? Who's there?") | `af_sky` | 1.1 s |
| `assets/audio/voice/labs_officer/what_was_that.ogg` | What was that? | `af_sky` | 1.0 s |
| `assets/audio/voice/labs_officer/is_someone_out_there.ogg` | Is someone out there? | `af_sky` | 1.4 s |
| `assets/audio/voice/labs_officer/intruder_briggs_rook.ogg` | Intruder! Briggs! Rook! | `af_sky` | 1.6 s |
| `assets/audio/voice/labs_officer/i_can_see_you_you_know.ogg` | I can see you, you know! | `af_sky` | 1.4 s |
| `assets/audio/voice/labs_officer/whats_going_on.ogg` | What's going on? | `af_sky` | 1.2 s |
| `assets/audio/voice/labs_officer/theyve_gone_off_camera.ogg` | They've gone off camera. | `af_sky` | 1.4 s |
| `assets/audio/voice/labs_officer/nothing_on_the_monitors.ogg` | Nothing on the monitors. | `af_sky` | 1.5 s |
| `assets/audio/voice/labs_officer/back_to_the_screens_then.ogg` | Back to the screens, then. | `af_sky` | 1.5 s |
| `assets/audio/voice/labs_officer/gotcha_out_you_go.ogg` | Gotcha. Out you go. | `af_sky` | 1.5 s |
| `assets/audio/voice/labs_officer/whats_that_dog_barking_at.ogg` | What's that dog barking at? | `af_sky` | 1.6 s |
| `assets/audio/voice/labs_officer/huh_i_wasnt_asleep_i_was_monitoring.ogg` | Huh? I wasn't asleep. I was monitoring. | `af_sky` | 2.4 s |
| `assets/audio/voice/labs_officer/right_where_was_i.ogg` | Right. Where was I? | `af_sky` | 1.2 s |
| `assets/audio/voice/labs_officer/tea_time_the_cameras_can_watch_themselves_for_fi.ogg` | Tea time. The cameras can watch themselves for five minutes. | `af_sky` | 3.3 s |
| `assets/audio/voice/labs_officer/whos_been_fiddling_with_my_switches.ogg` | Who's been fiddling with my switches? | `af_sky` | 2.0 s |
| `assets/audio/voice/labs_officer/got_you_on_camera_three_briggs_rook.ogg` | Got you on camera three! Briggs! Rook! | `af_sky` | 2.3 s |
| `assets/audio/voice/labs_officer/ooh_someone_made_coffee_dont_mind_if_i_do.ogg` | Ooh, someone made coffee. Don't mind if I do. | `af_sky` | 2.6 s |
| `assets/audio/voice/manor_pell/hm.ogg` | Hm? (read as "Hmm?") | `am_fenrir` | 0.5 s |
| `assets/audio/voice/manor_pell/is_someone_there.ogg` | Is someone there? | `am_fenrir` | 0.9 s |
| `assets/audio/voice/manor_pell/sir.ogg` | Sir? | `am_fenrir` | 0.5 s |
| `assets/audio/voice/manor_pell/and_who_might_you_be.ogg` | And who might you be? | `am_fenrir` | 1.1 s |
| `assets/audio/voice/manor_pell/intruder_guards.ogg` | Intruder! Guards! | `am_fenrir` | 1.0 s |
| `assets/audio/voice/manor_pell/i_think_not_stop_right_there.ogg` | I think not. Stop right there. | `am_fenrir` | 1.7 s |
| `assets/audio/voice/manor_pell/what_is_it_now.ogg` | What is it now? | `am_fenrir` | 0.9 s |
| `assets/audio/voice/manor_pell/ill_find_you_i_find_everything_in_this_house.ogg` | I'll find you. I find everything in this house. | `am_fenrir` | 2.5 s |
| `assets/audio/voice/manor_pell/mice_very_large_mice.ogg` | Mice. Very large mice. | `am_fenrir` | 1.5 s |
| `assets/audio/voice/manor_pell/nothing_as_usual.ogg` | Nothing. As usual. | `am_fenrir` | 1.2 s |
| `assets/audio/voice/manor_pell/this_way_out_if_you_please.ogg` | This way out, if you please. | `am_fenrir` | 1.5 s |
| `assets/audio/voice/manor_pell/coming.ogg` | Coming. | `am_fenrir` | 0.6 s |
| `assets/audio/voice/manor_pell/at_this_hour.ogg` | At this hour? | `am_fenrir` | 0.8 s |
| `assets/audio/voice/manor_pell/nobody_how_tiresome.ogg` | Nobody. How tiresome. | `am_fenrir` | 1.2 s |
| `assets/audio/voice/manor_pell/hello_hm.ogg` | Hello? ...Hm. (read as "Hello? ...Hmm.") | `am_fenrir` | 0.8 s |
| `assets/audio/voice/manor_pell/not_the_fuse_again.ogg` | Not the fuse again. | `am_fenrir` | 1.1 s |
| `assets/audio/voice/manor_pell/oh_splendid.ogg` | Oh, splendid. | `am_fenrir` | 0.9 s |
| `assets/audio/voice/manor_pell/light_youre_welcome_everyone.ogg` | Light. You're welcome, everyone. | `am_fenrir` | 1.5 s |
| `assets/audio/voice/manor_pell/the_alarm_coming_sir.ogg` | The alarm! Coming, sir! | `am_fenrir` | 1.3 s |
| `assets/audio/voice/manor_pell/duke_really.ogg` | Duke, really. | `am_fenrir` | 0.9 s |
| `assets/audio/voice/manor_pell/i_was_merely_resting_my_eyes.ogg` | I was merely resting my eyes. | `am_fenrir` | 1.6 s |
| `assets/audio/voice/manor_pell/more_gravy_sir.ogg` | More gravy, sir? | `am_fenrir` | 1.1 s |
| `assets/audio/voice/manor_pell/washing_up_again.ogg` | Washing up. Again. | `am_fenrir` | 1.0 s |
| `assets/audio/voice/manor_pell/silver_polished_alarm_on.ogg` | Silver polished. Alarm on. | `am_fenrir` | 1.6 s |
| `assets/audio/voice/manor_pell/back_door_locked.ogg` | Back door, locked. | `am_fenrir` | 1.0 s |
| `assets/audio/voice/manor_pell/front_door_locked.ogg` | Front door, locked. | `am_fenrir` | 1.0 s |
| `assets/audio/voice/manor_pell/someone_has_moved_the_poetry.ogg` | Someone has moved the poetry. | `am_fenrir` | 1.5 s |
| `assets/audio/voice/manor_pell/cellar_locked.ogg` | Cellar, locked. | `am_fenrir` | 0.9 s |
| `assets/audio/voice/manor_pell/feet_up_five_minutes.ogg` | Feet up. Five minutes. | `am_fenrir` | 1.2 s |
| `assets/audio/voice/manor_pell/who_turned_the_alarm_off.ogg` | Who turned the alarm off? | `am_fenrir` | 1.2 s |
| `assets/audio/voice/manor_pell/night_shift_come_in_wipe_your_boots.ogg` | Night shift? Come in. Wipe your boots. | `am_fenrir` | 1.9 s |
| `assets/audio/voice/manor_pell/there_is_only_one_butler_here_and_it_is_me.ogg` | There is only one butler here, and it is me. | `am_fenrir` | 2.5 s |
| `assets/audio/voice/manor_guard_a/who_goes_there.ogg` | Who goes there? | `am_adam` | 0.9 s |
| `assets/audio/voice/manor_guard_a/hello.ogg` | Hello? | `am_adam` | 0.7 s |
| `assets/audio/voice/manor_guard_a/duke_was_that_you.ogg` | Duke, was that you? | `am_adam` | 1.2 s |
| `assets/audio/voice/manor_guard_a/oi_whos_that.ogg` | Oi. Who's that? | `am_adam` | 1.0 s |
| `assets/audio/voice/manor_guard_a/stop_right_there.ogg` | Stop right there! | `am_adam` | 1.1 s |
| `assets/audio/voice/manor_guard_a/intruder_over_here.ogg` | Intruder! Over here! | `am_adam` | 1.3 s |
| `assets/audio/voice/manor_guard_a/whats_up.ogg` | What's up? | `am_adam` | 0.7 s |
| `assets/audio/voice/manor_guard_a/lost_them.ogg` | Lost them. | `am_adam` | 0.8 s |
| `assets/audio/voice/manor_guard_a/come_on_out_i_wont_bite.ogg` | Come on out, I won't bite. | `am_adam` | 1.5 s |
| `assets/audio/voice/manor_guard_a/probably_a_fox.ogg` | Probably a fox. | `am_adam` | 1.2 s |
| `assets/audio/voice/manor_guard_a/seeing_things_again.ogg` | Seeing things again. | `am_adam` | 1.2 s |
| `assets/audio/voice/manor_guard_a/got_you_off_you_go.ogg` | Got you. Off you go. | `am_adam` | 1.3 s |
| `assets/audio/voice/manor_guard_a/alarm_on_my_way.ogg` | Alarm! On my way! | `am_adam` | 1.4 s |
| `assets/audio/voice/manor_guard_a/whats_duke_barking_at.ogg` | What's Duke barking at? | `am_adam` | 1.3 s |
| `assets/audio/voice/manor_guard_a/huh_was_i_asleep_dont_tell_hoard.ogg` | Huh? Was I asleep? Don't tell Hoard. | `am_adam` | 2.1 s |
| `assets/audio/voice/manor_guard_a/gates_quiet.ogg` | Gate's quiet. | `am_adam` | 0.9 s |
| `assets/audio/voice/manor_guard_a/pell_says_hoard_leaves_his_vault_key_on_the_beds.ogg` | Pell says Hoard leaves his vault key on the bedside table. Then snores. | `am_adam` | 4.1 s |
| `assets/audio/voice/manor_guard_a/good_boy_duke_stay.ogg` | Good boy, Duke. Stay. | `am_adam` | 1.3 s |
| `assets/audio/voice/manor_guard_b/whos_there.ogg` | Who's there? | `af_kore` | 0.7 s |
| `assets/audio/voice/manor_guard_b/hello_o.ogg` | Hello-o? | `af_kore` | 0.7 s |
| `assets/audio/voice/manor_guard_b/ogden_is_that_you.ogg` | Ogden, is that you? | `af_kore` | 1.1 s |
| `assets/audio/voice/manor_guard_b/hang_on_whos_that.ogg` | Hang on. Who's that? | `af_kore` | 1.1 s |
| `assets/audio/voice/manor_guard_b/oi_stop.ogg` | Oi! Stop! | `af_kore` | 0.7 s |
| `assets/audio/voice/manor_guard_b/intruder_ogden.ogg` | Intruder! Ogden! | `af_kore` | 1.0 s |
| `assets/audio/voice/manor_guard_b/whats_going_on.ogg` | What's going on? | `af_kore` | 0.9 s |
| `assets/audio/voice/manor_guard_b/where_did_you_go.ogg` | Where did you go? | `af_kore` | 0.8 s |
| `assets/audio/voice/manor_guard_b/i_saw_you.ogg` | I saw you! | `af_kore` | 0.8 s |
| `assets/audio/voice/manor_guard_b/hedgehog_definitely_a_hedgehog.ogg` | Hedgehog. Definitely a hedgehog. | `af_kore` | 1.7 s |
| `assets/audio/voice/manor_guard_b/must_be_the_wind.ogg` | Must be the wind. | `af_kore` | 0.9 s |
| `assets/audio/voice/manor_guard_b/gotcha_out_you_go.ogg` | Gotcha! Out you go. | `af_kore` | 1.1 s |
| `assets/audio/voice/manor_guard_b/fuse_again_im_on_it.ogg` | Fuse again! I'm on it. | `af_kore` | 1.3 s |
| `assets/audio/voice/manor_guard_b/and_there_was_light.ogg` | And there was light! | `af_kore` | 0.9 s |
| `assets/audio/voice/manor_guard_b/alarm_coming.ogg` | Alarm! Coming! | `af_kore` | 0.9 s |
| `assets/audio/voice/manor_guard_b/duke_what_is_it.ogg` | Duke! What is it? | `af_kore` | 0.9 s |
| `assets/audio/voice/manor_guard_b/ow_who_threw_that.ogg` | Ow. Who threw that? | `af_kore` | 1.0 s |
| `assets/audio/voice/manor_guard_b/bins_thrilling.ogg` | Bins. Thrilling. | `af_kore` | 0.9 s |
| `assets/audio/voice/manor_guard_b/lovely_night_for_it_for_what_though.ogg` | Lovely night for it. For what, though? | `af_kore` | 1.8 s |
| `assets/audio/voice/manor_guard_b/hoards_prize_marrows_dont_touch.ogg` | Hoard's prize marrows. Don't touch. | `af_kore` | 1.8 s |

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
| `assets/audio/sfx/shop_bell.ogg` | a brass bell on a spring above a shop door jangling as the door opens | 32373 | 6 | 0.46 s | asked for 3 s; kept 1 sound of the take |
| `assets/audio/sfx/till_ding.ogg` | an old cash register drawer opening with a ding and a slide | 34476 | 6 | 1.17 s | asked for 2 s; kept 1 sound of the take |
| `assets/audio/sfx/bottle_machine.ogg` | a supermarket bottle return machine whirring and clattering empty bottles into a bin | 38638 | 6 | 3.99 s | asked for 4 s; last 0.5 s faded out |
| `assets/audio/sfx/cart_rattle.ogg` | a metal shopping cart pushed and nesting into a line of carts with a clattering clank | 69475 | 6 | 1.54 s | asked for 2 s; kept 1 sound of the take |
| `assets/audio/sfx/vent_crawl.ogg` | someone shuffling and crawling through a thin tin air duct, hollow metal bumps | 66236 | 6 | 3.02 s | asked for 3 s |
| `assets/audio/sfx/hatch_creak.ogg` | a heavy metal roof hatch creaking open on rusty hinges | 37878 | 6 | 0.61 s | asked for 3 s; kept 1 sound of the take |
| `assets/audio/sfx/line_start.ogg` | a factory bottling line motors spinning up and conveyors starting to rattle | 24092 | 6 | 3.99 s | asked for 4 s; last 0.5 s faded out |
| `assets/audio/sfx/line_stop.ogg` | factory machinery winding down to a stop, motors slowing, a last clunk | 33219 | 12 | 3.03 s | asked for 6 s; slowed to a stop over 2.5 s by the script (ThinkSound's takes kept running); take picked by hand: every take kept running at full speed, so a steady one is slowed to a stop |
| `assets/audio/sfx/crate_crash.ogg` | a wooden crate full of glass bottles falling and smashing on a concrete floor | 58807 | 6 | 2.05 s | asked for 3 s; kept 1 sound of the take |
| `assets/audio/sfx/crane_motor_loop.ogg` | an overhead factory gantry crane electric motor whining steadily as it moves, loopable | 3869 | 6 | 4.05 s | asked for 6 s; loop 0.74 to 4.79 s of the take, 0.50 s crossfade |
| `assets/audio/sfx/kettle_whistle.ogg` | a kettle on a stove coming to the boil and whistling | 83582 | 6 | 3.90 s | asked for 4 s; last 0.5 s faded out |
| `assets/audio/sfx/town_hall_bell.ogg` | a single deep bronze church bell toll from a tower, long ringing decay | 47179 | 12 | 5.99 s | asked for 6 s; kept 1 sound of the take |
| `assets/audio/sfx/coffee_machine.ogg` | an office coffee machine grinding beans then hissing and dripping coffee into a cup | 1195 | 6 | 3.99 s | asked for 4 s |
| `assets/audio/sfx/confetti_pop.ogg` | a big party popper confetti cannon bang followed by paper confetti fluttering down | 10535 | 6 | 2.80 s | asked for 3 s; kept 1 sound of the take |
| `assets/audio/sfx/gong.ogg` | a large gong struck once with a soft mallet, shimmering decay | 71809 | 12 | 5.99 s | asked for 6 s; kept 1 sound of the take |
| `assets/audio/sfx/glass_clink.ogg` | two champagne glasses clinking together in a toast | 4500 | 6 | 1.80 s | asked for 2 s; kept 1 sound of the take |
| `assets/audio/sfx/photo_flash.ogg` | an old camera shutter click with a flash bulb pop and whine | 14292 | 6 | 0.28 s | asked for 2 s; kept 1 sound of the take |

Kept synthesized (ThinkSound's takes were worse):

- `assets/audio/sfx/dog_whine.ogg`: ThinkSound's whines were steady tones; none of 24 takes rose clearly at the end, which is what makes it sound like a question.
- `assets/audio/sfx/doorbell.ogg`: none of 24 takes (this prompt and a more explicit one) was a clean two-tone chime: most held one tone, or rang several, or began mid-note.
