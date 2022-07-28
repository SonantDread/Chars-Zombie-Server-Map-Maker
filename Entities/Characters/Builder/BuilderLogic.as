// Builder logic

#include "Hitters.as";
//#include "Knocked.as";
#include "BuilderCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "MaterialCommon.as";
#include "BuilderHittable.as";
#include "PlacementCommon.as";
#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";
#include "BlobIndexer.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.0f;

void onInit(CBlob@ this)
{	
	this.set_bool("cicleselected", true);
	this.set_u8("brushsize", 6);
	//this.set_f32("pickaxe_distance", 10.0f);
	this.set_f32("gib health", -1.5f);

	this.Tag("player");
	this.Tag("flesh");

	this.Tag("respawn");
	InitRespawnCommand(this);
	InitClasses(this);
	this.Tag("change class drop inventory");

	HitData hitdata;
	this.set("hitdata", hitdata);

	this.addCommandID("pickaxe");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));
	
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_down | CBlob::map_collide_up);
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	// activate/throw
	if(ismyplayer)
	{
		Pickaxe(this);
		CBlob@ carried = this.getCarriedBlob();
		/*
		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				//client_SendThrowOrActivateCommand(this);
			}
		}
		*/
		if(this.isKeyJustPressed(key_action1))
		{
			if(carried !is null)
			{
				carried.server_setTeamNum(this.getTeamNum());
			}
		}

		if (this.get_bool("phaseon"))
		{
			this.getShape().getConsts().mapCollisions = false;
			this.getShape().getConsts().collidable = false;
			this.getSprite().SetZ(1000.0f);
		}
		else if (!this.get_bool("phaseon"))
		{
			this.getShape().getConsts().mapCollisions = true;
			this.getShape().getConsts().collidable = true;
			this.getSprite().SetZ(0.0f);
		}
		else if(this.isKeyPressed(key_action1) && !this.isKeyPressed(key_inventory)) //Don't let the builder place blocks if he/she is selecting which one to place
		{
			BlockCursor @bc;
			this.get("blockCursor", @bc);

			HitData@ hitdata;
			this.get("hitdata", @hitdata);
			hitdata.blobID = 0;
			hitdata.tilepos = bc.buildable ? bc.tileAimPos : Vec2f(-8, -8);	
		}
	}
	// get rid of the built item
	if(this.isKeyJustPressed(key_pickup)|| this.isKeyJustPressed(key_action2))
	{
		this.set_u8("buildblob", 255);
		this.set_TileType("buildtile", 0);

		CBlob@ blob = this.getCarriedBlob();
		if(blob !is null && blob.hasTag("temp blob"))
		{
			blob.Untag("temp blob");
			blob.server_Die();
		}
	}
}

void SendHitCommand(CBlob@ this, CBlob@ blob, const Vec2f tilepos, const Vec2f attackVel, const f32 attack_power)
{
	CBitStream params;
	params.write_netid(blob is null? 0 : blob.getNetworkID());
	params.write_Vec2f(tilepos);
	params.write_Vec2f(attackVel);
	params.write_f32(attack_power);

	this.SendCommand(this.getCommandID("pickaxe"), params);
}

bool RecdHitCommand(CBlob@ this, CBitStream@ params)
{
	u16 blobID;
	Vec2f tilepos, attackVel;
	f32 attack_power;

	if(!params.saferead_netid(blobID))
		return false;
	if(!params.saferead_Vec2f(tilepos))
		return false;
	if(!params.saferead_Vec2f(attackVel))
		return false;
	if(!params.saferead_f32(attack_power))
		return false;

	if(blobID == 0)
	{
		CMap@ map = getMap();
		if(map !is null)
		{
			if(map.getSectorAtPosition(tilepos, "no build") is null)
			{
				if (getNet().isServer())
				{
					this.server_HitMap(tilepos, attackVel, 1.0f, Hitters::builder);
				}
			}
		}
	}
	else
	{
		CBlob@ blob = getBlobByNetworkID(blobID);
		if(blob !is null)
		{
			bool isdead = blob.hasTag("dead");

			if(isdead) //double damage to corpses
			{
				attack_power *= 2.0f;
			}
			if (getNet().isServer())
			{
				const bool teamHurt = !blob.hasTag("flesh") || isdead;
				this.server_Hit(blob, tilepos, attackVel, attack_power, Hitters::builder, teamHurt);
			}
		}
	}
	return true;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(0, -16), this, SpawnCmd::buildMenu, "Change class", params);		
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("pickaxe"))
	{
		if(!RecdHitCommand(this, params))
			warn("error when recieving pickaxe command");
	}

	if (cmd == SpawnCmd::buildMenu || cmd == SpawnCmd::changeClass)
	{
		onRespawnCommand(this, cmd, params);
	}
}

//helper class to reduce function definition cancer
//and allow passing primitives &inout
class SortHitsParams
{
	Vec2f aimPos;
	Vec2f tilepos;
	Vec2f pos;
	bool justCheck;
	bool extra;
	bool hasHit;
	HitInfo@ bestinfo;
	f32 bestDistance;
};

void Pickaxe(CBlob@ this)
{
	HitData@ hitdata;
	CSprite @sprite = this.getSprite();
	bool strikeAnim = sprite.isAnimation("strike");

	if(!strikeAnim)
	{
		this.get("hitdata", @hitdata);
		hitdata.blobID = 0;
		hitdata.tilepos = Vec2f_zero;
		return;
	}

	// no damage cause we just check hit for cursor display
	bool justCheck = !sprite.isFrameIndex(hit_frame);
	bool adjusttime = sprite.getFrameIndex() < hit_frame - 1;

	// pickaxe!

	this.get("hitdata", @hitdata);

	if(hitdata is null) return;

	Vec2f blobPos = this.getPosition();
	Vec2f aimPos = this.getAimPos();
	Vec2f aimDir = aimPos - blobPos;

	// get tile surface for aiming at little static blobs
	Vec2f normal = aimDir;
	normal.Normalize();

	Vec2f attackVel = normal;

	hitdata.blobID = 0;
	hitdata.tilepos = Vec2f_zero;

	f32 arcdegrees = 90.0f;

	f32 aimangle = aimDir.Angle();
	Vec2f pos = blobPos;
	f32 radius = this.getRadius();
	CMap@ map = this.getMap();
	bool dontHitMore = false;

	bool hasHit = false;

	Vec2f tilepos = blobPos;
	Vec2f surfacepos;
	map.rayCastSolid(aimPos, aimPos, surfacepos);

	Vec2f surfaceoff = (tilepos - surfacepos);
	f32 surfacedist = surfaceoff.Normalize();
	tilepos = (surfacepos + (surfaceoff * (map.tilesize * 0.5f)));

	// this gathers HitInfo objects which contain blob or tile hit information
	HitInfo@ bestinfo = null;
	f32 bestDistance = 100000.0f;

	HitInfo@[] hitInfos;

	//setup params for ferrying data in/out
	SortHitsParams@ hit_p = SortHitsParams();

	//copy in
	hit_p.aimPos = aimPos;
	hit_p.tilepos = tilepos;
	hit_p.pos = pos;
	hit_p.justCheck = justCheck;
	hit_p.extra = true;
	hit_p.hasHit = hasHit;
	@(hit_p.bestinfo) = bestinfo;
	hit_p.bestDistance = bestDistance;

	if (map.getHitInfosFromArc(aimPos, 0.0f, 360.0f, 2.0f, this, @hitInfos))
	{
		SortHits(this, hitInfos, hit_damage, hit_p);
	}

	aimPos = hit_p.aimPos;
	tilepos = hit_p.tilepos;
	pos = hit_p.pos;
	justCheck = hit_p.justCheck;
	hasHit = hit_p.hasHit;
	@bestinfo = hit_p.bestinfo;
	bestDistance = hit_p.bestDistance;

	bool noBuildZone = map.getSectorAtPosition(tilepos, "no build") !is null;
	bool isgrass = false;
	if (this.isKeyJustReleased(key_action2)||this.isKeyJustReleased(key_pickup) && !this.isKeyPressed(key_action1))
	{
		if (map.getBlobAtPosition(aimPos) is null)
		{	
			Tile tile = map.getTile(surfacepos);
			
			if (!noBuildZone)
			{
				if(this.isKeyJustReleased(key_pickup))
					return;
				//normal, honest to god tile
				if (map.isTileBackgroundNonEmpty(tile) || map.isTileSolid(tile))
				{
					this.set_u8("build page", 0);
					hasHit = true;
					hitdata.tilepos = tilepos;
					u8 type = map.getTile(aimPos).type;
					
					if ((type >= 16 && type <= 24) || (type >= 29 && type <= 31) || type == 112) // ground dirt
					   this.set_TileType("buildtile", 16);

					if (type >= 25 && type <= 28) // grass						
					   this.set_TileType("buildtile", 25);

					if ((type >= 32 && type <= 40) || type >= 128 && type <= 137) // ground back
					   this.set_TileType("buildtile", 32);

					if ((type >= 48 && type <= 54) || (type >= 58 && type <= 63)) // castle
					   this.set_TileType("buildtile", 48);

					if ((type >= 64 && type <= 69) || (type >= 76 && type <= 79))// castle back
					   this.set_TileType("buildtile", 64);

					if ((type >= 80 && type <= 85) || (type >= 90 && type <= 94) || type == 160) // gold
					   this.set_TileType("buildtile", 80);

					if ((type >= 96 && type <= 97) || (type >= 100 && type <= 104) || type == 176) // stone
					   this.set_TileType("buildtile", 96);

					if ((type >= 196 && type <= 198) || (type >= 200 && type <= 204)) // wood
					   this.set_TileType("buildtile", 196);

					if ((type >= 106 && type <= 111) || type == 186) // bedrock
					   this.set_TileType("buildtile", 106);

					if ((type == 173) || (type >= 205 && type <= 207)) // wood back
					   this.set_TileType("buildtile", 205);

					if ((type >= 208 && type <= 209) || (type >= 214 && type <= 218) || type == 192) // thckstone
					   this.set_TileType("buildtile", 208);

					if (type >= 224 && type <= 226) // castle moss
					   this.set_TileType("buildtile", 224);

					if (type >= 227 && type <= 231) // castle back moss
					   this.set_TileType("buildtile", 227);
					
				}				
				else if (!map.isTileBackgroundNonEmpty(tile) || !map.isTileSolid(tile))
				{						
					this.set_u8("build page", 0);		
					this.set_TileType("buildtile", 126); // pink eraser tile
				}
			}
		}
		else if(getNet().isServer())
		{
			CBlob@ aimblob = map.getBlobAtPosition(aimPos);

			if (aimblob.hasTag("player"))
				return;

			CBlob@ blockBlob = server_CreateBlob(aimblob.getName(), this.getTeamNum(), blobPos);
			if (blockBlob !is null)
			{	
				this.server_Pickup(blockBlob);
				string abName = aimblob.getName();
				u8 indexed = getBuildBlobIndex(abName);
				u8 Page = 0;
				if (indexed >= 0 && indexed <= 20)
				{
				   Page = 0;
				}
				else if (indexed >= 21 && indexed <= 47)
				{
				   Page = 1;
				   indexed-=21;
				}
				else if (indexed >= 48 && indexed <= 66)
				{
				   Page = 2;
				   indexed-=48;
				}
				else if (indexed >= 67 && indexed <= 75)
				{
				   Page = 3;
				   indexed-=67;
				}
				else if (indexed >= 76 && indexed <= 84)
				{
				   Page = 4;
				   indexed-=76;
				}				
				else if (indexed >= 85 && indexed <= 107)
				{
				   Page = 5;
				   indexed-=85;
				}				
				else if (indexed >= 108 && indexed <= 116)
				{
				   Page = 6;
				   indexed-=108;
				}
				//print(""+ indexed);
				this.set_u8("build page", Page);
				this.set_u8("last build page", Page);
				this.set_u8("buildblob", indexed);
				blockBlob.Tag("temp blob");	

				if (this.isKeyJustReleased(key_pickup))	
				{						
					aimblob.server_Die();
					getMap().server_SetTile(aimPos, CMap::tile_empty);
				}		
			}
			else
			blockBlob.server_Die;
		}
	}

	if (!hasHit)
	{
		//copy in
		hit_p.aimPos = aimPos;
		hit_p.tilepos = tilepos;
		hit_p.pos = pos;
		hit_p.justCheck = justCheck;
		hit_p.extra = false;
		hit_p.hasHit = hasHit;
		@(hit_p.bestinfo) = bestinfo;
		hit_p.bestDistance = bestDistance;

		//try to find another possible one
		if (bestinfo is null)
		{
			SortHits(this, hitInfos, hit_damage, hit_p);
		}

		//copy out
		aimPos = hit_p.aimPos;
		tilepos = hit_p.tilepos;
		pos = hit_p.pos;
		justCheck = hit_p.justCheck;
		hasHit = hit_p.hasHit;
		@bestinfo = hit_p.bestinfo;
		bestDistance = hit_p.bestDistance;

		//did we find one (or have one from before?)
		if (bestinfo !is null)
		{
			hitdata.blobID = bestinfo.blob.getNetworkID();
		}
	}

	if (isgrass && bestinfo is null)
	{
		hitdata.tilepos = tilepos;
	}
}

void SortHits(CBlob@ this, HitInfo@[]@ hitInfos, f32 damage, SortHitsParams@ p)
{
	//HitInfo objects are sorted, first come closest hits
	for (uint i = 0; i < hitInfos.length; i++)
	{
		HitInfo@ hi = hitInfos[i];

		CBlob@ b = hi.blob;
		if (b !is null) // blob
		{
			if (!canHit(this, b, p.tilepos, p.extra))
			{
				continue;
			}

			if (!p.justCheck && isUrgent(this, b))
			{
				p.hasHit = true;
				SendHitCommand(this, hi.blob, hi.hitpos, hi.blob.getPosition() - p.pos, damage);
			}
			else
			{
				bool never_ambig = neverHitAmbiguous(b);
				f32 len = never_ambig ? 1000.0f : (p.aimPos - b.getPosition()).Length();
				if (len < p.bestDistance)
				{
					if (!never_ambig)
						p.bestDistance = len;

					@(p.bestinfo) = hi;
				}
			}
		}
	}
}

bool ExtraQualifiers(CBlob@ this, CBlob@ b, Vec2f tpos)
{
	//urgent stuff gets a pass here
	if (isUrgent(this, b))
		return true;

	//check facing - can't hit stuff we're facing away from
	f32 dx = (this.getPosition().x - b.getPosition().x) * (this.isFacingLeft() ? 1 : -1);
	if (dx < 0)
		return false;

	//only hit static blobs if aiming directly at them
	CShape@ bshape = b.getShape();
	if (bshape.isStatic())
	{
		bool bigenough = bshape.getWidth() >= 8 &&
		                 bshape.getHeight() >= 8;

		if (bigenough)
		{
			if (!b.isPointInside(this.getAimPos()) && !b.isPointInside(tpos))
				return false;
		}
		else
		{
			Vec2f bpos = b.getPosition();
			//get centered on the tile it's positioned on (for offset blobs like spikes)
			Vec2f tileCenterPos = Vec2f(s32(bpos.x / 8), s32(bpos.y / 8)) * 8 + Vec2f(4, 4);
			f32 dist = Maths::Min((tileCenterPos - this.getAimPos()).LengthSquared(),
			                      (tileCenterPos - tpos).LengthSquared());
			if (dist > 25) //>5*5
				return false;
		}
	}

	return true;
}

bool neverHitAmbiguous(CBlob@ b)
{
	string name = b.getName();
	return name == "saw";
}

bool canHit(CBlob@ this, CBlob@ b, Vec2f tpos, bool extra = true)
{
	if(extra && !ExtraQualifiers(this, b, tpos))
	{
		return false;
	}

	if(b.hasTag("invincible"))
	{
		return false;
	}

	if(b.getTeamNum() == this.getTeamNum())
	{
		//no hitting friendly carried stuff
		if(b.isAttached())
			return false;

		//yes hitting corpses
		if(b.hasTag("dead"))
			return true;

		//no hitting friendly mines (grif)
		if(b.getName() == "mine")
			return false;

		//no hitting friendly living stuff
		if(b.hasTag("flesh") || b.hasTag("player"))
			return false;
	}
	//no hitting stuff in hands
	else if(b.isAttached() && !b.hasTag("player"))
	{
		return false;
	}

	//static/background stuff
	CShape@ b_shape = b.getShape();
	if(!b.isCollidable() || (b_shape !is null && b_shape.isStatic()))
	{
		//maybe we shouldn't hit this..
		//check if we should always hit
		if(BuilderAlwaysHit(b))
		{
			if(!b.isCollidable() && !isUrgent(this, b))
			{
				//TODO: use a better overlap check here
				//this causes issues with quarters and
				//any other case where you "stop overlapping"
				if(!this.isOverlapping(b))
					return false;
			}
			return true;
		}
		//otherwise no hit
		return false;
	}

	return true;
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	// ignore collision for built blob
	BuildBlock[][]@ blocks;
	if(!this.get("blocks", @blocks))
	{
		return;
	}

	const u8 PAGE = this.get_u8("build page");
	for(u8 i = 0; i < blocks[PAGE].length; i++)
	{
		BuildBlock@ block = blocks[PAGE][i];
		if(block !is null && block.name == detached.getName())
		{
			this.IgnoreCollisionWhileOverlapped(null);
			detached.IgnoreCollisionWhileOverlapped(null);
		}
	}

	// BUILD BLOB
	// take requirements from blob that is built and play sound
	// put out another one of the same
	if(detached.hasTag("temp blob"))
	{
		if(!detached.hasTag("temp blob placed"))
		{
			detached.server_Die();
			return;
		}

		uint i = this.get_u8("buildblob");
		if(i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if(b.name == detached.getName())
			{
				this.set_u8("buildblob", 255);
				this.set_TileType("buildtile", 0);

				CInventory@ inv = this.getInventory();

				server_BuildBlob(this, blocks[PAGE], i);
			}
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	// destroy built blob if somehow they got into inventory
	if(blob.hasTag("temp blob"))
	{
		blob.server_Die();
		blob.Untag("temp blob");
	}

}
