
#include "SetLightFlags.as";

shared class HistoryBlock
{
	TileType tile;
	string name;
	u8 team;
	Vec2f pos;
	f32 angle;

	HistoryBlock() {} // required for handles to work

	HistoryBlock(TileType _tile, string _name, u8 _team, Vec2f _pos)
	{
		tile = _tile;
		name = _name;
		team = _team;
		pos = _pos;
	}
	HistoryBlock(TileType _tile, string _name, u8 _team, Vec2f _pos, f32 _angle)
	{
		tile = _tile;
		name = _name;
		team = _team;
		pos = _pos;
		angle = _angle;
	}
};

HistoryBlock@[][] historyblocks;
int currentHistoryTimeline = 1;

void setTimeline()
{		
	currentHistoryTimeline++;
	historyblocks.set_length(currentHistoryTimeline+2);
	historyblocks[currentHistoryTimeline-1].clear();
	historyblocks[currentHistoryTimeline].clear();
	historyblocks[currentHistoryTimeline+1].clear();
}

void PushHistory(Vec2f tilepos, u8 maptile, string name, u8 teamnum, f32 angle)
{
	// CBlob@ underblob = getMap().getBlobAtPosition(tilepos);	
	// if (name != "" && name != "waterspawner")
	// {
	// 	HistoryBlock b( maptile, name, teamnum, tilepos, angle);
	// 	historyblocks[currentHistoryTimeline-1].push_back( b );
	// }
	// else if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
	// {
	// 	HistoryBlock b( maptile, underblob.getName(), underblob.getTeamNum(), tilepos, underblob.getAngleDegrees());
	// 	historyblocks[currentHistoryTimeline-1].push_back( b );	
	// }
	// else if (getMap().isInWater(tilepos) || name == "waterspawner")
	// {
	// 	HistoryBlock b( maptile, "waterspawner", 0, tilepos, angle);
	// 	historyblocks[currentHistoryTimeline-1].push_back( b );	
	// }
	// else
	// {
	// 	HistoryBlock b( maptile, "", 0, tilepos, angle);
	// 	historyblocks[currentHistoryTimeline-1].push_back( b );	
	// }
}

void doUndo()
{
	if (currentHistoryTimeline-1 > 0)
	{
		currentHistoryTimeline--;
	
		for(uint i = 0; i < historyblocks[currentHistoryTimeline].length; i++)
		{
			HistoryBlock@ historyblock = historyblocks[currentHistoryTimeline][i];
	
			TileType maptile = getMap().getTile(historyblock.pos).type;
			Vec2f tpos = historyblock.pos;
			//string bname = historyblock.name;
			//u8 teamnum = historyblock.team;
			CBlob@ underblob = getMap().getBlobAtPosition(historyblock.pos);
			if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
			{
				HistoryBlock b( maptile, underblob.getName(), underblob.getTeamNum(), underblob.getPosition(), underblob.getAngleDegrees());
				historyblocks[currentHistoryTimeline+1].insertAt(i,b);	
			}	
			else
			{
				HistoryBlock b( maptile, "", 0, tpos);
				historyblocks[currentHistoryTimeline+1].insertAt(i,b);	
			}

			if (getMap().isInWater(tpos))
			{	
				Vec2f tilespace = getMap().getTileSpacePosition(tpos);
				getMap().RemoveTileFlag( getMap().getTileOffsetFromTileSpace(tilespace), Tile::WATER_PASSES );
				getMap().server_setFloodWaterWorldspace(tpos, false);
			}

			getMap().server_SetTile(historyblock.pos , historyblock.tile);
			if (getRules().get_u8("light selected") == 1) { SetLigtFlag( historyblock.pos ); }	

			CBlob@[] overlapping;
			getMap().getBlobsAtPosition(historyblock.pos, @overlapping);
			for(uint i = 0; i < overlapping.length; i++)
			{
				CBlob@ underblob = overlapping[i];
				if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
				{ 
					underblob.server_Die();
				}
			}			

			if (historyblock.name != "" && underblob is null)
			{					
				CBlob@ undoBlob = server_CreateBlob(historyblock.name, historyblock.team, historyblock.pos);
				if (undoBlob !is null)
				{
					undoBlob.setAngleDegrees(historyblock.angle);
					undoBlob.getShape().SetStatic(true);
				}
			}					
		}
		historyblocks[currentHistoryTimeline+1].set_length(historyblocks[currentHistoryTimeline].length);
	}	
}

void doRedo()
{	
	if (historyblocks[currentHistoryTimeline+1].length != 0)
	{
		currentHistoryTimeline++;
		for(uint i = 0; i < historyblocks[currentHistoryTimeline].length; i++)
		{
			HistoryBlock@ historyblock = historyblocks[currentHistoryTimeline][i];
		
			TileType maptile = getMap().getTile(historyblock.pos).type;
			Vec2f tpos = historyblock.pos;
			//string bname = historyblock.name;
			//u8 teamnum = historyblock.team;

			CBlob@ underblob = getMap().getBlobAtPosition(historyblock.pos);
			if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
			{
				HistoryBlock b( maptile, underblob.getName(), underblob.getTeamNum(), underblob.getPosition(), underblob.getAngleDegrees());
				historyblocks[currentHistoryTimeline-1].insertAt(i,b);	

				underblob.server_Die();
			}	
			else
			{
				HistoryBlock b( maptile, "", 0, tpos);
				historyblocks[currentHistoryTimeline-1].insertAt(i,b);	
			}	

			getMap().server_SetTile(historyblock.pos , historyblock.tile);
			if (getRules().get_u8("light selected") == 1) { SetLigtFlag( historyblock.pos ); }	
					

			CBlob@[] overlapping;
			getMap().getBlobsAtPosition(historyblock.pos, @overlapping);
			for(uint i = 0; i < overlapping.length; i++)
			{
				CBlob@ underblob = overlapping[i];
				if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
				{ 
					underblob.server_Die();
				}
			}			

			if (historyblock.name != "" && underblob is null)
			{					
				CBlob@ redoBlob = server_CreateBlob(historyblock.name, historyblock.team, historyblock.pos); // add team
				if (redoBlob !is null)
				{
					redoBlob.setAngleDegrees(historyblock.angle);
					redoBlob.getShape().SetStatic(true);
				}
			}		
		}
		historyblocks[currentHistoryTimeline-1].set_length(historyblocks[currentHistoryTimeline].length);		
	}	
}

