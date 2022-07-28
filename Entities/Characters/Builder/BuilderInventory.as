// Builder logic

#include "BuilderCommon.as";
#include "PlacementCommon.as";
#include "Help.as";
#include "CommonBuilderBlocks.as";
#include "BasePNGLoader.as";
#include "SetLightFlags.as";
#include "HistoryBlocks.as";

namespace Builder
{
	enum Cmd
	{
		nil = 0,
		TOOL_CLEAR = 31,
		PAGE_SELECT = 32,
		REPLACE_SELECT = 42,
		BRUSH_SELECT = 46,		
		BRUSH_SIZE_SELECT = 49,
		COLOUR_SELECT = 52,
		PHASE_ON = 60,
		GRID_ON = 62,
		SYMMETRY_ON = 64,
		LIGHTS_SELECT = 65,

		make_block = 70,
		make_reserved = 99
	};

	enum Page
	{
		PAGE_ZERO = 0,
		PAGE_ONE,
		PAGE_TWO,
		PAGE_THREE,
		PAGE_FOUR,
		PAGE_FIVE,
		PAGE_SIX,
		PAGE_SEVEN,
		PAGE_COUNT
	};

	enum Replace
	{
		EMPTY = 0,
		SOLID,
		EMPTY_AND_SOLID,
		REPLACE_COUNT
	};

	enum Brush
	{
		CIRCLE = 0,
		SQUARE,
		BRUSH_COUNT
	};

	enum Size
	{
		LESS = 0,
		SIZE,
		MORE,
		BRUSH_SIZE_COUNT
	};

	enum Colour
	{
		NONE = 0,
		BLUE,
		RED,
		GREEN,
		PURPLE,
		ORANGE,
		AQUA,
		TEAL,
		COLOUR_COUNT

	};

	enum Phase
	{
		PHASEON = 0,
		PHASEOFF,
		PHASE_COUNT
	};

	enum Grid
	{
		GRIDOFF = 0,
		GRIDON,
		GRID_COUNT
	};

	enum Lighting
	{
		LIGHTSOFF = 0,
		LIGHTSON,
		LIGHTS_COUNT
	};
}

const string[] PAGE_NAME =
{
	"Basic",
	"Items",
	"Industry",
	"Vehicles",
	"Natural",
	"Components",
	"Gamemode",
	"ZFB"
};

const string[] REPLACE_NAME =
{
	"Replace Non-Solid",
	"Replace Solid",
	"Replace All"
};

const string[] BRUSH_NAME =
{
	"Round Brush",
	"Box Brush"
};

const string[] BRUSH_SIZE_NAME =
{
	"Less",
	"Size",
	"More"
};

const string[] COLOUR_NAME =
{
	"None",
	"Blue",
	"Red",
	"Green",
	"Purple",
	"Orange",
	"Aqua",
	"Teal"
};

const string[] PHASE_NAME =
{
	"Turn Collisions Off",
	"Turn Collisions On"
};

const string[] GRID_NAME =
{
	"Turn Grid Off",
	"Turn Grid On"
};

const string[] LIGHTS_NAME =
{
	"Lights Off",
	"Lights On"
};

const u8 GRID_SIZE = 0;
const u8 GRID_PADDING = 12;

const Vec2f MENU_SIZE(6, 12);
const Vec2f REPLACE_MENU_SIZE(3, 1);
const Vec2f BRUSH_MENU_SIZE(3, 1);
const Vec2f BRUSH_SIZE_MENU_SIZE(3, 1);
const Vec2f COLOUR_MENU_SIZE(4, 2);
const Vec2f PHASE_MENU_SIZE(2, 1);
const Vec2f GRID_MENU_SIZE(2, 1);
const Vec2f LIGHTS_MENU_SIZE(2, 1);

const u32 SHOW_NO_BUILD_TIME = 90;

void onInit(CInventory@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob is null) return;

	if(!blob.exists(blocks_property))
	{
		BuildBlock[][] blocks;
		addCommonBuilderBlocks(blocks);
		blob.set(blocks_property, blocks);
	}

	if(!blob.exists(inventory_offset))
	{
		blob.set_Vec2f(inventory_offset, Vec2f(0, 0));
	}

	for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
	{
		AddIconToken("$"+PAGE_NAME[i]+"$", "BuilderPageIcons.png", Vec2f(48, 24), i);
	}
	for(u8 i = 0; i < Builder::REPLACE_COUNT; i++)
	{
		AddIconToken("$"+REPLACE_NAME[i]+"$", "MakerPlacementMenu.png", Vec2f(16, 16), i+3);
	}
	for(u8 i = 0; i < Builder::BRUSH_COUNT; i++)
	{
		AddIconToken("$"+BRUSH_NAME[i]+"$", "MakerPlacementMenu.png", Vec2f(16, 16), i+22);
	}
	for(u8 i = 0; i < Builder::BRUSH_SIZE_COUNT; i++)
	{
		AddIconToken("$"+BRUSH_SIZE_NAME[i]+"$", "MakerPlacementMenu.png", Vec2f(16, 16), i+11);
	}	
	for(u8 i = 0; i < Builder::COLOUR_COUNT; i++)
	{
		AddIconToken("$"+COLOUR_NAME[i]+"$", "LargeTeamPalette.png", Vec2f(8, 8), i); // do draw rect instead
	}	
	for(u8 i = 0; i < Builder::PHASE_COUNT; i++)
	{
		AddIconToken("$"+PHASE_NAME[i]+"$", "MakerPlacementMenu.png", Vec2f(16, 16), i+6);
	}	
	for(u8 i = 0; i < Builder::GRID_COUNT; i++)
	{
		AddIconToken("$"+GRID_NAME[i]+"$", "MakerPlacementMenu.png", Vec2f(16, 16), i+14);
	}	
	for(u8 i = 0; i < Builder::LIGHTS_COUNT; i++)
	{
		AddIconToken("$"+LIGHTS_NAME[i]+"$", "MakerPlacementMenu.png", Vec2f(16, 16), i+48);
	}

	AddIconToken("Symmetry", "MakerPlacementMenu.png", Vec2f(16, 16), 30);

	blob.set_Vec2f("backpack position", Vec2f_zero);

	blob.set_u8("build page", 0);
	blob.set_u8("replace type", 2);
	blob.set_u8("brush type", 0);	// starts on square // cache this stuff at some stage.
	blob.set_u8("brush arrow", 0);	
	blob.set_u8("colour selected", 1);
	blob.set_u8("phase selected", 0);
	blob.set_u8("grid selected", 0);
	getRules().set_u8("light selected", 0);

	blob.set_u8("buildblob", 255);
	blob.set_TileType("buildtile", 0);

	blob.set_u32("cant build time", 0);
	blob.set_u32("show build time", 0);

	this.getCurrentScript().removeIfTag = "dead";
}

void MakeBlocksMenu(CInventory@ this, const Vec2f &in INVENTORY_CE)
{
	CBlob@ blob = this.getBlob();
	if(blob is null) return;

	BuildBlock[][]@ blocks;
	blob.get(blocks_property, @blocks);
	if(blocks is null) return;

	const Vec2f MENU_CE = Vec2f(10, MENU_SIZE.y + getScreenHeight());	

	CGridMenu@ menu = CreateGridMenu(MENU_CE, blob, MENU_SIZE, "Build");
	if(menu !is null)
	{
		menu.deleteAfterClick = false;

		const u8 PAGE = blob.get_u8("last build page");

		for(u8 i = 0; i < blocks[PAGE].length; i++)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if(b is null) continue;

			CGridButton@ button = menu.AddButton(b.icon, "\n" + b.description, Builder::make_block + i);
			if(button is null) continue;

			button.selectOneOnClick = true;

			CBitStream missing;
			if(hasRequirements(this, b.reqs, missing))
			{
				button.hoverText = b.description;
			}
			//else
			//{
			///	button.hoverText = b.description + "\n" + getButtonRequirementsText(missing, true);
			//	button.SetEnabled(false);
			//}			
		}

		const Vec2f REPLACE_MENU_CE = Vec2f(520, REPLACE_MENU_SIZE.y + getScreenHeight());

		CGridMenu@ replacemenu = CreateGridMenu(REPLACE_MENU_CE, blob, REPLACE_MENU_SIZE, "Placement Method");
		if(replacemenu !is null)
		{
			replacemenu.deleteAfterClick = false;				
			const u8 SELECTED = blob.get_u8("replace type");

			CBitStream params;
			params.write_u16(blob.getNetworkID());

			for(u8 i = 0; i < Builder::REPLACE_COUNT; i++)
			{
				CGridButton@ replacebutton = replacemenu.AddButton("$"+REPLACE_NAME[i]+"$", REPLACE_NAME[i], Builder::REPLACE_SELECT + i, Vec2f(1, 1), params);
				if(replacebutton is null) continue;

				replacebutton.selectOneOnClick = true;

				if(i == SELECTED)
				{
					replacebutton.SetSelected(1);
				}
			}
		}

		const Vec2f COLOUR_MENU_CE = Vec2f(720, COLOUR_MENU_SIZE.y + getScreenHeight());

		CGridMenu@ colourmenu = CreateGridMenu(COLOUR_MENU_CE, blob, COLOUR_MENU_SIZE, "Team Colour");
		if(colourmenu !is null)
		{
			colourmenu.deleteAfterClick = false;				
			const u8 COLOUR_SELECTED = blob.get_u8("colour selected");
			CBitStream params;
			params.write_u16(blob.getNetworkID());

			for(u8 i = 0; i < Builder::COLOUR_COUNT; i++)
			{
				CGridButton@ colourbutton = colourmenu.AddButton("$"+COLOUR_NAME[i]+"$", COLOUR_NAME[i], Builder::COLOUR_SELECT + i, Vec2f(1, 1), params);
				if(colourbutton is null) continue;

				colourbutton.selectOneOnClick = true;

				if(i == COLOUR_SELECTED)
				{
					colourbutton.SetSelected(1);
					blob.server_setTeamNum(i-1);
				}
			}
		}

		const Vec2f BRUSH_MENU_CE = Vec2f(370, BRUSH_MENU_SIZE.y + getScreenHeight());

		CGridMenu@ brushmenu = CreateGridMenu(BRUSH_MENU_CE, blob, BRUSH_MENU_SIZE, "Brush Type");
		if(brushmenu !is null)
		{
			brushmenu.deleteAfterClick = false;				
			const u8 BRUSH_TYPE = blob.get_u8("brush type");
			CBitStream params;
			params.write_u16(blob.getNetworkID());

			for(u8 i = 0; i < Builder::BRUSH_COUNT; i++)
			{
				CGridButton@ brushbutton = brushmenu.AddButton("$"+BRUSH_NAME[i]+"$", BRUSH_NAME[i], Builder::BRUSH_SELECT + i, Vec2f(1, 1), params);
				if(brushbutton is null) continue;

				brushbutton.selectOneOnClick = true;

				if(i == BRUSH_TYPE)
				{
					brushbutton.SetSelected(1);
				}
			}
		}
		if (blob.get_u8("brush type") == 0)
		{
			const Vec2f BRUSH_SIZE_MENU_CE = Vec2f(370, BRUSH_SIZE_MENU_SIZE.y + getScreenHeight()-136.0f);

			CGridMenu@ brushsizemenu = CreateGridMenu(BRUSH_SIZE_MENU_CE, blob, BRUSH_SIZE_MENU_SIZE, "Brush Size");
			if(brushsizemenu !is null)
			{
				brushsizemenu.deleteAfterClick = false;				
				const u8 BRUSH_SIZE_TYPE = blob.get_u8("brush arrow");				

				//GUI::DrawText( "bs"+blob.get_u8("brushsize"), Vec2f(boxpos.x - 50, boxpos.y - 15.0f), Vec2f(boxpos.x + 50, boxpos.y + 15.0f), color_black, false, false, true );

				CBitStream params;
				params.write_u16(blob.getNetworkID());

				for(u8 i = 0; i < Builder::BRUSH_SIZE_COUNT; i++)
				{
					string icon;
					AddIconToken("circletoken", "MakerPlacementMenu.png", Vec2f(16, 16), 32+blob.get_u8("brushsize"));
					icon = "circletoken";

					CGridButton@ brushsizebutton = brushsizemenu.AddButton((i == 1)?icon:"$"+BRUSH_SIZE_NAME[i]+"$", BRUSH_SIZE_NAME[i], Builder::BRUSH_SIZE_SELECT + i, Vec2f(1, 1), params);
					if(brushsizebutton is null) continue;

					brushsizebutton.selectOneOnClick = false;

					if(i == BRUSH_SIZE_TYPE)
					{
						brushsizebutton.SetSelected(1);
					}
				}
			}
		}

		const Vec2f PHASEBUTTON_CE = Vec2f(350, 0);

		CGridMenu@ phasemenu = CreateGridMenu(PHASEBUTTON_CE, blob, PHASE_MENU_SIZE, "Phase");
		if(phasemenu !is null)
		{
			phasemenu.deleteAfterClick = true;
			const u8 PHASE_SELECTED = blob.get_u8("phase selected");
			CBitStream params;
			params.write_u16(blob.getNetworkID());	

			for(u8 i = 0; i < Builder::PHASE_COUNT; i++)
			{
				CGridButton@ phasebutton = phasemenu.AddButton("$"+PHASE_NAME[i]+"$", PHASE_NAME[i], Builder::PHASE_ON + i, Vec2f(1, 1), params);
				if(phasebutton is null) continue;

				phasebutton.selectOneOnClick = true;

				if(i == PHASE_SELECTED)
				{
					phasebutton.SetSelected(1);
				}

				if (PHASE_SELECTED == 0)
				{
					blob.set_bool("phaseon", true);
				}
				else if (PHASE_SELECTED == 1)
				{
					blob.set_bool("phaseon", false);
				}	
			}		
		}

		const Vec2f GRIDMENU_CE = Vec2f(460, 0);

		CGridMenu@ gridmenu = CreateGridMenu(GRIDMENU_CE, blob, GRID_MENU_SIZE, "Grid");
		if(gridmenu !is null)
		{
			gridmenu.deleteAfterClick = true;
			const u8 GRID_SELECTED = blob.get_u8("grid selected");
			CBitStream params;
			params.write_u16(blob.getNetworkID());	

			for(u8 i = 0; i < Builder::GRID_COUNT; i++)
			{
				CGridButton@ gridbutton = gridmenu.AddButton("$"+GRID_NAME[i]+"$", GRID_NAME[i], Builder::GRID_ON + i, Vec2f(1, 1), params);
				if(gridbutton is null) continue;

				gridbutton.selectOneOnClick = true;

				if(i == GRID_SELECTED)
				{
					gridbutton.SetSelected(1);
				}

				if (GRID_SELECTED == 0)
				{
					blob.set_bool("gridon", false);
				}
				else if (GRID_SELECTED == 1)
				{
					blob.set_bool("gridon", true);
				}	
			}		
		}

		const Vec2f INDEX_POS = Vec2f(menu.getLowerRightPosition().x + GRID_PADDING + GRID_SIZE+48, menu.getUpperLeftPosition().y + GRID_SIZE +48 * Builder::PAGE_COUNT / 2);

		CGridMenu@ index = CreateGridMenu(INDEX_POS, blob, Vec2f(2, Builder::PAGE_COUNT), "Type");
		if(index !is null)
		{
			index.deleteAfterClick = false;

			CBitStream params;
			params.write_u16(blob.getNetworkID());

			for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
			{
				CGridButton@ button = index.AddButton("$"+PAGE_NAME[i]+"$", PAGE_NAME[i], Builder::PAGE_SELECT + i, Vec2f(2, 1), params);
				if(button is null) continue;

				button.selectOneOnClick = true;

				if(i == PAGE)
				{
					button.SetSelected(1);
				}
			}
		}

		CGridMenu@ symmenu = CreateGridMenu(Vec2f( getScreenWidth()-32.0f, 24.0f), blob, Vec2f(1, 1), "Sym");
		if(symmenu !is null)
		{
			symmenu.deleteAfterClick = true;

			CBitStream params;
			params.write_u16(blob.getNetworkID());

			CGridButton@ symbutton = symmenu.AddButton("Symmetry", "On/Off", 64, Vec2f(1, 1), params);
			
			symbutton.selectOneOnClick = true;

			if (blob.get_bool("symmetry selected"))
			{
				symbutton.SetSelected(1);
			}
			else if (!blob.get_bool("symmetry selected"))
			{
				symbutton.SetSelected(0);
			}				
		}

		CGridMenu@ lightsmenu = CreateGridMenu(Vec2f( getScreenWidth()-112.0f, 0), blob, Vec2f(2, 1), "Lighting");
		if(lightsmenu !is null)
		{
			lightsmenu.deleteAfterClick = true;
			const u8 LIGHT_SELECTED = getRules().get_u8("light selected");

			CBitStream params;
			params.write_u16(blob.getNetworkID());

			for(u8 i = 0; i < Builder::LIGHTS_COUNT; i++)
			{
				CGridButton@ lightsbutton = lightsmenu.AddButton("$"+LIGHTS_NAME[i]+"$", LIGHTS_NAME[i], Builder::LIGHTS_SELECT + i, Vec2f(1, 1), params);
				if(lightsbutton is null) continue;
				lightsbutton.selectOneOnClick = true;

				if(i == LIGHT_SELECTED)
				{
					lightsbutton.SetSelected(1);
				}				
			}				
		}

/*
		const Vec2f STATISTICSMENU_CE = Vec2f(getScreenWidth(), 0);

		CGridMenu@ statisticsmenu = CreateGridMenu(STATISTICSMENU_CE, blob, Vec2f(3,5), "Statistics");
		if(statisticsmenu !is null)
		{
			statisticsmenu.deleteAfterClick = false;	
			
		}
*/
	}
}

void onCreateInventoryMenu(CInventory@ this, CBlob@ forBlob, CGridMenu@ menu)
{
	CBlob@ blob = this.getBlob();
	if(blob is null) return;

	const Vec2f INVENTORY_CE = menu.getUpperLeftPosition();
	blob.set_Vec2f("backpack position", Vec2f( 0, 0));

	blob.ClearGridMenusExceptInventory();

	MakeBlocksMenu(this, Vec2f( 0, getScreenHeight()));
}

void onCommand(CInventory@ this, u8 cmd, CBitStream@ params)
{
	string dbg = "BuilderInventory.as: Unknown command ";

	CBlob@ blob = this.getBlob();
	if(blob is null) return;

	if(cmd >= Builder::make_block && cmd < Builder::make_reserved)
	{
		const bool isServer = getNet().isServer();

		BuildBlock[][]@ blocks;
		if(!blob.get(blocks_property, @blocks)) return;

		uint i = cmd - Builder::make_block;

		const u8 PAGE = blob.get_u8("last build page");
		if(blocks !is null && i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ block = @blocks[PAGE][i];

			if(!canBuild(blob, @blocks[PAGE], i)) return;

			// put carried in inventory thing first
			if(isServer)
			{
				CBlob@ carryBlob = blob.getCarriedBlob();
				if(carryBlob !is null)
				{
					// check if this isn't what we wanted to create
					if(carryBlob.getName() == block.name)
					{
						return;
					}

					if(carryBlob.hasTag("temp blob"))
					{
						carryBlob.Untag("temp blob");
						carryBlob.server_Die();
					}
					else
					{
						// try put into inventory whatever was in hands
						// creates infinite mats duplicating if used on build block, not great :/
						if(!block.buildOnGround && !blob.server_PutInInventory(carryBlob))
						{
							carryBlob.server_DetachFromAll();
							carryBlob.server_Die();
						}
					}
				}
			}

			if(block.tile == 0)
			{
				server_BuildBlob(blob, @blocks[PAGE], i);
			}
			else
			{
				blob.set_TileType("buildtile", block.tile);
			}

			//if(blob.isMyPlayer())
			//{
				//SetHelp(blob, "help self action", "builder", "$Build$Build/Place  $LMB$", "", 3);
			//}
		}
	}
	else if(cmd >= Builder::PAGE_SELECT && cmd < Builder::PAGE_SELECT + Builder::PAGE_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;

		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		//target.ClearGridMenus();
		ClearCarriedBlock(target);
		target.set_u8("build page", cmd - Builder::PAGE_SELECT);
		target.set_u8("last build page", cmd - Builder::PAGE_SELECT);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}
	}

	else if(cmd >= Builder::BRUSH_SELECT && cmd < Builder::BRUSH_SELECT + Builder::BRUSH_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;
		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		//target.ClearGridMenus();
		//ClearCarriedBlock(target);
		target.set_u8("brush type", cmd - Builder::BRUSH_SELECT);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}

	}

	else if(cmd >= Builder::BRUSH_SIZE_SELECT && cmd < Builder::BRUSH_SIZE_SELECT + Builder::BRUSH_SIZE_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;
		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		//target.ClearGridMenus();
		target.set_u8("brush arrow", cmd - Builder::BRUSH_SIZE_SELECT);		
		u8 bs = target.get_u8("brushsize");

		if(cmd == 49 && bs > 1)
			bs--;
			target.set_u8("brushsize", bs);

		if(cmd == 51 && bs < 14)
			bs++;
			target.set_u8("brushsize", bs);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}

	}

	else if(cmd >= Builder::REPLACE_SELECT && cmd < Builder::REPLACE_SELECT + Builder::REPLACE_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;

		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		//target.ClearGridMenus();
		target.set_u8("replace type", cmd - Builder::REPLACE_SELECT);
		//ClearCarriedBlock(target);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}
	}

	else if(cmd >= Builder::COLOUR_SELECT && cmd < Builder::COLOUR_SELECT + Builder::COLOUR_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;

		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		//target.ClearGridMenus();
		target.set_u8("colour selected", cmd - Builder::COLOUR_SELECT);
		//ClearCarriedBlock(target);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}
	}
	else if(cmd >= Builder::PHASE_ON && cmd < Builder::PHASE_ON + Builder::PHASE_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;
		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		target.set_u8("phase selected", cmd - Builder::PHASE_ON);
		//target.ClearGridMenus();
		//ClearCarriedBlock(target);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}
	}
	else if(cmd >= Builder::GRID_ON && cmd < Builder::GRID_ON + Builder::GRID_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;
		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		target.set_u8("grid selected", cmd - Builder::GRID_ON);
		//target.ClearGridMenus();
		//ClearCarriedBlock(target);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}
	}
	else if(cmd >= 64 && cmd < 65)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;
		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;

		if(!target.get_bool("symmetry selected"))
		{target.set_bool("symmetry selected", true);}

		else
		{target.set_bool("symmetry selected", false);}
		//target.ClearGridMenus();
		//ClearCarriedBlock(target);

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}
	}
	else if(cmd >= Builder::LIGHTS_SELECT && cmd < Builder::LIGHTS_SELECT + Builder::LIGHTS_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;
		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		getRules().set_u8("light selected", cmd - Builder::LIGHTS_SELECT);
		//target.ClearGridMenus();
		//ClearCarriedBlock(target);
		if(cmd == 65 && getRules().get_u8("light selected") == 0)
		{
			LightSwitch(false);
		}
		else if(cmd == 66 && getRules().get_u8("light selected") == 1)
		{
			LightSwitch(true);
		}

		if(target is getLocalPlayerBlob())
		{
			target.CreateInventoryMenu(Vec2f(0,0));
		}
	}
}

void LightSwitch(bool on)
{
	CMap@ map = getMap();

	for (uint x = 0; x < map.tilemapwidth; x++)
	{
		for (uint y = 0; y < map.tilemapheight; y++)
		{
			Vec2f position = Vec2f(x*8,y*8);
			Vec2f tilespace = map.getTileSpacePosition(position);
			const int offset = map.getTileOffsetFromTileSpace(tilespace);
			Tile tile = map.getTile(position);
			u8 type = tile.type;

			if ( map.isTileSolid(tile) || map.isTileGroundBack(type) || map.isTileBackgroundNonEmpty(tile) && !map.isTileGrass(type))
			{
				if (on)
				{			
					map.AddTileFlag( offset, Tile::LIGHT_SOURCE );
				}
				else
				{
					map.RemoveTileFlag( offset, Tile::LIGHT_SOURCE );
				}
			}
		}
	}
}

void DrawGrid(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CMap@ map = blob.getMap();
	const f32 step = map.tilesize;
	f32 height = map.tilemapheight;
	f32 width = map.tilemapwidth;
	
	for (uint i = 0; i < map.tilemapwidth; i++)//vertical
  	{
		GUI::DrawLine(Vec2f(i*step,0), Vec2f(i*step,height*step), SColor(255,0,0,60));
	}	
	for (uint i = 0; i < map.tilemapheight; i++)//horizontal
  	{
		GUI::DrawLine(Vec2f(0,i*step), Vec2f(width*step,i*step), SColor(255,0,0,60));
	}
}

void DrawStats(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CMap@ map = blob.getMap();
	const f32 step = map.tilesize;
	f32 height = map.tilemapheight;
	f32 width = map.tilemapwidth;
	GUI::SetFont("menu");
	GUI::DrawText("Map Width = "+width, Vec2f(getScreenWidth()-256, 128), color_white);
	GUI::DrawText("Map Height = "+height, Vec2f(getScreenWidth()-256, 148), color_white);
	GUI::DrawText("Total Space = "+(width*height)/8, Vec2f(getScreenWidth()-256, 172), color_white);

	CBlob@[] allblobs;
	getBlobs(@allblobs);
	GUI::DrawText("Total Blobs = "+allblobs.length, Vec2f(getScreenWidth()-256, 196), color_white);
/*
	u32 solids = 0;
	for (int x_step = 0; x_step < width/8; ++x_step)
	{
		for (int y_step = 0; y_step < height/8; ++y_step)
		{
			Vec2f off(x_step*8, y_step*8);	
			if(map.isTileSolid(off) && getGameTime() % 6 == 0)
			{	
				blob.set_f32("solidcount", solids++);			
			}
		}
	}
	GUI::DrawText("Total Tiles = "+blob.get_f32("solidcount"), Vec2f(getScreenWidth()-256, 212), color_white);*/
	
}

void onRender(CSprite@ this)
{
	CMap@ map = getMap();

	CBlob@ blob = this.getBlob();
	CBlob@ localBlob = getLocalPlayerBlob();
	if(localBlob is blob)
	{
		if (blob.get_bool("gridon"))
		{
			DrawGrid(this);
		}
			//DrawStats(this);
		// no build zone show
		const bool onground = blob.isOnGround();
		const u32 time = blob.get_u32( "cant build time" );
		if(time + SHOW_NO_BUILD_TIME > getGameTime())
		{
			Vec2f space = blob.get_Vec2f( "building space" );
			Vec2f offsetPos = getBuildingOffsetPos(blob, map, space);

			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;
			Vec2f aligned = getDriver().getScreenPosFromWorldPos( offsetPos );

			for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
			{
				for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
				{
					Vec2f temp = ( Vec2f( step_x + 0.5, step_y + 0.5 ) * map.tilesize );
					Vec2f v = offsetPos + temp;
					Vec2f pos = aligned + (temp - Vec2f(0.5f,0.5f)* map.tilesize) * 2 * zoom;
					if (!onground || map.getSectorAtPosition(v , "no build") !is null || map.isTileSolid(v) || blobBlockingBuilding(map, v))
					{
						// draw red
						GUI::DrawIcon( "CrateSlots.png", 5, Vec2f(8,8), pos, zoom );
					}
					else
					{
						// draw white
						GUI::DrawIcon( "CrateSlots.png", 9, Vec2f(8,8), pos, zoom );
					}
				}
			}
		}

		// show cant build
		if (blob.isKeyPressed(key_action1) || blob.get_u32("show build time") + 15 > getGameTime())
		{
			if (blob.isKeyPressed(key_action1))
			{
				blob.set_u32( "show build time", getGameTime());
			}

			BlockCursor @bc;
			blob.get("blockCursor", @bc);
			if (bc !is null)
			{
				if (bc.blockActive || bc.blobActive)
				{
					Vec2f pos = blob.getPosition();
					Vec2f myPos =  blob.getScreenPos() + Vec2f(0.0f,(pos.y > blob.getAimPos().y) ? -blob.getRadius() : blob.getRadius());
					Vec2f aimPos2D = getDriver().getScreenPosFromWorldPos( blob.getAimPos() );

					if (!bc.hasReqs)
					{
						const string missingText = getButtonRequirementsText( bc.missing, true );
						Vec2f boxpos( myPos.x, myPos.y - 120.0f );
						GUI::DrawText( "Requires\n" + missingText, Vec2f(boxpos.x - 50, boxpos.y - 15.0f), Vec2f(boxpos.x + 50, boxpos.y + 15.0f), color_black, false, false, true );
					}
					else if (bc.cursorClose)
					{
						if (bc.rayBlocked)
						{
							Vec2f blockedPos2D = getDriver().getScreenPosFromWorldPos(bc.rayBlockedPos);
							//GUI::DrawArrow2D( aimPos2D, blockedPos2D, SColor(0xffdd2212) );
						}

						if (!bc.buildableAtPos && !bc.sameTileOnBack)
						{
							CMap@ map = getMap();
							Vec2f middle = blob.getAimPos() + Vec2f(map.tilesize*0.5f, map.tilesize*0.5f);
							CMap::Sector@ sector = map.getSectorAtPosition( middle, "no build");
							if (sector !is null)
							{
								GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(sector.upperleft), getDriver().getScreenPosFromWorldPos(sector.lowerright), SColor(0x65ed1202) );
							}
							else
							{
								CBlob@[] blobsInRadius;
								if (map.getBlobsInRadius( middle, map.tilesize, @blobsInRadius )) 
								{
									for (uint i = 0; i < blobsInRadius.length; i++)
									{
										CBlob @b = blobsInRadius[i];
										if (!b.isAttached())
										{
											Vec2f bpos = b.getPosition();
											GUI::DrawRectangle( getDriver().getScreenPosFromWorldPos(bpos + Vec2f(b.getWidth()/-2.0f, b.getHeight()/-2.0f)), 
																getDriver().getScreenPosFromWorldPos(bpos + Vec2f(b.getWidth()/2.0f, b.getHeight()/2.0f)),
																SColor(0x65ed1202) );
										}
									}
								}
							}
						}
					}/*
					else
					{
						const f32 maxDist = getMaxBuildDistance(blob) + 8.0f;
						Vec2f norm = aimPos2D - myPos;
						const f32 dist = norm.Normalize();
						norm *= (maxDist - dist);
						GUI::DrawArrow2D( aimPos2D, aimPos2D + norm, SColor(0xffdd2212) );
					}*/
				}
			}
		}
	}
}

bool blobBlockingBuilding(CMap@ map, Vec2f v)
{
	CBlob@[] overlapping;
	map.getBlobsAtPosition(v, @overlapping);
	for(uint i = 0; i < overlapping.length; i++)
	{
		CBlob@ o_blob = overlapping[i];
		CShape@ o_shape = o_blob.getShape();
		if (o_blob !is null &&
			o_shape !is null &&
			!o_blob.isAttached() &&
			o_shape.isStatic() &&
			!o_shape.getVars().isladder)
		{
			return true;
		}
	}
	return false;
}