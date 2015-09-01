
/*
=================================================================
Combat.qc -> T_Damage
=================================================================
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	local float	save, take;
	local entity	oldself;

	if (!targ.takedamage)
		return;

	damage_attacker = attacker;

	save = ceil(targ.armortype*damage);
	take = ceil(damage-save);

	if (attacker.classname == targ.classname)
		return;

	local vector	facevec;
	local float	facemul;

	makevectors(targ.angles);
	facevec = normalize(targ.origin - attacker.origin);
	facemul = facevec * v_forward;
	facemul = (facemul * 0.3) + 0.9;

	targ.health = targ.health - (take * facemul);
	targ.damageorg = inflictor.origin - '0 0 12';
	if (targ.health <= 0)
	{
		Killed (targ, attacker);
		return;
	}

	oldself = self;
	self = targ;

	if (self.th_pain)
	{
		self.th_pain(attacker, take);
		if ((skill == 3) && (self.flags & FL_MONSTER))
			self.pain_finished = time + 5;		
	}

	if ((attacker.classname == "reinforcer") &&
	    (self.flags & FL_MONSTER) &&
	    (!self.enemy))
	{
		self.enemy = attacker;
		FoundTarget();
	}

	self = oldself;
};



/*
=================================================================
AI.qc -> FoundTarget
=================================================================
*/
void() FoundTarget =
{
	if (self.enemy.classname == "reinforcer")
	{
		sight_entity = self;
		sight_entity_time = time + 0.4;
	}

	self.show_hostile = time + 0.4;
	SightSound ();
	HuntTarget ();
};



/*
=================================================================
AI.qc -> FindTarget
=================================================================
*/
float() FindTarget =
{
	local entity	client;

	if (sight_entity_time > time)
	{
		client = sight_entity;
		if (client.enemy == self.enemy)
			return FALSE;
	}
	else
	{
		client = lastforcer;
		if (!client)
			return FALSE;
	}

	if (client == self.enemy)
		return FALSE;

	if (client.health <= 0)
		return FALSE;

	if (!visible(client))
		return FALSE;

	if ((range(client) > RANGE_MELEE) && (!infront(client)) && (client.show_hostile < time))
		return FALSE;

	self.enemy = client;
	if (self.enemy.classname != "reinforcer")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "reinforcer")
		{
			self.enemy = world;
			return FALSE;
		}
	}

	FoundTarget();
	return TRUE;
};



/*
=================================================================
AI.qc -> ai_run
=================================================================
*/
void(float dist) ai_run =
{
	local	vector	delta;
	local	float	axis;
	local	float	direct, ang_rint, ang_floor, ang_ceil;

	movedist = dist;
	if (self.enemy.health <= 0)
	{
		self.enemy = world;
		if (self.movetarget)
			self.th_walk ();
		else
			self.th_stand ();
		return;
	}

	self.show_hostile = time + 1;

	enemy_vis = visible(self.enemy);
	if (enemy_vis)
		self.search_time = time + 5;
	else
	{
		if (FindTarget())
			return;
	}

	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);

	if (self.attack_state == AS_MISSILE)
	{
		ai_run_missile ();
		return;
	}
	if (self.attack_state == AS_MELEE)
	{
		ai_run_melee ();
		return;
	}

	if (CheckAnyAttack ())
		return;

	if (self.attack_state == AS_SLIDING)
	{
		ai_run_slide ();
		return;
	}

	if ((lastforcer != self.enemy) && (lastforcer.health > 0))
	{
		local float	distold, distnew;

		distold = vlen(self.enemy.origin - self.origin);
		distnew = vlen(lastforcer.origin - self.origin) * 1.2;

		if (distnew < distold)
		{
			if (FindTarget())
				return;
		}
	}

	movetogoal (dist);
};



/*
=================================================================
Doors.qc -> secret_touch
=================================================================
*/
void() secret_touch =
{
	if (other.classname != "reinforcer")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	
	if (self.message)
	{
		centerprint (other.pointer, self.message);
		sound (other.pointer, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};



/*
=================================================================
Doors.qc -> door_touch
=================================================================
*/
void() door_touch =
{
	if (other.classname != "reinforcer")
		return;
	if (self.owner.attack_finished > time)
		return;

	self.owner.attack_finished = time + 2;

	if (self.owner.message != "")
	{
		centerprint (other.pointer, self.owner.message);
		sound (other.pointer, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}
	
// key door stuff
	if (!self.items)
		return;

// FIXME: blink key on player's status bar
	if ( (self.items & other.pointer.permitems) != self.items )
	{
		if (self.owner.items == IT_KEY1)
		{
			if (world.worldtype == 2)
			{
				centerprint (other.pointer, "You need the silver keycard");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == 1)
			{
				centerprint (other.pointer, "You need the silver runekey");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == 0)
			{
				centerprint (other.pointer, "You need the silver key");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
		}
		else
		{
			if (world.worldtype == 2)
			{
				centerprint (other.pointer, "You need the gold keycard");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == 1)
			{
				centerprint (other.pointer, "You need the gold runekey");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);			
			}
			else if (world.worldtype == 0)
			{
				centerprint (other.pointer, "You need the gold key");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
		}
		return;
	}

	other.pointer.permitems = other.pointer.permitems - self.items;
	self.touch = SUB_Null;
	if (self.enemy)
		self.enemy.touch = SUB_Null;	// get paired door
	door_use ();
};



/*
=================================================================
Doors.qc -> door_trigger_touch
=================================================================
*/
void() door_trigger_touch =
{
	if (other.health <= 0)
		return;
	if (other.classname == "player")
		return;
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 1;

	activator = other;

	self = self.owner;
	door_use ();
};



/*
=================================================================
Triggers.qc -> multi_trigger
=================================================================
*/
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "reinforcer")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};



/*
=================================================================
Triggers.qc -> multi_touch
=================================================================
*/
void() multi_touch =
{
	if (other.classname != "reinforcer")
		return;
	
// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};



/*
=================================================================
Triggers.qc -> counter_use
=================================================================
*/
void() counter_use =
{
	local string junk;

	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (activator.classname == "translocator")
		activator = activator.owner;

	if (self.count != 0)
	{
		if (activator.classname == "reinforcer" && (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator.pointer, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator.pointer, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator.pointer, "Only 2 more to go...");
			else
				centerprint (activator.pointer, "Only 1 more to go...");
		}
		return;
	}
	
	if (activator.classname == "reinforcer" && (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator.pointer, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
};



/*
=================================================================
Buttons.qc -> button_touch
=================================================================
*/
void() button_touch =
{
	if (other.classname != "reinforcer")
		return;
	self.enemy = other;
	button_fire ();
};



/*
=================================================================
Plats.qc -> plat_center_touch
=================================================================
*/
void() plat_center_touch =
{
	if (other.classname != "reinforcer")
		return;
		
	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == STATE_BOTTOM)
		plat_go_up ();
	else if (self.state == STATE_TOP)
		self.nextthink = self.ltime + 1;	// delay going down
};



/*
=================================================================
Plats.qc -> plat_outside_touch
=================================================================
*/
void() plat_outside_touch =
{
	if (other.classname != "reinforcer")
		return;

	if (other.health <= 0)
		return;
		
//dprint ("plat_outside_touch\n");
	self = self.enemy;
	if (self.state == STATE_TOP)
		plat_go_down ();
};



/*
=================================================================
Triggers.qc -> teleport_touch
=================================================================
*/
void(vector startpos) PlaceReinforcer;
void() teleport_touch =
{
	local entity	destin;

	if (self.targetname)
	{
		if (self.nextthink < time)
		{
			return;
		}
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "reinforcer")
			return;
	}

	if ((other.health <= 0) || (other.solid != SOLID_SLIDEBOX))
		return;

	SUB_UseTargets ();

	destin = find (world, targetname, self.target);
	if (!destin)
		objerror ("couldn't find target");

	if (other.classname == "player")
	{
		self = other;
		ViewCentre(destin.origin);
		spawn_tfog(self.origin);
		return;
	}

	spawn_tfog(other.origin);
	other.angles = destin.mangle;
	other.flags = other.flags - other.flags & FL_ONGROUND;

	if (other.classname == "reinforcer")
	{
		local entity	temp;
		temp = self;
		self = other;
		PlaceReinforcer(destin.origin);
		ReinfCancelOrder(self);

		if (self.selected)
		{
			self = self.pointer;
			ViewCentre(destin.origin);
		}

		self = temp;
	}
	else
		setorigin (other, destin.origin);

	spawn_tfog (other.origin);
	spawn_tdeath(other.origin, other);
};



/*
=================================================================
Subs.qc -> SUB_UseTargets
=================================================================
*/
void() SUB_UseTargets =
{
	local entity t, skeep, okeep, act;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}
	
	
//
// print the message
//
	if (activator.classname == "reinforcer" && self.message != "")
	{
		centerprint (activator.owner, self.message);
		if (!self.noise)
			sound (activator.owner, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find (t, targetname, self.killtarget);
			if (!t)
				return;
			remove (t);
		} while ( 1 );
	}
	
//
// fire targets
//
	if (self.target)
	{
		t = world;
		skeep = self;
		okeep = other;
		act = activator;

		do
		{
			t = find(t, targetname, self.target);
			if (!t)
			{
				return;
			}

			self = t;
			other = skeep;

			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use();
			}

			self = skeep;
			other = okeep;
			activator = act;
		}
		while (TRUE);
	}
};



