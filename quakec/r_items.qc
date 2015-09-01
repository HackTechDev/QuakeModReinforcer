

void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};



/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos(self.origin));
	dprint ("\n");
	remove (self);
};



/*
============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
	local float	oldz;

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;
	if (!droptofloor())
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
		return;
	}
};

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
void() health_touch =
{
	if (other.classname != "reinforcer")
		return;

	if (other.health == 100)
		return;

	other.health = other.health + 10;
	if (other.health > 100)
		other.health = 100;

	sprint(other.pointer, other.netname);
	sprint(other.pointer, " picked up a health pack\n");

	sound(other, CHAN_ITEM, "items/health1.wav", 1, ATTN_NORM);
	remove(self);
};


/*void() item_health =
{	
	self.touch = health_touch;
	precache_model("maps/b_bh25.bsp");
	precache_sound("items/health1.wav");
	setmodel(self, "maps/b_bh25.bsp");
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};*/

void() item_health =
{
	remove(self);
};



/*
===============================================================================

ARMOR

===============================================================================
*/
void() item_armor1 =
{
	remove(self);
};


void() item_armor2 =
{
	remove(self);
};


void() item_armorInv =
{
	remove(self);
};


/*
=============
weapon_touch
=============
*/
void() weapon_supershotgun =
{
	remove(self);
};


void() weapon_nailgun =
{
	remove(self);
};


void() weapon_supernailgun =
{
	remove(self);
};


void() weapon_grenadelauncher =
{
	remove(self);
};


void() weapon_rocketlauncher =
{
	remove(self);
};


void() weapon_lightning =
{
	remove(self);
};


/*
===============================================================================

AMMO

===============================================================================
*/
void() item_shells =
{
	remove(self);
};


void() item_spikes =
{
	remove(self);
};


void() item_rockets =
{
	remove(self);
};


void() item_cells =
{
	remove(self);
};


void() item_weapon =
{
	remove(self);
};


/*
===============================================================================

KEYS

===============================================================================
*/

void() key_touch =
{
local entity	stemp;
local float		best;

	if (other.classname != "reinforcer")
		return;
	if (other.health <= 0)
		return;
	if (other.pointer.permitems & self.items)
		return;

	sprint (other.pointer, other.netname);
	sprint (other.pointer, " found the ");
	sprint (other.pointer, self.netname);
	sprint (other.pointer,"\n");

	sound (other.pointer, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	other.pointer.permitems = other.pointer.permitems | self.items;

	if (!coop)
	{	
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


void() key_setsounds =
{
	if (world.worldtype == 0)
	{
		precache_sound ("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}
	if (world.worldtype == 1)
	{
		precache_sound ("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}
	if (world.worldtype == 2)
	{
		precache_sound2 ("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key1 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_s_key.mdl");
		setmodel (self, "progs/w_s_key.mdl");
		self.netname = "silver key";
	}
	else if (world.worldtype == 1)
	{
		precache_model ("progs/m_s_key.mdl");
		setmodel (self, "progs/m_s_key.mdl");
		self.netname = "silver runekey";
	}
	else if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
		self.netname = "silver keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key2 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}
	if (world.worldtype == 1)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}
	if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{
local entity	stemp;
local float		best;

	if (other.classname != "reinforcer")
		return;
	if (other.health <= 0)
		return;

	sprint (other.pointer, other.netname);
	sprint (other.pointer, " found a rune\n");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other.pointer, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = "";		// so rune doors won't find it
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/
void() item_artifact_invulnerability =
{
	remove(self);
};

void() item_artifact_envirosuit =
{
	remove(self);
};


void() item_artifact_invisibility =
{
	remove(self);
};

void() item_artifact_super_damage =
{
	remove(self);
};


/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
	return;
};
