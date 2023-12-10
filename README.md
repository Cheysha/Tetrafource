
# ![TetraForce](https://tetraforce.io/wp-content/uploads/2020/07/Logo_FullyRendered-1024x617.png)
## TetraFource
Attempt to port Tetraforce to Godot 4.x, total WIP

## Project Goals
TetraForce is a multiplayer action game, reminiscent of the GameBoy Zelda series. The original project appears to be abandoned and has issues with tilemap placement, causing some items to be misaligned on the y-axis. This project aims to build upon the existing work of the TetraForce development team, rectify the identified issues, and port the project to Godot 4.x.

After porting is complete, implemented features hope to include
- improved Godot 4 utilization, eg improved tilemaps
- UDP ENnet peer usage, over Websocket TCP
- probally remove deticated AWS server stuff, uneeded for my uses

## TODOS:
Playability
- [x] Game Boots
- [x] Menus Work
- [ ] Menus Complete (Fix ui nodes)
- [x] Game loop Playable
- [x] Transitions working
- [x] Entire Map Traversable
- [x] MultiPlayer Server / Client visible
- [ ] MultiPlayer Playable
- [ ] some tiles dont spawn, eg, water, grass
- [ ] cut tall_grass dont despawnfrom overworld, 

Quality
- [ ] fix ui font
- [ ] fix ui backing elements
- [ ] fix quiet audio (tweening maybe)
- [ ] fix sign font
- [ ] fix broken saving ui element that never goes away, signal issue?
- [ ] fix 4.x autotiles, water, etc

Immediate issues
- [x]room transitions take pplayer to (random?) wrong location/ tweening entity wrong
- [ ] multiplayer crashes on client logon, client player not getting what it needs?
- [ ] zone transitions bounce when changing between two, tween issue?
- [ ] Enemies on overworld apper to be frozen
- [ ] nothing destroyed from overwordld

## What Changed

- this is a ton of work 
- found really weird thing where one layer on one map had a -16 vertical offset, took away offset and fixed map. also took the line out of the import script that gave the offset back. idk what that was all about
- changes in file acess api 
- some methods had been moved around 
- tween node was no longer a thing
- tilemap and tileset systems have been reworked
- Apperently godot 3 allowed for variables and methods to have the same name, this is nolonger the case
- 3.x to 4.x some properties were lost. like viewport stretching, restored
