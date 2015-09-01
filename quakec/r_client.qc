
//DONE: fix rune-collection
//DONE: fix teleporting
//DONE: try to stop Reinforcers obstructing camera
//DONE: implement attack-move command
//DONE: correct DP shadowing
//DONE: check for no obstructions when moving camera
//DONE: add look-at command
//DONE: implement Reinforcer naming
//DONE: add translocator
//DONE: increase rear-hit damage
//DONE: tweak ability ammo
//DONE: stop spawning camera in walls
//DONE: correct multi-move orders
//DONE-ISH: resize shambler ring

//FIXME: restore intermission
//FIXME: add target leading
//FIXME: improve Reinforcer targeting system (include range)
//FIXME: fix monster sight alerting
//FIXME: end of episode bug


//FIXME: move this stuff to the new defs file

float	modelindex_eyes, modelindex_player;
float	intermission_running;
float	intermission_exittime;

float	VIEWER_ACCEL	= 8000;
float	VIEWER_DAMPEN	= 0.82;
float	VIEWER_JUMPVEL	= 400;
float	VIEWER_JUMPDAMP	= 0.56;
float	VIEWER_CENTDIST	= 192;

float	POINT_MAXANGLE	= 45;
float	POINT_WALLDROP	= 64;

float	P_NULL		= 0;
float	P_LOCATION	= 1;
float	P_BADLOC	= 2;
float	P_ENFORCER	= 3;
float	P_MONSTERSMALL	= 4;
float	P_MONSTERLARGE	= 5;
float	P_FORCEATTACK	= 6;
float	P_TRANSLOCATE	= 7;

float	RE_BOMBER	= 1;
float	RE_GUNNER	= 2;
float	RE_HEALER	= 3;

float	KEY_UP		= 1;
float	KEY_DOWN	= 2;
float	KEY_LEFT	= 4;
float	KEY_RIGHT	= 8;
float	KEY_LEFTCLICK	= 16;
float	KEY_RIGHTCLICK	= 32;
float	KEY_SHIFT	= 64;
float	KEY_CONTROL	= 128;
float	KEY_Q		= 256;
float	KEY_E		= 512;
float	KEY_SPACEBAR	= 1024;

.entity	pointer;
.entity	bomber;
.entity	gunner;
.entity	healer;

.vector	truevel;
.float	z_jump;
.float	z_fix;

.float	keys;
.float	keyhold;
.float	lastimpulse;
.float	permitems;

.entity	selectmark;
.entity	targetmark;
.float	selected;
.float	class;

float	cvar_names;

entity(entity spot, float fclass) SpawnReinforcer;
void(entity forcer) ReinfCancelOrder;
void(entity forcer, entity attack) ReinfAttackOrder;
void(entity forcer, entity attack) ReinfSpecialQOrder;
void(entity forcer, vector lookto) ReinfDirectionOrder;
void(entity forcer, vector spot, vector surfangle) ReinfMoveOrder;
void(entity forcer, vector spot, vector surfangle) ReinfForceAttOrder;
void(entity forcer, vector spot) ReinfTranslocateOrder;
void(entity forcer, vector spot) ReinfForceSpecialQ;
void(entity forcer, vector spot) ReinfHealOrder;



/*
=================================================================
Player/Reinforcer Start Positions
=================================================================
*/
void() info_intermission = {};
void() info_player_deathmatch = {};
void() info_player_start = {};
void() info_player_start2 = {};
void() info_player_coop = {};
void() testplayerstart = {};



/*
=================================================================
Changelevel Trigger
=================================================================
*/

void() changelevel_touch =
{
	if (other.classname != "reinforcer")
		return;

	SUB_UseTargets();
	changelevel(self.map);
};

void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");

	InitTrigger ();
	self.touch = changelevel_touch;
};



/*
=================================================================
Set Reinforcer Names Based on Teamplay CVar
=================================================================
*/
void() NameForcers =
{
	if (cvar_names == TRUE)
	{
		local float	namefile;
		namefile = fopen("names.txt", 0);

		if (namefile >= 0)
		{
			self.healer.netname = strzone(fgets(namefile));
			self.bomber.netname = strzone(fgets(namefile));
			self.gunner.netname = strzone(fgets(namefile));
			fclose(namefile);
			return;
		}
	}

	if (teamplay == 1)
	{
		self.bomber.netname = "Hollenshead";
		self.gunner.netname = "Carmack";
		self.healer.netname = "Willits";
	}
	else if (teamplay == 2)
	{
		self.bomber.netname = "Quake Matt";
		self.gunner.netname = "Ninja Will";
		self.healer.netname = "Evil Rolf";
	}
	else if (teamplay == 3)
	{
		self.bomber.netname = "Renegade";
		self.gunner.netname = "Sweeper";
		self.healer.netname = "Saint";
	}
	else if (teamplay == 4)
	{
		self.bomber.netname = "Dave";
		self.gunner.netname = "Jim";
		self.healer.netname = "Brian";
	}
	else if (teamplay == 5)
	{
		self.bomber.netname = "Brock";
		self.gunner.netname = "Lauren";
		self.healer.netname = "Malcolm";
	}
	else if (teamplay == 6)
	{
		self.bomber.netname = "Kain";
		self.gunner.netname = "Raziel";
		self.healer.netname = "Melchiah";
	}
	else if (teamplay == 7)
	{
		self.bomber.netname = "Thor";
		self.gunner.netname = "Loki";
		self.healer.netname = "Odin";
	}
	else if (teamplay == 8)
	{
		self.bomber.netname = "Zeus";
		self.gunner.netname = "Reaper";
		self.healer.netname = "Omicron";
	}
	else if (teamplay == 9)
	{
		self.bomber.netname = "Corporal Hicks";
		self.gunner.netname = "Private Hudson";
		self.healer.netname = "Private Drake";
	}
	else if (teamplay == 10)
	{
		self.bomber.netname = "Lemmy";
		self.gunner.netname = "Nicko";
		self.healer.netname = "Ozzy";
	}
	else if (teamplay == 11)
	{
		self.bomber.netname = "Mad Dog";
		self.gunner.netname = "Adder";
		self.healer.netname = "Timber Wolf";
	}
	else if (teamplay == 12)
	{
		self.bomber.netname = "Syphon";
		self.gunner.netname = "Cyclone";
		self.healer.netname = "Sentinel";
	}
	else
	{
		self.bomber.netname = "Bomber";
		self.gunner.netname = "Gunner";
		self.healer.netname = "Healer";
	}
};



/*
=================================================================
Miscellaneous Functions
=================================================================
*/

float(float key) TapKey =
{
	if (self.keyhold & key)
		return FALSE;

	if (self.keys & key)
		return TRUE;

	return FALSE;
};


void() UpdateHUD =
{
	local entity	forcer;

	if (self.bomber.selected)
	{
		if ((!self.gunner.selected) && (!self.healer.selected))
			forcer = self.bomber;
	}
	else if (self.gunner.selected)
	{
		if (!self.healer.selected)
			forcer = self.gunner;
	}
	else if (self.healer.selected)
		forcer = self.healer;

	if (forcer)
	{
		self.items = forcer.items + self.permitems;
		self.health = forcer.health;
		self.currentammo = forcer.currentammo;
	}
	else
	{
		self.items = 0 + self.permitems;
		self.health = 100;
		self.currentammo = 0;
	}
};


float(vector org) CheckHullSpace =
{
	if (pointcontents(org) == CONTENT_SOLID)
		return FALSE;

	if (pointcontents(org + '0 0 32') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '0 0 -24') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '16 0 0') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '-16 0 0') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '0 16 0') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '0 -16 0') == CONTENT_SOLID)
		return FALSE;

	if (pointcontents(org + '16 16 32') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '-16 16 32') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '16 -16 32') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '-16 -16 32') == CONTENT_SOLID)
		return FALSE;

	if (pointcontents(org + '16 16 -24') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '-16 16 -24') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '16 -16 -24') == CONTENT_SOLID)
		return FALSE;
	if (pointcontents(org + '-16 -16 -24') == CONTENT_SOLID)
		return FALSE;

	return TRUE;
};



/*
=================================================================
Retrieving Level and Reinforcer Parms
=================================================================
*/
void() SetChangeParms =
{
};


void() SetNewParms =
{
};



/*
=================================================================
Issuing Group Orders
=================================================================
*/
void() GroupDeselect =
{
	if (!self.keys & KEY_SHIFT)
	{
		self.bomber.selected = FALSE;
		self.gunner.selected = FALSE;
		self.healer.selected = FALSE;
	}
};


void() IssueMoveOrders =
{
	if (self.bomber.selected)
		ReinfMoveOrder(self.bomber, self.pointer.origin, self.pointer.angles);
	if (self.gunner.selected)
		ReinfMoveOrder(self.gunner, self.pointer.origin, self.pointer.angles);
	if (self.healer.selected)
		ReinfMoveOrder(self.healer, self.pointer.origin, self.pointer.angles);
};

void() IssueCancelOrders =
{
	if (self.bomber.selected)
	{
		ReinfCancelOrder(self.bomber);
		self.bomber.ideal_yaw = vectoyaw(self.pointer.origin - self.bomber.origin);
	}
	if (self.gunner.selected)
	{
		ReinfCancelOrder(self.gunner);
		self.gunner.ideal_yaw = vectoyaw(self.pointer.origin - self.gunner.origin);
	}
	if (self.healer.selected)
	{
		ReinfCancelOrder(self.healer);
		self.healer.ideal_yaw = vectoyaw(self.pointer.origin - self.healer.origin);
	}
};

void() IssueDirectionOrders =
{
	if (self.bomber.selected)
		ReinfDirectionOrder(self.bomber, self.pointer.origin);
	if (self.gunner.selected)
		ReinfDirectionOrder(self.gunner, self.pointer.origin);
	if (self.healer.selected)
		ReinfDirectionOrder(self.healer, self.pointer.origin);
};

void() IssueForceAttOrder =
{
	if (self.bomber.selected)
		ReinfForceAttOrder(self.bomber, self.pointer.origin, self.pointer.angles);
	if (self.gunner.selected)
		ReinfForceAttOrder(self.gunner, self.pointer.origin, self.pointer.angles);
	if (self.healer.selected)
		ReinfForceAttOrder(self.healer, self.pointer.origin, self.pointer.angles);
};

void(entity targ) IssueAttackOrder =
{
	if (self.bomber.selected)
		ReinfAttackOrder(self.bomber, targ);
	if (self.gunner.selected)
		ReinfAttackOrder(self.gunner, targ);
	if (self.healer.selected)
		ReinfAttackOrder(self.healer, targ);
};

void(entity targ) IssueSpecialQOrder =
{
	if (self.bomber.selected)
		ReinfSpecialQOrder(self.bomber, targ);
	if (self.gunner.selected)
		ReinfSpecialQOrder(self.gunner, targ);
	if (self.healer.selected)
		ReinfHealOrder(self.healer, self.pointer.origin);
};

void() IssueTranslocateOrder =
{
	if (self.bomber.selected)
		ReinfTranslocateOrder(self.bomber, self.pointer.origin);
	if (self.gunner.selected)
		ReinfTranslocateOrder(self.gunner, self.pointer.origin);
	if (self.healer.selected)
		ReinfTranslocateOrder(self.healer, self.pointer.origin);
};

void() IssueForceSpecialQ =
{
	local vector	spot;
	spot = self.pointer.origin + (trace_plane_normal*20);

	if (self.bomber.selected)
		ReinfForceSpecialQ(self.bomber, spot);
	if (self.gunner.selected)
		ReinfForceSpecialQ(self.gunner, spot);
	if (self.healer.selected)
		ReinfHealOrder(self.healer, self.pointer.origin);
};



/*
=================================================================
Issuing Orders from the Viewpoint
=================================================================
*/
void() OrdersOnMonster =
{
	if (TapKey(KEY_RIGHTCLICK))
	{
		if (self.keys & KEY_Q)
			IssueSpecialQOrder(trace_ent);
		else
			IssueAttackOrder(trace_ent);
	}

	if (TapKey(KEY_SPACEBAR))
	{
		IssueCancelOrders();
	}
};


void() OrdersOnForcer =
{
	if (TapKey(KEY_LEFTCLICK))
		trace_ent.selected = TRUE;

	else if (TapKey(KEY_RIGHTCLICK))
	{
		if (self.keys & KEY_Q)
			IssueForceSpecialQ();
	}

	if (TapKey(KEY_SPACEBAR))
	{
		IssueCancelOrders();
	}
};


void() OrdersOnWall =
{
	if (TapKey(KEY_RIGHTCLICK))
	{
		if (self.keys & KEY_Q)
			IssueForceSpecialQ();

		else if (self.keys & KEY_CONTROL)
			IssueForceAttOrder();
	}

	if (TapKey(KEY_SPACEBAR))
	{
		IssueCancelOrders();
	}
};


void() OrdersOnFloor =
{
	if (TapKey(KEY_RIGHTCLICK))
	{
		if (self.keys & KEY_Q)
			IssueForceSpecialQ();
		else if (self.keys & KEY_E)
			IssueTranslocateOrder();
		else if (self.keys & KEY_CONTROL)
			IssueForceAttOrder();
		else
			IssueMoveOrders();
	}

	if (self.keys & KEY_RIGHTCLICK)
	{
		IssueDirectionOrders();
	}

	if (TapKey(KEY_SPACEBAR))
	{
		IssueCancelOrders();
	}
};



/*
=================================================================
Spawn and Control Player Pointer/Cursor
=================================================================
*/
void() SpawnPointer =
{
	local entity	point;

	point = spawn();
	point.owner = self;
	point.class = P_NULL;
	point.classname = "pointer";
	point.movetype = MOVETYPE_NOCLIP;
	point.effects = EF_NOSHADOW;

	setmodel(point, "");
	setsize(point, '0 0 0', '0 0 0');
	setorigin(point, self.origin);

	self.pointer = point;
};


void(float x) SetPointer =
{
	if (x == self.pointer.class)
		return;

	if (x == P_LOCATION)
		setmodel(self.pointer, "progs/p_moveto.mdl");
	else if (x == P_BADLOC)
		setmodel(self.pointer, "progs/p_badmov.mdl");
	else if (x == P_ENFORCER)
		setmodel(self.pointer, "progs/p_enforc.mdl");
	else if (x == P_MONSTERSMALL)
		setmodel(self.pointer, "progs/p_msmall.mdl");
	else if (x == P_MONSTERLARGE)
		setmodel(self.pointer, "progs/p_mlarge.mdl");
	else if (x == P_FORCEATTACK)
		setmodel(self.pointer, "progs/p_attack.mdl");
	else if (x == P_TRANSLOCATE)
		setmodel(self.pointer, "progs/p_tranto.mdl");
	else
		setmodel(self.pointer, "");

	self.pointer.class = x;
};


void() UpdatePointer =
{
	local vector	nangle, oldpos, oldnor, temp;

	makevectors(self.v_angle);
	traceline(self.origin, self.origin + (v_forward*2048), FALSE, self.pointer);
	nangle = vectoangles(trace_plane_normal);
	oldnor = trace_plane_normal;
	oldpos = trace_endpos;

	if ((self.keys & KEY_LEFTCLICK) && !(self.keyhold & KEY_LEFTCLICK))
		GroupDeselect();

	if (trace_fraction == 1.0)
	{
		SetPointer(P_NULL);
		return;
	}

	if (trace_ent.takedamage == DAMAGE_AIM)
	{
		//----- Pointing at Monster ----------------
		if (trace_ent.flags & FL_MONSTER)
		{
			self.pointer.origin = trace_ent.origin;
			self.pointer.angles = '0 0 0';

			if (trace_ent.classname == "monster_shambler")
				SetPointer(P_MONSTERLARGE);
			else
				SetPointer(P_MONSTERSMALL);

			OrdersOnMonster();
		}

		//----- Pointing at Reinforcer -------------
		else if (trace_ent.classname == "reinforcer")
		{
			self.pointer.origin = trace_ent.origin;
			self.pointer.angles = '0 0 0';
			SetPointer(P_ENFORCER);

			OrdersOnForcer();
		}
	}
	else
	{
		//----- Find Floor from Wall ---------------
		if (nangle_x <= POINT_MAXANGLE)
		{
			if ((!self.keys & KEY_CONTROL) && (!self.keys & KEY_Q))
			{
				temp = trace_endpos + (trace_plane_normal*8);
				traceline(temp, temp - ('0 0 1' * POINT_WALLDROP), TRUE, self);
				nangle = vectoangles(trace_plane_normal);

				if (trace_fraction == 1.0)
					nangle_x = 0;
			}
		}

		//----- Pointer on Floor -------------------
		if ((nangle_x > POINT_MAXANGLE) && (nangle_x < 100))
		{
			self.pointer.origin = trace_endpos + (trace_plane_normal*4);
			self.pointer.angles = nangle;
			if ((self.keys & KEY_CONTROL) || (self.keys & KEY_Q))
				SetPointer(P_FORCEATTACK);
			else if (self.keys & KEY_E)
				SetPointer(P_TRANSLOCATE);
			else
				SetPointer(P_LOCATION);

			OrdersOnFloor();
		}

		//----- Inaccessible Surface ---------------
		else
		{
			self.pointer.origin = oldpos + (oldnor*4);
			self.pointer.angles = vectoangles(oldnor);
			trace_plane_normal = oldnor;
			if ((self.keys & KEY_CONTROL) || (self.keys & KEY_Q))
				SetPointer(P_FORCEATTACK);
			else
				SetPointer(P_BADLOC);

			OrdersOnWall();
		}
	}
};



/*
=================================================================
Player View Movement and Control
=================================================================
*/
void(vector spot) ViewCentre =
{
	local vector	viewpos;
	local float	found;

	while (!(found))
	{
		viewpos_x = spot_x + (crandom()*VIEWER_CENTDIST);
		viewpos_y = spot_y + (crandom()*VIEWER_CENTDIST);
		viewpos_z = spot_z + (random()*128);

		if (CheckHullSpace(viewpos))
		{
			traceline(viewpos, spot, TRUE, world);
			if (trace_fraction != 1.0)
				found = FALSE;
			else
				found = TRUE;
		}
	}

	self.truevel = '0 0 0';
	self.origin = viewpos;
	self.angles = vectoangles(spot - viewpos);
	self.angles_x = 360 - self.angles_x;
	self.fixangle = TRUE;
};


void() ViewerMovement =
{
	//----- Check OnGround Flag ------------------------
	if (!(self.flags & FL_ONGROUND))
		self.flags = self.flags + FL_ONGROUND;

	//----- Modify Angles for Z-Fix --------------------
	local vector view;
	view = self.v_angle;
	if (self.z_fix)
		view_x = 0;

	//----- View-Oriented Motion -----------------------
	local vector	v;
	makevectors(view);
	if (self.keys & KEY_UP)
		v = v_forward;
	if (self.keys & KEY_DOWN)
		v = v - v_forward;
	if (self.keys & KEY_LEFT)
		v = v - v_right;
	if (self.keys & KEY_RIGHT)
		v = v + v_right;
	v = normalize(v);
	self.truevel = self.truevel + (v * VIEWER_ACCEL * frametime);

	//----- Dampen Motion ------------------------------
	local float	dampview, dampjump;
	dampview = 1 / (((1 - VIEWER_DAMPEN) * (frametime * 100)) + 1);
	dampjump = 1 / (((1 - VIEWER_JUMPDAMP) * (frametime * 100)) + 1);
	self.truevel = self.truevel * dampview;
	self.z_jump = self.z_jump * dampjump;

	//----- Output Velocity to Engine ------------------
	self.truevel_z = self.truevel_z + self.z_jump;
	self.velocity = self.truevel + ('0 0 800' * frametime);
};



/*
=================================================================
Client-Server Procedures
=================================================================
*/
void() CheckExtensions =
{
	if (cvar("pr_checkextension"))
	{
		if (checkextension("FRIK_FILE"))
			cvar_names = TRUE;
	}
};


void() PutClientInServer =
{
	local entity	spot;
	spot = find(world, classname, "info_player_start");

	self.classname = "player";
	self.health = 100;
	self.permitems = 0;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.permitems = 0;
	self.view_ofs = '0 0 16';
	self.z_jump = 0;
	self.z_fix = TRUE;

	self.keys = 0;
	self.keyhold = 0;

	setmodel (self, "progs/player.mdl");
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	ViewCentre(spot.origin);
	
	self.bomber = SpawnReinforcer(spot, RE_BOMBER);
	self.gunner = SpawnReinforcer(spot, RE_GUNNER);
	self.healer = SpawnReinforcer(spot, RE_HEALER);

	CheckExtensions();
	SpawnPointer();
	NameForcers();
};


void() ClientKill =
{
};

void() ClientConnect =
{
};

void() ClientDisconnect =
{
};

void(entity targ, entity attacker) ClientObituary =
{
};



/*
=================================================================
Keyboard Input and Impulses
=================================================================
*/
void(float key) PressKey =
{
	if (!(self.keys & key))
		self.keys = self.keys + key;
};


void(float key) ReleaseKey =
{
	if (self.keys & key)
		self.keys = self.keys - key;
};


void() ReadCursorKeys =
{
	//----- No Movement Early Exit ---------------------
	local vector	vel;
	vel = self.velocity;
	vel_z = 0;
	if (vlen(vel) < 1)
	{
		ReleaseKey(KEY_UP);
		ReleaseKey(KEY_DOWN);
		ReleaseKey(KEY_LEFT);
		ReleaseKey(KEY_RIGHT);
		return;
	}

	//----- Calculate Momvement Angle ------------------
	local float	ang;
	ang = vectoyaw(vel) - self.v_angle_y;
	while (ang >= 180)
		ang = ang - 360;

	//----- Test for Up Key ----------------------------
	if ((ang > -80) && (ang < 80))
		PressKey(KEY_UP);
	else
		ReleaseKey(KEY_UP);

	//----- Test for Down Key --------------------------
	if ((ang > 100) || (ang < -100))
		PressKey(KEY_DOWN);
	else
		ReleaseKey(KEY_DOWN);

	//----- Test for Left Key --------------------------
	if ((ang < 170) && (ang > 10))
		PressKey(KEY_LEFT);
	else
		ReleaseKey(KEY_LEFT);

	//----- Test for Right Key -------------------------
	if ((ang > -170) && (ang < -10))
		PressKey(KEY_RIGHT);
	else
		ReleaseKey(KEY_RIGHT);
};


void() PlayerImpulses =
{
	//----- Toggle Z-Movement Fix ----------------------
	if (self.impulse == 29)
		self.z_fix = TRUE - self.z_fix;

	//----- View Jump Up -------------------------------
	if (self.impulse == 30)
		self.z_jump = self.z_jump + VIEWER_JUMPVEL;

	//----- View Jump Down -----------------------------
	if (self.impulse == 31)
		self.z_jump = self.z_jump - VIEWER_JUMPVEL;

	//----- Left Mouse Button --------------------------
	if (self.button0)
		PressKey(KEY_LEFTCLICK);
	else
		ReleaseKey(KEY_LEFTCLICK);

	//----- Right Mouse Button -------------------------
	if (self.button2)
		PressKey(KEY_RIGHTCLICK);
	else
		ReleaseKey(KEY_RIGHTCLICK);

	//----- Special Order from Q -----------------------
	if (self.impulse == 21)
		PressKey(KEY_Q);
	else if (self.impulse == 22)
		ReleaseKey(KEY_Q);

	//----- Special Order from E -----------------------
	if (self.impulse == 23)
		PressKey(KEY_E);
	else if (self.impulse == 24)
		ReleaseKey(KEY_E);

	//----- Holding Shift Key --------------------------
	if (self.impulse == 41)
		PressKey(KEY_SHIFT);
	else if (self.impulse == 42)
		ReleaseKey(KEY_SHIFT);

	//----- Holding Control Key ------------------------
	if (self.impulse == 43)
		PressKey(KEY_CONTROL);
	else if (self.impulse == 44)
		ReleaseKey(KEY_CONTROL);

	//----- Holding Space Bar --------------------------
	if (self.impulse == 45)
		PressKey(KEY_SPACEBAR);
	else if (self.impulse == 46)
		ReleaseKey(KEY_SPACEBAR);

	//----- Key-Select Healer --------------------------
	if (self.impulse == 101)
	{
		GroupDeselect();
		if (self.healer.health > 0)
			self.healer.selected = TRUE;
		if (self.lastimpulse == 101)
			ViewCentre(self.healer.origin);
	}

	//----- Key-Select Bomber --------------------------
	if (self.impulse == 102)
	{
		GroupDeselect();
		if (self.bomber.health > 0)
			self.bomber.selected = TRUE;
		if (self.lastimpulse == 102)
			ViewCentre(self.bomber.origin);
	}

	//----- Key-Select Gunner --------------------------
	if (self.impulse == 103)
	{
		GroupDeselect();
		if (self.gunner.health > 0)
			self.gunner.selected = TRUE;
		if (self.lastimpulse == 103)
			ViewCentre(self.gunner.origin);
	}

	//----- Print Version Details ----------------------
	if (self.impulse == 100)
		sprint(self, "Reinforcer for Quake\n  by Matthew Lawrence\n    version 1.1 16/08/05\n");

	//----- Finish Impulses ----------------------------
	if (self.impulse > 0)
		self.lastimpulse = self.impulse;
	if ((self.button0) || (self.button2))
		self.lastimpulse = 0;
	self.impulse = 0;
};



/*
=================================================================
Per-Frame Player Thinking Routines
=================================================================
*/
void() PlayerPreThink =
{
	PlayerImpulses();
	ReadCursorKeys();
	ViewerMovement();

	if (self.pointer)
		UpdatePointer();

	UpdateHUD();
};


void() PlayerPostThink =
{
	self.velocity = '0 0 0';
	self.keyhold = self.keys;
};


