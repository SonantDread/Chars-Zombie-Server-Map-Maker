#include "UI.as"
#include "BasePNGLoader.as";

//skin
#include "MainButtonRender.as"
#include "MainImageRender.as"
#include "MainTextInputRender.as"
#include "MainToggleRender.as"
#include "MainOptionRender.as"
#include "MainSliderRender.as"
//controls
#include "UIButton.as"
#include "UIImage.as"
#include "UITextInput.as"
#include "UIToggle.as"
#include "UIOption.as"
#include "UILabel.as"
#include "UISlider.as"
//map maker
#include "UIGenSlider.as"
#include "UIMapMakerButton.as"
#include "UIMapMakerInfo.as"
#include "UIMapMakerMapPreview.as"


void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{	
	UI::Clear();
	UI::SetFont("hud");
	CBitStream params;

	CContextMenu@ mmm = Menu::addContextMenu(menu, "Map Maker Options");
	Menu::addSeparator(menu);

	Menu::addContextItemWithParams(mmm, "New Map", "MapMakerMenu.as", "Callback_Newmap", params);
	Menu::addContextItemWithParams(mmm, "Save Map", "MapMakerMenu.as", "Callback_Savemap", params);
	Menu::addContextItemWithParams(mmm, "Load Map", "MapMakerMenu.as", "Callback_Loadmap", params);

	CContextMenu@ applysymmenu = Menu::addContextMenu(mmm, "Apply Symmetry");
	
	Menu::addContextItemWithParams(applysymmenu, "Mirror from Left to Right ->", "BlockPlacement.as", "ApplySymLR", params);
	Menu::addContextItemWithParams(applysymmenu, "Mirror from Right to Left <-", "BlockPlacement.as", "ApplySymRL", params);


	CBlob@[] players;
    getBlobsByTag("player", players);
	for (uint i = 0; i < players.length; i++)
    {
    	CBlob@ blob = players[i];
		if(blob.isMyPlayer())
		{
			blob.server_SetActive(true);
			blob.getSprite().server_SetActive(true);
			blob.AddScript("StandardControls.as");
		}
	}
}

void Callback_Newmap(CBitStream@ params)
{		
	CloseMenu();
	ShowNewMap();

	CBlob@[] players;
    getBlobsByTag("player", players);
    for (uint i = 0; i < players.length; i++)
    {
    	CBlob@ blob = players[i];
		if(blob.isMyPlayer())
		{
			blob.server_SetActive(false);
			blob.RemoveScript("StandardControls.as");
		}
	}

}

void Callback_Savemap(CBitStream@ params)
{		
	CloseMenu();
	ShowSaveMap();

	CBlob@[] players;
    getBlobsByTag("player", players);
    for (uint i = 0; i < players.length; i++)
    {
    	CBlob@ blob = players[i];
		if(blob.isMyPlayer())
		{
			blob.server_SetActive(false);
			blob.RemoveScript("StandardControls.as");
		}
	}
}

float map_width = 0.2;
float map_height = 0.1;

float map_baseline = 0.55;
float map_deviation = 0.02;
float map_erodecycles = 0.05;
float map_margin = 0.06;
float map_lerp_distance = 0.1;
float map_purturb = 0;
float map_purtscale = 0.01;
float map_purtwidth = 0.3;

float map_cave_amount = 0.4;
float map_cave_amountvariation = 0.2;
float map_cave_scale = 0.3;
float map_cave_detailamp = 0.8;
float map_cave_distort = 1;
float map_cave_width = 0.4;
float map_cave_lerp = 0.1;
float map_cave_depth = 0.04;
float map_cave_depthvarition = 0.1;

float map_ruins_count = 0.02;
float map_ruins_variation = 0.05;
float map_ruins_size = 0.07;
float map_ruins_width = 0.5;

float SetMapWidth( float value )		{ return map_width = value;}
float SetMapHeight( float value )		{ return map_height	= value;}

float SetBaseLine( float value )		{ return map_baseline = value;}
float SetDevition( float value )		{ return map_deviation = value;}
float SetErode( float value )			{ return map_erodecycles = value;}
float SetMagin( float value )			{ return map_margin	= value;}	
float SetLerpDistance( float value )	{ return map_lerp_distance = value;}
float SetPurturb( float value )			{ return map_purturb = value;}
float SetPurtScale( float value )		{ return map_purtscale = value;}
float SetPurtWidth( float value )		{ return map_purtwidth	= value;}

float SetCaveAmount( float value )		{ return map_cave_amount = value;}
float SetCaveAmountVar( float value )	{ return map_cave_amountvariation = value;}
float SetCaveScale( float value )		{ return map_cave_scale = value;}
float SetCaveDetailAmp( float value )	{ return map_cave_detailamp	= value;}
float SetCaveDistort( float value )		{ return map_cave_distort = value;}
float SetCaveWidth( float value )		{ return map_cave_width	= value;}
float SetCaveLerp( float value )		{ return map_cave_lerp = value;}
float SetCaveDepth( float value )		{ return map_cave_depth	= value;}
float SetCaveDepthVar( float value )	{ return map_cave_depthvarition = value;}

float SetRuinsCount( float value )		{ return map_ruins_count = value;}
float SetRuinsVariation( float value )	{ return map_ruins_variation = value;}
float SetRuinsSize( float value )		{ return map_ruins_size = value;}
float SetRuinsWidth( float value )		{ return map_ruins_width = value;}

void WidthSliderProcessMouse( UI::Proxy@ proxy, u8 state ){
	UI::GenScroll::ProcessMouse(proxy, state);
	if (state == MouseEvent::DOWN || state == MouseEvent::HOLD){

		WidthAdjusted(null, null);
	}
}

void WidthAdjusted( UI::Group@ group, UI::Control@ control )
{
	SetLerpDistance(Maths::Min(map_lerp_distance, Maths::Min(map_width, 1.0)));
	SetMagin(Maths::Min(map_margin, Maths::Min(map_width,1.0)));

	UI::Data@ data = UI::getData();

	UI::Control@ margin = UI::getGroup(data, "Map Gen 1").controls[0][4];
	margin.vars.set( "maximum", Maths::Min(map_width, 1.0));
	margin.vars.set( "value", Maths::Min(map_margin, 1.0));

	UI::Control@ lerp = UI::getGroup(data, "Map Gen 1").controls[0][5];
	lerp.vars.set( "maximum", Maths::Min(map_width, 1.0));
	lerp.vars.set( "value", Maths::Min(map_lerp_distance,1.0));
}

int gen_type;
int  SetPresetGen	( int option ) 
{ 
	UI::Data@ data = UI::getData();

	UI::Control@ width = UI::getGroup(data, "Map Gen W+H").controls[0][0];
	UI::Control@ height = UI::getGroup(data, "Map Gen W+H").controls[0][1];
	UI::Control@ baseline = UI::getGroup(data, "Map Gen 1").controls[0][1];
	UI::Control@ deviation = UI::getGroup(data, "Map Gen 1").controls[0][2];
	UI::Control@ erode = UI::getGroup(data, "Map Gen 1").controls[0][3];
	UI::Control@ margin = UI::getGroup(data, "Map Gen 1").controls[0][4];
	UI::Control@ lerp_distance = UI::getGroup(data, "Map Gen 1").controls[0][5];
	UI::Control@ purturb = UI::getGroup(data, "Map Gen 1").controls[0][6];
	UI::Control@ purtscale = UI::getGroup(data, "Map Gen 1").controls[0][7];
	UI::Control@ purtwidth = UI::getGroup(data, "Map Gen 1").controls[0][8];
	UI::Control@ caveamt = UI::getGroup(data, "Map Gen 2").controls[0][0];
	UI::Control@ caveamtvar = UI::getGroup(data, "Map Gen 2").controls[0][1];
	UI::Control@ cavescale = UI::getGroup(data, "Map Gen 2").controls[0][2];
	UI::Control@ cavedetailamp = UI::getGroup(data, "Map Gen 2").controls[0][3];
	UI::Control@ cavedistort = UI::getGroup(data, "Map Gen 2").controls[0][4];
	UI::Control@ cavewidth = UI::getGroup(data, "Map Gen 2").controls[0][5];
	UI::Control@ cavelerp = UI::getGroup(data, "Map Gen 2").controls[0][6];
	UI::Control@ cavedepth = UI::getGroup(data, "Map Gen 2").controls[0][7];
	UI::Control@ cavedepthvar = UI::getGroup(data, "Map Gen 2").controls[0][8];
	UI::Control@ ruinscount = UI::getGroup(data, "Map Gen 3").controls[0][0];
	UI::Control@ ruinsvar = UI::getGroup(data, "Map Gen 3").controls[0][1];
	UI::Control@ ruinssize = UI::getGroup(data, "Map Gen 3").controls[0][2];
	UI::Control@ ruinswidth = UI::getGroup(data, "Map Gen 3").controls[0][3];

	if (option == 0 ) // Custom
	{
		
	}
	else if (option == 1 ) // Default
	{ 		
		width.vars.set( "value",  0.2);
		height.vars.set( "value",  0.1);

		baseline.vars.set( "value",  0.55);
		deviation.vars.set( "value",  0.02);
		erode.vars.set( "value",  0.05);
		margin.vars.set( "value",  0.06);
		lerp_distance.vars.set( "value",  0.1);
		purturb.vars.set( "value",  0);
		purtscale.vars.set( "value",  0.01);
		purtwidth.vars.set( "value",  0.3);

		caveamt.vars.set( "value",  0.4);
		caveamtvar.vars.set( "value",  0.2);
		cavescale.vars.set( "value",  0.3);
		cavedetailamp.vars.set( "value",  0.8);
		cavedistort.vars.set( "value",  1);
		cavewidth.vars.set( "value",  0.4);
		cavelerp.vars.set( "value",  0.1);
		cavedepth.vars.set( "value",  0.04);
		cavedepthvar.vars.set( "value",  0.1);

		ruinscount.vars.set( "value",  0.02);
		ruinsvar.vars.set( "value",  0.05);
		ruinssize.vars.set( "value",  0.07);
		ruinswidth.vars.set( "value",  0.5);

	}
	else if (option == 2 ) // Empty
	{ 		
		baseline.vars.set( "value",  0);
		deviation.vars.set( "value",  0);
		erode.vars.set( "value",  0);
		margin.vars.set( "value",  0);
		lerp_distance.vars.set( "value",  0.02);
		purturb.vars.set( "value",  0);
		purtscale.vars.set( "value",  0);
		purtwidth.vars.set( "value",  0);

		caveamt.vars.set( "value",  0);
		caveamtvar.vars.set( "value",  0);
		cavescale.vars.set( "value",  0);
		cavedetailamp.vars.set( "value",  0);
		cavedistort.vars.set( "value",  0);
		cavewidth.vars.set( "value",  0);
		cavelerp.vars.set( "value",  0.02);
		cavedepth.vars.set( "value",  0);
		cavedepthvar.vars.set( "value",  0);

		ruinscount.vars.set( "value",  0);
		ruinsvar.vars.set( "value",  0);
		ruinssize.vars.set( "value",  0);
		ruinswidth.vars.set( "value",  0);
	}	
	else if (option == 3 ) // Hills
	{ 		
		width.vars.set( "value",  0.3);
		height.vars.set( "value",  0.15);

		baseline.vars.set( "value",  0.5);
		deviation.vars.set( "value",  0.05);
		erode.vars.set( "value",  0.05);
		margin.vars.set( "value",  0.02);
		lerp_distance.vars.set( "value",  0.12);
		purturb.vars.set( "value",  0.01);
		purtscale.vars.set( "value",  0.02);
		purtwidth.vars.set( "value",  0.25);

		caveamt.vars.set( "value",  0);
		caveamtvar.vars.set( "value",  0);
		cavescale.vars.set( "value",  0);
		cavedetailamp.vars.set( "value",  0);
		cavedistort.vars.set( "value",  0);
		cavewidth.vars.set( "value",  0);
		cavelerp.vars.set( "value",  0.02);
		cavedepth.vars.set( "value",  0);
		cavedepthvar.vars.set( "value",  0);

		ruinscount.vars.set( "value",  0);
		ruinsvar.vars.set( "value",  0);
		ruinssize.vars.set( "value",  0);
		ruinswidth.vars.set( "value",  0);
	}
	else if (option == 4 ) // Flat
	{ 		
		width.vars.set( "value",  0.2);
		height.vars.set( "value",  0.1);

		baseline.vars.set( "value",  0.5);
		deviation.vars.set( "value",  0.02);
		erode.vars.set( "value",  0);
		margin.vars.set( "value",  0.19);
		lerp_distance.vars.set( "value",  0.2);
		purturb.vars.set( "value",  0);
		purtscale.vars.set( "value",  0);
		purtwidth.vars.set( "value",  0);

		caveamt.vars.set( "value",  0);
		caveamtvar.vars.set( "value",  0);
		cavescale.vars.set( "value",  0);
		cavedetailamp.vars.set( "value",  0);
		cavedistort.vars.set( "value",  0);
		cavewidth.vars.set( "value",  0);
		cavelerp.vars.set( "value",  0.02);
		cavedepth.vars.set( "value",  0);
		cavedepthvar.vars.set( "value",  0);

		ruinscount.vars.set( "value",  0);
		ruinsvar.vars.set( "value",  0);
		ruinssize.vars.set( "value",  0);
		ruinswidth.vars.set( "value",  0);
	}
	else if (option == 5 ) // Mid hole/hill
	{ 		
		width.vars.set( "value",  0.2);
		height.vars.set( "value",  0.1);

		baseline.vars.set( "value",  0.5);
		deviation.vars.set( "value",  0.02);
		erode.vars.set( "value",  0);
		margin.vars.set( "value",  0.14);
		lerp_distance.vars.set( "value",  0.02);
		purturb.vars.set( "value",  0.02);
		purtscale.vars.set( "value",  0.1);
		purtwidth.vars.set( "value",  0.3);

		caveamt.vars.set( "value",  0);
		caveamtvar.vars.set( "value",  0);
		cavescale.vars.set( "value",  0);
		cavedetailamp.vars.set( "value",  0);
		cavedistort.vars.set( "value",  0);
		cavewidth.vars.set( "value",  0);
		cavelerp.vars.set( "value",  0.02);
		cavedepth.vars.set( "value",  0);
		cavedepthvar.vars.set( "value",  0);

		ruinscount.vars.set( "value",  0);
		ruinsvar.vars.set( "value",  0);
		ruinssize.vars.set( "value",  0);
		ruinswidth.vars.set( "value",  0);
	}


	width.vars.get( "value",  map_width);
	height.vars.get( "value",  map_height);

	baseline.vars.get( "value",  map_baseline);
	deviation.vars.get( "value",  map_deviation);
	erode.vars.get( "value",  map_erodecycles);
	margin.vars.get( "value",  map_margin);
	lerp_distance.vars.get( "value",  map_lerp_distance);
	purturb.vars.get( "value",  map_purturb);
	purtscale.vars.get( "value", map_purtscale);
	purtwidth.vars.get( "value",  map_purtwidth);

	caveamt.vars.get( "value",  map_cave_amount);
	caveamtvar.vars.get( "value",  map_cave_amountvariation);
	cavescale.vars.get( "value",  map_cave_scale);
	cavedetailamp.vars.get( "value",  map_cave_detailamp);
	cavedistort.vars.get( "value", map_cave_distort);
	cavewidth.vars.get( "value",  map_cave_width);
	cavelerp.vars.get( "value",  map_cave_lerp);
	cavedepth.vars.get( "value",  map_cave_depth);
	cavedepthvar.vars.get( "value",  map_cave_depthvarition);

	ruinscount.vars.get( "value",  map_ruins_count);
	ruinsvar.vars.get( "value",  map_ruins_variation);
	ruinssize.vars.get( "value",  map_ruins_size);
	ruinswidth.vars.get( "value",  map_ruins_width);

 	return gen_type	= option; 
}

void ShowNewMap()
{
	UI::Group@ group;
	UI::Control@ control;
	UI::Clear();
	UI::Control@ c;

	UI::AddGroup("Map Gen W+H", Vec2f(0.05,0.1), Vec2f(0.445,0.3));
	UI::Grid( 1, 2, 0.1);	
		@c = UI::GenScroll::Add( "Map Width:", SetMapWidth, map_width, 0.001, 1000, 1, 0.05, 1.0, " Tiles", "" );
		c.processMouse = WidthSliderProcessMouse;
		UI::GenScroll::Add( "Map Height:", SetMapHeight, map_height, 0.001, 1000, 1, 0.05, 1.0, " Tiles" , "");
	UI::Background();

	UI::AddGroup("Map Gen Preset", Vec2f(0.05,0.305), Vec2f(0.245,0.38));
		UI::Grid( 1, 1, 0.1);
		UI::Option::Add( "Preset:", SetPresetGen, "Custom|Default|Empty|Hills|Flat|Mid hole/hill", 0, "Generation Preset" );
		UI::Background();

	UI::AddGroup("Map Gen Info", Vec2f(0.45,0.1), Vec2f(0.95,0.66));
		UI::Grid( 1, 1, 0.2);
		UI::Label::Add( "", 3.0f );
		UI::Background();	

	UI::AddGroup("generatebutton", Vec2f(0.655,0.66), Vec2f(0.95,0.95));
		UI::Grid( 1, 1, 0.3 );
		UI::Button::Add("Create Map", SelectCreate, "GenerateMap");
		UI::Background();

		ShowGenMenu();

	UI::SetLastSelection();
	@UI::getData().activeGroup = group;
}
void ShowGenMenu()
{
	UI::Group@ group;
	UI::Control@ control; 
	UI::Control@ c;

	UI::AddGroup("Map Gen 1", Vec2f(0.05,0.305), Vec2f(0.245,0.95));
	UI::Grid( 1, 9, 0.1);
		UI::AddSeparator();
		//Control@ Add( const string &in caption, SLIDER_FUNC@ setFunc, float value, float increment, float multiplier, int decimals, float min, float max string currency = "", string buttoninfo )
		UI::GenScroll::Add( "Baseline:", SetBaseLine, map_baseline, 0.01, 100, 1, 0, 1, " %", "Baseline:\n\n"+"The height of tile generation, 0% = all sky, 100% = no sky.");
		UI::GenScroll::Add( "Deviation:", SetDevition, map_deviation, 0.001, 1000, 1, 0, 1, "", "Deviation:\n\n"+"A measure that is used to quantify the amount of variation or dispersion of a set of data values." );
		UI::GenScroll::Add( "Erode Cycles:", SetErode, map_erodecycles, 0.01, 100, 1, 0, 1, "", "Erode Cycles:\n\n"+"More = less rough terrain, but slower generation." );		
		UI::GenScroll::Add( "Edge Margin:", SetMagin, map_margin, 0.002, 500, 1, 0, map_width, " Tiles", "Margin:\n\n"+"Tiles from the edge that are totally straight." );
		@c = UI::GenScroll::Add( "Lerp Distance:", SetLerpDistance, map_lerp_distance, 0.002, 500, 1, 0.004, map_width, "", "Lerp Distance:\n\n"+"Tiles from the margin that eases into the generator." );
		UI::GenScroll::Add( "Purturb Amount:", SetPurturb, map_purturb, 0.001, 100.0, 10, 0, 1, "", "Purturb Amount:\n\n"+"The amplitude of the purturbation function."+"\n"+"Can allow formation of caves, crags, and other cool things if the value is high, but also results in deformation of everything."+"\n"+"I didn't spell it that way - Monkey_Feats ");
		UI::GenScroll::Add( "Purt Scale:", SetPurtScale, map_purtscale, 0.01, 1.0, 100, 0, 1, "", "Purturb Scale:\n\n"+"Scale of the purturbation.");
		UI::GenScroll::Add( "Purturb Width:", SetPurtWidth, map_purtwidth, 0.01, 100, 1, 0.002, 1, "", "Purturb Width:\n\n"+"Width of the purturbation area."+"\n"+"negative equals deviation value.");
	UI::Background();

	UI::AddGroup("Map Gen 2", Vec2f(0.25,0.305), Vec2f(0.445,0.95));
	UI::Grid( 1, 9, 0.1);
		UI::GenScroll::Add( "Cave Amount:", SetCaveAmount, map_cave_amount, 0.01, 100, 1, 0, 1, "", "Cave Amount:\n\n"+"Overall 'amount' of cave - zero turns off cave generation." );
		UI::GenScroll::Add( "Cave Amount Variation:", SetCaveAmountVar, map_cave_amountvariation, 0.01, 100, 1, 0, 1, "", "Cave Amount Variation:\n\n"+"How much the cave amount can vary." );
		UI::GenScroll::Add( "Cave Scale:", SetCaveScale, map_cave_scale, 0.01, 100, 1, 0, 1, " %" , "Cave Scale:\n\n"+"Bigger means larger features, smaller means more noise.");		
		UI::GenScroll::Add( "Cave Detail Amplitude:", SetCaveDetailAmp, map_cave_detailamp, 0.01, 100, 1, 0, 1, " %", "Cave Detail Amplitude:\n\n"+"The amount the detail over the top of the cave." );
		UI::GenScroll::Add( "Cave Distortion:", SetCaveDistort, map_cave_distort, 0.01, 100, 1, 0, 1, " %", "Cave Distort:\n\n"+"The amount to distort the cave." );
		UI::GenScroll::Add( "Cave Width:", SetCaveWidth, map_cave_width, 0.01, 100.0, 1, 0, 1, " %", "Cave Width:\n\n"+"The width of area on the map that the cave spans."+"\n"+"1.0 = all map, 0.1 = middle 10%");
		UI::GenScroll::Add( "Cave Lerp:", SetCaveLerp, map_cave_lerp, 0.002, 500, 1, 0.002, 1, " Tiles", "Cave Lerp:\n\n"+"Tiles at the edge of the cave area that caves are faded out." );
		UI::GenScroll::Add( "Cave Depth:", SetCaveDepth, map_cave_depth, 0.002, 500, 1, 0, 1, " Tiles", "Cave Depth:\n\n"+"Tiles from the surface that the deep bit of the cave will target." );
		UI::GenScroll::Add( "Cave Depth Variation:", SetCaveDepthVar, map_cave_depthvarition, 0.01, 100, 1, 0, 1, "", "Cave Depth Variation:\n\n"+"Amount the cave depth may vary by." );
	UI::Background();

	UI::AddGroup("Map Gen 3", Vec2f(0.45,0.665), Vec2f(0.65,0.95));
	UI::Grid( 1, 4, 0.1);
		UI::GenScroll::Add( "Ruins Count:", SetRuinsCount, map_ruins_count, 0.01, 100, 1, 0, 1, "", "Ruins Count:\n\n"+"The overall number of ruins." );
		UI::GenScroll::Add( "Ruins Variation:", SetRuinsVariation, map_ruins_variation, 0.01, 100, 1, 0, 1, "", "Ruins Count Variation:\n\n"+"How much the ruin count may vary."+"\n"+"only matters for amount > 0" );
		UI::GenScroll::Add( "Ruins Size:", SetRuinsSize, map_ruins_size, 0.01, 100, 1, 0, 1, "", "Ruins Size:\n\n"+"The approximate horizontal size in tiles of each ruin." );		
		UI::GenScroll::Add( "Ruins Width:", SetRuinsWidth, map_ruins_width, 0.01, 1.0, 100, 0, 1, "", "Ruins Width:\n\n"+"The width of area on the map that ruins can appear on."+"\n"+"1.0 = all map, 0.1 = middle 10%");
	UI::Background();
}

string savemapname = "";
string SetSaveMapName( const string &in caption )	{ return savemapname		= caption ;	}

void ShowSaveMap()
{
	SetSaveMapName(getMap().getMapName().replace("Maps/", "").replace(".png", "")); // initilize save map name incase there was no input
	UI::Group@ group;
	UI::Control@ control;
	UI::Clear();

	UI::AddGroup("Save Map Name", Vec2f(0.25,0.45), Vec2f(0.75,0.55));
		UI::Grid( 1, 1, 0.4);
		UI::TextInput::Add( "", SetSaveMapName, getMap().getMapName().replace("Maps/", "").replace(".png", ""), "Your map name", 30 );
	UI::Background();

	UI::AddGroup("Maps/", Vec2f(0.30,0.45), Vec2f(0.35,0.55));
		UI::Grid( 1, 1, 0.1);
		UI::Label::Add("   Maps/");
	//UI::Background();

	UI::AddGroup(".png", Vec2f(0.64,0.45), Vec2f(0.69,0.55));
		UI::Grid( 1, 1, 0.5);
		UI::Label::Add(".png");
	//UI::Background();
		
	UI::AddGroup("Save Button", Vec2f(0.4,0.555), Vec2f(0.6,0.65));
		UI::Grid( 1, 1 ,0.2);
		UI::Button::Add("      Save Map", SelectSave, "savemap");
	UI::Background();

	@UI::getData().activeGroup = group;
}

void SelectSave( UI::Group@ group, UI::Control@ control )
{
	UI::Clear("Save Map Name");
	UI::Clear("Maps/");
	UI::Clear(".png");
	UI::Clear("Save Button");

	string checkname = CFileMatcher("Maps/"+savemapname+".png").getFirst();

	if (("Maps/"+savemapname+".png") == checkname)
	{	
		UI::AddGroup("Save Confirmation", Vec2f(0.25,0.35), Vec2f(0.75,0.55));
			UI::Grid( 1, 1, 0.3);
			UI::Label::Add( "Maps/"+savemapname+".png"+"\n"+"will be overwritten, are you sure?");
		UI::Background();

		UI::AddGroup("Save Confirmation Buttons", Vec2f(0.35,0.555), Vec2f(0.65,0.65));
			UI::Grid( 2, 1 ,0.05);
			UI::Button::Add("No", DenySave, "no");
			 UI::Button::AddIcon("MenuItems.png", Vec2f(32, 32), 29 );
			UI::Button::Add("Yes", ConfirmSave, "yes");
			 UI::Button::AddIcon("MenuItems.png", Vec2f(32, 32), 28 );
		UI::Background();
	}
	else { ConfirmSave(group, control); }
}
void DenySave( UI::Group@ group, UI::Control@ control )
{
	UI::Clear("Save Confirmation");
	UI::Clear("Save Confirmation Buttons");
	ShowSaveMap();
}
void ConfirmSave( UI::Group@ group, UI::Control@ control )
{
	CBlob@[] players;
    getBlobsByTag("player", players);
	for (uint i = 0; i < players.length; i++)
    {
    	CBlob@ blob = players[i];
		if(blob.isMyPlayer())
		{
			blob.server_SetActive(true);
			blob.getSprite().server_SetActive(true);
			blob.AddScript("StandardControls.as");
		}
	}
	SaveMap(getMap(), savemapname+".png");
	UI::Clear();
}

string[] MapNames;
string filepath = "";
string[] filepaths;

void Callback_Loadmap(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu
	MapNames.clear();
	filepaths.clear();

	ConfigFile cfg = ConfigFile();	
	if (cfg.loadFile("MapDirectories.cfg"))
	{
		cfg.readIntoArray_string( filepaths, "filepaths" );
		for (uint i = 0; i < filepaths.length; i++)
		{
			filepath = filepaths[i];
			CFileMatcher@ files = CFileMatcher(filepath+".png");
			while (files.iterating())
			{		
				const string filename = files.getCurrent();

				if (filename != "Maps/randomgrid_castle.png" && filename != "Maps/randomgrid_castle_2.png" &&
					filename != "Maps/randomgrid_cave.png"   && filename != "Maps/randomgrid_cave_2.png" &&
					filename != "Maps/tutorial_archer.png"   && filename != "Maps/tutorial_builder.png" &&
					filename != "Maps/tutorial_knight.png"   && filename != "Maps/MapPalette.png")
				{
					MapNames.push_back(filename);	
				}
					
			}
		}
	}	

	CBlob@[] players;
    getBlobsByTag("player", players);
    for (uint i = 0; i < players.length; i++)
    {
    	CBlob@ blob = players[i];
		if(blob.isMyPlayer())
		{
			blob.server_SetActive(false);
			blob.RemoveScript("StandardControls.as");
		}
	}

	ShowLoadMap();
}

void ShowLoadMap()
{
	UI::Group@ group;
	UI::Control@ control;
	UI::Clear();
	
	UI::Control@ c;

	UI::AddGroup("Load Map list", Vec2f(0.02,0.025), Vec2f(0.4,0.935));
		UI::Grid( 1, 20, 0.01 );
		for (int i = 0; i < 20; ++i)
		{
			UI::AddSeparator();
		}
		UI::Background();

	UI::AddGroup("Load Map scroll", Vec2f(0.4,0.025), Vec2f(0.43,0.985));	
		UI::Grid( 1, 1, 0.0 );
		UI::VerticalScrollbar::Add(ScrollMapList, 1, 1.1);
		UI::Background();

	UI::AddGroup("Load Map map preview", Vec2f(0.435,0.05), Vec2f(0.99,0.70));
		UI::Grid( 1, 1, 0.136 );
		UI::AddSeparator();


	UI::AddGroup("Load Map info", Vec2f(0.435,0.025), Vec2f(0.99,0.985));
		UI::Grid( 1, 1, 0.05 );
		UI::Background();

	UI::AddGroup("Load Map Search Bar", Vec2f(0.02,0.935), Vec2f(0.4,0.99));
		UI::Grid( 1, 1, 0.0 );
		@c = UI::TextInput::Add("", null, search, "", 0, "Search..");
		 c.proxy.align.Set(0.02f, 0.5f);
		 c.vars.set("caption centered", false);
		 c.input = UpdateSearch;

	UI::AddGroup("Load Map Search Clear Button", Vec2f(0.345,0.935), Vec2f(0.405,0.99));
		UI::Grid( 1, 1, 0.3 );
		UI::Button::Add("", ClearLoadMapSearch, "");
		 UI::Button::AddIcon("MakerPlacementMenu.png", Vec2f(24, 8), 62 );

		//Refresh(null,null);

		ApplyFilters();
		SortMapList();

	@UI::getData().activeGroup = group;
}

void ClearLoadMapSearch(UI::Group@ group, UI::Control@ control)
{	
	search = "";
	UI::Data@ data = UI::getData();
	UI::Control@ textbar = UI::getGroup(data, "Load Map Search Bar").controls[0][0];
	textbar.caption = "";
	ApplyFilters();
	SortMapList();
}

string search;
void UpdateSearch( UI::Control@ control, const s32 key, bool &out ok, bool &out cancel )
{
	UI::TextInput::Input( control, key, ok, cancel );
	CRules@ rules = getRules();
	if (key != 0) 
	{
		rules.set_u32("search update time", getGameTime());
	} 
	else 
	{
		uint gameTime = getGameTime();
		uint updateTime = rules.get_u32("search update time");
		if (updateTime == 0) {
			rules.set_u32("search update time", gameTime);
			updateTime = gameTime;
		}

		if (gameTime == updateTime + 10) {
			search = control.caption;
			ApplyFilters();
			SortMapList();
		}
	}
}

float ScrollMapList( float newValue )
{
	UI::Data@ data = UI::getData();
	UI::Control@ scroll = UI::getGroup(data, "Load Map scroll").controls[0][0];
	float oldValue;
	scroll.vars.get( "value", oldValue );

	bool refresh = newValue == -1;
	if(refresh) newValue = 0;
	int offset = Maths::Round(Maths::Max(searchlist.length-20, 0) * newValue);
	if(offset == Maths::Round((searchlist.length-20) * oldValue) && !refresh) return newValue;

	UI::Group@ list = UI::getGroup(data, "Load Map list");

	int sunkenIndex = -1, selectedIndex = -1;
	UI::Control@ prev;
	if(getRules().get("radio set map selection", @prev) && prev !is null){
		prev.vars.get( "i", sunkenIndex );
	}
	if (list.activeControl !is null) {
		list.activeControl.vars.get( "i", selectedIndex );
	}

	UI::Group@ active = data.activeGroup;
	@data.activeGroup = list;
// print("ClearGroup: "+list.name);
	UI::ClearGroup(list);
	for (int i = 0; i < 20; ++i)
		if(i < searchlist.length)	
			UI::LoadMapButton::Add(searchlist[offset + i], offset + i);
		else
			UI::AddSeparator();

	sunkenIndex -= offset;
	selectedIndex -= offset;
	if (sunkenIndex >= 0 && sunkenIndex < 20) {
		UI::Control@ sunken = list.controls[0][sunkenIndex];
		getRules().set("radio set map selection", @sunken);
		sunken.vars.set( "sunken", true );
	}
	if (selectedIndex >= 0 && selectedIndex < 20) {
		UI::SetSelection(selectedIndex);
	}

	@data.activeGroup = active;

	return newValue;
}

void Refresh( UI::Group@ group, UI::Control@ control )
{
	searchlist.clear();

	UI::Data@ data = UI::getData();
	UI::Control@ scroll = UI::getGroup(data, "Load Map scroll").controls[0][0];
	scroll.vars.set( "value", ScrollMapList(-1) );
	getRules().set("radio set map selection", null);

	UI::Group@ active = data.activeGroup;
	UI::Group@ info = UI::getGroup(data, "Load Map info");
	@data.activeGroup = info;
	UI::ClearGroup(info);
	UI::MapInfo::Add("");
	UI::Group@ map = UI::getGroup(data, "Load Map map preview");
	@data.activeGroup = map;
	UI::ClearGroup(map);
	UI::AddSeparator();
	@data.activeGroup = active;
}

void SortMapList()
{
	searchlist.sortAsc();
	UI::Group@ group = UI::getGroup(UI::getData(), "Load Map scroll");
	if (group is null) return;
	UI::Control@ scroll = group.controls[0][0];
	scroll.vars.set( "increment", searchlist.length > 20 ? 1.0/(searchlist.length-20) : 2 );
	scroll.vars.set( "value", ScrollMapList(-1) );
}

string[] searchlist;
void ApplyFilters()
{
	searchlist.clear();
	for (int i = 0; i < MapNames.length; i++)
	{
		if (search == "" || MapNames[i].toLower().find(search) != -1) 
		{
			searchlist.push_back(MapNames[i]);
		}
	}
}


void SelectCreate( UI::Group@ group, UI::Control@ control )
{
	UI::Clear();

	string s = CFileMatcher("MapMaker"+".cfg").getFirst();
	print(s);

	ConfigFile cfg = ConfigFile(s);
	cfg.add_f32("m_width", Maths::Round(map_width*1000));
	cfg.add_f32("m_height", Maths::Round(map_height*1000));

	cfg.add_f32("baseline", Maths::Round(map_baseline*100));
	cfg.add_f32("deviation", Maths::Round(map_deviation*1000));
	cfg.add_f32("erode_cycles", Maths::Round(map_erodecycles*100));
	cfg.add_f32("map_margin", Maths::Round(map_margin*500));
	cfg.add_f32("lerp_distance", Maths::Round(map_lerp_distance*500));
	cfg.add_f32("purturb", Maths::Floor(map_purturb*1000)/10);
	cfg.add_f32("purt_scale", Maths::Floor(map_purtscale*100)/100);
	cfg.add_f32("purt_width", Maths::Round(map_purtwidth*100));

	cfg.add_f32("cave_amount", Maths::Floor(map_cave_amount*100)/100);
	cfg.add_f32("cave_amount_var", Maths::Floor(map_cave_amountvariation*100)/100);
	cfg.add_f32("cave_scale", Maths::Round(Maths::Floor(map_cave_scale*1000)/10));
	cfg.add_f32("cave_detail_amp", Maths::Floor(map_cave_detailamp*100)/100);
	cfg.add_f32("cave_distort", Maths::Floor(map_cave_distort*100)/100);
	cfg.add_f32("cave_width", Maths::Floor(map_cave_width*100)/100);
	cfg.add_f32("cave_lerp", Maths::Round(map_cave_lerp*500));
	cfg.add_f32("cave_depth", Maths::Round(map_cave_depth*500));
	cfg.add_f32("cave_depth_var", Maths::Round(map_cave_depthvarition*100));

	cfg.add_f32("ruins_count", Maths::Round(map_ruins_count*100));
	cfg.add_f32("ruins_count_var", Maths::Round(map_ruins_variation*100));
	cfg.add_f32("ruins_size", Maths::Round(map_ruins_size*100));
	cfg.add_f32("ruins_width", Maths::Floor(map_ruins_width*10)/10);

	cfg.saveFile("MapMaker.kaggen.cfg");
	LoadMap("../Cache/MapMaker.kaggen.cfg");
	//save
}

void SelectLoad( UI::Group@ group, UI::Control@ control )
{
	UI::Clear();
	LoadMap(getRules().get_string("filepath"));

	//print(""+s);
}

void OnCloseMenu(CRules@ this)
{
	UI::Clear();
}

void CloseMenu()
{
	Menu::CloseAllMenus();
}