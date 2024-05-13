# love2d-gameloop

Times taken for the player to reach the end of the ruler. In other words, the
player, moving at a constant speed of 10 pixels per second, took this much game
time to cover a distance of 66 pixels:

| ..   | vsync   | novsync  & dynthrot | novsync & stathrot | novsync & simpdynthrot |
|------|---------|---------------------|--------------------|------------------------|
| ..   | 6.64569 | 6.63680             | 6.63416            | 6.6385                 |
| ..   | 6.64745 | 6.63504             | 6.63669            | 6.64532                |
| ..   | 6.64496 | 6.64029             | 6.63644            | 6.64029                |
| avg  | 6.64603 | 6.63504             | 6.63576            | 6.64137                |
| diff | 0       | 0.01099             | 0.01026            | 0.00466                |


This still needs more testing. I will expand on each table entry with explanations after I have tested them thoroughly in actual games.
When we don't have vsync the `novsync & simpdynthrot` method works best and is
what's implemented in `src/engine/runtime.lua`. The same method works when vsync
is on, the throttling simply won't happen since the desired fps is not being
exceeded.

- Use `v` key to toggle vsync
- Use `r` key to toggle slow rendering simulation
- Use `u` key to toggle fast rendering simulation
- Play with globals declared in `src/main.lua`

## Resources:
* https://medium.com/@tglaiel/how-to-make-your-game-run-at-60fps-24c61210fe75
* https://web.archive.org/web/20150702054525/http://bulletphysics.org/mediawiki-1.5.8/index.php/Canonical_Game_Loop
* https://web.archive.org/web/20141217095341/http://www.koonsolo.com/news/dewitters-gameloop/
* https://web.archive.org/web/20170608104357/http://gafferongames.com/game-physics/fix-your-timestep/
* https://marioslab.io/posts/jitterbugs/#The%20story%20of%20Pixi
