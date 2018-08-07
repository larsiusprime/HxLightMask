package;

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
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormatAlign;
import openfl.utils.ByteArray.ByteArrayData;

/**
 * ...
 * @author 
 */
class Main extends Sprite
{
	private var demo:Sprite = null;
	private var currDemo = 0;
	private var MAX_DEMO:Int = 3;
	
	public function new()
	{
		super();
		runDemo(0);
		var txt = new TextField();
		txt.width = Lib.current.stage.width - 500;
		txt.defaultTextFormat.size = 16;
		txt.text = "Press < and > to switch demos. Arrow keys do stuff within (most) demos";
		txt.x = 10;
		txt.y = 550 - txt.textHeight;
		addChild(txt);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
	}
	
	private function onKey(e:KeyboardEvent)
	{
		var s:String = String.fromCharCode(e.charCode);
		switch(s)
		{
			case "<", ",": runDemo( -1);
			case ">", ".": runDemo( 1);
			default: //nothing
		}
	}
	
	private function runDemo(i:Int)
	{
		currDemo += i;
		
		if (currDemo < 0) currDemo = MAX_DEMO;
		else if (currDemo > MAX_DEMO) currDemo = 0;
		
		if (demo != null) 
		{
			cast(demo,IDestroyable).destroy();
			removeChild(demo);
		}
		
		switch(currDemo)
		{
			case 0: demo = new DemoLightAndShadowMask();
			case 1: demo = new DemoFancyLightMask();
			case 2: demo = new DemoShadowMask();
			case 3: demo = new DemoFastLightMask();
			default: //donothing
		}
		
		if (demo != null)
		{
			addChild(demo);
		}
	}
}