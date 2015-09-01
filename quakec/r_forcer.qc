
//FIXME: move to defs

.void()	th_alive;
.float	ack_finished;


float	RE_SPAWNAREA	= 64;
float	RE_GRENADEDELAY	= 0.9;
float	RE_SHOTGUNDELAY	= 0.6;
float	RE_NAILGUNDELAY	= 0.1;
float	RE_SNIPERDELAY	= 0.7;

float	ATT_DEFENSIVE	= 0;
float	ATT_AGGRESSIVE	= 1;
float	ATT_SPECIALQ	= 2;
float	ATT_HEAL	= 3;
float	ATT_FORCED	= 4;
float	ATT_TRANSLOCATE	= 5;

float	T_NULL		= 0;
float	T_MOVE		= 1;
float	T_FORCEFIRE	= 2;
float	T_ATTACK	= 3;
float	T_ATTACKLARGE	= 4;
float	T_SNIPE		= 5;
float	T_ROCKET	= 6;
float	T_HEAL		= 7;
float	T_TRANSLOCATE	= 8;


/*
=================================================================
Reinforcer Model Frames
=================================================================
*/

$cd id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

$frame paina1 paina2 paina3 paina4

$frame painb1 painb2 painb3 painb4 painb5

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8
$frame paind9 paind10 paind11 paind12 paind13 paind14 paind15 paind16
$frame paind17 paind18 paind19


/*
=================================================================
Miscellaneous Functions
=================================================================
*/
float(entity ent) SnipingGunner =
{
	if (ent.attack_state != ATT_SPECIALQ)
		return FALSE;
	if (ent.class != RE_GUNNER)
		return FALSE;
	return TRUE;
};


void(entity source) OrderAcknowledge =
{
	if (source.ack_finished > time)
		return;

	local float	r;
	r = random()*4;
	if (r < 1)
		sound (source, CHAN_VOICE, "enforcer/sight1.wav", 1, ATTN_NONE);
	else if (r < 2)
		sound (source, CHAN_VOICE, "enforcer/sight2.wav", 1, ATTN_NONE);
	else if (r < 3)
		sound (source, CHAN_VOICE, "enforcer/sight3.wav", 1, ATTN_NONE);
	else
		sound (source, CHAN_VOICE, "enforcer/sight4.wav", 1, ATTN_NONE);

	source.ack_finished = time + 1 + random();
};


void(entity my, float x) SetTargetmark =
{
	//----- Don't Unnecessarily use SetModel -----------
	if (x == my.targetmark.class)
		return;

	//----- Change Target to Correct Model -------------
	if (x == T_MOVE)
		setmodel(my.targetmark, "progs/s_moveto.mdl");
	else if (x == T_FORCEFIRE)
		setmodel(my.targetmark, "progs/s_fireat.mdl");
	else if (x == T_ATTACK)
		setmodel(my.targetmark, "progs/s_msmall.mdl");
	else if (x == T_ATTACKLARGE)
		setmodel(my.targetmark, "progs/s_mlarge.mdl");
	else if (x == T_SNIPE)
		setmodel(my.targetmark, "progs/t_snipe.mdl");
	else if (x == T_ROCKET)
		setmodel(my.targetmark, "progs/t_rocket.mdl");
	else if (x == T_HEAL)
		setmodel(my.targetmark, "progs/t_heal.mdl");
	else if (x == T_TRANSLOCATE)
		setmodel(my.targetmark, "progs/t_trans.mdl");
	else
		setmodel(my.targetmark, "");
	my.targetmark.class = x;
};


entity(entity parent, vector spot, float minlen) ClosestReinforcer =
{
	local float	bomblen, gunlen, heallen;

	bomblen = vlen(spot - parent.bomber.origin);
	heallen = vlen(spot - parent.healer.origin);
	gunlen = vlen(spot - parent.gunner.origin);

	if ((bomblen < gunlen) && (bomblen < heallen) && (bomblen < minlen))
		return parent.bomber;
	if ((heallen < gunlen) && (heallen < minlen))
		return parent.healer;
	if (gunlen < minlen)
		return parent.gunner;

	return world;
};


void(entity targ) ProvideHealing =
{
	local float	give;

	give = 100 - targ.health;
	if (give > 50)
		give = 50;

	self.currentammo = self.currentammo - 1;
	sound (self, CHAN_VOICE, "items/r_item2.wav", 1, ATTN_NONE);

	if (targ.health <= 0)
	{
		sprint(self.pointer, self.netname);
		sprint(self.pointer, " has resuscitated ");
		sprint(self.pointer, targ.netname);
		sprint(self.pointer, "\n");

		targ.think = targ.th_alive;
		targ.nextthink = time + 0.1;
	}
	else
	{
		targ.health = targ.health + give;

		if (targ != self)
		{
			sprint(self.pointer, self.netname);
			sprint(self.pointer, " has provided ");
			sprint(self.pointer, targ.netname);
			sprint(self.pointer, " with ");
			sprint(self.pointer, ftos(give));
			sprint(self.pointer, " health\n");
		}
	}
};



/*
=================================================================
Spotting and Targeting Monsters
=================================================================
*/
float() GoalMonsterDead =
{
	if (self.attack_state == ATT_FORCED)
		return FALSE;

	if (!self.goalentity)
		return TRUE;

	if (self.goalentity.flags & FL_MONSTER)
	{
		if (self.goalentity.health <= 0)
			return TRUE;
	}

	return FALSE;
};


float(entity targ) ClearShot =
{
	if (!targ)
		return FALSE;

	if (!visible(targ))
		return FALSE;

	if (SnipingGunner(self))
		return TRUE;

	traceline(self.origin, targ.origin, FALSE, self);
	if (trace_ent.classname == "reinforcer")
		return FALSE;

	return TRUE;
};


entity() VisibleMonster =
{
	local entity	head;

	makevectors(self.angles);
	head = findradius(self.origin + (v_forward*256), 1024);

	while (head)
	{
		if ((head.flags & FL_MONSTER) && (head.health > 0))
		{
			if (ClearShot(head))
			{
				if (infront(head))
					return head;
			}
		}
		head = head.chain;
	}

	return world;
};



/*
=================================================================
Per-Frame Reinforcer Updates
=================================================================
*/
void() UpdateSelectRing =
{
	//----- Position and Set Selection Ring ------------
	setorigin(self.selectmark, self.origin + '0 0 1');
	//self.selectmark.origin = self.origin;
	if (self.selected == self.selectmark.selected)
		return;

	if (self.selected == TRUE)
		setmodel(self.selectmark, "progs/s_enforc.mdl");
	else
		setmodel(self.selectmark, "");
	self.selectmark.selected = self.selected;
};


void() UpdateTargetRing =
{
	//----- Don't Reposition under Attack-Move ---------
	if (self.attack_state == ATT_FORCED)
		return;

	//----- Special Check for Healing ------------------
	if (self.attack_state == ATT_HEAL)
	{
		self.targetmark.origin = self.targetmark.goalentity.origin;
		return;
	}

	//----- Special Check for Sniping ------------------
	if ((self.targetmark.goalentity) && (self.attack_state == ATT_SPECIALQ))
	{
		self.targetmark.origin = self.targetmark.goalentity.origin;
		return;
	}

	//----- Position and Set Targeting Ring ------------
	if (!self.goalentity.flags & FL_MONSTER)
		return;

	if (SnipingGunner(self))
		return;

	if (self.goalentity.health > 0)
		self.targetmark.origin = self.goalentity.origin;
	else
		SetTargetmark(self, T_NULL);
};


void(vector dir) UseButtons =
{
	local vector	org;
	org = self.origin;
	org_z = self.origin_z + (random()*24);

	traceline(org, org + dir, TRUE, self);
	if (trace_fraction == 1.0)
		return;

	//----- Interact with Doors and Buttons ------------
	if ((trace_ent.classname == "func_button") || (trace_ent.classname == "door"))
	{
		local entity	oldself;
		oldself = self;
		other = self;
		self = trace_ent;

		self.touch();

		self = oldself;
	}

	//----- Interact with Platforms --------------------
	if (trace_ent.classname == "plat")
	{
		local entity	oldself;
		oldself = self;
		other = self;
		self = trace_ent;

		self.use();

		self = oldself;
	}
};


void() ReinforcerThink =
{
	//----- Pseudo Interaction with Environment --------
		UseButtons('36 0 0');
		UseButtons('-36 0 0');
		UseButtons('0 36 0');
		UseButtons('0 -36 0');
		UseButtons('0 0 -48');

	//----- Per-Frame Updates --------------------------
	UpdateSelectRing();
	UpdateTargetRing();
	ChangeYaw();

	//----- Slow Descent in Water ----------------------
	local float	test;
	test = pointcontents(self.origin);
	if ((test == CONTENT_WATER) || (test == CONTENT_SLIME) || (test == CONTENT_LAVA))
		self.velocity_z = self.velocity_z * 0.5;
};



/*
=================================================================
Issuing Orders to Individual Reinforcers
=================================================================
*/
void(entity forcer, vector lookto) ReinfDirectionOrder =
{
	forcer.targetmark.dest = lookto;
};


void(entity forcer) ReinfCancelOrder =
{
	forcer.goalentity = world;
	forcer.attack_state = ATT_DEFENSIVE;
	forcer.ideal_yaw = forcer.angles * '0 1 0';
	forcer.think = forcer.th_stand;
	forcer.nextthink = time + 0.05;

	SetTargetmark(forcer, T_NULL);
};


void(entity forcer, vector spot, vector surfangle) ReinfMoveOrder =
{
	forcer.attack_state = ATT_DEFENSIVE;
	forcer.targetmark.health = 0;
	forcer.targetmark.origin = spot;
	forcer.targetmark.angles = surfangle;
	forcer.goalentity = forcer.targetmark;
	forcer.ideal_yaw = vectoyaw(spot - forcer.origin);
	forcer.think = forcer.th_run;
	forcer.nextthink = time + 0.05;

	SetTargetmark(forcer, T_MOVE);
	OrderAcknowledge(forcer);
};


void(entity forcer, vector spot) ReinfTranslocateOrder =
{
	forcer.attack_state = ATT_TRANSLOCATE;
	forcer.targetmark.health = 0;
	forcer.targetmark.origin = spot;
	forcer.targetmark.angles = '0 0 0';
	forcer.goalentity = forcer.targetmark;
	forcer.ideal_yaw = vectoyaw(spot - forcer.origin);
	forcer.think = forcer.th_run;
	forcer.nextthink = time + 0.05;

	SetTargetmark(forcer, T_TRANSLOCATE);
	OrderAcknowledge(forcer);
};


void(entity forcer, vector spot, vector surfangle) ReinfForceAttOrder =
{
	forcer.attack_state = ATT_FORCED;
	forcer.targetmark.health = 1;
	forcer.targetmark.origin = spot;
	forcer.targetmark.angles = surfangle;
	forcer.goalentity = forcer.targetmark;
	forcer.ideal_yaw = vectoyaw(spot - forcer.origin);
	forcer.think = forcer.th_run;
	forcer.nextthink = time + 0.05;

	SetTargetmark(forcer, T_FORCEFIRE);
	OrderAcknowledge(forcer);
};


void(entity forcer, entity attack) ReinfAttackOrder =
{
	forcer.attack_state = ATT_AGGRESSIVE;
	forcer.targetmark.angles = '0 0 0';
	forcer.goalentity = attack;
	forcer.ideal_yaw = vectoyaw(attack.origin - forcer.origin);
	forcer.think = forcer.th_run;
	forcer.nextthink = time + 0.05;

	if (attack.classname == "monster_shambler")
		SetTargetmark(forcer, T_ATTACKLARGE);
	else
		SetTargetmark(forcer, T_ATTACK);
	OrderAcknowledge(forcer);
};


void(entity forcer, vector spot) ReinfHealOrder =
{
	//----- Find Nearest Target for Heal ---------------
	local entity	targ;
	targ = ClosestReinforcer(forcer.pointer, spot, 256);

	//----- Check Validity of Target -------------------
	if (targ)
	{
		if (targ.health == 100)
		{
			sprint(forcer.pointer, targ.netname);
			sprint(forcer.pointer, " needs no medical attention\n");
			ReinfCancelOrder(forcer);
			return;
		}
	}
	else
	{
		sprint(forcer.pointer, "No one there to heal\n");
		ReinfCancelOrder(forcer);
		return;
	}

	//----- Set Healer's State -------------------------
	forcer.attack_state = ATT_HEAL;
	forcer.targetmark.angles = '0 0 0';
	forcer.targetmark.goalentity = targ;
	forcer.targetmark.origin = targ.origin;
	forcer.goalentity = forcer.targetmark;
	forcer.ideal_yaw = vectoyaw(targ.origin - forcer.origin);
	forcer.think = forcer.th_run;
	forcer.nextthink = time + 0.05;
	SetTargetmark(forcer, T_HEAL);

	//----- Inform Player of Action --------------------
	if (targ == forcer)
	{
		sprint(forcer.pointer, forcer.netname);
		sprint(forcer.pointer, " tending to his wounds\n");
	}
	else
	{
		sprint(forcer.pointer, forcer.netname);
		sprint(forcer.pointer, " moving to assist ");
		sprint(forcer.pointer, targ.netname);
		sprint(forcer.pointer, "\n");
	}
	OrderAcknowledge(forcer);
};


void(entity forcer, vector spot) ReinfForceSpecialQ =
{
	//----- Out of Special Charges ---------------------
	if (forcer.currentammo == 0)
	{
		sprint(forcer.pointer, forcer.netname);
		if (forcer.class == RE_BOMBER)
			sprint(forcer.pointer, " is out of rockets\n");
		else if (forcer.class == RE_HEALER)
			sprint(forcer.pointer, " is out of medical equipment\n");
		else if (forcer.class == RE_GUNNER)
			sprint(forcer.pointer, " is out of sniper rounds\n");

		ReinfCancelOrder(forcer);
		return;
	}

	//----- Healer Requires Special Orders -------------
	if (forcer.class == RE_HEALER)
	{
		ReinfHealOrder(forcer, spot);
		return;
	}

	//----- Prepare States for Special -----------------
	forcer.targetmark.health = 1;
	forcer.attack_state = ATT_SPECIALQ;
	forcer.targetmark.origin = spot;
	forcer.targetmark.angles = '0 0 0';
	forcer.targetmark.goalentity = world;
	forcer.goalentity = forcer.targetmark;
	forcer.ideal_yaw = vectoyaw(spot - forcer.origin);
	forcer.think = forcer.th_run;
	forcer.nextthink = time + 0.05;

	//----- Inform Player of Activation ----------------
	if (forcer.class == RE_BOMBER)
	{
		SetTargetmark(forcer, T_ROCKET);
		sprint(forcer.pointer, forcer.netname);
		sprint(forcer.pointer, " preparing to use rocket\n");
	}
	else
	{
		SetTargetmark(forcer, T_SNIPE);
		sprint(forcer.pointer, forcer.netname);
		sprint(forcer.pointer, " assuming sniper position\n");
	}
	OrderAcknowledge(forcer);
};


void(entity forcer, entity attack) ReinfSpecialQOrder =
{
	//----- Use Force-Special Routine ------------------
	ReinfForceSpecialQ(forcer, attack.origin);
	forcer.targetmark.goalentity = attack;
};



/*
=================================================================
Reinforcer Main Firing Sequence
=================================================================
*/
void(float step) think_mainfire;
void() reinf_postfire1;

void()	reinf_mainfire1	=[	$attack5,	reinf_mainfire1	] {think_mainfire(1);};
void()	reinf_mainfire2	=[	$attack6,	reinf_mainfire3	] {think_mainfire(2);};
void()	reinf_mainfire3	=[	$attack7,	reinf_mainfire4	] {think_mainfire(3);};
void()	reinf_mainfire4	=[	$attack8,	reinf_mainfire5	] {think_mainfire(4);};
void()	reinf_mainfire5	=[	$attack9,	reinf_mainfire6	] {think_mainfire(5);};
void()	reinf_mainfire6	=[	$attack10,	reinf_mainfire1	] {think_mainfire(6);};

void(float step) think_mainfire =
{
	//----- Sniping Gunner -----------------------------
	if (SnipingGunner(self))
	{
		if (self.currentammo == 0)
			self.attack_state = ATT_DEFENSIVE;

		self.goalentity = VisibleMonster();
		if (!self.goalentity)
		{
			self.goalentity = self.targetmark;
			if (self.attack_finished <= time)
				self.attack_finished = time + 0.1;
		}
	}

	//----- Switching Attack-Move Target ---------------
	if (self.attack_state == ATT_FORCED)
	{
		self.goalentity = VisibleMonster();
		if (!self.goalentity)
			self.goalentity = self.targetmark;
	}

	//----- Find New Targets ---------------------------
	if (GoalMonsterDead())
	{
		self.attack_state = ATT_DEFENSIVE;
		self.goalentity = VisibleMonster();
	}

	//----- Cancel Firing on Hidden Targets ------------
	if ((!ClearShot(self.goalentity)) && (self.attack_state != ATT_TRANSLOCATE))
	{
		self.think = reinf_postfire1;
		return;
	}

	//----- Firing Frame -------------------------------
	if (step == 2)
	{
		self.effects = self.effects | EF_MUZZLEFLASH;
		self.attack_finished = time + self.delay;
		self.show_hostile = time + 0.2;

		//----- Fire Translocator --------------------------
		if (self.attack_state == ATT_TRANSLOCATE)
		{
			self.attack_finished = time + 10000;
			FireTranslocator(self.goalentity.origin);
		}

		//----- Bomber's Attacks ---------------------------
		else if (self.class == RE_BOMBER)
		{
			if (self.attack_state == ATT_SPECIALQ)
			{
				BomberFireRocket(self.goalentity.origin);
				SetTargetmark(self, T_NULL);
				self.goalentity = world;
				self.attack_state = ATT_DEFENSIVE;
				self.currentammo = self.currentammo - 1;
			}
			else
				BomberFireGrenade(self.goalentity.origin);
		}

		//----- Healers's Attacks ---------------------------
		else if (self.class == RE_HEALER)
		{
			HealerFireShotgun(self.goalentity.origin);
		}

		//----- Gunners's Attacks ---------------------------
		else if (self.class == RE_GUNNER)
		{
			self.think = reinf_mainfire6;
			if (self.attack_state == ATT_SPECIALQ)
			{
				GunnerFireSniper(self.goalentity.origin);
				self.attack_finished = time + RE_SNIPERDELAY;
				self.currentammo = self.currentammo - 1;
			}
			else
				GunnerFireNail(self.goalentity.origin);
		}
	}

	//----- Skip to Firing Frame when Ready ------------
	if (self.attack_finished <= time)
	{
		self.think = reinf_mainfire2;
		return;
	}

	//----- Standard Updates ---------------------------
	if (self.goalentity)
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	else
		self.ideal_yaw = self.angles_y;
	ReinforcerThink();
};



/*
=================================================================
Reinforcer Pre- and Post-Firing Sequences
=================================================================
*/
void() think_prefire =
{
	if (self.goalentity)
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	else
		self.ideal_yaw = self.angles_y;
	ReinforcerThink();
};

void() reinf_postfire4 =
{
	if ((GoalMonsterDead()) || (self.attack_state == ATT_DEFENSIVE))
		ReinfCancelOrder(self);
	else
		self.th_run();
};

void()	reinf_prefire1	=[	$attack1,	reinf_prefire2	] {think_prefire();};
void()	reinf_prefire2	=[	$attack2,	reinf_prefire3	] {think_prefire();};
void()	reinf_prefire3	=[	$attack3,	reinf_prefire4	] {think_prefire();};
void()	reinf_prefire4	=[	$attack4,	reinf_mainfire1	] {think_prefire();};

void()	reinf_postfire1	=[	$attack3,	reinf_postfire2	] {think_prefire();};
void()	reinf_postfire2	=[	$attack2,	reinf_postfire3	] {think_prefire();};
void()	reinf_postfire3	=[	$attack1,	reinf_postfire4	] {think_prefire();};

void() reinf_fire =
{
	reinf_prefire1();
	self.attack_finished = time;
};



/*
=================================================================
Reinforcer is Idle
=================================================================
*/
void() think_idle =
{
	local entity	targ;

	targ = VisibleMonster();
	if (targ)
	{
		self.attack_state = ATT_DEFENSIVE;
		self.goalentity = targ;
		self.think = self.th_missile;
	}

	ReinforcerThink();
};

void()	reinf_idle1	=[	$stand1,	reinf_idle2	] {think_idle();};
void()	reinf_idle2	=[	$stand2,	reinf_idle3	] {think_idle();};
void()	reinf_idle3	=[	$stand3,	reinf_idle4	] {think_idle();};
void()	reinf_idle4	=[	$stand4,	reinf_idle5	] {think_idle();};
void()	reinf_idle5	=[	$stand5,	reinf_idle6	] {think_idle();};
void()	reinf_idle6	=[	$stand6,	reinf_idle7	] {think_idle();};
void()	reinf_idle7	=[	$stand7,	reinf_idle1	] {think_idle();};

void() reinf_idle =
{
	local float	r;

	r = random() * 7;

	if (r < 1)
		reinf_idle1();
	else if (r < 2)
		reinf_idle2();
	else if (r < 3)
		reinf_idle3();
	else if (r < 4)
		reinf_idle4();
	else if (r < 5)
		reinf_idle5();
	else if (r < 6)
		reinf_idle6();
	else
		reinf_idle7();
};



/*
=================================================================
Reinforcer is Running
=================================================================
*/
void(float dist) think_run =
{
	//----- Stop Chasing Dead Monsters -----------------
	if (GoalMonsterDead())
		ReinfCancelOrder(self);
	
	//----- Attack-Move Order --------------------------
	if (self.attack_state == ATT_FORCED)
	{
		self.goalentity = VisibleMonster();
		if (!self.goalentity)
			self.goalentity = self.targetmark;
	}

	//----- Fire at Visible Target ---------------------
	if (self.goalentity.health > 0)
	{
		if (ClearShot(self.goalentity))
		{
			if (self.search_time < time)
				self.th_missile();
		}
		else
			self.search_time = time + 0.3;
	}

	//----- Test for Healing ---------------------------
	if (self.attack_state == ATT_HEAL)
	{
		if (vlen(self.origin - self.targetmark.origin) < 80)
		{
			ProvideHealing(self.targetmark.goalentity);
			ReinfCancelOrder(self);
		}
	}

	//----- Within Translocator Range ------------------
	if (self.attack_state == ATT_TRANSLOCATE)
	{
		local vector	test;
		test_x = self.goalentity.origin_x - self.origin_x;
		test_y = self.goalentity.origin_y - self.origin_y;
		test_z = 0.0;
		if (vlen(test) < 280)
			reinf_fire();
	}

	//----- Test Contact with Target Marker ------------
	local vector	goalvect;
	local float	goaldist;
	goalvect = self.origin - self.targetmark.origin;
	goalvect_z = goalvect_z * 0.5;
	goaldist = vlen(goalvect);

	if ((self.goalentity == self.targetmark) && !(self.targetmark.health))
	{
		//----- Multi-Order Fix ----------------------------
		if (goaldist < 60)
		{
			traceline(self.origin, self.targetmark.origin, FALSE, self);
			if (trace_ent.classname == "reinforcer")
				goaldist = 0;
		}

		if (goaldist < 20)
		{
			ReinfCancelOrder(self);

			local vector	lookdir;
			lookdir = self.targetmark.dest - self.targetmark.origin;
			if (vlen(lookdir) > 16)
				self.ideal_yaw = vectoyaw(lookdir);
			else
				self.ideal_yaw = self.angles_y;
			return;
		}
	}

	//----- General Updates ----------------------------
	ReinforcerThink();
	if (goaldist < 64)
	{
		self.ideal_yaw = vectoyaw(self.targetmark.origin - self.origin);
		if (walkmove (self.ideal_yaw, dist))
			return;
	}
	movetogoal(dist);
};

void()	reinf_run1	=[	$run1,		reinf_run2	] {think_run(18);};
void()	reinf_run2	=[	$run2,		reinf_run3	] {think_run(14);};
void()	reinf_run3	=[	$run3,		reinf_run4	] {think_run(7);};
void()	reinf_run4	=[	$run4,		reinf_run5	] {think_run(12);};
void()	reinf_run5	=[	$run5,		reinf_run6	] {think_run(14);};
void()	reinf_run6	=[	$run6,		reinf_run7	] {think_run(14);};
void()	reinf_run7	=[	$run7,		reinf_run8	] {think_run(7);};
void()	reinf_run8	=[	$run8,		reinf_run1	] {think_run(11);};

void() reinf_run =
{
	reinf_run8();
};



/*
=================================================================
Reinforcer has been Revived
=================================================================
*/
void()	reinf_alive1	=[	$death12,	reinf_alive2	] {};
void()	reinf_alive2	=[	$death11,	reinf_alive3	] {};
void()	reinf_alive3	=[	$death10,	reinf_alive4	] {};
void()	reinf_alive4	=[	$death9,	reinf_alive5	] {};
void()	reinf_alive5	=[	$paind8,	reinf_alive6	] {};
void()	reinf_alive6	=[	$paind9,	reinf_alive7	] {};
void()	reinf_alive7	=[	$paind10,	reinf_alive8	] {};
void()	reinf_alive8	=[	$paind11,	reinf_alive9	] {};
void()	reinf_alive9	=[	$paind12,	reinf_alive10	] {};
void()	reinf_alive10	=[	$paind13,	reinf_alive11	] {};
void()	reinf_alive11	=[	$paind14,	reinf_alive12	] {};
void()	reinf_alive12	=[	$paind15,	reinf_alive13	] {};
void()	reinf_alive13	=[	$paind16,	reinf_alive14	] {};
void()	reinf_alive14	=[	$paind17,	reinf_alive15	] {};
void()	reinf_alive15	=[	$paind18,	reinf_alive16	] {};
void()	reinf_alive16	=[	$paind19,	reinf_idle	] {ReinfCancelOrder(self);};

void() reinf_alive =
{
	self.health = 50;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	if (!walkmove (0, 0))
	{
		self.nextthink = time + 0.1;
		self.think = reinf_alive;
		self.solid = SOLID_NOT;
		return;
	}

	self.takedamage = DAMAGE_AIM;
	reinf_alive1();
};



/*
=================================================================
Reinforcer has been hit
=================================================================
*/
void(entity attacker, float damage) reinf_pain =
{
	//----- Report Low Health --------------------------
	if (self.pain_finished < time)
	{
		if (self.health <= 30)
		{
			sprint(self.pointer, self.netname);
			sprint(self.pointer, " is low on health\n");
			self.pain_finished = time + 2;

			if (random() < 0.5)
				sound (self, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NONE);
			else
				sound (self, CHAN_VOICE, "enforcer/pain2.wav", 1, ATTN_NONE);
		}
	}

	//----- Turn to Face Attackers ---------------------
	if (!infront(attacker))
	{
		if (!self.goalentity)
			self.ideal_yaw = vectoyaw(attacker.origin - self.origin);
	}
};



/*
=================================================================
Reinforcer is Dead/Dying
=================================================================
*/
void(float dist) think_die =
{
	if (self.selected == TRUE)
		self.selected = FALSE;

	walkmove(self.angles_y, dist);
};

void()	reinf_die1	=[	$death1,	reinf_die2	] {think_die(0);};
void()	reinf_die2	=[	$death2,	reinf_die3	] {think_die(8);};
void()	reinf_die3	=[	$death3,	reinf_die4	] {think_die(5);};
void()	reinf_die4	=[	$death4,	reinf_die5	] {think_die(0);};
void()	reinf_die5	=[	$death5,	reinf_die6	] {think_die(0);};
void()	reinf_die6	=[	$death6,	reinf_die7	] {think_die(0);};
void()	reinf_die7	=[	$death7,	reinf_die8	] {think_die(1);};
void()	reinf_die8	=[	$death8,	reinf_die9	] {think_die(2);};
void()	reinf_die9	=[	$death9,	reinf_die10	] {think_die(4);};
void()	reinf_die10	=[	$death10,	reinf_die11	] {think_die(5);};
void()	reinf_die11	=[	$death11,	reinf_die12	] {think_die(4);};
void()	reinf_die12	=[	$death12,	reinf_die13	] {think_die(1);};
void()	reinf_die13	=[	$death13,	reinf_die14	] {think_die(0);};
void()	reinf_die14	=[	$death14,	reinf_die14	] {think_die(0);};

void() reinf_die =
{
	sprint(self.pointer, self.netname);
	sprint(self.pointer, " has been incapacitated\n");

	sound (self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NONE);

	self.selected = 0;
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;

	ReinfCancelOrder(self);
	reinf_die1();

	setmodel(self.selectmark, "");
};



/*
=================================================================
Spawning the Reinforcers
=================================================================
*/
void(vector startpos) PlaceReinforcer =
{
	local vector	anglepos;
	while (TRUE)
	{
		self.origin_x = startpos_x + (crandom()*RE_SPAWNAREA);
		self.origin_y = startpos_y + (crandom()*RE_SPAWNAREA);
		self.origin_z = startpos_z + 1;

		droptofloor();
		if (walkmove(0,0))
		{
			makevectors(self.angles);
			anglepos = startpos - (v_forward*RE_SPAWNAREA*1.5);
			self.angles_y = vectoyaw(self.origin - anglepos);
			return;
		}
	}
};


void() InitReinforcer =
{
	local vector	startpos, anglepos;
	startpos = self.origin;

	self.skin = self.class;
	self.health = 100;

	if (self.class == RE_BOMBER)
	{
		self.items = self.items + IT_ARMOR2 + IT_ROCKETS;
		self.delay = RE_GRENADEDELAY;
		self.armortype = 0.45;
		self.currentammo = 4;
	}
	else if (self.class == RE_HEALER)
	{
		self.items = self.items + IT_ARMOR3 + IT_SHELLS;
		self.delay = RE_SHOTGUNDELAY;
		self.armortype = 0.55;
		self.currentammo = 8;
	}
	else if (self.class == RE_GUNNER)
	{
		self.items = self.items + IT_ARMOR1 + IT_NAILS;
		self.delay = RE_NAILGUNDELAY;
		self.armortype = 0.3;
		self.currentammo = 80;
	}

	PlaceReinforcer(self.origin);
	ReinfCancelOrder(self);
};


entity(entity spot, float fclass) SpawnReinforcer=
{
	local entity	forcer, smark, tmark;

	//----- Spawn Reinforcer ---------------------------
	forcer = spawn();
	forcer.class = fclass;
	forcer.classname = "reinforcer";
	forcer.origin = spot.origin;
	forcer.angles = spot.angles;
	forcer.selected = FALSE;
	forcer.ideal_yaw = forcer.angles * '0 1 0';
	forcer.yaw_speed = 30;
	forcer.view_ofs = '0 0 24';

	forcer.solid = SOLID_SLIDEBOX;
	forcer.movetype = MOVETYPE_STEP;
	forcer.takedamage = DAMAGE_AIM;
	forcer.pain_finished = time + 2;
	forcer.ack_finished = time + 0.4;

	forcer.th_stand = reinf_idle;
	forcer.th_run = reinf_run;
	forcer.th_missile = reinf_fire;
	forcer.th_pain = reinf_pain;
	forcer.th_alive = reinf_alive;
	forcer.th_die = reinf_die;

	forcer.think = InitReinforcer;
	forcer.nextthink = time + 0.05;

	setmodel(forcer, "progs/enforcer.mdl");
	setsize(forcer, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin(forcer, forcer.origin);

	//----- Spawn Selector Ring ------------------------
	smark = spawn();
	smark.owner = forcer;
	smark.effects = EF_NOSHADOW;
	smark.movetype = MOVETYPE_FLY;

	setmodel(smark, "");
	setsize(smark, '0 0 0', '0 0 0');
	setorigin(smark, forcer.origin);

	//----- Spawn Destination Marker -------------------
	tmark = spawn();
	tmark.owner = forcer;
	tmark.effects = EF_NOSHADOW;
	tmark.movetype = MOVETYPE_FLY;

	setmodel(tmark, "");
	setsize(tmark, '0 0 0', '0 0 0');
	setorigin(tmark, forcer.origin);

	//----- Final Entity Bindings ----------------------
	forcer.owner = self;
	forcer.pointer = self;
	forcer.selectmark = smark;
	forcer.targetmark = tmark;
	return forcer;
};
