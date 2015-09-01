
Mod Info
--------
Title		: Reinforcer
Version		: 1.1
Date		: 16/08/05
Author:		: Matthew "Quake Matt" Lawrence
Email		: rogermelon@yahoo.com

Description	: This tactical mod sees the player commanding a team of
		  elite Enforcers, each with their own weapons and
		  abilities, through the standard Quake levels.


Type of Mod
-----------
Quake C		: Yes
Sound		: No
MDL		: Yes



Format of Quake C
-----------------
unified diff	: No
context diff	: No
.qc files	: No
progs.dat	: Yes
.pak file	: No



Backstory
---------
        "*FZZZT*
..uesting backup! I repea..
       *FzzzzzSH*
 ..ackup! I'm pinned dow..
        *THZZZFF*
  ..Send reinforcements!
        *FZZZZTH*"

As the radio gave it's final breath, dying like the many soldiers of
Operation Counterstrike, the last words resonated through the heads of
the three survivors. Although leaderless and reduced to ruins, the
operation had gone ahead - a lone man had leapt through the slipgate;
leapt into the unknown to stand against an army foreign to this world.

And now he needs help.

Armed and ready, the three Enforcers engage the gate. Driven by duty
and fortified by training, they shall be the aid the embattled warrior
so desperately needs. Let no foe - Human, Demon, or otherwise - stand
in their way:
	Quake Man shall be saved - saved by the Reinforcers!



Introducing the Reinforcers
---------------------------
Your squad is made up of three Enforcers, spared the evil fate Shub-
Niggurath had in store for them, selflessly seeking Quake Man.
They are:

	Bomber:
Expert with explosives and heavy-weapons, his weapon of choice is an
auto-loading grenade launcher. For additional destructive power at
increased range, the weapon can also be armed with larger rockets,
limited to sporadic deployment by carrying capacity. To cope with the
rigors of combat, Bomber is outfitted with yellow armour.

	Healer:
Although handy with a shotgun, Healer's primary designation is combat
medic. His knowledge of medicine plus high-tech resuscitation pack
can bring soliders back from the brink of death, and have kept his
squad alive through many dangerous encounters. Being so instrumental
to the team, he is protected by red armour.

	Gunner:
A master of weapons on all kinds, Gunner deems his custom nailgun to
be the pinnacle of combat engineering. Lightweight and compact, the
nailgun offers great maneuverability without sacrificing power. Gunner
has further increased the flexibility of the weapon by adding a scope
and a secondary sniper system, based around the Perforator design. To
ensure high mobility, Gunner wears only green armour.

In many engines, these names can be altered by editing the "names.txt"
file, found in the data directory of the game. If you're using an older
engine, there are also a series of preset names you can use, which are
selected by changing the teamplay cvar. Set it to a number between 0
and 12, then restart the map for new names!



Controlling the Reinforcers
---------------------------
Viewer movement is done with both the keyboard and the mouse. For the
keyboard, it's preferable to use W/A/S/D, but the cursor keys can work
just as well. With these keys, you can fly the viewport around, while
adjusting your direction with the mouse. Pressing the middle mouse
button toggles the vertical motion of the view, and makes you always
move horizontally, regardless of viewer direction, which is useful
when assuming a tactical position. You can then use the mouse wheel
to control vertical motion.

Most interation with the Reinforcers is done with the mouse: use the
mouse to point the cursor at someone, and left click to select him.
A blue ring shall appear around him, letting you know that he's waiting
for orders. You can also select individual Reinforcers by pressing the
keys 1, 2 and 3. Pressing any of these keys twice in a row shall centre
the view on the Reinforcer and, if you hold shift, you can select more
than one Reinforcer at a time.

The right mouse button is used for issuing basic orders. Clicking on the
floor will order the selected Reinforcer(s) to move there, while clicking
on an enemy shall order them to attack. Additionally, when ordering them
to move, if you hold the button and drag the cursor along the floor, the
Reinforcer shall turn to face that direction when they arrive, which is
useful for ensuring they defend themselves properly. You can also force
them to attack the floor by holding the control key and right clicking,
which helps you bounce grenades round corners or hit secret doors. This
force attack also doubles as an attack-move order, as the Reinforcers
will first kill any monsters they can see, which is handy for clearing
rooms of weak monsters.

Each Reinforcer has a limited-use special ability that can be engaged by
holding the Q key and clicking the right mouse button on a target. Bomber
will fire a rocket at the target (or wall) as soon as he can see it.
Gunner moves into position then readies his weapon, firing upon any
monsters he sees from then on. Healer will move to the selected Reinforcer
and heal him.

The Reinforcers carry too much gear to jump or swim, so for added
maneuverability, they each carry a portable slipgate device - the
translocator, pioneered by the Liandri Corporation. By holding the E key
and right clicking, you will order a Reinforcer to fire his translocator,
which will then teleport him when it reaches the destination point. You
can use these to cross gaps, leap to and from ledges and, as they are
bouyant, escape from water.



Default Controls
----------------
Arrow keys	: Camera movement
W/A/S/D		: Camera movement
Mouse wheel	: Camera up/down
Middle mouse	: Toggle Z movement

1 key		: Select "Bomber"
2 key		: Select "Healer"
3 key		: Select "Gunner"
Left mouse	: Select Reinforcer
Right mouse	: Issue order (context sensitive)
Hold shift	: Select multiple Reinforcers
Hold Q		: Use special ability
Hold E		: Fire translocator

V Key		: Version information



Installing the Modification
---------------------------
Extract to a new directory under your Quake directory, so the path looks
something like "C:\Quake\Reinforcer". Then run your favourite Quake engine
with the command line "Quake -game Reinforcer".

Configuration is done mostly through the autoexec.cfg file, but you may
still wish to configure mouse sensitivity and inversion. You must also
note that some controls cannot be set through the Quake menus, as
Reinforcer uses a lot of custom impulses.



Playable Levels
---------------
Hopefully, practically all levels are playable now! The only
known exception is Ziggurat Vertigo (e1m8), although some levels
with large/complex bodies of water may not be finishable.



Bugs and Limitations
--------------------
- Intermissions have been removed due to a bug
- Selection ring motion not interpolated (no idea why)
- Pathfinding still useless



Changelog
---------
	v1.1
- QExpo release!
- All known crashes fixed
- Camera no longer gets stuck in walls
- Camera can pass through Reinforcers
- Reinforcers can translocate for extra mobility
- Reinforcers can be individually named
- Reinforcers no longer telefrag each other
- Force attack doubles as attack move
- Better behaviour when moving as a group
- Attacking from the rear does more damage
- Cancel/lookat order added
- Misc tweaks and bugfixes


	v1.0
- Competition release!
- Reinforcers have special abilities
- Reinforcers have names and give text and audio feedback
- Reinforcer skins tweaked
- Reinforcer movement marginally improved
- Misc bug and balance fixes


	v0.2 Alpha
- Getting good now!
- Reinforcers move and individual weapons
- Reinforcers have health, but no pain animations
- Reinforcers interact with buttons, doors, monsters, etc
- Monsters no longer attack player viewport
- Monsters reliably target Reinforcers
- Gold/silver keys work correctly
- 'Sticky' key problems mostly fixed


	v0.1 Alpha
- First release
- Mostly incomplete
- Intended as movement/control demonstration



Copyright and Distribution
--------------------------
Reinforcer for Quake is Copyright (C) 2005, Matthew Lawrence

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation.

The source code will be available in the next release.



GPL? So where's the Source Code?
--------------------------------
It's coming, it's just not in this release. Right now, it's
untidy and full of little hacks - not very useful to anyone!
By next version, I'll have cleaned it up and ready to use.
