// Standard menu player controls

#include "EmotesCommon.as"
#include "StandardControlsCommon.as"

int zoomLevel = 1; // we can declare a global because this script is just used by myPlayer

void onInit(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
	CBlob@[] blobs;
	this.set("pickup blobs", blobs);
	this.set_u16("hover netid", 0);
	this.set_bool("release click", false);
	this.set_bool("can button tap", true);
	this.addCommandID("pickup");
	this.addCommandID("putin");
	this.addCommandID("getout");
	this.addCommandID("detach");
	this.addCommandID("cycle");

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void server_PutIn(CBlob@ this, CBlob@ picker, CBlob@ pickBlob)
{
	CInventory@ inv = this.getInventory();
	if (pickBlob is null || picker is null || !inv.canPutItem(pickBlob))
		return;
	CBitStream params;
	params.write_netid(picker.getNetworkID());
	params.write_netid(pickBlob.getNetworkID());
	this.SendCommand(this.getCommandID("putin"), params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (!getNet().isServer())                                // server only!
	{
		return;
	}

	if (cmd == this.getCommandID("putin"))
	{
		CBlob@ owner = getBlobByNetworkID(params.read_netid());
		CBlob@ pick = getBlobByNetworkID(params.read_netid());

		if (owner !is null && pick !is null)
		{
			if (!owner.server_PutInInventory(pick))
				owner.server_Pickup(pick);
		}
	}
	else if (cmd == this.getCommandID("pickup"))
	{
		CBlob@ owner = getBlobByNetworkID(params.read_netid());
		CBlob@ pick = getBlobByNetworkID(params.read_netid());

		if (owner !is null && pick !is null)
		{
			owner.server_Pickup(pick);
		}
	}
	else if (cmd == this.getCommandID("detach"))
	{
		CBlob@ obj = getBlobByNetworkID(params.read_netid());

		if (obj !is null)
		{
			this.server_DetachFrom(obj);
		}
	}
	else if (cmd == this.getCommandID("getout"))
	{
		if (this.getInventoryBlob() !is null)
		{
			this.getInventoryBlob().server_PutOutInventory(this);
		}
	}
}

bool ClickGridMenu(CBlob@ this, int button)
{
	CGridMenu @gmenu;
	CGridButton @gbutton;
	CBlob @pickBlob = this.getCarriedBlob();

	if (this.ClickGridMenu(button, gmenu, gbutton))   // button gets pressed here - thing get picked up
	{
		if (gmenu !is null)
		{
			// if (gmenu.getName() == this.getInventory().getMenuName() && gmenu.getOwner() !is null)
			{
				if (pickBlob !is null && gbutton is null)    // carrying something, put it in
				{
					server_PutIn(this, gmenu.getOwner(), pickBlob);
				}
				else // take something
				{
					// handled by button cmd   // hardcoded still :/
				}
			}
			return true;
		}
	}

	return false;
}


void ButtonOrMenuClick(CBlob@ this, Vec2f pos, bool clear, bool doClosestClick)
{
	if (!ClickGridMenu(this, 0))
		if (!this.ClickInteractButton())
		{
			clear = false;
		}
		else if (doClosestClick)
		{
			if (this.ClickClosestInteractButton(pos, this.getRadius() * 1.0f))
			{
				this.ClearButtons();
				clear = false;
			}
		}

	if (clear)
	{
		this.ClearButtons();
		this.ClearMenus();
	}
}

void onTick(CBlob@ this)
{
	if (getCamera() is null)
	{
		return;
	}
	ManageCamera(this);

	if (this.getTickSinceCreated() <= 1) // open and close menu, make phase work straight up.
	{
		this.CreateInventoryMenu(Vec2f(0,0));
		this.ClearMenus();
	}

	// use menu

	if (this.isKeyJustPressed(key_use))
	{
		Tap(this);
		this.set_bool("can button tap", !getHUD().hasMenus());
		this.ClearMenus();
		this.ShowInteractButtons();
		this.set_bool("release click", true);
	}
	else if (this.isKeyJustReleased(key_use))
	{
		if (this.get_bool("release click"))
		{
			ButtonOrMenuClick(this, this.getPosition(), true, isTap(this) && this.get_bool("can button tap"));
		}

		this.ClearButtons();
	}

	CBlob @carryBlob = this.getCarriedBlob();

	// inventory menu

	if (this.getInventory() !is null && this.getTickSinceCreated() > 10)
	{
		if (this.isKeyJustPressed(key_inventory))
		{
			Tap(this);
			this.set_bool("release click", true);
			// this.ClearMenus();

			//  Vec2f center =  getDriver().getScreenCenterPos(); // center of screen
			Vec2f center = getControls().getMouseScreenPos();
			if (this.exists("inventory offset"))
			{
				this.CreateInventoryMenu(Vec2f(0,0));
			}
			else
			{
				this.CreateInventoryMenu(Vec2f(0,0));
			}

			//getControls().setMousePosition( center );
		}
		else if (this.isKeyJustReleased(key_inventory))
		{
			
			this.set_u32("closetime", getGameTime());

			if (this.get_bool("release click"))
			{
				ClickGridMenu(this, 0);
			}

			if (!this.hasTag("dont clear menus"))
			{
				this.ClearMenus();
			}
			else
			{
				this.Untag("dont clear menus");
			}			
		}
	}

	// bubble menu

	if (this.isKeyJustPressed(key_bubbles))
	{
		this.CreateBubbleMenu();
		Tap(this);
	}

	if (getHUD().hasButtons())
	{
		if ((this.isKeyJustPressed(key_action1) /*|| getControls().isKeyJustPressed(KEY_LBUTTON)*/) && !this.isKeyPressed(key_pickup))
		{
			ButtonOrMenuClick(this, this.getAimPos(), false, true);
			this.set_bool("release click", false);
		}
	}	
}

// show dots on chat

void onDie(CBlob@ this)
{
	set_emote(this, "");
}

// CAMERA

void ManageCamera(CBlob@ this)
{
	CCamera@ camera = getCamera();
	f32 zoom = camera.targetDistance;
	CControls@ controls = this.getControls();

	// mouse look & zoom
	if ((getGameTime() - this.get_s32("tap_time") > 5) && controls !is null)
	{
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMOUT)))
		{
			if (zoomLevel == 2)
			{
				zoomLevel = 1;
			}
			else if (zoomLevel == 1)
			{
				zoomLevel = 0;
			}
			else if (zoomLevel == 3)
			{
				zoomLevel = 0;
			}

			Tap(this);
		}
		else  if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMIN)))
		{
			if (zoomLevel == 0)
			{
				zoomLevel = 3;
			}
			else if (zoomLevel == 3)
			{
				zoomLevel = 2;
			}
			else if (zoomLevel == 1)
			{
				zoomLevel = 2;
			}

			Tap(this);
		}
	}

	f32 zoomSpeed = 0.1f;
	f32 minZoom = 0.5f; // TODO: make vars
	f32 maxZoom = 2.0f;

	if (zoomLevel == 1 && (this.wasKeyPressed(key_use) || this.wasKeyPressed(key_pickup)))
	{
		zoom = 1.0f;
	}

	switch (zoomLevel)
	{
		case 0:
			if (zoom > 0.5f)
			{
				zoom -= zoomSpeed;
			}

			break;

		case 1:
			if (zoom > 1.0f)
			{
				zoom -= zoomSpeed;
			}
			else
			{
				zoom = 1.0f;
			}

			break;

		case 2:
			if (zoom < maxZoom)
			{
				zoom += zoomSpeed;
			}

			break;

		case 3:
			if (zoom < 1.0f)
			{
				zoom += zoomSpeed;
			}
			else
			{
				zoom = 1.0f;
			}

			break;

		default:
			zoom = 1.0f;
			break;
	}

	// security check

	if (zoom < minZoom)
	{
		zoom = minZoom;
	}

	if (zoom > maxZoom)
	{
		zoom = maxZoom;
	}


	bool fixedCursor = true;
	if (zoom < 1.0f)  // zoomed out
	{
		camera.mousecamstyle = 1; // fixed
	}
	else
	{
		// gunner
		if (this.isAttachedToPoint("GUNNER"))
		{
			camera.mousecamstyle = 2;
		}
		else if (g_fixedcamera) // option
		{
			camera.mousecamstyle = 1; // fixed
		}
		else
		{
			camera.mousecamstyle = 2; // soldatstyle
		}
	}

	// camera
	camera.mouseFactor = 0.5f; // doesn't affect soldat cam
	camera.targetDistance = zoom;
}


