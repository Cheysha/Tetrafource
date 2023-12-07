
# ![TetraForce](https://tetraforce.io/wp-content/uploads/2020/07/Logo_FullyRendered-1024x617.png)
## TetraFource
Attempt to port Tetraforce to Godot 4.x, total WIP

## Project Goals
TetraForce is a multiplayer action game, reminiscent of the GameBoy Zelda series. The original project appears to be abandoned and has issues with tilemap placement, causing some items to be misaligned on the y-axis. This project aims to build upon the existing work of the TetraForce development team, rectify the identified issues, and port the project to Godot 4.x.

## Roadmap
- [x] Game Boots
- [x] Menus Work
- [ ] Menus Complete (Fix ui nodes)
- [x] Starting Area Playable
- [ ] Transitions working
- [ ] MultiPlayer Woking


## Notes
- fix item script form using old conventions
- get overworld

## What Changed
- found really weird thing where one layer on one map had a -16 vertical offset, took away offset and fixed map. also took the line out of the import script that gave the offset back. idk what that was all about
- changes in file acess api 
- some methods had been moved around 
- tween node was no longer a thing
- tilemap and tileset systems have been reworked
- Apperently godot 3 allowed for variables and methods to have the same name, this is nolonger the case
- 3.x to 4.x some properties were lost. like viewport stretching, restored
