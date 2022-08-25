// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

namespace CMap
{
	enum CustomTiles2
	{ 
		tile_eraser = 126,
	};
};
#include "CustomBlocks.as";
#include "BuildBlock.as";
#include "Requirements.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{
	AddIconToken("$bucket$", "Entities/Items/Bucket/Bucket.png", Vec2f(16, 16), 0);
	AddIconToken("$eraser$", "Entities/Characters/Sprites/TileCursor.png", Vec2f(8, 8), 0);
	AddIconToken("$water$", "Sprites/Water/WaterTiles.png", Vec2f(8, 8), 1);

	//AddIconToken("$aiarcher$", "Entities/Characters/AIcons.png", Vec2f(24, 24), 1);
	//AddIconToken("$aiknight$", "Entities/Characters/AIcons.png", Vec2f(24, 24), 0);
	//AddIconToken("$ainecromancer$", "Entities/Characters/AIcons.png", Vec2f(24, 24), 2);

	//AddIconToken("$bushytree$", "Entities/Natural/Trees/Treeicons.png", Vec2f(16, 40), 1);
	AddIconToken("$tree$", "Entities/Natural/Trees/Treeicons.png", Vec2f(16, 40), 0);
	AddIconToken("$flowersicon$", "Entities/Natural/Flowers/Flowers.png", Vec2f(16, 16), 6);

	AddIconToken("$tile_ground$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_ground);
	AddIconToken("$tile_ground_back$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_ground_back);
	AddIconToken("$tile_thickstone$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_thickstone);
	AddIconToken("$tile_bedrock$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_bedrock);
	AddIconToken("$tile_castle_moss$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle_moss);
	AddIconToken("$tile_gold$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_gold);
	AddIconToken("$tile_stone$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_stone);
	AddIconToken("$tile_grass$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_grass);
	AddIconToken("$tile_castle_back_moss$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle_back_moss);
	AddIconToken("$tile_eraser$", "Sprites/World.png", Vec2f(8, 8), 126);

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_eraser, "tile_eraser", "$tile_eraser$", "Eraser");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "waterspawner", "$water$", "Flowing Water");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ground, "tile_ground", "$tile_ground$", "Dirt Block");
		blocks[0].push_back(b);
	}	
	{
		BuildBlock b(CMap::tile_stone, "tile_stone", "$tile_stone$", "Sparse Stone");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_thickstone, "tile_thickstone", "$tile_thickstone$", "Thick Stone");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_bedrock, "tile_bedrock", "$tile_bedrock$", "Bedrock Block");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_gold, "tile_gold", "$tile_gold$", "Gold Block");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ground_back, "tile_ground_back", "$tile_ground_back$", "Dirt Back Wall");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_moss, "tile_castle_moss", "$tile_castle_moss$", "Mossy Stone Block");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back_moss, "tile_castle_back_moss", "$tile_castle_back_moss$", "Mossy Stone Back Wall");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Stone Back Wall");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block");
		blocks[0].push_back(b);
	}	
	{
		BuildBlock b(CMap::tile_grass, "tile_grass", "$tile_grass$", "Grass");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$stone_door$", "Stone Door");
		blocks[0].push_back(b);
	}		
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform");
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes");
		blocks[0].push_back(b);
	}
	
	BuildBlock[] page_1;
	blocks.push_back(page_1); // Items

		
	{
		BuildBlock b(0, "saw", "$saw$", "Saw");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "lantern", "$lantern$", "Lantern");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "bucket", "$bucket$", "Bucket");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "sponge", "$sponge$", "Sponge");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "heart", "$heart$", "Heart");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "food", "$food$", "Food");
		blocks[1].push_back(b);
	}			
	{
		BuildBlock b(0, "steak", "$steak$", "Steak");
		blocks[1].push_back(b);
	}	
	{
		BuildBlock b(0, "powerup", "$powerup$", "Powerup");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "trampoline", "$trampoline$", "Trampoline");
		blocks[1].push_back(b);
	}	
	{
		BuildBlock b(0, "boulder", "$boulder$", "Boulder");
		blocks[1].push_back(b);
	}/*
	{
		BuildBlock b(0, "bomb", "$bomb$", "Lit Bomb");
		blocks[1].push_back(b);
	}*/	
	{
		BuildBlock b(0, "mat_bombs", "$mat_bombs$", "Bomb");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "mat_waterbombs", "$waterbomb$", "Water Bomb");
		blocks[1].push_back(b);
	}	
	{
		BuildBlock b(0, "mine", "$mine$", "Mine");
		blocks[1].push_back(b);
	}	
	{
		BuildBlock b(0, "keg", "$keg$", "Keg");
		blocks[1].push_back(b);
	}	
	{
		BuildBlock b(0, "satchel", "$satchel$", "Satchel");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_firearrows", "$mat_firearrows$", "Fire Arrows");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_waterarrows", "$mat_waterarrows$", "Water Arrows");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_bombarrows", "$mat_bombarrows$", "Bomb Arrows");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_arrows", "$mat_arrows$", "Arrows");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_bolts", "$mat_bolts$", "Ballista Bolts");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_gold", "$mat_gold$", "Gold Mats");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_wood", "$mat_wood$", "Wood Mats");
		blocks[1].push_back(b);
	}		
	{
		BuildBlock b(0, "mat_stone", "$mat_stone$", "Stone Mats");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "scroll", "$scroll$", "Scroll" + "\n" + "Red or Blue only.");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "crappyscroll", "$crappyscroll$", "Random Crappy Scroll");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "mediumscroll", "$mediumscroll$", "Random Medium Scroll");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "chainsaw", "$chainsaw$", "A Chainsaw");
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "gaslantern", "$gaslantern$", "Gas Lantern");
		blocks[1].push_back(b);
	}

	BuildBlock[] page_2;
	blocks.push_back(page_2); // Industry

	{
		BuildBlock b(0, "archershop", "$archershop$", "Archer Shop");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "knightshop", "$knightshop$", "Knight Shop");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "buildershop", "$buildershop$", "Builder Shop");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "vehicleshop", "$vehicleshop$", "Vehicle Shop");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "boatshop", "$boatshop$", "Boat Shop");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "quarters", "$quarters$", "Quarters");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "storage", "$storage$", "Storage");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "factory", "$factory$", "Factory");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "tunnel", "$tunnel$", "Tunnel");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "nursery", "$nursery$", "Nursery");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "barracks", "$barracks$", "Barracks");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "kitchen", "$kitchen$", "Kitchen");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "research", "$research$", "Research");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "workbench", "$workbench$", "Workbench");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "fireplace", "$fireplace$", "Fireplace");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "crate", "$crate$", "Crate");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "chest", "$chest$", "Chest");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "tradingpost", "$tradingpost$", "Trading Post");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "hall", "$hall$", "Hall");
		blocks[2].push_back(b);
	}
	/*	
	{
		BuildBlock b(0, "war_base", "$war_base$", "WAR Base");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "sign", "$sign$", "Sign");
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "building", "$building$", "CTF Building");
		blocks[2].push_back(b);
	}
	*/
	
	BuildBlock[] page_3;
	blocks.push_back(page_3); //Vehicles
	
	{
		BuildBlock b(0, "longboat", "$longboat$", "Longboat");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "dinghy", "$dinghy$", "Dinghy");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "warboat", "$warboat$", "Warboat");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "airship", "$airship$", "Airship");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "bomber", "$bomber$", "Bomber");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "catapult", "$catapult$", "Catapult");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "raft", "$raft$", "Raft");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "ballista", "$ballista$", "Ballista");
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "mounted_bow", "$mounted_bow$", "Mounted Bow");
		blocks[3].push_back(b);
	}


	BuildBlock[] page_4;
	blocks.push_back(page_4); // Natural

	{
		BuildBlock b(0, "mmtree", "$tree$", "Tree");
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "log", "$log$", "Log");
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "bush", "$bush$", "Bush");
		blocks[4].push_back(b);
	}	
	{
		BuildBlock b(0, "grain_plant", "$grain_plant$", "Grain Plant");
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "flowers", "$flowersicon$", "Flowers");
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "bison", "$bison$", "Bison");
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "shark", "$shark$", "Shark");
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "chicken", "$chicken$", "Chicken");
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "fishy", "$fishy$", "Fishy");
		blocks[4].push_back(b);
	}

	BuildBlock[] page_5;
	blocks.push_back(page_5);		//Components

	{
		BuildBlock b(0, "wire", "$wire$", "Wire");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "tee", "$tee$", "Tee");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "junction", "$junction$", "Junction");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "diode", "$diode$", "Diode");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "lever", "$lever$", "Lever");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$pushbutton$", "Button");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "magazine", "$magazine$", "Magazine");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "bolter", "$bolter$", "Bolter");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "spiker", "$spiker$", "Spiker");
		blocks[5].push_back(b);
	}	
	{
		BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
		blocks[5].push_back(b);
	}	
	{
		BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		blocks[5].push_back(b);
	}


	BuildBlock[] page_6;
	blocks.push_back(page_6);	// Gamemode
		/*
	{
		BuildBlock b(0, "flag_base", "$flag_base$", "CTF flag");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "tdm_spawn", "$tdm_spawn$", "TDM Ruins");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "tent", "$tent$", "Tent");
		blocks[5].push_back(b);
	}
	*/
	{
		BuildBlock b(0, "mainspawnmarker", "$mainspawnmarker$", "Main Spawn Marker." + "\n" + "Used in CTF, TDM, TTH, Challenge" + "\n" + "Place on ground");
		blocks[6].push_back(b);
	}
	{
		BuildBlock b(0, "spawnmarker", "$spawnmarker$", "Spawn Marker." + "\n" + "CTF: Flag" + "\n" + "TTH: Hall");
		blocks[6].push_back(b);
	}
	{
		BuildBlock b(0, "checkpointmarker", "$checkpointmarker$", "Checkpoint Marker." + "\n" + "Finish point in Challenge.");
		blocks[6].push_back(b);
	}/*
	{
		BuildBlock b(0, "x10mookmarker", "$x10mookmarker$", "*10 Mook Spawn Marker." + "\n" + "Just a regular x10 marker, until otherwise.");
		blocks[6].push_back(b);
	}
	{
		BuildBlock b(0, "mookmarker", "$mookmarker$", "Mook Spawn Marker." + "\n" + "It's a marker for a mook.");
		blocks[6].push_back(b);
	}*/
	{
		BuildBlock b(0, "necrotpmarker", "$necrotpmarker$", "Necromancer Teleport Marker." + "\n" + "The Necromancer can teleport here");
		blocks[6].push_back(b);
	}/*
	{
		BuildBlock b(0, "symmetricalmarker", "$symmetricalmarker$", "Symmetry marker");
		blocks[5].push_back(b);
	}
	{
		BuildBlock b(0, "migrant", "$aimigrant$", "Migrant");
		blocks[5].push_back(b);
	}*/
	{
		BuildBlock b(0, "princess", "$princess$", "Princess");
		blocks[6].push_back(b);
	}
	{
		BuildBlock b(0, "aiknight", "$aiknight$", "AI Knight");
		blocks[6].push_back(b);
	}
	{
		BuildBlock b(0, "aiarcher", "$aiarcher$", "AI Archer");
		blocks[6].push_back(b);
	}
	{
		BuildBlock b(0, "ainecromancer", "$ainecromancer$", "AI Necromancer");
		blocks[6].push_back(b);
	}
	{
		BuildBlock b(0, "dummy", "$dummy$", "Dummy");
		blocks[6].push_back(b);
	}

	BuildBlock[] page_7;
	blocks.push_back(page_7);	// ZFB
	{
		BuildBlock b(0, "ZombiePortal", "$ZombiePortal$", "Zombie Portal");
		blocks[7].push_back(b);
	}
	{
		BuildBlock b(0, "zombiespawn", "$zombiespawn$", "Zombie Spawn");
		blocks[7].push_back(b);
	}
	/*{
		BuildBlock b(0, "abomination", "$abomination$", "Abomination");
		blocks[7].push_back(b);
	}
	{
		BuildBlock b(0, "Skeleton", "$Skeleton$", "Skeleton");
		blocks[7].push_back(b);
	}
	{
		BuildBlock b(0, "Wraith", "$Wraith$", "Wraith");
		blocks[7].push_back(b);
	}
	{
		BuildBlock b(0, "Zombie", "$Zombie$", "Zombie");
		blocks[7].push_back(b);
	}
	{
		BuildBlock b(0, "ZombieArm", "$ZombieArm$", "Zombie Arm");
		blocks[7].push_back(b);
	}
	{
		BuildBlock b(0, "BossZombieKnight", "$BossZombieKnight$", "BossZombieKnight");
		blocks[7].push_back(b);
	}
	{
		BuildBlock b(0, "ZombieKnight", "$ZombieKnight$", "ZombieKnight");
		blocks[7].push_back(b);
	}*/
}