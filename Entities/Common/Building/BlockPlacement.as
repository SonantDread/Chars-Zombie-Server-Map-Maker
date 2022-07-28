#include "PlacementCommon.as";
#include "BuildBlock.as";
#include "HistoryBlocks.as";
#include "Requirements.as";
#include "GameplayEvents.as";
#include "SetLightFlags.as";

Random@ map_random = Random();

const string historyblocks_property = "historyblocks";

void PlaceBlock(CBlob@ this, u8 index, Vec2f cursorPos)
{
	BuildBlock @bc = getBlockByIndex(this, index);

	CBlob@ blob = this.getCarriedBlob();
	if (blob !is null)
	{	
		f32 buildang = this.get_u16("build_angle");				
		CBlob@ underblob = getMap().getBlobAtPosition(cursorPos);
		if (underblob !is null && !underblob.isAttached())
		{	
			TileType maptile = getMap().getTile(cursorPos).type;
			PushHistory(cursorPos, maptile, blob.getName(), blob.getTeamNum(), buildang);	
		}	
	}
	else 
	{
		if (bc is null)
		{
			warn("BuildBlock is null " + index);
			return;
		}
		
		CMap@ map = getMap();
		CBitStream missing;
		CInventory@ inv = this.getInventory();

		u8 radius = this.get_u8("brushsize");
		f32 halfTile = map.tilesize / 2.0f;
		f32 radsq = radius * 4 * radius * 4;
		Vec2f tpos;	

		if (bc.tile > 0)
		{
			if (this.get_u8("brush type") == 0)
			{
				for (int x_step = -radius; x_step < radius; ++x_step)
				{
					for (int y_step = -radius; y_step < radius; ++y_step)
					{
						Vec2f off(x_step * map.tilesize, y_step * map.tilesize);

						if (off.LengthSquared() > radsq)
							continue;

						Vec2f tpos = cursorPos + off;			
						TileType maptile = map.getTile(tpos).type;
						TileType buildtile = this.get_TileType("buildtile");

						if (tpos.x > -8 && tpos.x < map.tilemapwidth*8)
						{
							paintbrushat(this, map, tpos+Vec2f(4,4), index, bc);
						}				
					}			
				}
			}
			else if (this.get_u8("brush type") == 1)
			{	
				Vec2f temp_start = this.get_Vec2f("temp start");
				Vec2f temp_finish = this.get_Vec2f("temp finish");		 
				f32 Distance_x = (temp_finish.x - temp_start.x);
				f32 Distance_y = (temp_finish.y - temp_start.y);
				//u8 amountofblocks = (Distance_x / 8) * (Distance_y / 8);
				TileType buildtile = this.get_TileType("buildtile");

				if( !this.get_bool("canceled"))
				{
					for (int x_step = 0; x_step-1 < (Distance_x < 0 ? -Distance_x/8 : Distance_x/8); ++x_step)
					{
						for (int y_step = 0; y_step-1 < (Distance_y < 0 ? -Distance_y/8 : Distance_y/8); ++y_step)
						{
							Vec2f off(((Distance_x < 0 ? -x_step : x_step) * map.tilesize), ((Distance_y < 0 ? -y_step : y_step) * map.tilesize));

							Vec2f tpos = cursorPos - off + Vec2f(4,4);				
							TileType maptile = map.getTile(tpos).type;
							if (tpos.x > -8 && tpos.x < map.tilemapwidth*8)
							{
								paintbrushat(this, map, tpos, index, bc);
							}																	
						}	
					}			
				}
				else
				{
					this.set_bool("canceled",false);
				}
			}
		}
	}
}

void paintbrushat(CBlob@ this, CMap@ map, Vec2f tilepos, u8 index, BuildBlock @bc)
{		
	TileType maptile = map.getTile(tilepos).type;
	TileType buildtile = this.get_TileType("buildtile");

	f32 mapcenter = map.tilemapwidth*8/2;
	f32 aimdistfromcenter = tilepos.x-mapcenter;
	Vec2f sympos = Vec2f(mapcenter-aimdistfromcenter, tilepos.y);

	bool candie = true;
	CBlob@[] behindBlob;
	getMap().getBlobsAtPosition( tilepos, @behindBlob);

	for(uint i = 0; i < behindBlob.length; i++)
	{
        if (behindBlob[i].hasTag("player") || this.get_u8("replace type") == 1) 
        {
        	candie = false;								
        }
        if(candie)
        {
        	behindBlob[i].server_Die();
        }
	}

	if (map.isInWater(tilepos))
	{	
		PushHistory(tilepos, maptile, "", -1,0);
		Vec2f tilespace = map.getTileSpacePosition(tilepos);
		map.RemoveTileFlag( map.getTileOffsetFromTileSpace(tilespace), Tile::WATER_PASSES );
		map.server_setFloodWaterWorldspace(tilepos, false);
	}
	else if (index == 0)
	{		
		if (map.getBlobAtPosition(tilepos) !is null || maptile != CMap::tile_empty)
		{
			PushHistory(tilepos, maptile, "", -1,0);
			map.server_SetTile(tilepos, CMap::tile_empty);
		}
	}
	else if (index == 12 && maptile != buildtile && maptile != buildtile+1 && maptile != buildtile+2 && maptile != buildtile+3)// is grass
	{
		PushHistory(tilepos, maptile, "", -1,0);
		map.server_SetTile(tilepos, CMap::tile_grass + map_random.NextRanged(3));
	}

	else if(index != 0 && index != 12 && maptile != buildtile && this.get_u8("replace type") == 2)
	{	
		PushHistory(tilepos, maptile, "", -1,0);
		map.server_SetTile(tilepos , bc.tile);
		SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), bc.tile));
	}
	else if(index != 0 && index != 12 && maptile != buildtile && this.get_u8("replace type") == 1 && map.isTileSolid(tilepos))
	{	
		PushHistory(tilepos, maptile, "", -1,0);
		map.server_SetTile(tilepos , bc.tile);
		SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), bc.tile));
	}
	else if(index != 0 && index != 12 && maptile != buildtile && this.get_u8("replace type") == 0 && !map.isTileSolid(tilepos))
	{	
		PushHistory(tilepos, maptile, "", -1,0);
		map.server_SetTile(tilepos , bc.tile);
		SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), bc.tile));
	}
	//SetLigtFlag( this, tilepos);

	if (this.get_bool("symmetry selected"))
	{			
		TileType symmaptile = map.getTile(sympos).type;
		CBlob@[] behindBlobSym;
		getMap().getBlobsAtPosition( sympos, @behindBlobSym);

  		for(uint i = 0; i < behindBlobSym.length; i++)
		{
            if (behindBlobSym[i].hasTag("player"))
            {
            	candie = false;								
            }
            if(candie)
            {
            	behindBlobSym[i].server_Die();
            }
		}
		if (map.isInWater(sympos))
		{			
			PushHistory(sympos, symmaptile, "", -1,0);
			Vec2f symtilespace = map.getTileSpacePosition(sympos);					
			map.RemoveTileFlag( map.getTileOffsetFromTileSpace(symtilespace), Tile::WATER_PASSES );
			map.server_setFloodWaterWorldspace(sympos, false);
		}
		else if (index == 0)
		{
			if (map.getBlobAtPosition(sympos) !is null || symmaptile != CMap::tile_empty)
			{
				PushHistory(sympos, symmaptile, "", -1,0);
				map.server_SetTile(sympos, CMap::tile_empty);
			}				
		}
		else if (index == 12 && symmaptile != buildtile && symmaptile != buildtile+1 && symmaptile != buildtile+2 && symmaptile != buildtile+3)
		{	
			PushHistory(sympos, symmaptile, "", -1,0);
			map.server_SetTile(sympos, CMap::tile_grass + map_random.NextRanged(3));
		}
		else if(index != 0 && index != 12 && symmaptile != buildtile && this.get_u8("replace type") == 2)
		{	
			PushHistory(sympos, symmaptile, "", -1,0);
			map.server_SetTile(sympos , bc.tile);
			SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), bc.tile));
		}
		else if(index != 0 && index != 12 && symmaptile != buildtile && this.get_u8("replace type") == 1 && map.isTileSolid(sympos))
		{	
			PushHistory(sympos, symmaptile, "", -1,0);
			map.server_SetTile(sympos, bc.tile);
			SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), bc.tile));
		}
		else if(index != 0 && index != 12 && symmaptile != buildtile && this.get_u8("replace type") == 0 && !map.isTileSolid(sympos))
		{		
			PushHistory(sympos, symmaptile, "", -1,0);
			map.server_SetTile(sympos , bc.tile);
			SendGameplayEvent(createBuiltBlockEvent(this.getPlayer(), bc.tile));
		}
	}

	if (getRules().get_u8("light selected") == 1)
	{
		SetLigtFlag(tilepos);

		if (this.get_bool("symmetry selected"))
		{
			SetLigtFlag(sympos);
		}
	}	
}

void onInit(CBlob@ this)
{
	AddCursor(this);
	SetupBuildDelay(this);
	this.addCommandID("placeBlock");
	this.set_bool("canceled", false);
	this.set(historyblocks_property, historyblocks);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";	
}

Vec2f getBottomOfCursor(Vec2f cursorPos, CBlob@ carryBlob)
{
	// check at bottom of cursor
	CMap@ map = getMap();
	f32 w = map.tilesize / 2.0f;
	f32 h = map.tilesize / 2.0f;
	return Vec2f(cursorPos.x + w, cursorPos.y + h);
}

void ApplySymRL(CBitStream@ params)
{	
	Menu::CloseAllMenus();
	setTimeline();
	CMap@ map = getMap();
	for (uint x = 0; x < map.tilemapwidth/2; x++)
	{
		for (uint y = 0; y < map.tilemapheight; y++)
		{
			Vec2f position = Vec2f((map.tilemapwidth-1)*8+(-x*8),y*8)+Vec2f(4,4);
			Vec2f newpos = Vec2f(-position.x+(map.tilemapwidth)*8, position.y);

			TileType newmaptile = map.getTile(position).type;
			TileType oldmaptile = map.getTile(newpos).type;
	
			CBlob@ underblob = getMap().getBlobAtPosition(newpos);
			if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
			{	
				PushHistory(underblob.getPosition(), oldmaptile, underblob.getName(), underblob.getTeamNum(), underblob.getAngleDegrees());
				underblob.server_Die();
			}
			else
			{
				PushHistory(newpos, oldmaptile, "", -1,0);
			}	

			map.server_SetTile(newpos, newmaptile);
			if (getRules().get_u8("light selected") == 1) { SetLigtFlag( newpos ); }
		
			CBlob@ nb = map.getBlobAtPosition(position);
			u8 team;
			if (nb !is null && !nb.hasTag("player") && !nb.isAttached())
			{
				if (nb.getTeamNum() == 0) { team = 1; }
				else if (nb.getTeamNum() == 1) { team = 0; }
				else  { team = nb.getTeamNum(); }

				CBlob@ newblob = server_CreateBlob(nb.getName(), team, newpos);
				if( newblob !is null)
				{
					f32 nbang = nb.getAngleDegrees();
					if (nbang == 90)
					newblob.setAngleDegrees(270);
					else if (nbang == 270)
					newblob.setAngleDegrees(90);
					else
					newblob.setAngleDegrees(nbang);

					newblob.getShape().SetStatic(true); }
			}
		}
	}
}

void ApplySymLR(CBitStream@ params)
{	
	Menu::CloseAllMenus();
	setTimeline();
	CMap@ map = getMap();
	for (uint x = 0; x < map.tilemapwidth/2; x++)
	{
		for (uint y = 0; y < map.tilemapheight; y++)
		{
			Vec2f position = Vec2f(x*8,y*8)+Vec2f(4,4);
			Vec2f newpos = Vec2f(-position.x+(map.tilemapwidth)*8, position.y);

			TileType newmaptile = map.getTile(position).type;
			TileType oldmaptile = map.getTile(newpos).type;
	
			CBlob@ underblob = getMap().getBlobAtPosition(newpos);
			if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
			{	
				PushHistory(underblob.getPosition(), oldmaptile, underblob.getName(), underblob.getTeamNum(), underblob.getAngleDegrees());	
				underblob.server_Die();
			}
			else
			{
				PushHistory(newpos, oldmaptile, "", -1,0);
			}	

			map.server_SetTile(newpos, newmaptile);
			if (getRules().get_u8("light selected") == 1) { SetLigtFlag( newpos ); }
		
			CBlob@ nb = map.getBlobAtPosition(position);
			u8 team;
			if (nb !is null && !nb.hasTag("player") && !nb.isAttached())
			{
				if (nb.getTeamNum() == 0) { team = 1; }
				else if (nb.getTeamNum() == 1) { team = 0; }
				else  { team = nb.getTeamNum(); }

				CBlob@ newblob = server_CreateBlob(nb.getName(), team, newpos);
				if( newblob !is null)
				{
					f32 nbang = nb.getAngleDegrees();
					if (nbang == 90)
					newblob.setAngleDegrees(270);
					else if (nbang == 270)
					newblob.setAngleDegrees(90);
					else
					newblob.setAngleDegrees(nbang);

					newblob.getShape().SetStatic(true); }
			}
		}
	}
}

void pushPickup(CBlob@ this)
{
	CMap@ map = getMap();

	CBlob@ underblob = getMap().getBlobAtPosition(this.getAimPos());
	if (underblob !is null && !underblob.isAttached() && !underblob.hasTag("player"))
	{			
		setTimeline();
		TileType maptile = getMap().getTile(underblob.getPosition()).type;
		PushHistory(underblob.getPosition(), maptile, underblob.getName(), underblob.getTeamNum(), underblob.getAngleDegrees());	
	}
}

void onTick(CBlob@ this)
{
	if (this.isInInventory())
	{
		return;
	}
	if (getHUD().hasMenus())
	{
		return;
	}
	if (getGameTime() - this.get_u32("closetime") < 1 )
	{
		this.DisableKeys(key_action1); // dodgy?
		return;
	}
	if (isBuildDelayed(this))
	{
		//return;
	}
	if (this.isKeyJustReleased(key_pickup))
	{
		pushPickup(this);
	}

	BlockCursor @bc;
	this.get("blockCursor", @bc);
	if (bc is null)
	{
		return;
	}

	if ((getControls().isKeyPressed( KEY_LCONTROL ) || getControls().isKeyPressed( KEY_RCONTROL )) && getControls().isKeyJustPressed( KEY_KEY_Z ))
	{
		doUndo();
	}

	else if ((getControls().isKeyPressed( KEY_LCONTROL ) || getControls().isKeyPressed( KEY_RCONTROL )) && getControls().isKeyJustPressed( KEY_KEY_Y ))
	{	
		doRedo();
	}

	SetTileAimpos(this, bc);
	// check buildable
	bc.buildable = false;
	bc.supported = false;
	bc.hasReqs = true;
	TileType buildtile = this.get_TileType("buildtile");
	bool hasCanceled = false;

	CBlob @carryBlob = this.getCarriedBlob();
	if (carryBlob !is null)
	{
		if (this.isKeyJustPressed(key_action1))
		{
			setTimeline();
			//print(""+currentHistoryTimeline);
		}
		if (this.isKeyPressed(key_action1))
		{
			Vec2f halftileoffset(getMap().tilesize * 0.5f, getMap().tilesize * 0.5f);

			CBlob@ underblob = getMap().getBlobAtPosition(bc.tileAimPos + halftileoffset);
			if (underblob !is null && bc.sameTileOnBack)
			{ return; }	

			TileType maptile = getMap().getTile(bc.tileAimPos + halftileoffset).type;
			CBitStream params;
			params.write_u8(maptile);
			params.write_Vec2f(bc.tileAimPos + halftileoffset);
			this.SendCommand(this.getCommandID("placeBlock"), params);
			//u32 delay = this.get_u32("build delay");
			//SetBuildDelay(this, block.tile < 255 ? delay : delay / 3);
			//bc.blockActive = false;			
		}
	}

	if (this.isKeyJustPressed(key_action2) && this.isKeyPressed(key_action1))
	{			
		hasCanceled = true;	
		this.set_bool("canceled", true);
		currentHistoryTimeline--;
	}
	else
	{
		this.set_bool("canceled",false);
	}

	if (buildtile > 0 && !hasCanceled)
	{
		bc.blockActive = true;
		bc.blobActive = false;
		CMap@ map = this.getMap();
		u8 blockIndex = getBlockIndexByTile(this, buildtile);
		BuildBlock @block = getBlockByIndex(this, blockIndex);
		if (block !is null)
		{
			bc.missing.Clear();
			bc.hasReqs = hasRequirements(this.getInventory(), block.reqs, bc.missing);
		}

		if (this.isKeyJustPressed(key_action1))
		{
			setTimeline();
			//print(""+currentHistoryTimeline);
		}

		if (bc.cursorClose)
		{
			Vec2f halftileoffset(map.tilesize * 0.5f, map.tilesize * 0.5f);
			bc.buildableAtPos = isBuildableAtPos(this, bc.tileAimPos + halftileoffset, buildtile, null, bc.sameTileOnBack);
			//printf("bc.buildableAtPos " + bc.buildableAtPos );
			bc.rayBlocked = isBuildRayBlocked(this.getPosition(), bc.tileAimPos + halftileoffset, bc.rayBlockedPos);
			bc.buildable = true;
			bc.supported = true;
		}

		// place block
		if (this.get_u8("brush type") == 1)
		{
			if (this.isKeyJustPressed(key_action1))
			{				
				this.set_Vec2f("temp start", bc.tileAimPos);
			}
			if (this.isKeyPressed(key_action1) && bc.tileAimPos != this.get_Vec2f("temp finish"))
			{				
				this.set_Vec2f("temp finish", bc.tileAimPos);
			}		
			if (this.isKeyJustReleased(key_action1))
			{	
				CBitStream params;
				params.write_u8(blockIndex);
				params.write_Vec2f(bc.tileAimPos);
				this.SendCommand(this.getCommandID("placeBlock"), params);
				u32 delay = this.get_u32("build delay");
				SetBuildDelay(this, block.tile < 255 ? delay : delay / 3);
				bc.blockActive = false;
				
				this.set_Vec2f("temp start", bc.tileAimPos);	
				this.set_Vec2f("temp finish", bc.tileAimPos);
			}
			Vec2f ts = this.get_Vec2f("temp start");
			u8 stxp = ts.x;

			if (!this.isKeyPressed(key_action1))
			{	
				if (stxp < bc.tileAimPos.x)	
				{		
					this.set_Vec2f("temp start", bc.tileAimPos);	
					this.set_Vec2f("temp finish", bc.tileAimPos);
				}
			}
		}

		if (this.get_u8("brush type") == 0)
		{
			if (bc.cursorClose && bc.buildable && bc.supported && this.isKeyPressed(key_action1))
			{
				CBitStream params;
				params.write_u8(blockIndex);
				params.write_Vec2f(bc.tileAimPos);
				this.SendCommand(this.getCommandID("placeBlock"), params);
				u32 delay = this.get_u32("build delay");
				SetBuildDelay(this, block.tile < 255 ? delay : delay / 3);
				bc.blockActive = false;
			}
			else if (this.isKeyJustPressed(key_action1) && !bc.sameTileOnBack)
			{
				Sound::Play("NoAmmo.ogg");
			}
		}
	}
	else
	{
		bc.blockActive = false;
		this.set_Vec2f("temp start", bc.tileAimPos);	
		this.set_Vec2f("temp finish", bc.tileAimPos);
	}
}
// render block placement

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

//	if (currentHistoryTimeline >= 0 && currentHistoryTimeline+1 < historyblocks.length)
//	{
//		for(uint i = 0; i < historyblocks[currentHistoryTimeline].length; i++)
//		{			
//			HistoryBlock@ historyblock = historyblocks[currentHistoryTimeline][i];	
//
//		//	if (historyblock.name != "")
//		//	{
//				GUI::DrawLine(Vec2f( historyblock.pos.x-2, historyblock.pos.y-2), Vec2f( historyblock.pos.x+2, historyblock.pos.y+2), SColor(255,255,255,255));
//		//	}
//		}
//	}
//	if (currentHistoryTimeline-1 >= 0 && currentHistoryTimeline+1 < historyblocks.length)
//	{
//		for(uint i = 0; i < historyblocks[currentHistoryTimeline-1].length; i++)
//		{			
//			HistoryBlock@ historyblock = historyblocks[currentHistoryTimeline-1][i];	
//
//		//	if (historyblock.name != "")
//		//	{
//				GUI::DrawLine(Vec2f( historyblock.pos.x-2, historyblock.pos.y-2), Vec2f( historyblock.pos.x+2, historyblock.pos.y+2), SColor(255,0,0,255));
//		//	}
//		}
//	}

	CBlob @carryBlob = blob.getCarriedBlob();
	if (carryBlob !is null)
	{
		return;
	}
	// draw a map block or other blob that snaps to grid
	TileType buildtile = blob.get_TileType("buildtile");

	if (buildtile > 0)
	{
		CMap@ map = getMap();
		BlockCursor @bc;
		blob.get("blockCursor", @bc);
	
		if (blob.get_u8("brush type") == 0)
		{			
			u8 radius = blob.get_u8("brushsize");
			f32 radsq = radius * 4 * radius * 4;		

			for (int x_step = -radius; x_step < radius; ++x_step)
			{
				for (int y_step = -radius; y_step < radius; ++y_step)
				{
					Vec2f off(x_step * map.tilesize, y_step * map.tilesize);

					if (off.LengthSquared() >  radsq)
						continue;

					Vec2f tpos = bc.tileAimPos +  off;				

					drawbrushat(this, map, tpos);	

					if (blob.get_bool("symmetry selected")) // draw symmetry boxes
					{	
						f32 mapcenter = map.tilemapwidth*8/2;

						Vec2f tl(tpos.x+0.5f,tpos.y+0.5f);
						Vec2f tr(tpos.x+7.5f,tpos.y+0.5f);
						Vec2f bl(tpos.x+0.5f,tpos.y+7.5f);
						Vec2f br(tpos.x+7.5f,tpos.y+7.5f);

						GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-tr.x,tr.y), SColor(255,255,0,225));
						GUI::DrawLine( Vec2f(mapcenter*2-bl.x,bl.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));

						GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-bl.x,bl.y), SColor(255,255,0,225));
						GUI::DrawLine( Vec2f(mapcenter*2-tr.x,tr.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));
					}			
				}		
			}
		}
		else if (blob.get_u8("brush type") == 1)
		{
			Vec2f temp_start = blob.get_Vec2f("temp start");
			Vec2f temp_finish = blob.get_Vec2f("temp finish");
	 
			f32 Distance_x = (temp_finish.x - temp_start.x);
			f32 Distance_y = (temp_finish.y - temp_start.y);	
			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;	
			u8 rpt = blob.get_u8("replace type");		

			for (int x_step = 0; x_step-1 < (Distance_x < 0 ? -Distance_x/8 : Distance_x/8); ++x_step)
			{
				for (int y_step = 0; y_step-1 < (Distance_y < 0 ? -Distance_y/8 : Distance_y/8); ++y_step)
				{				
					Vec2f off(((Distance_x < 0 ? -x_step : x_step) * map.tilesize), ((Distance_y < 0 ? -y_step : y_step) * map.tilesize));

					map.DrawTile(bc.tileAimPos - off, buildtile,
					SColor(255, 255, 255, 255),
					getCamera().targetDistance, false);

					u8 placecolour = rpt == 2 ? 1 : rpt == 0 ? map.isTileSolid(bc.tileAimPos - off) ? 0:1 : map.isTileSolid(bc.tileAimPos - off) ? 1:0;
					
					Vec2f aligned = getDriver().getScreenPosFromWorldPos(bc.tileAimPos - off);
					GUI::DrawIcon( "PlaceColours.png", placecolour, Vec2f(8,8), aligned, zoom );					
				}
			}	
					
			u8 xamount = (Distance_x < 0 ? -Distance_x/8 : Distance_x/8)+1;
			u8 yamount = (Distance_y < 0 ? -Distance_y/8 : Distance_y/8)+1;
			GUI::SetFont("menu");
			GUI::DrawText(("x:"+xamount)+"\n"+("y:"+yamount), getDriver().getScreenPosFromWorldPos(bc.tileAimPos - Vec2f(Distance_x < 0 ? 12.0f : -12.0f, Distance_y < 0 ? 12.0f : -12.0f)), SColor(32,255,255,255));	
			//GUI::DrawText(, getDriver().getScreenPosFromWorldPos(bc.tileAimPos - Vec2f(0.0f, 10.0f) : Vec2f(0.0f, -10.0f))), color_white);

			if (blob.get_bool("symmetry selected")) // draw symmetry box
			{	
				f32 mapcenter = map.tilemapwidth*8/2;

				Vec2f tl(((Distance_x >= 0.0f ? 0.5f : 7.5f)+temp_start.x),(Distance_y >= 0.0f ? 0.5f : 7.5f)+temp_start.y);
				Vec2f tr(((Distance_x >= 0.0f ? 7.5f : 0.5f)+temp_finish.x),(Distance_y >= 0.0f ? 0.5f : 7.5f)+temp_start.y);
				Vec2f bl(((Distance_x >= 0.0f ? 0.5f : 7.5f)+temp_start.x),(Distance_y >= 0.0f ? 7.5f : 0.5f)+temp_finish.y);
				Vec2f br(((Distance_x >= 0.0f ? 7.5f : 0.5f)+temp_finish.x),(Distance_y >= 0.0f ? 7.5f : 0.5f)+temp_finish.y);

				GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-tr.x,tr.y), SColor(255,255,0,225));
				GUI::DrawLine( Vec2f(mapcenter*2-bl.x,bl.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));

				GUI::DrawLine( Vec2f(mapcenter*2-tl.x,tl.y), Vec2f(mapcenter*2-bl.x,bl.y), SColor(255,255,0,225));
				GUI::DrawLine( Vec2f(mapcenter*2-tr.x,tr.y), Vec2f(mapcenter*2-br.x,br.y), SColor(255,255,0,225));
			}	
		}
	}
}

void drawbrushat(CSprite@ this, CMap@ map, Vec2f tilepos)
{
	CBlob@ blob = this.getBlob();
	TileType buildtile = blob.get_TileType("buildtile");

	map.DrawTile(tilepos, buildtile,
	SColor(255, 255, 255, 255),
	getCamera().targetDistance, false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer() && cmd == this.getCommandID("placeBlock"))
	{
		u8 index = params.read_u8();
		Vec2f pos = params.read_Vec2f();
		PlaceBlock(this, index, pos);
	}
}
