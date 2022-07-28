#include "UI.as"
#include "UICommonUpdates.as"
#include "UILabel.as"

namespace UI
{
	funcdef float GENSLIDER_FUNC( float );

	namespace GenScroll
	{

		Control@ Add( const string &in caption, GENSLIDER_FUNC@ setFunc, float value, float increment, float multiplier, float decimals, float minimium, float maximum, string currency = "",  string buttoninfo = "")
		{
			Data@ data = getData();
			Control@ control = AddControl( caption );
			@control.input = Input;
			@control.action = Action;
			@control.processMouse = ProcessMouse;
			@control.move = Move;
			control.vars.set( "set func", @setFunc );
			control.vars.set( "value", value );
			control.vars.set( "increment", increment );
			control.vars.set( "multiplier", multiplier );
			control.vars.set( "decimals", decimals );
			control.vars.set( "minimium", minimium );
			control.vars.set( "maximum", maximum );
			control.vars.set( "currency", currency );
			control.vars.set( "buttoninfo", buttoninfo );
			@control.proxy = AddProxy( data, Render, Update, data.activeGroup, control, 1.0f );
			return control;
		}

		void Update( Proxy@ proxy  )
		{
			NoTransitionUpdate( proxy );

			if (proxy.control !is null && proxy.control.caption != "")
			{
				float increment, value, multiplier, minimium, maximum;
				string currency, caption;
				int decimals;
				proxy.control.vars.get( "value", value );
				proxy.control.vars.get( "increment", increment );
				proxy.control.vars.get( "multiplier", multiplier );
				proxy.control.vars.get( "decimals", decimals );
				proxy.control.vars.get( "currency", currency );
				proxy.control.vars.get( "minimium", minimium );
				proxy.control.vars.get( "maximum", maximum );

				if(value == minimium)	{ currency += " (Min)";	}
				if(value == maximum)	{ currency += " (Max)";	}
				
				proxy.caption = proxy.control.caption + " " + Maths::Floor((value * multiplier)*decimals)/decimals + "" + currency;
				if (currency == "/"){
					proxy.caption += multiplier;
				}
			}
		}

		void Input( Control@ control, const s32 key, bool &out ok, bool &out cancel )
		{
			_Input( control, key, ok, cancel, false );
		}

		void _Input( Control@ control, const s32 key, bool &out ok, bool &out cancel, bool v )
		{
			ok = false;
			cancel = false;
			CControls@ controls = getControls();
			const u32 time = getGameTime();

			u32 lastTime;
			s32 lastKey;
			control.vars.get( "last key time", lastTime);
			control.vars.get( "last key", lastKey);
			bool hasValue2 = control.vars.exists( "value2" );
			bool altActive = control.vars.get("alt active", altActive) && altActive; //side effects feel so exploited right now

		//	printf("lastKey " + lastKey + " " + key);
			
			if (lastKey != key && lastKey != -1 || lastTime + 10 < time || key == MOUSE_SCROLL_UP || key == MOUSE_SCROLL_DOWN)
			{
				if (key == KEY_RETURN || key == controls.getActionKeyKey(AK_ACTION1) && key != KEY_LBUTTON){
					if (altActive || !hasValue2) {
						ok = true;
						control.vars.set("alt active", false);
						Sound::Play("back" );
					} else {
						control.vars.set("alt active", true);
						Sound::Play("menuclick" );
					}
				}
				else if (key == KEY_ESCAPE || key == controls.getActionKeyKey(AK_ACTION2) && key != KEY_RBUTTON){
					ok = true;
					control.vars.set("alt active", false);
					Sound::Play("back" );
				}
				else if (!v && (key == KEY_LEFT || key == controls.getActionKeyKey(AK_MOVE_LEFT))
					|| v && (key == KEY_UP || key == controls.getActionKeyKey(AK_MOVE_UP))
					|| key == MOUSE_SCROLL_UP)
				{
					Move( control, true );
				}
				else if (!v && (key == KEY_RIGHT || key == controls.getActionKeyKey(AK_MOVE_RIGHT))
					|| v && (key == KEY_DOWN || key == controls.getActionKeyKey(AK_MOVE_DOWN))
					|| key == MOUSE_SCROLL_DOWN)
				{
					Move( control, false );
				}
			}

			if (lastKey != key){
				control.vars.set( "last key", key );
				control.vars.set( "last key time", time );
			}
		}

		void Action( Group@ group, Control@ control )
		{
			@group.editControl = control;
			control.vars.set( "last key", -1 );
			control.vars.set( "last key time", getGameTime() );
		}

		void ProcessMouse( Proxy@ proxy, u8 state )
		{
			Control@ control = proxy.control;
			Vec2f mouse = getControls().getMouseScreenPos();
			//print("processMouse control: "+proxy.caption+" state: "+state);

			Vec2f ul = proxy.ul;
			Vec2f lr = proxy.lr;
			
			if (proxy.control.caption != "") {
				Vec2f textDim;
				GUI::GetTextDimensions( proxy.control.caption, textDim );
				ul.y += textDim.y;
			}

			string buttoninfo;
			proxy.control.vars.get( "buttoninfo", buttoninfo );

			if (proxy.selected) 
			{
				UI::Data@ data = UI::getData();
				UI::Control@ mgp = UI::getGroup(data, "Map Gen Preset").controls[0][0];
				mgp.vars.set( "current option", 2 );
				mgp.vars.set( "selected", 2  );
				mgp.caption = "Custom";

				UI::Control@ mgi = UI::getGroup(data, "Map Gen Info").controls[0][0];
				mgi.caption = buttoninfo;
			}
			
			Vec2f pad(3, Maths::Max((lr.y - ul.y - 30) / 2, 3.0));
			Vec2f size = lr - ul - pad * 2;
			Vec2f dim(size.y, size.y);

			float value, minimium, maximum;
			proxy.control.vars.get( "value", value );
			proxy.control.vars.get( "minimium", minimium );
			proxy.control.vars.get( "maximum", maximum );
			Vec2f offset = ul + pad
				+ Vec2f(dim.x + value * (lr - pad - dim * 3 - (ul + pad)).x, 0);

			bool inY = mouse.y > ul.y + pad.y && mouse.y < ul.y + pad.y + dim.y;

			if (state == MouseEvent::DOWN){
				control.vars.delete("drag x");
				if(mouse.x > offset.x && mouse.x < offset.x + dim.x && inY){
					control.vars.set( "drag x", mouse.x - offset.x );
				}
			} else if (state == MouseEvent::HOLD){
				float dragX;
				bool exists = control.vars.get( "drag x", dragX );
				if (exists) {
					float value = ((mouse.x - dragX) - dim.x - ul.x - pad.x) 
					/ (lr - pad - dim * 3 - (ul + pad)).x;
					if (value < minimium)
						value = minimium;
					if (value > maximum)
						value = maximum;

					GENSLIDER_FUNC@ setFunc;
					control.vars.get("set func", @setFunc );
					if (setFunc !is null){
						value = setFunc( value );
					}

					control.vars.set( "value", value );
				}
			} else if (state == MouseEvent::UP){
				if (control.vars.exists("drag x")) {
					control.vars.delete("drag x");
				} else {
					if(mouse.x > ul.x + pad.x && mouse.x < ul.x + pad.x + dim.x && inY)
						Move(proxy.control, true);

					if(mouse.x > lr.x - pad.x - dim.x && mouse.x < lr.x - pad.x && inY)
						Move(proxy.control, false);
				}
			}
		}

		void Move( UI::Control@ control, const bool left )
		{	
			bool altActive = control.vars.get("alt active", altActive) && altActive;
			bool hasValue2 = control.vars.exists( "value2" );

			string valueString = altActive ? "value2" : "value";
			string otherValueString = !altActive ? "value2" : "value";
			string funcString = altActive ? "set func2" : "set func";			

			float increment, value, otherValue, minimium, maximum;
			control.vars.get( valueString, value );
			control.vars.get( otherValueString, otherValue );
			control.vars.get( "increment", increment );
			control.vars.get( "minimium", minimium );
			control.vars.get( "maximum", maximum );
			if ((left ? value : 1 - value) < 0.00001 || increment > 1) return;
			value += (left ? -1 : 1) * increment;
			
			value = Maths::Max(value, minimium);
			value = Maths::Min(value, maximum);

			if (altActive) {
				value = Maths::Max(value, otherValue);
			} else if(hasValue2){
				value = Maths::Min(value, otherValue);
			}

			SLIDER_FUNC@ setFunc;
			control.vars.get(funcString, @setFunc );
			if (setFunc !is null){
				value = setFunc( value );
			}

			control.vars.set( valueString, value );
			Sound::Play("select");			
		}
	}
}

namespace UI
{
	namespace GenScroll
	{
		void Render( Proxy@ proxy )
		{
			if(proxy.control is null) return;

			if (proxy.selected) 
			{
				GUI::DrawRectangle( proxy.ul, proxy.lr, CONTROL_HOVER_COLOR );
			}

			Vec2f ul = proxy.ul;
			Vec2f lr = proxy.lr;
			
			if (proxy.caption != "") {
				Vec2f textDim;
				GUI::GetTextDimensions( proxy.caption, textDim );
				GUI::DrawText( proxy.caption, proxy.ul, proxy.selected ? CAPTION_HOVER_COLOR : CAPTION_COLOR );
				ul.y += textDim.y;
			}

			Vec2f pad(3, Maths::Max((lr.y - ul.y - 30) / 2, 3.0));
			Vec2f size = lr - ul - pad * 2;
			Vec2f dim(size.y, size.y);
			//GUI::DrawPane(ul + pad, lr - pad);
			GUI::DrawRectangle(ul + pad, lr - pad);

			GUI::DrawButton(ul + pad, ul + pad + dim);
			GUI::DrawIcon("MenuArrows.png", 2, Vec2f(7, 7), ul + pad + dim / 2 - Vec2f(3, 3), 0.5);
			GUI::DrawButton(lr - pad - dim, lr - pad);
			GUI::DrawIcon("MenuArrows.png", 3, Vec2f(7, 7), lr - pad - dim / 2 - Vec2f(3, 3), 0.5);

			float value;
			proxy.control.vars.get( "value", value );
			Vec2f offset = ul + pad
				+ Vec2f(dim.x + value * (lr - pad - dim * 3 - (ul + pad)).x, 0);

			if(proxy.group.editControl is proxy.control && getGameTime() % 20 > 10)
				GUI::DrawRectangle(offset, offset + dim);
			else
				GUI::DrawButton(offset, offset + dim);
		}
	}
}
