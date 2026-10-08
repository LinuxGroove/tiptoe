# Kenney audio picks for Tiptoe

Recommended files from Kenney's CC0 audio packs for the sounds `make_sfx.py` doesn't make. Paths are relative to `/home/claude/kenney-assets/Audio/`. Nobody has listened to these: the picks are based on file names, durations and a quick spectral check, so try them in the game before settling on them. Most of these files are mastered right up to 0 dBFS, which is louder than the synthesized set (-3 dBFS), so start them about 3 dB lower.

## Footsteps (5 variations per surface, play at random)

- Carpet: `Impact Sounds/Audio/footstep_carpet_000.ogg` to `footstep_carpet_004.ogg` (0.14 s)
- Grass: `Impact Sounds/Audio/footstep_grass_000.ogg` to `footstep_grass_004.ogg` (0.6 to 0.8 s, long rustle tails, so shorten them when running)
- Snow: `Impact Sounds/Audio/footstep_snow_000.ogg` to `footstep_snow_004.ogg` (0.37 s)
- Concrete: `Impact Sounds/Audio/footstep_concrete_000.ogg` to `footstep_concrete_004.ogg` (0.11 s)
- Wood: `Impact Sounds/Audio/footstep_wood_000.ogg` to `footstep_wood_004.ogg` (0.25 s)
- Extra for indoor floorboards: `RPG Audio/Audio/footstep00.ogg` to `footstep09.ogg`

## Doors and creaks

- Door open: `RPG Audio/Audio/doorOpen_1.ogg` (0.9 s), `RPG Audio/Audio/doorOpen_2.ogg` (1.4 s, slower)
- Door close: `RPG Audio/Audio/doorClose_1.ogg`, `doorClose_2.ogg`, `doorClose_3.ogg`, `doorClose_4.ogg` (0.6 to 0.7 s; `doorClose_4` is the dullest)
- Creaky door or floorboard: `RPG Audio/Audio/creak1.ogg` (0.66 s), `RPG Audio/Audio/creak2.ogg` (0.83 s), `RPG Audio/Audio/creak3.ogg` (0.34 s, good for a floorboard you step on)

## Drawers and cupboards

Kenney has no real drawer sound. These are the closest:

- Drawer slide and bump: `Foley Sounds/Audio/Rocks/stoneDragHit1.ogg`, `stoneDragHit2.ogg`, `stoneDragHit3.ogg` (about 1.1 s, stone dragging then a knock); pitch them up about 1.3 to 1.5 times and trim them. A recorded wooden drawer would be better.
- Cupboard door open: `RPG Audio/Audio/creak3.ogg`, pitched up a little
- Cupboard door shut: `RPG Audio/Audio/bookClose.ogg` (0.23 s), `RPG Audio/Audio/doorClose_4.ogg` pitched up
- Bumping a cupboard: `Impact Sounds/Audio/impactWood_light_000.ogg` to `impactWood_light_004.ogg`

## Latches and keys

- Latch: `RPG Audio/Audio/metalLatch.ogg` (0.26 s)
- Key turn or small mechanism: `RPG Audio/Audio/metalClick.ogg` (0.45 s)
- Keys jingling (picking up a key): `RPG Audio/Audio/handleCoins2.ogg` (0.34 s), `RPG Audio/Audio/beltHandle1.ogg` (0.28 s)

## Picking up and putting down

- Pick up (soft things): `RPG Audio/Audio/handleSmallLeather.ogg`, `RPG Audio/Audio/handleSmallLeather2.ogg` (about 0.3 s)
- Pick up (rustle): `RPG Audio/Audio/cloth2.ogg`, `RPG Audio/Audio/cloth4.ogg`
- Put down: `RPG Audio/Audio/bookPlace1.ogg`, `bookPlace2.ogg`, `bookPlace3.ogg` (about 0.3 s)
- Put down (light): `Impact Sounds/Audio/impactGeneric_light_000.ogg` to `impactGeneric_light_004.ogg` (0.14 s)
- Put down (soft): `Impact Sounds/Audio/impactSoft_medium_000.ogg` to `impactSoft_medium_004.ogg`
- Coins or small treasure: `RPG Audio/Audio/handleCoins.ogg` (0.85 s)

## Things knocked over

- Glass breaking: `Impact Sounds/Audio/impactGlass_heavy_000.ogg` to `impactGlass_heavy_004.ogg`
- Glass clink (tipped, not broken): `Impact Sounds/Audio/impactGlass_light_000.ogg` to `impactGlass_light_004.ogg`, `impactGlass_medium_000.ogg` to `impactGlass_medium_004.ogg`
- Plate: `Impact Sounds/Audio/impactPlate_heavy_000.ogg` to `impactPlate_heavy_004.ogg`, `impactPlate_medium_000.ogg` to `impactPlate_medium_004.ogg`; also `Foley Sounds/Audio/Plating/platesHit1.ogg` to `platesHit10.ogg`
- Wood: `Impact Sounds/Audio/impactWood_heavy_000.ogg` to `impactWood_heavy_004.ogg`, `impactPlank_medium_000.ogg` to `impactPlank_medium_004.ogg` (0.78 s, a plank or chair falling)
- Metal: `Impact Sounds/Audio/impactMetal_heavy_000.ogg` to `impactMetal_heavy_004.ogg`, `impactMetal_medium_000.ogg` to `impactMetal_medium_004.ogg`
- Pots and pans clattering: `RPG Audio/Audio/metalPot1.ogg` (1.46 s), `metalPot2.ogg`, `metalPot3.ogg`
- Tin cans: `Impact Sounds/Audio/impactTin_medium_000.ogg` to `impactTin_medium_004.ogg`

## Keypads

- Key press beeps (short tones, about 2 kHz): `Interface Sounds/Audio/glass_002.ogg`, `glass_005.ogg`, `glass_006.ogg` (about 0.12 s); `Interface Sounds/Audio/toggle_001.ogg`, `toggle_002.ogg` (0.14 s)
- Right code: `Interface Sounds/Audio/confirmation_001.ogg` (0.29 s)
- Wrong code: `Interface Sounds/Audio/error_004.ogg` (0.1 s), `Interface Sounds/Audio/error_008.ogg` (0.14 s)

## Menus and HUD

- Button click: `Interface Sounds/Audio/click_001.ogg` (0.1 s)
- Hover or focus: `Interface Sounds/Audio/select_001.ogg`, `Interface Sounds/Audio/select_002.ogg` (0.04 s)
- Back: `Interface Sounds/Audio/back_001.ogg`
- Toggle a setting: `Interface Sounds/Audio/switch_002.ogg`
- Open and close a panel: `Interface Sounds/Audio/open_001.ogg`, `Interface Sounds/Audio/close_001.ogg`
- Confirm: `Interface Sounds/Audio/confirmation_002.ogg`
- Not allowed: `Interface Sounds/Audio/error_002.ogg`
- (`UI Audio/Audio/click1.ogg` to `click5.ogg` are recorded much quieter, -13 to -30 dBFS peaks, so prefer Interface Sounds.)

## Jingles for a job's results

Pizzicato suits a sneaky caper and the saxophone set has a heist flavour. Up and down are estimated from the melody's pitch.

- Job done, all treasures back: `Music Jingles/Audio (Saxophone)/jingles-saxophone_01.ogg` (0.87 s, rising), `Music Jingles/Audio (Pizzicato)/jingles-pizzicato_00.ogg` (0.96 s, rising)
- Job done, small: `Music Jingles/Audio (Pizzicato)/jingles-pizzicato_02.ogg` (0.56 s, rising), `Music Jingles/Audio (Pizzicato)/jingles-pizzicato_13.ogg` (0.81 s, rising)
- Caught or job failed: `Music Jingles/Audio (Pizzicato)/jingles-pizzicato_03.ogg` (0.54 s, falling), `Music Jingles/Audio (Pizzicato)/jingles-pizzicato_16.ogg` (1.0 s, falling), `Music Jingles/Audio (Saxophone)/jingles-saxophone_00.ogg` (0.89 s, falling)
- New job or night starts: `Music Jingles/Audio (Steeldrum)/jingles-steel_06.ogg` (0.8 s, rising)

## Also handy in houses

- Sink: `Foley Sounds/Audio/Water/sinkWater1.ogg` to `sinkWater4.ogg`; dripping tap: `Foley Sounds/Audio/Water/drip1.ogg` to `drip4.ogg`
- Toilet flush (a classic distraction): `Foley Sounds/Audio/Water/toiletFlush.ogg` (8 s)
- Swish (throwing something): `Foley Sounds/Audio/Woosh/woosh1.ogg` to `woosh8.ogg`
- Sneaky background music: `Music Loops/Loops/Mishief Stroll.ogg`, `Music Loops/Loops/Mission Plausible.ogg`
