package;

import demo.src.DemoCircle;
import demo.src.DemoFastLightMask;
import demo.src.DemoShadowMask;
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
		
		addChild(new DemoShadowMask());
		//addChild(new DemoLightMask());
		//addChild(new DemoCircle());
	}
}