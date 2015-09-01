/*
*/
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};

float() crandom =
{
	return 2*(random() - 0.5);
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile, mpuff;
//	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};




void() spike_touch;
void() superspike_touch;

/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	local entity	old;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	local entity	old;
	
	makevectors (self.v_angle);
	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

	self.punchangle_x = -2;
};



.float hit_z;
void() spike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};


void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};























/*
=================================================================
Bomber Rocket Control
=================================================================
*/
void() BomberExplode =
{
	T_RadiusDamage (self, self.owner, self.dmg, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	self.avelocity = '0 0 0';
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;

	setmodel (self, "progs/s_explod.spr");
	s_explode1 ();

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

};


void(vector targ) BomberFireRocket =
{
	local entity	rock;
	local vector	dir;

	makevectors(self.angles);
	dir = normalize(targ - self.origin);

	rock = spawn();
	rock.owner = self;
	rock.movetype = MOVETYPE_FLY;
	rock.solid = SOLID_BBOX;
	rock.dmg = 220;

	rock.angles = vectoangles(dir);
	rock.velocity = dir*1200;

	rock.touch = BomberExplode;
	rock.think = BomberExplode;
	rock.nextthink = time + 4;

	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	setmodel(rock, "progs/missile.mdl");
	setsize (rock, '0 0 0', '0 0 0');		
	setorigin (rock, self.origin + (v_forward*16) + (v_right*4) + '0 0 16');
};



/*
=================================================================
Bomber Grenade Control
=================================================================
*/
void() BomberGrenTouch =
{
	if (other.classname == "reinforcer")
		return;

	if (other.takedamage)
	{
		if (other.classname == "monster_zombie")
			T_Damage(other, self, self.owner, 150);

		BomberExplode();
		return;
	}

	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};


void(vector targ) BomberFireGrenade =
{
	local entity	gren;
	local vector	dir, off;
	local float	heightmod;

	makevectors(self.angles);
	dir = normalize(targ - self.origin);
	heightmod = (1 + dir_z) * 35;
	off = ((v_up*crandom()) + (v_right*crandom())) * heightmod;

	gren = spawn();
	gren.owner = self;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	gren.dmg = 70;

	gren.velocity = (dir*800) + off + '0 0 150';
	gren.angles = vectoangles(gren.velocity);
	gren.avelocity = '300 300 300';

	gren.touch = BomberGrenTouch;
	gren.think = BomberExplode;
	gren.nextthink = time + 1.8;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	setmodel (gren, "progs/grenade.mdl");
	setsize (gren, '0 0 0', '0 0 0');		
	setorigin (gren, self.origin + (v_forward*16) + (v_right*8) + '0 0 16');
};



/*
=================================================================
Gunner Nailgun/Sniper Control
=================================================================
*/
void() GunnerNailTouch =
{
	local vector org;
	
	if (other == self.owner)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	if (other.takedamage)
	{
		spawn_touchblood (self.dmg);
		T_Damage (other, self, self.owner, self.dmg);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}
	
	remove(self);	
};



void(vector targ) GunnerFireNail =
{
	local entity	nail;
	local vector	dir, off;
	local float	vel, heightmod;

	makevectors(self.angles);
	dir = normalize(targ - self.origin);
	off = (v_up*crandom()) + (v_right*crandom());

	heightmod = (1 - dir_z) * 0.5;
	vel = 800 + (heightmod * 1000);

	nail = spawn();
	nail.owner = self;
	nail.movetype = MOVETYPE_FLY;
	nail.solid = SOLID_BBOX;

	nail.angles = vectoangles(dir);
	nail.velocity = (dir*vel) + (off*20);
	nail.dmg = 10 + (heightmod * 10);

	nail.touch = GunnerNailTouch;
	nail.think = SUB_Remove;
	nail.nextthink = time + 4;

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	setmodel(nail, "progs/spike.mdl");
	setsize (nail, '0 0 0', '0 0 0');		
	setorigin (nail, self.origin + (v_forward*16) + (v_right*8) + '0 0 16');
};


void(vector targ) GunnerFireSniper =
{
	local entity	nail;
	local vector	dir;
	local float	vel, heightmod;

	makevectors(self.angles);
	dir = normalize(targ - (self.origin + (v_forward*16) + (v_right*6)));

	heightmod = (1 - dir_z) * 0.5;
	vel = 1200 + (heightmod * 1800);

	nail = spawn();
	nail.owner = self;
	nail.movetype = MOVETYPE_FLY;
	nail.solid = SOLID_BBOX;

	nail.angles = vectoangles(dir);
	nail.velocity = dir*vel;
	nail.dmg = 20 + (heightmod * 60);

	nail.touch = GunnerNailTouch;
	nail.think = SUB_Remove;
	nail.nextthink = time + 4;

	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	setmodel(nail, "progs/s_snipe.mdl");
	setsize (nail, '0 0 0', '0 0 0');		
	setorigin (nail, self.origin + (v_forward*16) + (v_right*6) + '0 0 16');
};



/*
=================================================================
Healer Shotgun Control
=================================================================
*/
void(vector targ) HealerFireShotgun =
{
	local vector	dir, spread;
	local float	heightmod;

	dir = normalize(targ - self.origin);
	self.v_angle = vectoangles(dir);

	heightmod = (1 + dir_z) * 0.5;
	spread_y = 0.06 + (heightmod * 0.18);
	spread_x = spread_y * 1.2;

	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
	FireBullets (12, dir, spread);
};



/*
=================================================================
Translocator Control
=================================================================
*/

void(entity forcer) ReinfCancelOrder;
void(vector org) spawn_tfog;
void() TransloThink =
{
	local float	test;

	test = self.origin_x - self.dest_x;
	if (fabs(test) < 24)
	{
		test = self.origin_y - self.dest_y;
		if ((fabs(test) < 24) && (self.origin_z > (self.dest_z + 8)))
		{
			other = self.owner;

			if (CheckHullSpace(self.origin))
			{
				other.origin = self.origin;
				other.flags = other.flags - (other.flags & FL_ONGROUND);

				spawn_tfog(other.origin);
				spawn_tfog(other.oldorigin);

				ReinfCancelOrder(other);
				remove(self);
				return;
			}
		}
	}

	self.angles = vectoangles(self.velocity);
	self.think = TransloThink;
	self.nextthink = time + 0.05;

	test = pointcontents(self.origin);
	if ((test == CONTENT_WATER) || (test == CONTENT_SLIME) || (test == CONTENT_LAVA))
	{
		if (!self.count)
			self.count = self.velocity_z;
		self.velocity_z = self.count;
	}
	else
		self.count = 0;
};


void() TransloTouch =
{
	sound (self.owner, CHAN_VOICE, "items/r_item1.wav", 1.0, ATTN_NORM);
	ReinfCancelOrder(self.owner);
	sprint(self.owner.owner, self.owner.netname);
	sprint(self.owner.owner, " failed to translocate\n");
	remove(self);
};


void(vector targ) FireTranslocator =
{
	local entity	gren;
	local vector	dir;
	local float	zaim;

	gren = spawn();
	gren.owner = self;
	gren.classname = "translocator";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	gren.dest = targ;

	dir_x = targ_x - self.origin_x;
	dir_y = targ_y - self.origin_y;
	dir_z = 0.0;

	zaim = vlen(dir) * 0.0022;
	if (zaim > 0.8)
		zaim = 0.8;

	dir = normalize(targ - self.origin);
	dir_z = dir_z + zaim;
	if (dir_z < 0)
		dir_z = 0;

	gren.velocity = normalize(dir) * 500;
	gren.angles = vectoangles(gren.velocity);

	gren.touch = TransloTouch;
	gren.think = TransloThink;
	gren.nextthink = time + 0.1;

	makevectors(self.angles);
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	setmodel (gren, "progs/translo.mdl");
	setsize (gren, '0 0 0', '0 0 0');		
	setorigin (gren, self.origin + (v_forward*16) + (v_right*8) + '0 0 16');
};




