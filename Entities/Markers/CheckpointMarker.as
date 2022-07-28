// Lantern script
//#include "StandardControlsCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("place norotate");
	this.Tag("place ignore facing");
	this.addCommandID("cycled");
	AddIconToken("$cycle$", "MenuItems.png", Vec2f(32, 32), 1);
	AddIconToken("$arrow$", "GUI/InteractionIcons.png", Vec2f(32, 32), 19, 2);
}

int sp_cycleframe = 0;

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.getDistanceTo(caller) > 300.0f ) return;
		
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CButton@ button = caller.CreateGenericButton(
		"$cycle$",              // icon token
		Vec2f_zero,                             // button offset
		this,                                   // button attachment
		this.getCommandID("cycled"),             // command id
		"Cycle Frame",                          // description
		params);                                // cbitstream

		button.radius = 16.0f;
		button.enableRadius = 24.0f;
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("cycled"))
	{
		if (getGameTime() - this.get_s32("tap_time") < 10) return;
		if(getNet().isServer())
		{
			u16 id;
			if(!params.saferead_u16(id)) return;

			CBlob@ caller = getBlobByNetworkID(id);
			if(caller is null) return;
	
			if (sp_cycleframe == 0)	
			{	
				this.set_s32("tap_time", getGameTime());
				sp_cycleframe = 1;
			}
			else if (sp_cycleframe == 1)	
			{
				this.set_s32("tap_time", getGameTime());
				sp_cycleframe = 0;
			}	
		}		
	}
}

void onRender(CSprite@ this)
{
	if (sp_cycleframe == 0 && !this.getBlob().isAttached())
	{
		Vec2f pos = this.getBlob().getPosition();
		Vec2f pos2d = getDriver().getScreenPosFromWorldPos(pos);
		pos2d.x -= 40.0f;
		pos2d.y -= 48.0f + 16.0f * Maths::Sin(getGameTime() / 4.5f);
		//GUI::DrawIconByName("$DEFEND_THIS$",  pos2d);
		GUI::DrawIconDirect("GUI/InteractionIcons.png", pos2d, Vec2f(92, 124), Vec2f(32, 32), 1, 2, SColor(100, 255, 255, 255));
	}
}