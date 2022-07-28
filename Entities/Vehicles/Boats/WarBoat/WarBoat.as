//#include "VehicleCommon.as"
//#include "Requirements_Tech.as";

// Boat logic

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 96, 56);
	if (front !is null)
	{
		front.addAnimation("default", 0, false);
		int[] frames = { 0, 4, 5 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(55.0f);
	}

	CSpriteLayer@ flag = sprite.addSpriteLayer("flag", sprite.getConsts().filename, 40, 56);
	if (flag !is null)
	{
		flag.addAnimation("default", 3, true);
		int[] frames = { 5, 4, 3 };
		flag.animation.AddFrames(frames);
		flag.SetRelativeZ(-5.0f);
		flag.SetOffset(Vec2f(28, -24));
	}
}