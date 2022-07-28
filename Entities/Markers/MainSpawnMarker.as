// Lantern script
//#include "StandardControlsCommon.as";

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
	this.RemoveSpriteLayer("tentlayer");
	CSpriteLayer@ tent = this.addSpriteLayer("tentlayer", "Tent.png" , 64, 64, blob.getTeamNum(), 0);
	if (tent !is null)
	{
		Animation@ anim = tent.addAnimation("tent", 0, false);
		int[] frames = {0};
		anim.AddFrames(frames);
		tent.SetRelativeZ(-2.0f);
		tent.SetOffset(Vec2f(-12,-4.0f));
		tent.setRenderStyle(RenderStyle::light);
		tent.SetVisible(true);
	}	
	this.RemoveSpriteLayer("ruinslayer");
	CSpriteLayer@ ruins = this.addSpriteLayer("ruinslayer", "TDM_Ruins.png" , 64, 64, blob.getTeamNum(), 0);
	if (tent !is null)
	{
		Animation@ anim = ruins.addAnimation("ruins", 0, false);
		int[] frames = {0};
		anim.AddFrames(frames);
		ruins.SetRelativeZ(-2.0f);
		ruins.SetOffset(Vec2f(0,-28.0f));
		ruins.setRenderStyle(RenderStyle::light);
		ruins.SetVisible(false);
	}
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


			CSprite@ sprite = this.getSprite();
			CSpriteLayer@ tent = sprite.getSpriteLayer("tentlayer");
			CSpriteLayer@ ruins = sprite.getSpriteLayer("ruinslayer");
			if (tent !is null && ruins !is null)
			{	
				if (sp_cycleframe == 0)	
				{	
					this.set_s32("tap_time", getGameTime());
					tent.SetVisible(false);
					ruins.SetVisible(true);
					sp_cycleframe = 1;
				}
				else if (sp_cycleframe == 1)	
				{
					this.set_s32("tap_time", getGameTime());
					ruins.SetVisible(false);
					sp_cycleframe = 2;
				}
				else if (sp_cycleframe == 2)	
				{
					this.set_s32("tap_time", getGameTime());
					tent.SetVisible(true);
					sp_cycleframe = 0;
				}		
			}
		}		
	}
}