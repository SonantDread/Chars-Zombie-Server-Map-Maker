void onTick(CRules@ rules){
    if(getGameTime() % 30 == 0){
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
        for (int i = 0; i < blobs.length; i++) {
            if (blobs[i].getName() == "ZombiePortal"){
                portals++;
            }
        }

        rules.SetGlobalMessage("Max Zombies: " + max_zombies + "\nMax Portal Zombies: " + max_portal_zombies + "\nMap Width: " + map.tilemapwidth + "\nMap Height: " + map.tilemapheight);
    }
}