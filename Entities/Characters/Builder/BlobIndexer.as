u8 getBuildBlobIndex(string name)
{ 
	u8 index = 0;
    const string[] blobNames =
    {        
	//PAGE 0
	"tile_eraser",
	"waterspawner",
	"tile_ground",
	"tile_stone",
	"tile_thickstone",
	"tile_bedrock",
	"tile_gold",
	"tile_ground_back",
	"tile_castle_moss",
	"tile_castle_back_moss",
	"back_stone_block",
	"stone_block",
	"tile_grass",
	"stone_door",
	"wood_block",
	"back_wood_block",
	"wooden_door",
	"trap_block",
	"ladder",
	"wooden_platform",
	"spikes",
	//PAGE 1
	"saw",
	"lantern",
	"bucket",
	"sponge",
	"heart",
	"food",
	"steak",
	"powerup",
	"trampoline",
	"boulder",
	"mat_bombs",
	"mat_waterbombs",
	"mine",
	"keg",
	"satchel",
	"mat_firearrows",
	"mat_waterarrows",
	"mat_bombarrows",
	"mat_arrows",
	"mat_bolts",
	"mat_gold",
	"mat_wood",
	"mat_stone", 
	"scroll",
	"crappyscroll",
	"mediumscroll",
	"superscroll",

	//PAGE 2
	"archershop",
	"knightshop",
	"buildershop",
	"vehicleshop",
	"boatshop",
	"quarters",
	"storage",
	"factory",
	"tunnel",
	"nursery",
	"barracks",
	"kitchen",
	"research",
	"workbench",
	"fireplace",
	"crate",
	"chest",
	"tradingpost",
	"hall",

	//PAGE 3
	"longboat",
	"dinghy",
	"warboat",
	"airship",
	"bomber",
	"catapult", 
	"raft",
	"ballista",
	"mounted_bow",

	//PAGE 4
	"mmtree",
	"log",
	"bush",
	"grain_plant", 
	"flowers",
	"bison",
	"shark",
	"chicken",
	"fishy",

	//PAGE 5
	"wire",
	"elbow",
	"tee",
	"junction",
	"diode",
	"resistor",
	"randomizer",
	"inverter",
	"oscillator",
	"transistor",
	"toggle",
	"lever",
	"push_button",
	"pressure_plate",
	"coin_slot",
	"sensor",
	"receiver",
	"emitter",
	"magazine",
	"bolter",
	"spiker",
	"obstructor",
	"lamp",

	//PAGE 6
	"mainspawnmarker",
	"spawnmarker",
	"checkpointmarker",
	"necrotpmarker",
	"princess",
	"aiknight",
	"aiarcher",
	"ainecromancer",
	"dummy",

	//CharZFB, PAGE 7
	"ZombiePortal",
	"abomination",
	"chainsaw",
	"gaslantern",
	"Skeleton",
	"Wraith",
	"Zombie",
	"Zombiearm",
	"BossZombieKnight",
	"ZombieKnight"
    };

 	for (uint i = 0; i < blobNames.length; i++)
    {
        if (blobNames[i] == name)
        {
           index = i;
        }
    }

    return index;
}