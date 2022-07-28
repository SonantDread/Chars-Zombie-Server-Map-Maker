#include "UI.as"
#include "UICommonUpdates.as"


namespace UI
{
	namespace MapPreview
	{
		Control@ Add(string s){
			Control@ control = AddControl( "" );
			control.vars.set( "map", s );
			control.vars.set( "map offset", Vec2f() );
			control.vars.set( "scale", 1.0 );
			Data@ data = getData();
			@control.proxy = AddProxy( data, Render, NoTransitionUpdate, data.activeGroup, control, 1 );
			@control.processMouse = ProcessMouse;
			@control.input = Input;
			@control.action = Action;
			return control;
		}

		void Action( Group@ group, Control@ control )
		{
			@group.editControl = control;
			control.vars.set( "last key", -1 );
			control.vars.set( "last key time", getGameTime() );
		}

		void Input( Control@ control, const s32 key, bool &out ok, bool &out cancel )
		{
			ok = false;
			cancel = false;
			CControls@ controls = getControls();
			const u32 time = getGameTime();

			Vec2f mapOffset;
			control.vars.get("map offset capped", mapOffset);
			u32 lastTime;
			s32 lastKey;
			control.vars.get( "last key time", lastTime);
			control.vars.get( "last key", lastKey);
			bool hasValue2 = control.vars.exists( "value2" );
			bool altActive = control.vars.get("alt active", altActive) && altActive; //side effects feel so exploited right now

		//	printf("lastKey " + lastKey + " " + key);
			
			if (lastKey != key && lastKey != -1 || lastTime + 10 < time || key == MOUSE_SCROLL_UP || key == MOUSE_SCROLL_DOWN)
			{
				if (   key == KEY_RETURN || key == controls.getActionKeyKey(AK_ACTION1) && key != KEY_LBUTTON
					|| key == KEY_ESCAPE || key == controls.getActionKeyKey(AK_ACTION2) && key != KEY_RBUTTON){
					ok = true;
					Sound::Play("back" );
				}
				else if (key == KEY_UP || key == controls.getActionKeyKey(AK_MOVE_UP))
				{
					mapOffset.y += 10;
				}
				else if (key == KEY_DOWN || key == controls.getActionKeyKey(AK_MOVE_DOWN))
				{
					mapOffset.y -= 10;
				}
				else if (key == KEY_LEFT || key == controls.getActionKeyKey(AK_MOVE_LEFT))
				{
					mapOffset.x += 10;
				}
				else if (key == KEY_RIGHT || key == controls.getActionKeyKey(AK_MOVE_RIGHT))
				{
					mapOffset.x -= 10;
				}
				else if (key == MOUSE_SCROLL_UP || key == controls.getActionKeyKey(AK_ZOOMIN))
				{
					float scale;
					control.vars.get("scale", scale);
					control.vars.set("scale", Maths::Min(scale*2, 4.0));
				}
				else if (key == MOUSE_SCROLL_DOWN || key == controls.getActionKeyKey(AK_ZOOMOUT))
				{
					float scale;
					control.vars.get("scale", scale);
					control.vars.set("scale", Maths::Max(scale/2, 1.0/2));
				}
			}

			control.vars.set("map offset", mapOffset);
			if (lastKey != key){
				control.vars.set( "last key", key );
				control.vars.set( "last key time", time );
			}
		}

		void ProcessMouse( Proxy@ proxy, u8 state)
		{
			Control@ control = proxy.control;
			// print("processMouse control: "+control.caption+" state: "+state);
			Vec2f mouse = getControls().getMouseScreenPos();

			if (state == MouseEvent::DOWN){
				control.vars.set("mouse pos", mouse);
				Vec2f mapOffsetCapped;
				control.vars.get("map offset capped", mapOffsetCapped);
				control.vars.set("map offset", mapOffsetCapped);
			} else if (state == MouseEvent::HOLD) {
				Vec2f mouseOld, mapOffset;
				control.vars.get("mouse pos", mouseOld);
				control.vars.get("map offset", mapOffset);
				control.vars.set("map offset", mapOffset+mouse-mouseOld);
				control.vars.set("mouse pos", mouse);
			} else if (state == MouseEvent::UP) {
			}
		}

		void Render( Proxy@ proxy ){
			if(proxy.control is null) return;

			string s;
			proxy.control.vars.get( "map", s );

			if (proxy.selected){
				GUI::DrawRectangle( proxy.ul, proxy.lr, CONTROL_HOVER_COLOR );
			}
			
			GUI::DrawFramedPane(proxy.ul + Vec2f(5,5), proxy.lr - Vec2f(5,5));

			float scale;
			proxy.control.vars.get("scale", scale);
			Vec2f pos, mapOffset, origin, offset, size;

			Vec2f dim;
			GUI::GetImageDimensions( s, dim );
			
			size = proxy.lr - proxy.ul - Vec2f(318, 212);
			proxy.control.vars.get("map offset", mapOffset);
			origin = (dim*scale - size) / 2;

			origin.x = Maths::Max(origin.x, 0.0);
			origin.y = Maths::Max(origin.y, 0.0);
			dim.x = Maths::Min(dim.x, size.x/scale);
			dim.y = Maths::Min(dim.y, size.y/scale);
			pos = proxy.ul + (size - dim*scale) / 2 + Vec2f(11,11);

			mapOffset.x = Maths::Min(mapOffset.x, origin.x);
			mapOffset.y = Maths::Min(mapOffset.y, origin.y);
			mapOffset.x = Maths::Max(mapOffset.x, -origin.x);
			mapOffset.y = Maths::Max(mapOffset.y, -origin.y);
			offset = (origin-mapOffset)/scale;
			proxy.control.vars.set("map offset capped", mapOffset);

			//s.drawMinimap(pos, offset, dim, scale);
			GUI::DrawIconDirect(s, pos, offset, dim, scale, 0, color_white);
			//GUI::DrawIcon(s, 0, dim, pos, scale);
			
			if(proxy.group.editControl !is proxy.control || getGameTime() % 20 > 10)
				GUI::DrawIcon("MenuItems.png", 80, Vec2f(16, 16), proxy.lr - Vec2f(27, 27), 0.5);
		}
	}



	namespace CreateMapPreview
	{
		void Add()
		{
			Control@ control = UI::VerticalScrollbar::Add(SetMapHeight, 0.1, 0.1);
				
			control.proxy.renderFunc = Render;
		}

		//float SetMapHeight( float value )	{ return map_height	= value; }

		void Render( Proxy@ proxy ){
			if(proxy.control is null) return;

			GUI::DrawFramedPane(proxy.ul, proxy.lr);

			GUI::DrawText("deviation:", proxy.ul+Vec2f(30,30), color_white);

			



			/*
			u32 height = map_height;

			u32 baseline = map_baseline*320;
			u16 deviation = map_deviation;
			u16 erode = map_erodecycles*10;
			//GUI::DrawText("" + mheight, proxy.ul - Vec2f(0,30), color_white);

			Vec2f bloff = Vec2f(0,baseline);

			GUI::DrawFramedPane(proxy.ul, proxy.lr);

			GUI::DrawSpline2D(Vec2f(proxy.ul.x,proxy.lr.y)-bloff, Vec2f(proxy.lr.x,proxy.lr.y)-bloff,
								//
							 Vec2f(proxy.ul.x+deviation,-bloff.y), Vec2f(proxy.lr.x-deviation,-bloff.y),
							 	//
							 erode, color_white);

			*/

		}
	}
}
