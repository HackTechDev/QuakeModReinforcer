
/*
=================================================================
Physics-Enhanced Gib Code
=================================================================
*/
void(string gibname, float dm) ThrowGib =
{
	local entity	gib;
	local vector	flydir;

	gib = spawn();

	gib.movetype = MOVETYPE_BOUNCE;
	gib.solid = SOLID_NOT;

	gib.origin_x = self.origin_x + (crandom()*8);
	gib.origin_y = self.origin_y + (crandom()*8);
	gib.origin_z = self.origin_z + (crandom()*16);

	gib.avelocity_x = random()*600;
	gib.avelocity_y = random()*600;
	gib.avelocity_z = random()*600;

	flydir = normalize(self.damageorg - gib.origin);
	gib.velocity = flydir*dm*5;

	gib.think = SUB_Remove;
	gib.nextthink = time + 15 + random()*10;

	setmodel (gib, gibname);
	setsize (gib, '0 0 0', '0 0 0');
};


void(string gibname, float dm) ThrowHead =
{
	ThrowGib(gibname, dm);

	self.nextthink = time + 0.1;
	self.think = SUB_Remove;
};


