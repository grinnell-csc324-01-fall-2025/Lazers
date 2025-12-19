This game takes influence from Space Invaders to create a bullet-hell arcade experience. Dodge enemy lasers while firing your own, earning points for every enemy destroyed.

W to go forward
A/D to turn left/right

Debug mode can be activated by setting DEBUG to TRUE in main.lua. Debug mode allows you to see player and enemy hitboxes, as well as read FPS.

For testing:
1) Ensure game is running in debug mode by setting DEBUG to TRUE in main.lua
2) On game start, does player spawn in the middle of the screen?
3) Do WAD keys move player in accurate directions?
4) Does player accelerate the longer the W key is held? Does the player deccelerate when W key is not held?
5) Do lasers collide with enemy/player hitboxes (red circle) deleting the laser and destroying the enemy/cause a game over?
6) Do more enemies spawn over time?
7) Does the spitter enemy (green) enter the spawn pool after the player earns 10 points? Does the basic enemy (white) stay in the spawn pool?
8) What causes FPS drops, if anything?
