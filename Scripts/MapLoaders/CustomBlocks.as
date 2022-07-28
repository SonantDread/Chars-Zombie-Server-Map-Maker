#include "LoaderColors.as";
#include "LoaderUtilities.as";
namespace CMap
{
	enum CustomTiles
	{
		// fake ground tiles are placed and replaced so the back dirt can be destroyed for map making.
		tile_preground = 112,
		tile_pregold = 160,
		tile_prethickstone = 192,
		tile_prestone = 176,
		tile_prebedrock = 186,
		tile_preground_back = 128,
	};
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	
}