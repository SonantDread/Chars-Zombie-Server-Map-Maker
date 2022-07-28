// Lantern script
#include "StandardControlsCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("place norotate");
	this.Tag("place ignore facing");
	this.addCommandID("cycled");
	AddIconToken("$cycle$", "MenuItems.png", Vec2f(32, 32), 1);
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.RemoveSpriteLayer("flaglayer");
	CSpriteLayer@ flag = this.addSpriteLayer("flaglayer", "CTF_Flag.png" , 32, 32, blob.getTeamNum(), 0);
	if (flag !is null)
	{
		Animation@ anim = flag.addAnimation("flag", 0, false);
		flag.SetFrame(3);
		flag.SetRelativeZ(-2.0f);
		flag.SetOffset(Vec2f(12.0f,-4.0f));
		flag.setRenderStyle(RenderStyle::light);
		flag.SetVisible(true);
	}

	this.RemoveSpriteLayer("halllayer");
	CSpriteLayer@ hall = this.addSpriteLayer("halllayer", "Hall.png" , 80, 48, blob.getTeamNum(), 0);
	if (flag !is null)
	{
		Animation@ anim = hall.addAnimation("hall", 0, false);
		hall.SetRelativeZ(-2.0f);
		hall.SetOffset(Vec2f(0.0f,-12.0f));
		hall.setRenderStyle(RenderStyle::light);
		hall.SetVisible(false);		
	}
}

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

int sp_cycleframe = 0;
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

			CSprite@ sprite = this.getSprite();
			CSpriteLayer@ flag = sprite.getSpriteLayer("flaglayer");
			CSpriteLayer@ hall = sprite.getSpriteLayer("halllayer");
			if (flag !is null && hall !is null)
			{	
				if (sp_cycleframe == 0)	
				{	
					this.set_s32("tap_time", getGameTime());
					flag.SetVisible(false);
					hall.SetVisible(true);
					sp_cycleframe = 1;
				}
				else if (sp_cycleframe == 1)	
				{
					this.set_s32("tap_time", getGameTime());
					hall.SetVisible(false);
					sp_cycleframe = 2;
				}
				else if (sp_cycleframe == 2)	
				{
					this.set_s32("tap_time", getGameTime());
					flag.SetVisible(true);
					sp_cycleframe = 0;
				}		
			}
		}		
	}
}