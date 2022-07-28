const int sail_index = 0;
void onInit(CBlob@ this)
{	//block knight sword
	this.Tag("blocks sword");
	this.set_bool("has mast", true);

	const Vec2f mastOffset(2, -3);

	CSpriteLayer@ mast = this.getSprite().addSpriteLayer("mast", 48, 64);
	if (mast !is null)
	{
		Animation@ anim = mast.addAnimation("default", 0, false);
		int[] frames = {4, 5};
		anim.AddFrames(frames);
		mast.SetOffset(Vec2f(9, -6) + mastOffset);
		mast.SetRelativeZ(-10.0f);
	}

	if (this.get_bool("has mast"))		// client-side join - might be false
	{
		// add sail

		CSpriteLayer@ sail = this.getSprite().addSpriteLayer("sail " + sail_index, 32, 32);
		if (sail !is null)
		{
			Animation@ anim = sail.addAnimation("default", 3, false);
			int[] frames = {3, 7, 11};
			anim.AddFrames(frames);
			sail.SetOffset(Vec2f(1, -10) + mastOffset);
			sail.SetRelativeZ(-9.0f);

			sail.SetVisible(false);
		}
	}
	else
	{
		if (mast !is null)
		{
			mast.animation.frame = 1;
		}
	}

	// add head
	{
		CSpriteLayer@ head = this.getSprite().addSpriteLayer("head", 16, 16);
		if (head !is null)
		{
			Animation@ anim = head.addAnimation("default", 0, false);
			anim.AddFrame(5);
			head.SetOffset(Vec2f(-32, -13));
			head.SetRelativeZ(1.0f);
		}
	}

	//add minimap icon
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(16, 8));
}