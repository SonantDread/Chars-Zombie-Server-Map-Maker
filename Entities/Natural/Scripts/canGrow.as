//common "can a plant grow at this tile" code

bool isNotTouchingOthers(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			if (blob.getName() == "seed" || blob.getName() == "tree_bushy" || blob.getName() == "tree_pine")
			{
				return false;
			}
		}
	}

	return true;
}

bool canGrowAt(CBlob@ this, Vec2f pos)
{	
	CMap@ map = this.getMap();
	return true;
}
