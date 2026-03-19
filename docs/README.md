# Defender
**Please add to this document as we make decisions about the game**

### Overview

This is a small twinstick incremental horde game to test out the ability to go from concept to steam release. 

We're leaning into juice / physics / explosions / debris - for the game, and leaving very little "artwork" to be produced. 

We are scoping small - but will have aroudn 10 enemy types, and around 3-4 weapon types for the player. The upgrade tree will have upwards of 50-60 nodes

the entire game from start to end credits - should take around 1 hour to play. 

### Theme
The game is set inside a computer - so dark materials with glowy neon lines. The protagonist is a Developing AGI that needs our help to survive. 
An enemy faction is attempting to attack our AGI friend, who is asking for our help, we defend it while it crunches numbers and develops its capabilities

while doing so - we gather bits from the enemies and use the processing that the agi is doing - to purchase upgrades on our upgrade tree. 

### Directives
1) Do not create UID from scratch - let godot build the UID when we open the scenes. 
2) Code should be Human Readable - Verbose variable and function names
3) Scenes should be broken up into nodes, and each script should be small.
