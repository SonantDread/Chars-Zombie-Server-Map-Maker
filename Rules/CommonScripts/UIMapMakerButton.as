#include "UI.as"
#include "UICommonUpdates.as"
#include "UIButton.as"
#include "UIDialog.as"
#include "MainButtonRender.as"


namespace UI
{
	namespace LoadMapButton
	{
		Control@ scroll;

		void Add(string s, int i){
			Control@ c = UI::RadioButton::Add( s, SelectMap, "maps");
			c.vars.set( "i", i );
			c.vars.set( "filepath", s );

			c.proxy.renderFunc = Render;
			c.input = Input;
			//c.processMouse = ProcessMouseDoubleClick;
			c.proxy.align.Set(0.05f, 0.5f);
			@scroll = getGroup("Load Map scroll").controls[0][0];
		}

		void Input( Control@ control, const s32 key, bool &out ok, bool &out cancel )
		{
			scroll.input(scroll, key, ok, cancel);
		}

		void SelectMap( Group@ group, Control@ control ){
			UI::Data@ data = UI::getData();

			string s;
			control.vars.get( "filepath", s );			
			getRules().set_string("filepath", s);

			UI::Group@ active = data.activeGroup;
			UI::Group@ info = UI::getGroup(data, "Load Map info");
			@data.activeGroup = info;
			UI::ClearGroup(info);
			UI::MapInfo::Add(s);
			UI::AddGroup("loadbutton", Vec2f(0.6,0.8), Vec2f(0.8,0.9));
			UI::Grid( 1, 1 );
			UI::Button::Add("Load", SelectLoad, "loadmap");
			UI::Group@ map = UI::getGroup(data, "Load Map map preview");
			@data.activeGroup = map;
			UI::ClearGroup(map);
			UI::MapPreview::Add(s);
			@data.activeGroup = active;
			//s.loadMinimap();
		}
		void Render( Proxy@ proxy )
		{
			if(proxy.control is null) return;
			UI::Button::Render(proxy);
		}
	}	
}