// LoaderUtilities.as

#include "DummyCommon.as";
#include "LoaderColors.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(isDummyTile(map.getTile(offset).type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}

/*
TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
}
*/

void onInit(CMap@ this)
{
    this.legacyTileMinimap = false; 
    this.MakeMiniMap(); 
}
/*
void CalculateMinimapColour( CMap@ this, u32 offset, TileType tile, SColor &out col)
{    
	u8 type = this.getTile(offset).type; 

	if (type >= 16 && type <= 24) 							{ col = color_tile_ground; }
	else if (type >= 96 && type <= 97)						{ col = color_tile_stone; }
	else if (type >= 208 && type <= 209)					{ col = color_tile_thickstone; }
	else if (type >= 106 && type <= 111)					{ col = color_tile_bedrock; }
	else if (type >= 80 && type <= 85)						{ col = color_tile_gold; }
	else if (type >= 48 && type <= 54) 						{ col = color_tile_castle; }
	else if (type >= 64 && type <= 69)						{ col = color_tile_castle_back; }
	else if (type >= 224 && type <= 226)					{ col = color_tile_castle_moss; }
	else if (type >= 227 && type <= 231)					{ col = color_tile_castle_back_moss; }
	else if (type >= 25 && type <= 28) 						{ col = color_tile_grass; }
	else if (type >= 196 && type <= 198)					{ col = color_tile_wood; }
	else if ((type == 173) || (type >= 205 && type <= 207))	{ col = color_tile_wood_back; }
																//	color_tile_ladder;
																//	color_tile_ladder_ground;
																//	color_tile_ladder_castle;
																//	color_tile_ladder_wood;
																//	color_tile_sand;
	else if ((type >= 32 && type <= 40) && !this.isInWater(this.getTileWorldPosition(offset))) { col = color_tile_ground_back; }
	else if ((type >= 32 && type <= 40) &&  this.isInWater(this.getTileWorldPosition(offset))) { col = color_water_backdirt; }
	else if (this.isInWater(this.getTileWorldPosition(offset))) 							   { col = color_water_air; }

	else { col = sky; }	

}

//	CBlob@ gettileBlob(CMap@ this, u32 offset)
//	{
//		CBlob@ blob = this.getBlobAtPosition(this.getTileSpacePosition(offset)*8);
//		if (blob !is null)	
//		{
//			return blob;
//				//if (blob.getName() == "shark") 	{ col = color_shark; }
//		}
//		return blob;
//	}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if(isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}

	if ( !map.isInWater(map.getTileSpacePosition(index)*8))
	{
		map.RemoveTileFlag( index, Tile::WATER_PASSES );		
	}
}