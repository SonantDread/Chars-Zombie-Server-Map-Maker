// BasePNGLoader.as

#include "LoaderColors.as";
#include "LoaderUtilities.as";
#include "CustomBlocks.as";

enum WAROffset
{
	autotile_offset = 0,
	tree_offset,
	bush_offset,
	grain_offset,
	spike_offset,
	ladder_offset,
	offsets_count
};

enum Offset
{
	blue_team_scroll = offsets_count,
	red_team_scroll,
	crap_scroll,
	medium_scroll,
	super_scroll,
	war_offsets_count
};

//global
Random@ map_random = Random();

class PNGLoader
{
	PNGLoader()
	{
		offsets = array<array<int>>(offsets_count, array<int>(0));
	}

	CFileImage@ image;
	CMap@ map;

	array<array<int>> offsets;

	int current_offset_count;

	bool loadMap(CMap@ _map, const string& in filename)
	{
		@map = _map;
		@map_random = Random();

		if(!getNet().isServer())
		{
			SetupMap(0, 0);
			SetupBackgrounds();

			return true;
		}

		@image = CFileImage( filename );

		if(image.isLoaded())
		{
			SetupMap(image.getWidth(), image.getHeight());
			SetupBackgrounds();

			while(image.nextPixel())
			{
				SColor pixel = image.readPixel();
				int offset = image.getPixelOffset();

				handlePixel(pixel, offset);

				getNet().server_KeepConnectionsAlive();
			}

			// late load - after placing tiles
			for(uint i = 0; i < offsets.length; ++i)
			{
				int[]@ offset_set = offsets[i];
				current_offset_count = offset_set.length;
				for(uint step = 0; step < current_offset_count; ++step)
				{
					handleOffset(i, offset_set[step], step, current_offset_count);
					getNet().server_KeepConnectionsAlive();
				}
			}
			return true;
		}
		return false;
	}

	void handlePixel(SColor pixel, int offset)
	{
		u8 alpha = pixel.getAlpha();

		if(alpha < 255)
		{
			alpha &= ~0x80;
			SColor rgb = SColor(0xFF, pixel.getRed(), pixel.getGreen(), pixel.getBlue());
			const Vec2f position = getSpawnPosition(map, offset);

			//print(" ARGB = "+alpha+", "+rgb.getRed()+", "+rgb.getGreen()+", "+rgb.getBlue());

			// BLOCKS
			if(rgb == ladder)
			{
				spawnBlob(map, "ladder", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == spikes)
			{
				spawnBlob(map, "spikes", getTeamFromChannel(alpha), position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == stone_door)
			{
				spawnBlob(map, "stone_door", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == trap_block)
			{
				spawnBlob(map, "trap_block", getTeamFromChannel(alpha), position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == wooden_door)
			{
				spawnBlob(map, "wooden_door", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == wooden_platform)
			{
				spawnBlob(map, "wooden_platform", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			// NATURAL
			else if(rgb == stalagmite)
			{
				CBlob@ blob = spawnBlob(map, "stalagmite", 255, position, getAngleFromChannel(alpha), true);
				blob.set_u8("state", 1); // Spike::stabbing
				offsets[autotile_offset].push_back(offset);
			}
			// MECHANISMS
			else if(rgb == lever)
			{
				CBlob@ blob = spawnBlob(map, "lever", getTeamFromChannel(alpha), position, true);
				offsets[autotile_offset].push_back(offset);

				// | state          | binary    | hex  | dec |
				// ---------------------vv--------------------
				// | off            | 0000 0000 | 0x00 |   0 |
				// | on             | 0001 0000 | 0x10 |  16 |
				// | random         | 0010 0000 | 0x20 |  32 |

				/*
				not implimented at the moment
				if(alpha & 0x10 != 0 || alpha & 0x20 != 0 && XORRandom(2) == 0)
				{
					blob.SendCommand(blob.getCommandID("toggle"));
				}
				*/
			}
			else if(rgb == pressure_plate)
			{
				spawnBlob(map, "pressure_plate", 255, position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == push_button)
			{
				spawnBlob(map, "push_button", getTeamFromChannel(alpha), position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == coin_slot)
			{
				spawnBlob(map, "coin_slot", getTeamFromChannel(alpha), position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == sensor)
			{
				spawnBlob(map, "sensor", getTeamFromChannel(alpha), position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == diode)
			{
				spawnBlob(map, "diode", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == elbow)
			{
				spawnBlob(map, "elbow", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == emitter)
			{
				spawnBlob(map, "emitter", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == inverter)
			{
				spawnBlob(map, "inverter", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == junction)
			{
				spawnBlob(map, "junction", getTeamFromChannel(alpha), position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == magazine)
			{
				CBlob@ blob = spawnBlob(map, "magazine", 255, position, true);
				offsets[autotile_offset].push_back(offset);

				const string[] items = {
				"mat_bombs",
				"mat_waterbombs",
				"mat_arrows",
				"mat_waterarrows",
				"mat_firearrows",
				"mat_bombarrows",
				"food",
				"random"};

				if(alpha >= items.length) return;

				string name = items[alpha];
				if(name == "random")
				{
					name = items[XORRandom(items.length - 2)];
				}

				CBlob@ item = server_CreateBlob(name, 255, position);
				blob.server_PutInInventory(item);
			}
			else if(rgb == oscillator)
			{
				spawnBlob(map, "oscillator", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == randomizer)
			{
				spawnBlob(map, "randomizer", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == receiver)
			{
				spawnBlob(map, "receiver", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == resistor)
			{
				spawnBlob(map, "resistor", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == tee)
			{
				spawnBlob(map, "tee", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == toggle)
			{
				spawnBlob(map, "toggle", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == transistor)
			{
				spawnBlob(map, "transistor", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == wire)
			{
				spawnBlob(map, "wire", getTeamFromChannel(alpha), position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == bolter)
			{
				spawnBlob(map, "bolter", 255, position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == dispenser)
			{
				spawnBlob(map, "dispenser", 255, position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == lamp)
			{
				spawnBlob(map, "lamp", 255, position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == obstructor)
			{
				spawnBlob(map, "obstructor", 255, position, true);
				offsets[autotile_offset].push_back(offset);
			}
			else if(rgb == spiker)
			{
				spawnBlob(map, "spiker", 255, position, getAngleFromChannel(alpha), true);
				offsets[autotile_offset].push_back(offset);
			}
		}
		else if(pixel == color_tile_ground)
		{
			map.SetTile(offset, CMap::tile_preground);
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES | Tile::SOLID | Tile::COLLISION  );
		}
		else if(pixel == color_tile_ground_back)
		{
			map.SetTile(offset, CMap::tile_preground_back);
			//map.AddTileFlag( offset, Tile::BACKGROUND | Tile::WATER_PASSES );
		}
		else if(pixel == color_tile_stone)
		{
			map.SetTile(offset, CMap::tile_prestone);
			//map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION  );
		}
		else if(pixel == color_tile_thickstone)
		{
			map.SetTile(offset, CMap::tile_prethickstone);
			//map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION  );
		}
		else if(pixel == color_tile_bedrock)
		{
			map.SetTile(offset, CMap::tile_prebedrock);
			//map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION  );
		}
		else if(pixel == color_tile_gold)
		{
			map.SetTile(offset, CMap::tile_pregold);
			//map.AddTileFlag( offset, Tile::SOLID | Tile::COLLISION  );
		}
		else if(pixel == color_tile_castle)
		{
			map.SetTile(offset, CMap::tile_castle);
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		}
		else if(pixel == color_tile_castle_back)
		{
			map.SetTile(offset, CMap::tile_castle_back);
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		}
		else if(pixel == color_tile_castle_moss)
		{
			map.SetTile(offset, CMap::tile_castle_moss);
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES);
		}
		else if(pixel == color_tile_castle_back_moss)
		{
			map.SetTile(offset, CMap::tile_castle_back_moss);
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		}
		else if(pixel == color_tile_wood)
		{
			map.SetTile(offset, CMap::tile_wood);
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		}
		else if(pixel == color_tile_wood_back)
		{
			map.SetTile(offset, CMap::tile_wood_back );
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		}
		else if(pixel == color_tile_grass)
		{
			map.SetTile(offset, CMap::tile_grass + map_random.NextRanged(3));
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES );
		}
		else if(pixel == color_water_air)
		{
			map.server_setFloodWaterOffset(offset, true);
		}
		else if(pixel == color_water_backdirt)
		{			
			map.server_setFloodWaterOffset(offset, true);
			map.SetTile(offset, CMap::tile_preground_back );
			//map.AddTileFlag( offset, Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::BACKGROUND );
		}
		else if(pixel == color_princess)
		{
			spawnBlob(map, "princess", offset, 6, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_necromancer)
		{
			spawnBlob( map, "ainecromancer", offset, 3, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_necromancer_teleport)
		{
			//AddMarker(map, offset, "blue main spawn"); // done in mainspawnmarker.as
			spawnBlob(map, "necrotpmarker", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_checkpoint)
		{
			//AddMarker(map, offset, "blue main spawn"); // done in mainspawnmarker.as
			spawnBlob(map, "checkpointmarker", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_blue_main_spawn)
		{
			//AddMarker(map, offset, "blue main spawn"); // done in mainspawnmarker.as
			spawnBlob(map, "mainspawnmarker", offset, 0, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_red_main_spawn)
		{
			spawnBlob( map, "mainspawnmarker", offset, 1, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_green_main_spawn)
		{
			spawnBlob( map, "mainspawnmarker", offset, 2, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_purple_main_spawn)
		{
			spawnBlob( map, "mainspawnmarker", offset, 3, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_orange_main_spawn)
		{
			spawnBlob( map, "mainspawnmarker", offset, 4, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_aqua_main_spawn)
		{
			spawnBlob( map, "mainspawnmarker", offset, 5, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_teal_main_spawn)
		{
			spawnBlob( map, "mainspawnmarker", offset, 6, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_gray_main_spawn)
		{
			spawnBlob( map, "mainspawnmarker", offset, 255, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_blue_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 0, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_red_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 1, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_green_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 2, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_purple_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 3, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_orange_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 4, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_aqua_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 5, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_teal_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 6, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_gray_spawn)
		{
			spawnBlob( map, "spawnmarker", offset, 255, true );			
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_knight_shop)
		{
			spawnBlob( map, "knightshop", offset, 255, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_builder_shop)
		{
			spawnBlob( map, "buildershop", offset, 255, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_archer_shop)
		{
			spawnBlob( map, "archershop", offset, 255, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_boat_shop)
		{
			spawnBlob( map, "boatshop", offset, 255, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_vehicle_shop)
		{
			spawnBlob(map, "vehicleshop", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_quarters)
		{
			spawnBlob(map, "quarters", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_storage_noteam)
		{
			spawnBlob(map, "storage", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_barracks_noteam)
		{
			spawnBlob(map, "barracks", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_factory_noteam)
		{
			spawnBlob(map, "factory", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_tunnel_blue)
		{
			spawnBlob(map, "tunnel", offset, 0, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_tunnel_red)
		{
			spawnBlob(map, "tunnel", offset, 1, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_tunnel_noteam)
		{
			spawnBlob(map, "tunnel", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_kitchen)
		{
			spawnBlob(map, "kitchen", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_nursery)
		{
			spawnBlob(map, "nursery", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_research)
		{
			spawnBlob(map, "research", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_workbench)
		{
			spawnBlob(map, "workbench", offset, -1, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if(pixel == color_campfire)
		{
			spawnBlob(map, "fireplace", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_saw)
		{
			spawnBlob( map, "saw", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_tree)
		{
			offsets[tree_offset].push_back(offset);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_bush)
		{
			offsets[bush_offset].push_back( offset );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_grain)
		{
			spawnBlob( map, "grain_plant", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_flowers)
		{
			spawnBlob( map, "flowers", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_log)
		{
			spawnBlob(map, "log", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_ZombiePortal)
		{
			spawnBlob(map, "ZombiePortal", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_playerspawn)
		{
			spawnBlob(map, "playerspawn", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_zombie_spawn){
			spawnBlob(map, "zombiespawn", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_abomination)
		{
			spawnBlob(map, "abomination", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_chainsaw)
		{
			spawnBlob(map, "chainsaw", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_gaslantern)
		{
			spawnBlob(map, "gaslantern", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_Skeleton)
		{
			spawnBlob(map, "Skeleton", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_Wraith)
		{
			spawnBlob(map, "Wraith", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_Zombie)
		{
			spawnBlob(map, "Zombie", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_ZombieArm)
		{
			spawnBlob(map, "ZombieArm", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_BossZombieKnight)
		{
			spawnBlob(map, "BossZombieKnight", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_ZombieKnight)
		{
			spawnBlob(map, "ZombieKnight", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_shark)
		{
			spawnBlob(map, "shark", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_fish)
		{
			spawnBlob( map, "fishy", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_bison)
		{
			spawnBlob( map, "bison", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_chicken)
		{
			spawnBlob( map, "chicken", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_ladder || pixel == color_tile_ladder_ground || pixel == color_tile_ladder_castle || pixel == color_tile_ladder_wood)
		{
			offsets[ladder_offset].push_back( offset );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_platform_up)
		{
			spawnBlob( map, "wooden_platform", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_platform_right)
		{
			CBlob@ blob = spawnBlob(map, "wooden_platform", offset, 255, true);
			offsets[autotile_offset].push_back(offset);
			blob.setAngleDegrees(90.0f);
		}
		else if (pixel == color_platform_down)
		{
			CBlob@ blob = spawnBlob( map, "wooden_platform", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 180.0f );
		}
		else if (pixel == color_platform_left)
		{
			CBlob@ blob = spawnBlob( map, "wooden_platform", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( -90.0f );
		}
		else if (pixel == color_wooden_door_h_blue)
		{
			spawnBlob( map, "wooden_door", offset, 0, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_wooden_door_v_blue)
		{
			CBlob@ blob = spawnBlob( map, "wooden_door", offset, 0, true );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 90.0f );
		}
		else if (pixel == color_wooden_door_h_red)
		{
			spawnBlob( map, "wooden_door", offset, 1, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_wooden_door_v_red)
		{
			CBlob@ blob = spawnBlob( map, "wooden_door", offset, 1, true );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 90.0f );
		}
		else if (pixel == color_wooden_door_h_noteam)
		{
			spawnBlob( map, "wooden_door", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_wooden_door_v_noteam)
		{
			CBlob@ blob = spawnBlob( map, "wooden_door", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 90.0f );
		}
		else if (pixel == color_stone_door_h_blue)
		{
			spawnBlob( map, "stone_door", offset, 0, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_stone_door_v_blue)
		{
			CBlob@ blob = spawnBlob( map, "stone_door", offset, 0, true );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 90.0f );
		}
		else if (pixel == color_stone_door_h_red)
		{
			spawnBlob( map, "stone_door", offset, 1, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_stone_door_v_red)
		{
			CBlob@ blob = spawnBlob( map, "stone_door", offset, 1, false );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 90.0f );
		}
		else if (pixel == color_stone_door_h_noteam)
		{
			spawnBlob( map, "stone_door", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_stone_door_v_noteam)
		{
			CBlob@ blob = spawnBlob( map, "stone_door", offset, 255, false );
			offsets[autotile_offset].push_back( offset );
			CShape@ shape = blob.getShape();
			blob.setAngleDegrees( 90.0f );
		}
		else if (pixel == color_trapblock_blue)
		{
			spawnBlob( map, "trap_block", offset, 0, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_trapblock_red)
		{
			spawnBlob( map, "trap_block", offset, 1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_trapblock_noteam)
		{
			spawnBlob( map, "trap_block", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_spikes)
		{
			offsets[spike_offset].push_back( offset );
		}
		else if (pixel == color_spikes_ground)
		{
			map.SetTile(offset, CMap::tile_preground_back );
			offsets[spike_offset].push_back( offset );
		}
		else if (pixel == color_spikes_castle)
		{
			map.SetTile(offset, CMap::tile_castle_back );
			offsets[spike_offset].push_back( offset );
		}
		else if (pixel == color_spikes_wood)
		{
			map.SetTile(offset, CMap::tile_wood_back );
			offsets[spike_offset].push_back( offset );
		}
		else if(pixel == chest)
		{
			spawnBlob( map, "chest", offset, 255, true );
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_drill)
		{
			spawnBlob( map, "drill", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_trampoline)
		{
			spawnBlob( map, "trampoline", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_lantern)
		{
			spawnBlob( map, "lantern", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_crate)
		{
			spawnBlob( map, "crate", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_bucket)
		{
			spawnBlob( map, "bucket", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_sponge)
		{
			spawnBlob( map, "sponge", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_steak)
		{
			spawnBlob( map, "steak", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_burger)
		{
			spawnBlob( map, "food", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_heart)
		{
			spawnBlob( map, "heart", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_catapult)
		{
			spawnBlob( map, "catapult", offset, 0, true); // HACK: team for Challenge
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_ballista)
		{
			spawnBlob( map, "ballista", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_mountedbow)
		{
			spawnBlob( map, "mounted_bow", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_longboat)
		{
			spawnBlob( map, "longboat", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_warboat)
		{
			spawnBlob( map, "warboat", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_dinghy)
		{
			spawnBlob( map, "dinghy", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_raft)
		{
			spawnBlob( map, "raft", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_airship)
		{
			spawnBlob( map, "airship", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_bomber)
		{
			spawnBlob( map, "bomber", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_bombs)
		{
			spawnBlob( map, "mat_bombs", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_waterbombs)
		{
			spawnBlob( map, "mat_waterbombs", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_arrows)
		{
			spawnBlob( map, "mat_arrows", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_bombarrows)
		{
			spawnBlob( map, "mat_bombarrows", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_waterarrows)
		{
			spawnBlob( map, "mat_waterarrows", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_firearrows)
		{
			spawnBlob( map, "mat_firearrows", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_bolts)
		{
			spawnBlob( map, "mat_bolts", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_blue_mine)
		{
			spawnBlob( map, "mine", offset, 0, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_red_mine)
		{
			spawnBlob( map, "mine", offset, 1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_mine_noteam)
		{
			spawnBlob( map, "mine", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_boulder)
		{
			spawnBlob( map, "boulder", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_satchel)
		{
			spawnBlob( map, "satchel", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_keg)
		{
			spawnBlob( map, "keg", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == _color_gold)
		{
			spawnBlob( map, "mat_gold", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == _color_stone)
		{
			spawnBlob( map, "mat_stone", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == _color_wood)
		{
			spawnBlob( map, "mat_wood", offset, -1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if (pixel == color_mook_knight)
		{
			spawnBlob( map, "aiknight", offset, 1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_mook_archer)
		{
			spawnBlob( map, "aiarcher", offset, 1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_dummy)
		{
			spawnBlob(map, "dummy", offset, 1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_mook_spawner)
		{
			spawnBlob(map, "mookmarker", offset, 1, true);
			offsets[autotile_offset].push_back( offset );
		}
		else if(pixel == color_mook_spawner_10)
		{
			spawnBlob(map, "x10mookmarker", offset, 1, true);
			offsets[autotile_offset].push_back( offset );
		}		
		else if (pixel == color_hall)
		{
			spawnBlob(map, "hall", offset, -1, true);
			offsets[autotile_offset].push_back(offset);
		}		
		else if (pixel == color_tradingpost_1)
		{
			spawnBlob(map, "tradingpost", offset, 0, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_tradingpost_2)
		{
			spawnBlob(map, "tradingpost", offset, 1, true);
			offsets[autotile_offset].push_back(offset);
		}
		//random scroll per-team
		else if (pixel == color_blue_team_scroll)
		{
			spawnBlob(map, "scroll", offset, 0, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_red_team_scroll)
		{
			spawnBlob(map, "scroll", offset, 1, true);
			offsets[autotile_offset].push_back(offset);
		}
		//generic random scrolls
		else if (pixel == color_crappy_scroll)
		{
			spawnBlob(map, "crappyscroll", offset, -1, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_medium_scroll)
		{
			spawnBlob(map, "mediumscroll", offset, -1, true);
			offsets[autotile_offset].push_back(offset);
		}
		else if (pixel == color_super_scroll)
		{
			spawnBlob(map, "superscroll", offset, -1, true);
			offsets[autotile_offset].push_back(offset);
		}
		else
		{
			HandleCustomTile( map, offset, pixel );
		}
	}

	//override this to add post-load offset types.
	void handleOffset(int type, int offset, int position, int count)
	{
		if(type == autotile_offset)
		{
			PlaceMostLikelyTile(map, offset);
		}
		else if(type == tree_offset)
		{
			// load trees only at the ground
			//if(!map.isTileSolid(map.getTile(offset + map.tilemapwidth))) return;
			if(map.getTile(offset + map.tilemapwidth).type == CMap::tile_empty) return;

			CBlob@ tree = server_CreateBlobNoInit("mmtree" );
			if(tree !is null)
			{			
				tree.setPosition( getSpawnPosition( map, offset ) );
				tree.Init();
				tree.getShape().SetStatic( true );
			}
		}
		else if(type == bush_offset)
		{
			server_CreateBlob("bush", -1, map.getTileWorldPosition(offset) + Vec2f(4, 4));
		}
		else if(type == spike_offset)
		{
			CBlob@ spikes = server_CreateBlob( "spikes", -1, map.getTileWorldPosition(offset) + Vec2f(4, 4));

			if(spikes !is null)
			{
				spikes.getShape().SetStatic( true );
			}
		}
		else if(type == ladder_offset)
		{
			spawnLadder( map, offset );
		}
	}

	void SetupMap(int width, int height)
	{
		map.CreateTileMap(width, height, 8.0f, "Sprites/world.png");
	}

	void SetupBackgrounds()
	{
		// sky
		map.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
		map.CreateSkyGradient("Sprites/skygradient.png"); // override sky color with gradient

		// background
		map.AddBackground("Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, -18.0f), Vec2f(0.3f, 0.3f), color_white);
		map.AddBackground("Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  -5.0f), Vec2f(0.4f, 0.4f), color_white);
		map.AddBackground("Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, 0.0f), Vec2f(0.6f, 0.6f), color_white);

		// fade in
		SetScreenFlash(255,   0,   0,   0);
	}

	CBlob@ spawnLadder(CMap@ map, int offset)
	{
		bool up = false, down = false, right = false, left = false;
		int[]@ ladders = offsets[ladder_offset];
		for (uint step = 0; step < ladders.length; ++step)
		{
			const int lof = ladders[step];
			if (lof == offset-map.tilemapwidth) {
				up = true;
			}
			if (lof == offset+map.tilemapwidth) {
				down = true;
			}
			if (lof == offset+1) {
				right = true;
			}
			if (lof == offset-1) {
				left = true;
			}
		}
		if ( offset % 2 == 0 && ((left && right) || (up && down)) )
		{
			return null;
		}

		CBlob@ blob = server_CreateBlob( "ladder", -1, getSpawnPosition( map, offset) );
		if (blob !is null)
		{
			// check for horizontal placement
			for (uint step = 0; step < ladders.length; ++step)
			{
				if (ladders[step] == offset-1 || ladders[step] == offset+1)
				{
					blob.setAngleDegrees( 90.0f );
					break;
				}
			}
			blob.getShape().SetStatic( true );
		}
		return blob;
	}
}

void PlaceMostLikelyTile(CMap@ map, int offset)
{
	TileType up = map.getTile( offset - map.tilemapwidth).type;
	TileType down = map.getTile( offset + map.tilemapwidth).type;
	TileType left = map.getTile( offset - 1).type;
	TileType right = map.getTile( offset + 1).type;

	bool upEmpty = (up == CMap::tile_empty);

	if(!upEmpty)
	{
		if(up == CMap::tile_castle || up == CMap::tile_castle_back || down == CMap::tile_castle || down == CMap::tile_castle_back ||
			left == CMap::tile_castle || left == CMap::tile_castle_back || right == CMap::tile_castle || right == CMap::tile_castle_back)
		{
			map.SetTile(offset, CMap::tile_castle_back);
		}
		else if( up == CMap::tile_wood || up == CMap::tile_wood_back || down == CMap::tile_wood || down == CMap::tile_wood_back ||
				left == CMap::tile_wood || left == CMap::tile_wood_back || right == CMap::tile_wood || right == CMap::tile_wood_back)
		{
			map.SetTile(offset, CMap::tile_wood_back );
		}
		else if(up == CMap::tile_ground || up == CMap::tile_ground_back || up == CMap::tile_preground_back ||  down == CMap::tile_ground || down == CMap::tile_ground_back || down == CMap::tile_preground_back ||
				left == CMap::tile_ground || left == CMap::tile_ground_back || left == CMap::tile_preground_back || right == CMap::tile_ground || right == CMap::tile_ground_back || right == CMap::tile_preground_back)
		{
			map.SetTile(offset, CMap::tile_preground_back);
		}
	}
	else if(map.isTileSolid(down) && (map.isTileGrass(left) || map.isTileGrass(right)))
	{
		map.SetTile(offset, CMap::tile_grass + 2 + map_random.NextRanged(2));
	}
}

u8 getTeamFromChannel(u8 channel)
{
	// only the bits we want
	channel &= 0x0F;

	return (channel > 7)? 255 : channel;
}

u8 getChannelFromTeam(u8 team)
{
	return (team > 7)? 0x0F : team;
}

u16 getAngleFromChannel(u8 channel)
{
	// only the bits we want
	channel &= 0x30;

	switch(channel)
	{
		case 16: return 90;
		case 32: return 180;
		case 48: return 270;
	}
	return 0;
}

u8 getChannelFromAngle(u16 angle)
{
	switch(angle)
	{
		case  90: return 16;
		case 180: return 32;
		case 270: return 48;
	}
	return 0;
}

Vec2f getSpawnPosition(CMap@ map, int offset)
{
	Vec2f pos = map.getTileWorldPosition(offset);
	f32 tile_offset = map.tilesize * 0.5f;
	pos.x += tile_offset;
	pos.y += tile_offset;
	return pos;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position)
{
	CBlob@ blob = server_CreateBlob(name, team, position);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, const bool fixed)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, u16 angle)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string name, u8 team, Vec2f position, u16 angle, const bool fixed)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, int offset, int team, bool attached_to_map, Vec2f posOffset)
{
	CBlob@ blob = server_CreateBlob(name, team, getSpawnPosition( map, offset) + posOffset);
	if(blob !is null && attached_to_map)
	{
		blob.getShape().SetStatic( true );
	}
	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, int offset, int team, bool attached_to_map = false)
{
	return spawnBlob(map, name, offset, team, attached_to_map, Vec2f_zero);
}

CBlob@ spawnVehicle(CMap@ map, const string& in name, int offset, int team = -1)
{
	CBlob@ blob = server_CreateBlob(name, team, getSpawnPosition( map, offset));
	if(blob !is null)
	{
		blob.RemoveScript("DecayIfLeftAlone.as");
	}
	return blob;
}

void AddMarker(CMap@ map, int offset, const string& in name)
{
	map.AddMarker(map.getTileWorldPosition(offset), name);
	PlaceMostLikelyTile(map, offset);
}

void SaveMap(CMap@ map, const string &in fileName)
{
	const u32 width = map.tilemapwidth;
	const u32 height = map.tilemapheight;
	const u32 space = width * height;

	CFileImage image(width, height, true);
	image.setFilename(fileName, IMAGE_FILENAME_BASE_MAPS);

	// image starts at -1, 0
	image.nextPixel();

	// iterate through tiles
	for(uint i = 0; i < space; i++)
	{
		SColor color = getColorFromTileType(map.getTile(i).type);
		if(map.isInWater(map.getTileWorldPosition(i)))
		{
			if(color == sky)
			{
				color = color_water_air;
			}
			else
			{
				color = color_water_backdirt;
			}
		}
		image.setPixelAndAdvance(color);
	}

	// iterate through blobs
	CBlob@[] blobs;
	getBlobs(@blobs);
	for(uint i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if(blob.getShape() is null) continue;

		SColor color;
		Vec2f offset;

		getInfoFromBlob(blob, color, offset);
		if(color == unused) continue;

		const Vec2f position = map.getTileSpacePosition(blob.getPosition() + offset);

		image.setPixelAtPosition(position.x, position.y, color, false);
	}

	// iterate through markers
	const array<string> TEAM_NAME =
	{
		"blue",
		"red",
		"green",
		"purple",
		"orange",
		"aqua",
		"teal",
		"gray"
	};

	for(u8 i = 0; i < TEAM_NAME.length; i++)
	{
		array<Vec2f> position;

		SColor color;

		if(map.getMarkers(TEAM_NAME[i]+" main spawn", @position))
		{
			for(u8 j = 0; j < position.length; j++)
			{
				color = spawn;
				color.setAlpha(0x80 | getChannelFromTeam(i));
				position[j] = map.getTileSpacePosition(position[j]);

				image.setPixelAtPosition(position[j].x, position[j].y, color, false);
			}
		}

		position.clear();
		if(map.getMarkers(TEAM_NAME[i]+" spawn", @position))
		{
			for(u8 j = 0; j < position.length; j++)
			{
				color = flag;
				color.setAlpha(0x80 | getChannelFromTeam(i));
				position[j] = map.getTileSpacePosition(position[j]);

				image.setPixelAtPosition(position[j].x, position[j].y, color, false);
			}
		}
	}

	image.Save();
}

void getInfoFromBlob(CBlob@ this, SColor &out color, Vec2f &out offset)
{
	const string name = this.getName();

	// declare some default values
	color = unused;
	offset = Vec2f_zero;

	// BLOCKS
	if(this.getShape().isStatic())
	{
		if(name == "ladder")
		{
			color = ladder;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "spikes")
		{
			color = spikes;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "stone_door")
		{
			color = stone_door;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "trap_block")
		{
			color = trap_block;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "wooden_door")
		{
			color = wooden_door;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "wooden_platform")
		{
			color = wooden_platform;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		// MECHANISMS
		else if(name == "coin_slot")
		{
			color = coin_slot;
			color.setAlpha(getChannelFromTeam(255));
		}
		else if(name == "lever")
		{
			color = lever;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "pressure_plate")
		{
			color = pressure_plate;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
		else if(name == "push_button")
		{
			color = push_button;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "sensor")
		{
			color = sensor;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "diode")
		{
			color = diode;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "elbow")
		{
			color = elbow;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "emitter")
		{
			color = emitter;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "inverter")
		{
			color = inverter;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "junction")
		{
			color = junction;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "magazine")
		{
			color = magazine;

			const string[] MAGAZINE_ITEM = {
			"mat_bombs",
			"mat_waterbombs",
			"mat_arrows",
			"mat_waterarrows",
			"mat_firearrows",
			"mat_bombarrows",
			"food"};

			u8 alpha = MAGAZINE_ITEM.length;

			CInventory@ inventory = this.getInventory();
			if(inventory.isFull())
			{
				CBlob@ blob = inventory.getItem(0);

				s8 element = MAGAZINE_ITEM.find(blob.getName());
				if(element != -1)
				{
					alpha = element;
				}
			}
			color.setAlpha(alpha);
		}
		else if(name == "oscillator")
		{
			color = oscillator;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "randomizer")
		{
			color = randomizer;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "receiver")
		{
			color = receiver;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "resistor")
		{
			color = resistor;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "tee")
		{
			color = tee;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "toggle")
		{
			color = toggle;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "transistor")
		{
			color = transistor;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "wire")
		{
			color = wire;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "bolter")
		{
			color = bolter;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
		else if(name == "dispenser")
		{
			color = dispenser;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
		else if(name == "lamp")
		{
			color = lamp;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "obstructor")
		{
			color = obstructor;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "spiker")
		{
			color = spiker;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
		else if(name == "chest")
		{
			color = chest;
			//color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}

		// FLORA
		else if(name == "bush")
		{
			color = color_bush;
		}
		else if(name == "flowers")
		{
			color = color_flowers;
		}
		else if(name == "grain_plant")
		{
			color = color_grain;
		}
		else if(name == "mmtree")
		{
			color = color_tree;
		}
		// FAUNA
		else if(name == "bison")
		{
			color = color_bison;
		}
		else if(name == "chicken")
		{
			color = color_chicken;
		}
		else if(name == "fishy")
		{
			color = color_fish;
		}
		else if(name == "shark")
		{
			color = color_shark;
		}
		else if(name == "ZombiePortal")
		{
			color = color_ZombiePortal;
		}
		else if(name == "playerspawn")
		{
			color = color_playerspawn;
		}
		else if(name == "zombiespawn")
		{
			color = color_zombie_spawn;
		}
		else if(name == "abomination")
		{
			color = color_abomination;
		}
		else if(name == "chainsaw")
		{
			color = color_chainsaw;
		}
		else if(name == "gaslantern")
		{
			color = color_gaslantern;
		}
		else if(name == "Skeleton")
		{
			color = color_Skeleton;
		}
		else if(name == "Wraith")
		{
			color = color_Wraith;
		}
		else if(name == "Zombie")
		{
			color = color_Zombie;
		}
		else if(name == "ZombieArm")
		{
			color = color_ZombieArm;
		}
		else if(name == "BossZombieKnight")
		{
			color = color_BossZombieKnight;
		}
		else if(name == "ZombieKnight")
		{
			color = color_ZombieKnight;
		}


		// below added for map maker mode

		else if(name == "log")
		{
			color = color_log;
		}	
		else if(name == "trampoline")
		{
			color = color_trampoline;
		}
		else if(name == "dummy")
		{
			color = color_dummy;
		}
		else if(name == "bush")
		{
			color = color_bush;
		}
		else if(name == "boulder")
		{
			color = color_boulder;
		}
		else if(name == "satchel")
		{
			color = color_satchel;
		}		
		else if(name == "keg")
		{
			color = color_keg;
		}
		else if(name == "raft")
		{
			color = color_raft;
		}
		else if(name == "factory")
		{
			color = color_factory_noteam;
		}
		else if(name == "nursery")
		{
			color = color_nursery;
		}
		else if(name == "knightshop")
		{
			color = color_knight_shop;
		}
		else if(name == "buildershop")
		{
			color = color_builder_shop;
		}
		else if(name == "archershop")
		{
			color = color_archer_shop;
		}
		else if(name == "boatshop")
		{
			color = color_boat_shop;
		}
		else if(name == "vehicleshop")
		{
			color = color_vehicle_shop;
		}
		else if(name == "quarters")
		{
			color = color_quarters;
		}
		else if(name == "storage")
		{
			color = color_storage_noteam;
		}
		else if(name == "barracks")
		{
			color = color_barracks_noteam;
		}
		else if(name == "nursery")
		{
			color = color_nursery;
		}
		else if(name == "tunnel")
		{
			if(this.getTeamNum() == 0)
			{
				color = color_tunnel_blue;
			}
			else if(this.getTeamNum() == 1)
			{
				color = color_tunnel_red;
			}
			else
			{
				color = color_tunnel_noteam;
			}
		}
		else if(name == "kitchen")
		{
			color = color_kitchen;
		}
		else if(name == "research")
		{
			color = color_research;
		}
		else if(name == "workbench")
		{
			color = color_workbench;
		}
		else if(name == "dinghy")
		{
			color = color_dinghy;
		}
		else if(name == "warboat")
		{
			color = color_warboat;
		}
		else if(name == "longboat")
		{
			color = color_longboat;
		}
		else if(name == "airship")
		{
			color = color_airship;
		}
		else if(name == "bomber")
		{
			color = color_bomber;
		}
		else if(name == "catapult")
		{
			color = color_catapult;
		}
		else if(name == "ballista")
		{
			color = color_ballista;
		}
		else if(name == "mounted_bow")
		{
			color = color_mountedbow;
		}
		else if(name == "crate")
		{
			color = color_crate;
		}
		//else if(name == "chest")
		//{
		//	color = color_chest;
		//}
		else if(name == "bucket")
		{
			color = color_bucket;
		}
		else if(name == "fireplace")
		{
			color = color_campfire;
		}
		else if(name == "heart")
		{
			color = color_heart;
		}
		else if(name == "food")
		{
			color = color_burger;
		}
		else if(name == "steak")
		{
			color = color_steak;
		}
		else if(name == "mat_bombs")
		{
			color = color_bombs;
		}
		else if(name == "mat_waterbombs")
		{
			color = color_waterbombs;
		}
		else if(name == "mat_arrows")
		{
			color = color_arrows;
		}
		else if(name == "mat_firearrows")
		{
			color = color_firearrows;
		}
		else if(name == "mat_bombarrows")
		{
			color = color_bombarrows;
		}
		else if(name == "mat_waterarrows")
		{
			color = color_waterarrows;
		}
		else if(name == "mat_bolts")
		{
			color = color_bolts;
		}
		else if(name == "mat_gold")
		{
			color = _color_gold;
		}
		else if(name == "mat_stone")
		{
			color = _color_stone;
		}
		else if(name == "mat_wood")
		{
			color = _color_wood;
		}
		else if(name == "mat_bombarrows")
		{
			color = color_bombarrows;
		}
		else if(name == "lantern")
		{
			color = color_lantern;
		}
		else if(name == "sponge")
		{
			color = color_sponge;
		}
		else if(name == "mine")
		{
			if(this.getTeamNum() == 0)
			{
				color = color_blue_mine;
			}
			else if(this.getTeamNum() == 1)
			{
				color = color_red_mine;
			}
			else
			{
				color = color_mine_noteam;
			}
		}

		else if(name == "mainspawnmarker")
		{
			if(this.getTeamNum() == 0)
			{
				color = color_blue_main_spawn;
			}
			else if(this.getTeamNum() == 1)
			{
				color = color_red_main_spawn;
			}
			else
			{
				color = color_gray_main_spawn;
			}
		}

		else if(name == "spawnmarker")
		{
			if(this.getTeamNum() == 0)
			{
				color = color_blue_spawn;
			}
			else if(this.getTeamNum() == 1)
			{
				color = color_red_spawn;
			}
			else
			{
				color = color_gray_spawn;
			}
		}
		else if(name == "checkpointmarker")
		{
			color = color_checkpoint;
		}
		else if(name == "mookmarker")
		{
			color = color_mook_spawner;
		}
		else if(name == "x10mookmarker")
		{
			color = color_mook_spawner_10;
		}
		else if(name == "aiknight")
		{
			color = color_mook_knight;
		}
		else if(name == "aiarcher")
		{
			color = color_mook_archer;
		}
		else if(name == "ainecromancer")
		{
			color = color_necromancer;
		}
		else if(name == "princess")
		{
			color = color_princess;
		}	
		else if(name == "necrotpmarker")
		{
			color = color_necromancer_teleport;
		}		
		else if(name == "hall")
		{
			color = color_hall;
		}
		else if(name == "tradingpost")
		{
			if(this.getTeamNum() == 0)
			{
				color = color_tradingpost_1;
			}
			else if(this.getTeamNum() == 1)
			{
				color = color_tradingpost_2;
			}
		}		
		else if(name == "scroll")
		{
			if(this.getTeamNum() == 0)
			{
				color = color_blue_team_scroll;
			}
			else if(this.getTeamNum() == 1)
			{
				color = color_red_team_scroll;
			}
		}		
		else if(name == "crappyscroll")
		{
			color = color_crappy_scroll;
		}		
		else if(name == "mediumscroll")
		{
			color = color_medium_scroll;
		}		
		else if(name == "superscroll")
		{
			color = color_super_scroll;
		}		
		else if(name == "saw")
		{
			color = color_saw;			
		}
		// set last bit to true so the minimum alpha is 128
		u8 alpha = color.getAlpha();
		if(alpha != 0xFF)
		{
			color.setAlpha(0x80 | alpha);
		}
	}
}

SColor getColorFromTileType(TileType tile)
{
	if(tile >= TILE_LUT.length)
	{
		return unused;
	}
	return TILE_LUT[tile];
}

const SColor[] TILE_LUT = {
unused,                                           // |   0 |
unused,                                           // |   1 |
unused,                                           // |   2 |
unused,                                           // |   3 |
unused,                                           // |   4 |
unused,                                           // |   5 |
unused,                                           // |   6 |
unused,                                           // |   7 |
unused,                                           // |   8 |
unused,                                           // |   9 |
unused,                                           // |  10 |
unused,                                           // |  11 |
unused,                                           // |  12 |
unused,                                           // |  13 |
unused,                                           // |  14 |
unused,                                           // |  15 |
color_tile_ground,                                // |  16 |
color_tile_ground,                                // |  17 |
color_tile_ground,                                // |  18 |
color_tile_ground,                                // |  19 |
color_tile_ground,                                // |  20 |
color_tile_ground,                                // |  21 |
color_tile_ground,                                // |  22 |
color_tile_ground,                                // |  23 |
color_tile_ground,                                // |  24 |
color_tile_grass,                                 // |  25 |
color_tile_grass,                                 // |  26 |
color_tile_grass,                                 // |  27 |
color_tile_grass,                                 // |  28 |
color_tile_ground,                                // |  29 | damaged
color_tile_ground,                                // |  30 | damaged
color_tile_ground,                                // |  31 | damaged
color_tile_ground_back,                           // |  32 |
color_tile_ground_back,                           // |  33 |
color_tile_ground_back,                           // |  34 |
color_tile_ground_back,                           // |  35 |
color_tile_ground_back,                           // |  36 |
color_tile_ground_back,                           // |  37 |
color_tile_ground_back,                           // |  38 |
color_tile_ground_back,                           // |  39 |
color_tile_ground_back,                           // |  40 |
color_tile_ground_back,                           // |  41 |
unused,                                           // |  42 |
unused,                                           // |  43 |
unused,                                           // |  44 |
unused,                                           // |  45 |
unused,                                           // |  46 |
unused,                                           // |  47 |
color_tile_castle,                                // |  48 |
color_tile_castle,                                // |  49 |
color_tile_castle,                                // |  50 |
color_tile_castle,                                // |  51 |
color_tile_castle,                                // |  52 |
color_tile_castle,                                // |  53 |
color_tile_castle,                                // |  54 |
unused,                                           // |  55 |
unused,                                           // |  56 |
unused,                                           // |  57 |
color_tile_castle,                                // |  58 | damaged
color_tile_castle,                                // |  59 | damaged
color_tile_castle,                                // |  60 | damaged
color_tile_castle,                                // |  61 | damaged
color_tile_castle,                                // |  62 | damaged
color_tile_castle,                                // |  63 | damaged
color_tile_castle_back,                           // |  64 |
color_tile_castle_back,                           // |  65 |
color_tile_castle_back,                           // |  66 |
color_tile_castle_back,                           // |  67 |
color_tile_castle_back,                           // |  68 |
color_tile_castle_back,                           // |  69 |
unused,                                           // |  70 |
unused,                                           // |  71 |
unused,                                           // |  72 |
unused,                                           // |  73 |
unused,                                           // |  74 |
unused,                                           // |  75 |
color_tile_castle_back,                           // |  76 | damaged
color_tile_castle_back,                           // |  77 | damaged
color_tile_castle_back,                           // |  78 | damaged
color_tile_castle_back,                           // |  79 | damaged
color_tile_gold,                                  // |  80 |
color_tile_gold,                                  // |  81 |
color_tile_gold,                                  // |  82 |
color_tile_gold,                                  // |  83 |
color_tile_gold,                                  // |  84 |
color_tile_gold,                                  // |  85 |
unused,                                           // |  86 |
unused,                                           // |  87 |
unused,                                           // |  88 |
unused,                                           // |  89 |
color_tile_gold,                                  // |  90 | damaged
color_tile_gold,                                  // |  91 | damaged
color_tile_gold,                                  // |  92 | damaged
color_tile_gold,                                  // |  93 | damaged
color_tile_gold,                                  // |  94 | damaged
unused,                                           // |  95 |
color_tile_stone,                                 // |  96 |
color_tile_stone,                                 // |  97 |
unused,                                           // |  98 |
unused,                                           // |  99 |
color_tile_stone,                                 // | 100 | damaged
color_tile_stone,                                 // | 101 | damaged
color_tile_stone,                                 // | 102 | damaged
color_tile_stone,                                 // | 103 | damaged
color_tile_stone,                                 // | 104 | damaged
unused,                                           // | 105 |
color_tile_bedrock,                               // | 106 |
color_tile_bedrock,                               // | 107 |
color_tile_bedrock,                               // | 108 |
color_tile_bedrock,                               // | 109 |
color_tile_bedrock,                               // | 110 |
color_tile_bedrock,                               // | 111 |
color_tile_ground,                                           // | 112 |
unused,                                            // | 113 |
unused,                                            // | 114 |
unused,                                           // | 115 |
unused,                                           // | 116 |
unused,                                           // | 117 |
unused,                                           // | 118 |
unused,                                           // | 119 |
unused,                                           // | 120 |
unused,                                           // | 121 |
unused,                                           // | 122 |
unused,                                           // | 123 |
unused,                                           // | 124 |
unused,                                           // | 125 |
unused,                                           // | 126 |
unused,                                           // | 127 |
color_tile_ground_back,                                           // | 128 |
color_tile_ground_back,                                           // | 129 |
color_tile_ground_back,                                           // | 130 |
color_tile_ground_back,                                           // | 131 |
color_tile_ground_back,                                           // | 132 |
color_tile_ground_back,                                           // | 133 |
color_tile_ground_back,                                           // | 134 |
color_tile_ground_back,                                           // | 135 |
color_tile_ground_back,                                           // | 136 |
unused,                                           // | 137 |
unused,                                           // | 138 |
unused,                                           // | 139 |
unused,                                           // | 140 |
unused,                                           // | 141 |
unused,                                           // | 142 |
unused,                                           // | 143 |
unused,                                           // | 144 |
unused,                                           // | 145 |
unused,                                           // | 146 |
unused,                                           // | 147 |
unused,                                           // | 148 |
unused,                                           // | 149 |
unused,                                           // | 150 |
unused,                                           // | 151 |
unused,                                           // | 152 |
unused,                                           // | 153 |
unused,                                           // | 154 |
unused,                                           // | 155 |
unused,                                           // | 156 |
unused,                                           // | 157 |
unused,                                           // | 158 |
unused,                                           // | 159 |
color_tile_gold,                                           // | 160 |
unused,                                           // | 161 |
unused,                                           // | 162 |
unused,                                           // | 163 |
unused,                                           // | 164 |
unused,                                           // | 165 |
unused,                                           // | 166 |
unused,                                           // | 167 |
unused,                                           // | 168 |
unused,                                           // | 169 |
unused,                                           // | 170 |
unused,                                           // | 171 |
unused,                                           // | 172 |
color_tile_wood_back,                             // | 173 |
unused,                                           // | 174 |
unused,                                           // | 175 |
color_tile_stone,                                           // | 176 |
unused,                                           // | 177 |
unused,                                           // | 178 |
unused,                                           // | 179 |
unused,                                           // | 180 |
unused,                                           // | 181 |
unused,                                           // | 182 |
unused,                                           // | 183 |
unused,                                           // | 184 |
unused,                                           // | 185 |
color_tile_bedrock,                                           // | 186 |
unused,                                           // | 187 |
unused,                                           // | 188 |
unused,                                           // | 189 |
unused,                                           // | 190 |
unused,                                           // | 191 |
color_tile_thickstone,                                           // | 192 |
unused,                                           // | 193 |
unused,                                           // | 194 |
unused,                                           // | 195 |
color_tile_wood,                                  // | 196 |
color_tile_wood,                                  // | 197 |
color_tile_wood,                                  // | 198 |
unused,                                           // | 199 |
color_tile_wood,                                  // | 200 | damaged
color_tile_wood,                                  // | 201 | damaged
color_tile_wood,                                  // | 202 | damaged
color_tile_wood,                                  // | 203 | damaged
color_tile_wood,                                  // | 204 | damaged
color_tile_wood_back,                             // | 205 |
color_tile_wood_back,                             // | 206 |
color_tile_wood_back,                             // | 207 | damaged
color_tile_thickstone,                            // | 208 |
color_tile_thickstone,                            // | 209 |
unused,                                           // | 210 |
unused,                                           // | 211 |
unused,                                           // | 212 |
unused,                                           // | 213 |
color_tile_thickstone,                            // | 214 | damaged
color_tile_thickstone,                            // | 215 | damaged
color_tile_thickstone,                            // | 216 | damaged
color_tile_thickstone,                            // | 217 | damaged
color_tile_thickstone,                            // | 218 | damaged
unused,                                           // | 219 |
unused,                                           // | 220 |
unused,                                           // | 221 |
unused,                                           // | 222 |
unused,                                           // | 223 |
color_tile_castle_moss,                           // | 224 |
color_tile_castle_moss,                           // | 225 |
color_tile_castle_moss,                           // | 226 |
color_tile_castle_back_moss,                      // | 227 |
color_tile_castle_back_moss,                      // | 228 |
color_tile_castle_back_moss,                      // | 229 |
color_tile_castle_back_moss,                      // | 230 |
color_tile_castle_back_moss,                      // | 231 |
unused,                                           // | 232 |
unused,                                           // | 233 |
unused,                                           // | 234 |
unused,                                           // | 235 |
unused,                                           // | 236 |
unused,                                           // | 237 |
unused,                                           // | 238 |
unused,                                           // | 239 |
unused,                                           // | 240 |
unused,                                           // | 241 |
unused,                                           // | 242 |
unused,                                           // | 243 |
unused,                                           // | 244 |
unused,                                           // | 245 |
unused,                                           // | 246 |
unused,                                           // | 247 |
unused,                                           // | 248 |
unused,                                           // | 249 |
unused,                                           // | 250 |
unused,                                           // | 251 |
unused,                                           // | 252 |
unused,                                           // | 253 |
unused,                                           // | 254 |
unused,											  // | 255 |
unused,
};                                         