//#include "VehicleCommon.as"

// Boat logic

void onInit(CBlob@ this)
{

	CSpriteLayer@ front = this.getSprite().addSpriteLayer("front layer", this.getSprite().getConsts().filename, 96, 56);
	if (front !is null)
	{
		front.addAnimation("default", 0, false);
		int[] frames = { 0, 4, 5 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(55.0f);
	}
}