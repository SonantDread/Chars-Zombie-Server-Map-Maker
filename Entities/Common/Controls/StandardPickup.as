// Standard menu player controls
// add to blob and sprite

#include "StandardControlsCommon.as"

const u32 PICKUP_ERASE_TICKS = 80;

void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	// drop / pickup / throw
	if (this.isKeyJustPressed(key_pickup))
	{
		CBlob @carryBlob = this.getCarriedBlob();

		if (this.isAttached()) // default drop from attachment
		{
			int count = this.getAttachmentPointCount();

			for (int i = 0; i < count; i++)
			{
				AttachmentPoint @ap = this.getAttachmentPoint(i);

				if (ap.getOccupied() !is null && ap.name != "PICKUP")
				{
					CBitStream params;
					params.write_netid(ap.getOccupied().getNetworkID());
					this.SendCommand(this.getCommandID("detach"), params);
					this.set_bool("release click", false);
					break;
				}
			}
		}
		else if (carryBlob !is null)
		{
			carryBlob.server_Die();
			this.set_bool("release click", false);

		}
		else
		{
			this.set_bool("release click", true);
		}
	}
	else
	{

		if (this.isKeyJustReleased(key_pickup))
		{
			CBlob@ underblob = getMap().getBlobAtPosition(this.getAimPos());

			server_Pickup(this, this, underblob);
			//Vec2f aimpos = underblob.getPosition();
			//getMap().server_SetTile(aimpos, CMap::tile_empty);
				
		}
	}
}

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	// render item held when in inventory
	
//	if (blob.isKeyPressed(key_pickup))
//	{
//		CBlob@ underblob = getMap().getBlobAtPosition(blob.getAimPos());
//
//		if (underblob !is null)
//		{
//			underblob.RenderForHUD(RenderStyle::outline);
//		}		
//	}
}
