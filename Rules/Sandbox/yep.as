void onTick(CRules@ rules){
    if(getGameTime() % 10*30 == 0){
        CMap@ map = getMap();
        s32 max_zombies = (map.tilemapwidth + map.tilemapheight) / 5; //base the amount of zombies on the map
        max_zombies = Maths::Floor(max_zombies);

        if(max_zombies > 125)
        {
            max_zombies = 125;  //hard capped here
        }

        s32 max_portal_zombies = Maths::Ceil(max_zombies*0.25f);
        max_zombies = Maths::Floor(max_zombies*0.75f);

        CBlob@[] blobs;
        int portals = 0;
		if (getBlobsByName("ZombiePortal", @blobs)){
			for (int i = 0; i < blobs.length; i++) {
				portals++;
			}
		}

        int gold = 0;
        int stone = 0;
        int thickstone = 0;

        for(int y = 0; y < getMap().tilemapheight; ++y){
            for(int x = 0; x < getMap().tilemapwidth; ++x){
                Vec2f pos = Vec2f(x,y)*8.0f;
                if(getMap().getTile(pos).type == 80 || getMap().getTile(pos).type == 81 || getMap().getTile(pos).type == 82 || getMap().getTile(pos).type == 83 || getMap().getTile(pos).type == 84 || getMap().getTile(pos).type == 85 || getMap().getTile(pos).type == 90 || getMap().getTile(pos).type == 91 || getMap().getTile(pos).type == 92 || getMap().getTile(pos).type == 93 || getMap().getTile(pos).type == 94){
                    gold++;
                }
                else if(getMap().getTile(pos).type == 96 || getMap().getTile(pos).type == 97 || getMap().getTile(pos).type == 100 || getMap().getTile(pos).type == 101 || getMap().getTile(pos).type == 102 || getMap().getTile(pos).type == 103 || getMap().getTile(pos).type == 104){
                    stone++;
                }
                else if(getMap().getTile(pos).type == 208 || getMap().getTile(pos).type == 209 || getMap().getTile(pos).type == 214 || getMap().getTile(pos).type == 215 || getMap().getTile(pos).type == 216 || getMap().getTile(pos).type == 217 || getMap().getTile(pos).type == 218){
                    thickstone++;
                }
            }
        }

        rules.SetGlobalMessage("Max Zombies: " + max_zombies + "\nMax Portal Zombies: " + max_portal_zombies + "\nMap Width: " + map.tilemapwidth + "\nMap Height: " + map.tilemapheight + "\nZombie Portals: " + portals + "\nMap Resources: \n-Gold Ore: " + gold + "\n-Stone Ore: " +stone + "\n-Thickstone Ore: " + thickstone);
    }
}