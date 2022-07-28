#include "UI.as"
#include "UICommonUpdates.as"


namespace UI
{
	namespace MapInfo
	{
		Control@ Add(string s)
		{
			//string caption;
			//caption = "Map Preview can be dragged and scaled.";
			
			Control@ control = AddControl( "" );
			control.selectable = false;
			control.vars.set( "map", s );
			Data@ data = getData();
			@control.proxy = AddProxy( data, Render, NoTransitionUpdate, data.activeGroup, control, 1 );
			return control;
		}

		void Render( Proxy@ proxy ){
			if(proxy.control is null) return;

			string s;
			proxy.control.vars.get( "map", s );

			RenderCaption(@proxy);			
			
			Vec2f dim, pos;
			string text;

			text = s;
			GUI::GetTextDimensions( text, dim );
			pos = proxy.ul + Vec2f( Maths::Max((proxy.lr.x - proxy.ul.x - dim.x)/2, 0.0), 0 );
			GUI::DrawText( text, pos, proxy.lr, CAPTION_COLOR, false, false );

			Vec2f imagedim;
			GUI::GetImageDimensions( s, imagedim );

			string mapWord, pingWord;
			if (imagedim.x > 500) {
				mapWord = "HUGE";
			}
			  else if (imagedim.x > 400) {
				mapWord = "LARGE";
			} else if (imagedim.x > 200) {
				mapWord = "MEDIUM";
			} else if (imagedim.x > 100) {
				mapWord = "SMALL";
			} else {
				mapWord = "TINY";
			}

			text = ("Map size: " + imagedim.x + "x" + imagedim.y +  " (" + mapWord + ")\n\n");
			GUI::GetTextDimensions( text, dim );
			pos = proxy.ul + Vec2f( 40, (proxy.lr.y - proxy.ul.y)*0.69 );
			GUI::DrawText( text, pos, CAPTION_COLOR );

			//text = s;
			//GUI::GetTextDimensions( text, dim );
			//pos = proxy.ul + Vec2f( 0, (proxy.lr.y - proxy.ul.y)*0.84 );
			//GUI::DrawText( text, pos, proxy.lr, CAPTION_COLOR, false, false );
		}
	}
}