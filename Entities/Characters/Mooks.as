void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;

	CSprite@ sprite = this.getSprite(); 
	int frame = sprite.getFrameIndex();
	if(this.getName() == "aiarcher" && frame != 1)
	{
		sprite.SetFrameIndex(1);
	}
	if(this.getName() == "ainecromancer" && frame != 2)
	{
		sprite.SetFrameIndex(2);
	}	
}

void onTick(CBlob@ this)
{
	if(this.getName() == "ainecromancer" && this.getTeamNum() != 3)
	{
		this.server_setTeamNum(3);
	}

	else if (this.getName() == "aiarcher" || this.getName() == "aiknight")
	{
		this.server_setTeamNum(1);
	}
}