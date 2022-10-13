// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out
// By the way, in case you couldn't tell, "mat" stands for "material(s)"

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "GenerateFromKAGGen.as";

const bool chatCommandCooldown = false; // enable if you want cooldown on your server
const uint chatCommandDelay = 3 * 30; // Cooldown in seconds
const string[] blacklistedItems = {
	"hall",         // grief
	"shark",        // grief spam
	"bison",        // grief spam
	"necromancer",  // annoying/grief
	"greg",         // annoying/grief
	"ctf_flag",     // sound spam
	"flag_base"     // sound spam + bedrock grief
};

void onInit(CRules@ this)
{
	this.addCommandID("SendChatMessage");
}

//bedrock generation
void GenerateBedrock(){
    for(int x = 0; x < getMap().tilemapwidth; ++x){
		float height = getMap().tilemapheight;
		PlaceBlocks(Vec2f(x*8.0f,height*8.0f+8.0f), "up", 10, 106);
	} //place 10 rows of bedrock at the bottom of the map
	float width = getMap().tilemapwidth*8.0f;
	int random3 = XORRandom(5);
	for(int x = 0; x < getMap().tilemapwidth; x++){
		int random = XORRandom(8); //how far down do we go?
		int random2 = XORRandom(5); //how far do we place the blocks?
		for(int i = 0; i < random2; i++){
			PlaceBlocks(Vec2f(x*8.0f+i*8.0f,getMap().tilemapheight*8.0f-80.0f), "down", random, 0);
		}
	}
    for(int y = 0; y < getMap().tilemapheight; ++y){ //smooth to the right
        for(int x = 0; x < getMap().tilemapwidth; ++x){
			if(getMap().getTile(Vec2f(x*8.0f,y*8.0f)).type == 106){
				if(CheckBlocks(Vec2f(x*8.0f+8.0f,y*8.0f), "down", 2, false) == true){ //check right
					continue; //assume we hit bedrock
				}
				else{ //no bedrock
					if(CheckBlocks(Vec2f(x*8.0f+16.0f,y*8.0f), "down", 2, false) == true){ //do we hit bedrock?
						PlaceBlocks(Vec2f(x*8.0f+8.0f,y*8.0f), "down", 4, 106); //is there more bedrock to the side of it?
					}
					else{ //no bedrock nearby
						PlaceBlocks(Vec2f(x*8.0f+8.0f,y*8.0f), "down", 4, 106); //place two bedrock down
					}
				}
			}
		}
	}
    for(int y = 0; y < getMap().tilemapheight; ++y){ //smooth to the left
        for(int x = 0; x < getMap().tilemapwidth; ++x){
			if(getMap().getTile(Vec2f(x*8.0f,y*8.0f)).type == 106){
				if(CheckBlocks(Vec2f(x*8.0f-8.0f,y*8.0f), "down", 1, false) == true){ //check left
					continue; //assume we hit bedrock
				}
				else{ //no bedrock
					if(CheckBlocks(Vec2f(x*8.0f-16.0f,y*8.0f), "down", 2, false) == true){ //do we hit bedrock?
						PlaceBlocks(Vec2f(x*8.0f-8.0f,y*8.0f), "down", 4, 106); //is there more bedrock to the side of it?
					}
					else{ //no bedrock nearby
						PlaceBlocks(Vec2f(x*8.0f-8.0f,y*8.0f), "down", 4, 106); //place two bedrock down
					}
				}
			}
		}
	}
    for(int y = 0; y < getMap().tilemapheight; ++y){ //fix random holes
        for(int x = 0; x < getMap().tilemapwidth; ++x){
			if(getMap().getTile(Vec2f(x*8.0f,y*8.0f)).type == 106){ //is this bedrock?
				if(getMap().getTile(Vec2f(x*8.0f,y*8.0f+8.0f)).type == 0){ //is this air?
					PlaceBlocks(Vec2f(x*8.0f,y*8.0f), "down", 5, 106); //place a pillar down
				}
			}
		}
	}
}

//returns true if it is an ore
bool IsOre(Vec2f pos){ //is this ore?
	int a = getMap().getTile(pos).type;
	if(a == 80 || a == 81 || a == 81 || a == 82 || a == 83 || a == 84 || a == 85 || a == 90 || a == 91 || a == 92 || a == 93 || a == 94 || a == 96 || a == 97 || a == 100 || a == 101 || a == 102 || a == 103 || a == 104 || a == 208 || a == 209 || a == 214 || a == 215 || a == 216 || a == 217 || a == 218){
		print(""+a);
		return true;
	}
	else{
		return false;
	}
}

//start position
//what radius are we checking?
bool CheckOres(Vec2f pos,uint radius){ //this will check if there is at least one ore in a radius * radius square area
	for(int x = 0; x < radius+1; x++){ //+1 because we also check the ore in the center
		for(int y = 0; y < radius+1; y++){
			if(IsOre(Vec2f((pos.x+x*8.0f)*0.5f,(pos.y+y*8.0f)*0.5f))){
				return true; //ore is found
			}
		}
	}
	return false;
}

//start position
//which direction should we check in
//how many tiles are we checking?
//do we interact with blobs?
bool CheckBlocks(Vec2f pos, string direction,int howfar,bool interact){
	if(interact == true){ //we interact with blobs
		if(direction == "left"){ //check left
			float end = pos.x-(howfar*8.0f);
			return getMap().rayCastSolid(pos, Vec2f(end,pos.y)); //is there tiles here?
		}
		else if(direction == "right"){ //check right
			float end = pos.x+(howfar*8.0f);
			return getMap().rayCastSolid(pos, Vec2f(end,pos.y)); //is there tiles here?
		}
		else if(direction == "up"){ //check up
			float end = pos.y-(howfar*8.0f);
			return getMap().rayCastSolid(pos, Vec2f(pos.x,end)); //is there tiles here?
		}
		else{ 
			float end = pos.y+(howfar*8.0f);
			return getMap().rayCastSolid(pos, Vec2f(pos.x,end)); //is there tiles here?
		}
	}
	else{ //we do not interact with blobs
		if(direction == "left"){ //check left
			float end = pos.x-(howfar*8.0f);
			return getMap().rayCastSolidNoBlobs(pos, Vec2f(end,pos.y)); //is there tiles here?
		}
		else if(direction == "right"){ //check right
			float end = pos.x+(howfar*8.0f);
			return getMap().rayCastSolidNoBlobs(pos, Vec2f(end,pos.y)); //is there tiles here?
		}
		else if(direction == "up"){ //check up
			float end = pos.y-(howfar*8.0f);
			return getMap().rayCastSolidNoBlobs(pos, Vec2f(pos.x,end)); //is there tiles here?
		}
		else{ 
			float end = pos.y+(howfar*8.0f);
			return getMap().rayCastSolidNoBlobs(pos, Vec2f(pos.x,end)); //is there tiles here?
		}
	}
}

//start position
//which direction should we check in
//how many tiles are we checking?
//what block are we placing?
void PlaceBlocks(Vec2f pos, string direction,int howfar, int block){
	if(direction == "left"){ //place left
		for (int i = 0; i < howfar; i++){
			float end = pos.x-(howfar+i*8.0f);
			getMap().server_SetTile(Vec2f(end,pos.y), block);
		}
	}
	if(direction == "right"){ //place right
		for (int i = 0; i < howfar; i++){
			float end = pos.x+(howfar+i*8.0f);
			getMap().server_SetTile(Vec2f(end,pos.y), block);
		}
	}
	if(direction == "up"){ //place up
		for (int i = 0; i < howfar; i++){
			float end = pos.y-(howfar+i*8.0f);
			getMap().server_SetTile(Vec2f(pos.x,end), block);
		}
	}
	if(direction == "down"){ //place down
		for (int i = 0; i < howfar; i++){
			float end = pos.y+(howfar+i*8.0f);
			getMap().server_SetTile(Vec2f(pos.x,end), block);
		}
	}
}

void PlaceGrass(Vec2f pos){
	int whichgrass = XORRandom(4);
	if (whichgrass == 4-1){ //grass type one
		getMap().server_SetTile(pos, 25);
	}
	else if (whichgrass == 3-1){ //grass type two
		getMap().server_SetTile(pos, 26);
	}
	else if (whichgrass == 2-1){ //grass type three
		getMap().server_SetTile(pos, 27);
	}
	else if (whichgrass == 1-1){ //grass type four
		getMap().server_SetTile(pos, 28);
	}
}

void PlaceNature(uint16 tileType, Vec2f pos)
{
	CMap@ map = getMap();
	//reference basepngloader.as for tiles
    if (tileType == 16){ //search for dirt
        Vec2f pos2;
        pos2.x = pos.x;
        pos2.y = pos.y-8.0f;
		int random = XORRandom(10); //10 so these can be percents
		if (random < 8-1){ //grass
			if(map.getTile(pos2).type == 0){ //search for air
				PlaceGrass(pos2); //set tile to grass
        	}
		}

		else if (random == 9-1){ //trees
			int whichtree = XORRandom(2); //which tree should we generate?
			if (whichtree == 2-1){ // pine tree
				float pos3 = pos2.y;
				//we are already one block up
				//can the tree fully grow here?
				if(CheckBlocks(pos2,"up",8,true) == false){ //if there is no blocks, place the tree
					// CBlob@ tree = server_CreateBlob("tree_pine", -1, pos2);
					CBlob@ tree = server_CreateBlobNoInit("tree_pine");
					if(tree !is null){ //let us instant grow the tree
						tree.Tag("startbig");
						tree.setPosition(pos2);
						tree.Init();
					}
				}
				else{
					if(map.getTile(pos2).type == 0){
						PlaceGrass(pos2); //set tile to grass if we cannot grow a tree
					}
				}
			}
			else if (whichtree == 1-1){ //bushy tree
				float pos3 = pos2.y;
				//we are already one block up
				//can the tree fully grow here?
				if(CheckBlocks(pos2,"up",6,true) == false){
					CBlob@ tree = server_CreateBlobNoInit("tree_bushy");
					if(tree !is null){ //let us instant grow the tree
						tree.Tag("startbig");
						tree.setPosition(pos2);
						tree.Init();
					}
				}
				else{
					if(map.getTile(pos2).type == 0){
						PlaceGrass(pos2); //set tile to grass if we cannot grow a tree
					}
				}
			}
		}

		else if (random == 10-1){ //flower
			if(map.getTile(pos2).type == 0){
				server_CreateBlob("flowers",-1,pos2);
			}
		}
    }
}

void PlaceDirt(){
	CMap@ map = getMap(); //get map for later use

    //for(int y = 0; y < getMap().tilemapheight; y++){
		int nb_of_mountains = 4;
		float amplitude = 1.5f; // between 0.5 and 2 is prob good
		float roughness_attenuation = 0.1f; //here, higher mean less scuffed, between 0.5 and 1 is prob good
		nb_of_mountains = XORRandom(5)+1;//0.25f+(1/(XORRandom(30)+1))*(5.0f - 0.25f);
		amplitude = 0.30f+(1/float(XORRandom(10000)+1))*(1.5f - 0.50f);
		roughness_attenuation = (1/float(XORRandom(100)+1))*(0.5f);
		bool onlyPositive = false;
		if(XORRandom(100) < 25){
			onlyPositive = true;
		}
    	for(int x = 0; x < map.tilemapwidth; x++){
			float baseline_height = map.tilemapheight*amplitude*Maths::Sin(2*Maths::Pi*x*8/(map.tilemapwidth*8));
			float baseline_height_2 = map.tilemapheight*amplitude*Maths::Sin(float(nb_of_mountains)*2*Maths::Pi*x*8/(map.tilemapwidth*8));
			float roughness_baseline = map.tilemapheight*amplitude*roughness_attenuation*Maths::Sin(60*2*Maths::Pi*x*8/(map.tilemapwidth*8));
			float final_sine = baseline_height_2+baseline_height+roughness_baseline;
			if (onlyPositive){
				final_sine = Maths::Abs(baseline_height_2)+Maths::Abs(baseline_height)+roughness_baseline;
			}
			//map.server_SetTile(Vec2f((x*8.0f)*(place*5.0f)*2.0f,baseline*8.0f+32.0f), 106); 
			map.server_SetTile(Vec2f(x*8,getMap().tilemapheight*4.0f-final_sine),16); 
		}
	//fix for being very holey
    for(int y = 0; y < getMap().tilemapheight; y++){
    	for(int x = 0; x < getMap().tilemapwidth; x++){
			Vec2f pos = Vec2f(x*8.0f,y*8.0f);
			if(map.getTile(pos).type == 16){
				if(map.getTile(Vec2f(x*8.0f,y*8.0f+8.0f)).type == 0){
					map.server_SetTile(Vec2f(x*8.0f,y*8.0f+8.0f), 16);
				}
			}
		}
	}
}

int genore(){ //for OreChunk()
	int whatore = XORRandom(12); //what ore are we placing?
	if(whatore > 7){
		return 16; //dirt
	}
	if (whatore == 7){
		return 80; //gold
	}
	else if (whatore == 6 || whatore == 5 || whatore == 4 || whatore == 3 || whatore == 2){
		return 96; //stone
	}
	else if (whatore == 1 || whatore == 0){
		return 208; //thick stone
	}
	print("failed to generate a correct value.");
	return 16;
}

void OreChunk(){
	for(int y = 0; y < getMap().tilemapheight; y++){
		for(int x = 0; x < getMap().tilemapwidth; x++){
			Vec2f pos = Vec2f(x*8.0f, y*8.0f);
			if(getMap().getTile(pos).type == 16){ //dirt
				if(x*8.0f % (XORRandom(4.0f)+3.0f*8.0f) == 0 && y*8.0f % (XORRandom(4.0f)+3.0f*8.0f) == 0){
					int radius = XORRandom(4)+1; //1-5
					for(int x = 0; x < radius+1; x++){ //+1 because we also check the ore in the center
						for(int y = 0; y < radius+1; y++){
							if(getMap().getTile(Vec2f(pos.x+x*8.0f,pos.y+y*8.0f)).type == 16){ //only go onto dirt...
								getMap().server_SetTile(Vec2f(pos.x+x*8.0f,pos.y+y*8.0f), genore()); //up and left
							}
							if(getMap().getTile(Vec2f(pos.x-x*8.0f,pos.y-y*8.0f)).type == 16){
								getMap().server_SetTile(Vec2f(pos.x-x*8.0f,pos.y-y*8.0f), genore()); //down and right
							}
						}
					}
				}
			}
		}
		//todo: some type of smoothing system...
	}
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	//--------MAKING CUSTOM COMMANDS-------//
	// Making commands is easy - Here's a template:
	//
	// if (text_in == "!YourCommand")
	// {
	//	// what the command actually does here
	// }
	//
	// Switch out the "!YourCommand" with
	// your command's name (i.e., !cool)
	//
	// Then decide what you want to have
	// the command do
	//
	// Here are a few bits of code you can put in there
	// to make your command do something:
	//
	// blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 10.0f, 0);
	// Deals 10 damage to the player that used that command (20 hearts)
	//
	// CBlob@ b = server_CreateBlob('mat_wood', -1, pos);
	// insert your blob/the thing you want to spawn at 'mat_wood'
	//
	// player.server_setCoins(player.getCoins() + 100);
	// Adds 100 coins to the player's coins
	//-----------------END-----------------//

	// cannot do commands while dead

	if (player is null)
		return true;

	CBlob@ blob = player.getBlob(); // now, when the code references "blob," it means the player who called the command

	if (blob is null || text_in.substr(0, 1) != "!") // dont continue if its not a command
	{
		return true;
	}

	const Vec2f pos = blob.getPosition(); // grab player position (x, y)
	const int team = blob.getTeamNum(); // grab player team number (for i.e. making all flags you spawn be your team's flags)
	const bool isMod = player.isMod();
	const string gamemode = this.gamemode_name;
	bool wasCommandSuccessful = true; // assume command is successful 
	string errorMessage = ""; // so errors can be printed out of wasCommandSuccessful is false
	SColor errorColor = SColor(255,255,0,0); // ^

	if (!isMod && this.hasScript("Sandbox_Rules.as") || chatCommandCooldown) // chat command cooldown timer
	{
		uint lastChatTime = 0;
		if (blob.exists("chat_last_sent"))
		{
			lastChatTime = blob.get_u16("chat_last_sent");
			if (getGameTime() < lastChatTime)
			{
				return true;
			}
		}
	}

	
	// commands that don't rely on sv_test being on (sv_test = 1)

	if (isMod)
	{
		if (text_in == "!bot")
		{
			AddBot("Henry");
			return true;
		}
		else if (text_in == "!debug")
		{
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ blob = all[i];
				print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
			}
		}
		else if (text_in == "!endgame")
		{
			this.SetCurrentState(GAME_OVER); //go to map vote
			return true;
		}
		else if (text_in == "!startgame")
		{
			this.SetCurrentState(GAME);
			return true;
		}
		else if (text_in == "!drain"){ //removes all water
			print("hello");
            for(int y = 0; y < getMap().tilemapheight; ++y){
                for(int x = 0; x < getMap().tilemapwidth; ++x){
					getMap().server_setFloodWaterWorldspace(Vec2f(x*8.0f,y*8.0f), false);
				}
			}
			return true;
		}
		else if (text_in == "!placenature" || text_in == "!pn" || text_in == "!generatenature" || text_in == "!gn"){
            CMap@ map = getMap(); //loop through entire map
            for(int y = 0; y < map.tilemapheight; ++y){
                for(int x = 0; x < map.tilemapwidth; ++x){
                    Vec2f pos = Vec2f(x,y)*8.0f;
                    PlaceNature(map.getTile(pos).type,pos);
                }
            }
			return true;
        }
		else if (text_in == "!removenature"){
            for(int y = 0; y < getMap().tilemapheight; ++y){
                for(int x = 0; x < getMap().tilemapwidth; ++x){
					Vec2f pos = Vec2f(x,y)*8.0f;
					if(getMap().getTile(pos).type == 25 || getMap().getTile(pos).type == 26 || getMap().getTile(pos).type == 27 || getMap().getTile(pos).type == 28){ //remove grass
						getMap().server_SetTile(pos,0);
					}
					CBlob@[] blobs;
					if (getBlobsByName("tree_pine", @blobs)){
						for (int i = 0; i < blobs.length; i++) {
							blobs[i].server_Die();
						}
					}
					if (getBlobsByName("tree_bushy", @blobs)){
						for (int i = 0; i < blobs.length; i++) {
							blobs[i].server_Die();
						}
					}
					if (getBlobsByName("flowers", @blobs)){
						for (int i = 0; i < blobs.length; i++) {
							blobs[i].server_Die();
						}
					}
					// no cleanup required for logs & seeds due to cfg not including their creation file
				}
			}
			return true;
		}
		else if (text_in == "!generateoreold"){ //todo: make the ratio value configurable
            for(int y = 0; y < getMap().tilemapheight; ++y){
                for(int x = 0; x < getMap().tilemapwidth; ++x){
					Vec2f pos = Vec2f(x,y)*8.0f;
					//all the ore values, including dirt.
					if(getMap().getTile(pos).type == 16 || getMap().getTile(pos).type == 17 || getMap().getTile(pos).type == 18 || getMap().getTile(pos).type == 19 || getMap().getTile(pos).type == 20 || getMap().getTile(pos).type == 21 || getMap().getTile(pos).type == 22 || getMap().getTile(pos).type == 23 || getMap().getTile(pos).type == 24 || getMap().getTile(pos).type == 29 || getMap().getTile(pos).type == 30 || getMap().getTile(pos).type == 31 || getMap().getTile(pos).type == 80 || getMap().getTile(pos).type == 81 || getMap().getTile(pos).type == 81 || getMap().getTile(pos).type == 82 || getMap().getTile(pos).type == 83 || getMap().getTile(pos).type == 84 || getMap().getTile(pos).type == 85 || getMap().getTile(pos).type == 90 || getMap().getTile(pos).type == 91 || getMap().getTile(pos).type == 92 || getMap().getTile(pos).type == 93 || getMap().getTile(pos).type == 94 || getMap().getTile(pos).type == 96 || getMap().getTile(pos).type == 97 || getMap().getTile(pos).type == 100 || getMap().getTile(pos).type == 101 || getMap().getTile(pos).type == 102 || getMap().getTile(pos).type == 103 || getMap().getTile(pos).type == 104 || getMap().getTile(pos).type == 208 || getMap().getTile(pos).type == 209 || getMap().getTile(pos).type == 214 || getMap().getTile(pos).type == 215 || getMap().getTile(pos).type == 216 || getMap().getTile(pos).type == 217 || getMap().getTile(pos).type == 218){ //only run if it is an ore or dirt
						int whatore = XORRandom(29); //change this higher to have more dirt
						if(whatore > 9-1){
							getMap().server_SetTile(pos, 16); //dirt
						}
						else if (whatore == 8-1 || whatore == 7-1){
							getMap().server_SetTile(pos, 80); //gold
						}
						else if (whatore == 6-1 || whatore == 5-1 || whatore == 4-1){
							getMap().server_SetTile(pos, 96); //stone
						}
						else if (whatore == 3-1 || whatore == 2-1 || whatore == 1-1){
							getMap().server_SetTile(pos, 208); //thick stone
						}
					}
				}
			}
			return true;
		}
		else if (text_in == "!generateore"){
			OreChunk();
			return true;
		}
		else if (text_in == "!removeore"){
            for(int y = 0; y < getMap().tilemapheight; ++y){
                for(int x = 0; x < getMap().tilemapwidth; ++x){
					Vec2f pos = Vec2f(x,y)*8.0f;
					//all the ore values, including dirt.
					if(getMap().getTile(pos).type == 16 || getMap().getTile(pos).type == 17 || getMap().getTile(pos).type == 18 || getMap().getTile(pos).type == 19 || getMap().getTile(pos).type == 20 || getMap().getTile(pos).type == 21 || getMap().getTile(pos).type == 22 || getMap().getTile(pos).type == 23 || getMap().getTile(pos).type == 24 || getMap().getTile(pos).type == 29 || getMap().getTile(pos).type == 30 || getMap().getTile(pos).type == 31 || getMap().getTile(pos).type == 80 || getMap().getTile(pos).type == 81 || getMap().getTile(pos).type == 81 || getMap().getTile(pos).type == 82 || getMap().getTile(pos).type == 83 || getMap().getTile(pos).type == 84 || getMap().getTile(pos).type == 85 || getMap().getTile(pos).type == 90 || getMap().getTile(pos).type == 91 || getMap().getTile(pos).type == 92 || getMap().getTile(pos).type == 93 || getMap().getTile(pos).type == 94 || getMap().getTile(pos).type == 96 || getMap().getTile(pos).type == 97 || getMap().getTile(pos).type == 100 || getMap().getTile(pos).type == 101 || getMap().getTile(pos).type == 102 || getMap().getTile(pos).type == 103 || getMap().getTile(pos).type == 104 || getMap().getTile(pos).type == 208 || getMap().getTile(pos).type == 209 || getMap().getTile(pos).type == 214 || getMap().getTile(pos).type == 215 || getMap().getTile(pos).type == 216 || getMap().getTile(pos).type == 217 || getMap().getTile(pos).type == 218){ //only run if it is an ore or dirt
						getMap().server_SetTile(pos, 16); //dirt
					}
				}
			}
			return true;
		}
		else if (text_in == "!placebedrock" || text_in == "!generatebedrock"){
            GenerateBedrock();
			return true;
		}
		else if (text_in == "!removebedrock"){ //turn bedrock to dirt
            for(int y = 0; y < getMap().tilemapheight; ++y){
                for(int x = 0; x < getMap().tilemapwidth; ++x){
					Vec2f pos = Vec2f(x,y)*8.0f;
					//all the ore values, including dirt.
					if(getMap().getTile(pos).type == 106){ //only run if it is an ore or dirt
						getMap().server_SetTile(pos, 16); //dirt
					}
				}
			}
			return true;
		}
		else if (text_in == "!placedirt" || text_in == "!generatedirt"){
			PlaceDirt();
			return true;
		}
		else if (text_in == "!generateall"){
			GenerateBedrock();
			PlaceDirt();
			OreChunk();
            for(int y = 0; y < getMap().tilemapheight; ++y){ //placenature();
                for(int x = 0; x < getMap().tilemapwidth; ++x){
                    Vec2f pos = Vec2f(x,y)*8.0f;
                    PlaceNature(getMap().getTile(pos).type,pos);
                }
            }
			// OreChunk();
			return true;
		}
	}

	// spawning things

	// these all require sv_test - no spawning without it
	// some also require the player to have mod status (!spawnwater)

	if (sv_test || isMod)
	{
		if (text_in == "!tree") // pine tree (seed)
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
		else if (text_in == "!btree") // bushy tree (seed)
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!allarrows") // 30 normal arrows, 2 water arrows, 2 fire arrows, 1 bomb arrow (full inventory for archer)
		{
			server_CreateBlob('mat_arrows', -1, pos);
			server_CreateBlob('mat_waterarrows', -1, pos);
			server_CreateBlob('mat_firearrows', -1, pos);
			server_CreateBlob('mat_bombarrows', -1, pos);
		}
		else if (text_in == "!arrows") // 3 mats of 30 arrows (90 arrows)
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!allbombs") // 2 normal bombs, 1 water bomb
		{
			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
			server_CreateBlob('mat_waterbombs', -1, pos);
		}
		else if (text_in == "!bombs") // 3 (unlit) bomb mats
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		/*else if (text_in == "!drink") // removes 1 water tile roughly at the player's x, y, coordinates (I notice that it favors the bottom left of the player's sprite)
		{
			getMap().server_setFloodWaterWorldspace(pos, false);
		}*/
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0)); //e.g., !crate shark Your Little Darling
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins") // adds 100 coins to the player's coins
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in == "!coinoverload") // + 10000 coins
		{
			player.server_setCoins(player.getCoins() + 10000);
		}
		else if (text_in == "!fishyschool") // spawns 12 fishies
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('fishy', -1, pos);
			}
		}
		else if (text_in == "!chickenflock") // spawns 12 chickens
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('chicken', -1, pos);
			}
		}
		else if (text_in == "!allmats") // 500 wood, 500 stone, 100 gold
		{
			//wood
			CBlob@ wood = server_CreateBlob('mat_wood', -1, pos);
			wood.server_SetQuantity(500); // so I don't have to repeat the server_CreateBlob line again
			//stone
			CBlob@ stone = server_CreateBlob('mat_stone', -1, pos);
			stone.server_SetQuantity(500);
			//gold
			CBlob@ gold = server_CreateBlob('mat_gold', -1, pos);
			gold.server_SetQuantity(100);
		}
		else if (text_in == "!woodstone") // 250 wood, 500 stone
		{
			server_CreateBlob('mat_wood', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_stone', -1, pos);
			}
		}
		else if (text_in == "!stonewood") // 500 wood, 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_wood', -1, pos);
			}
		}
		else if (text_in == "!wood") // 250 wood
		{
			server_CreateBlob('mat_wood', -1, pos);
		}
		else if (text_in == "!stones" || text_in == "!stone") // 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!gold") // 200 gold
		{
			for (int i = 0; i < 4; i++)
			{
				server_CreateBlob('mat_gold', -1, pos);
			}
		}
		// removed/commented out since this can easily be abused...
		/*else if (text_in == "!sharkpit") // spawns 5 sharks, perfect for making shark pits
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('shark', -1, pos);
			}
		}
		else if (text_in == "!bisonherd") // spawns 5 bisons
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('bison', -1, pos);
			}
		}*/
		else
		{
			string[]@ tokens = text_in.split(" ");
			for (int ii = 0; ii < tokens.length; ++ii)
			{
				print("TOKEN NUMBER " + ii + " : "+tokens[ii]+"whitespacecheck");
			}

			if (tokens.length > 1)
			{
				//(see above for crate parsing example)
				if (tokens[0] == "!crate")
				{
					string item = tokens[1];

					if (!isMod && isBlacklisted(item))
					{
						wasCommandSuccessful = false;
						errorMessage = "blob is currently blacklisted";
					}
					else
					{
						int frame = item == "catapult" ? 1 : 0;
						string description = tokens.length > 2 ? tokens[2] : item;
						server_MakeCrate(item, description, frame, -1, Vec2f(pos.x, pos.y));
					}
				}
				// eg. !team 2
				else if (tokens[0] == "!team")
				{
					// Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
					// We should consider if this should change the player team as well, or not.
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
					{
						s += " " + tokens[i];
					}
					server_MakePredefinedScroll(pos, s);
				}
				else if(tokens[0] == "!coins")
				{
					int money = parseInt(tokens[1]);
					player.server_setCoins(money);
				}
				else if(tokens[0] == "!generatemap" || tokens[0] == "!gm")
				{
					if(tokens[1].length != 0 && tokens[2].length != 0){
						CRules@ myrule = getRules();
						//the laws of reality are ours
						int width = parseInt(tokens[1]);
						int height = parseInt(tokens[2]);

						myrule.set_s32("width", width);
						myrule.set_s32("height", height);
						//we need to call the global function LoadMap engine side, less go
						if(getNet().isServer())
						{
							LoadMap("Maps/test.kaggen.cfg");
							print("i am a server");
						}
						else{
						}

						return true;
					}
					else{
						errorMessage = "Please provide valid map values\nExample: !generatemap 50 50";
					}
				}
			}
			else
			{
				string name = text_in.substr(1, text_in.size());
				if (!isMod && isBlacklisted(name))
				{
					wasCommandSuccessful = false;
					errorMessage = "blob is currently blacklisted";
				}
				else
				{
					CBlob@ newBlob = server_CreateBlob(name, team, Vec2f(0, -5) + pos); // currently any blob made will come back with a valid pointer

					if (newBlob !is null)
					{
						if (newBlob.getName() != name)  // invalid blobs will have 'broken' names
						{
							wasCommandSuccessful = false;
							errorMessage = "blob " + text_in + " not found";
						}
					}
				}
			}
		}
	}

	if (wasCommandSuccessful)
	{
		blob.set_u16("chat_last_sent", getGameTime() + chatCommandDelay);
	}
	else if(errorMessage != "") // send error message to client
	{
		CBitStream params;
		params.write_string(errorMessage);

		// List is reverse so we can read it correctly into SColor when reading
		params.write_u8(errorColor.getBlue());
		params.write_u8(errorColor.getGreen());
		params.write_u8(errorColor.getRed());
		params.write_u8(errorColor.getAlpha());

		this.SendCommand(this.getCommandID("SendChatMessage"), params, player);
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream @para)
{
	if (cmd == this.getCommandID("SendChatMessage"))
	{
		string errorMessage = para.read_string();
		SColor col = SColor(para.read_u8(), para.read_u8(), para.read_u8(), para.read_u8());
		client_AddToChat(errorMessage, col);
	}
}

bool isBlacklisted(string name)
{
	return blacklistedItems.find(name) != -1;
}