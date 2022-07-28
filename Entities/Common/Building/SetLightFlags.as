
void SetLigtFlag(Vec2f pos)
{
	CMap@ map = getMap();
	Vec2f tilespace = map.getTileSpacePosition(pos);
	const int offset = map.getTileOffsetFromTileSpace(tilespace);
	map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
}