void onInit(CBlob@ this)
{
	this.Tag("place norotate");
	this.Tag("place ignore facing");
}

void onTick(CBlob@ this)
{	
	if(this.getShape().isStatic())	
	{
		CMap@ map = this.getMap();	
		Vec2f position = this.getPosition();

		Vec2f tilespace = map.getTileSpacePosition(position);					
		map.AddTileFlag( map.getTileOffsetFromTileSpace(tilespace), Tile::WATER_PASSES );

		map.server_setFloodWaterWorldspace(position, true);
		this.server_Die();
	}
}