package;

import DemoCircle;
import DemoFastLightMask;
import DemoFancyLightMask;
import DemoLightAndShadowMask;
import DemoShadowMask;
import Main;
import flash.display.BitmapData;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Lib;
import hxlightmask.FastLightMask;
import openfl.events.Event;
import openfl.utils.ByteArray.ByteArrayData;

/**
 * ...
 * @author 
 */
class Main extends Sprite
{
	public function new()
	{
		super();
		
		addChild(new DemoLightAndShadowMask());
		//addChild(new DemoFancyLightMask());
		//addChild(new DemoShadowMask());
		//addChild(new DemoFastLightMask());
		//addChild(new DemoCircle());
	}
}