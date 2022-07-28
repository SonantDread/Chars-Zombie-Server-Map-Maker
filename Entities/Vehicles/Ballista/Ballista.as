
void onInit(CBlob@ this)
{	// init arm sprites
	CSprite@ sprite = this.getSprite();
	
	sprite.SetZ(-25.0f);
	CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 40, 40);
	if (front !is null)
	{
		front.addAnimation("default", 0, false);
		int[] frames = { 0, 1, 2 };
		front.animation.AddFrames(frames);
		front.SetRelativeZ(0.8f);
	}

	CSpriteLayer@ flag = sprite.addSpriteLayer("flag layer", sprite.getConsts().filename, 32, 32);
	if (flag !is null)
	{
		flag.addAnimation("default", 3, true);
		int[] frames = { 15, 14, 13 };
		flag.animation.AddFrames(frames);
		flag.SetRelativeZ(-0.8f);
		flag.SetOffset(Vec2f(20.0f, -2.0f));
	}
}