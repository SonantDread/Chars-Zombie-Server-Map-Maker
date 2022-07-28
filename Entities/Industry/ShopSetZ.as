void onInit(CBlob@ this)
{
	this.Tag("place norotate");
	this.Tag("place ignore facing");
	this.getSprite().SetZ(-10);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(!isStatic) return;
	this.getSprite().SetZ(-10);
}