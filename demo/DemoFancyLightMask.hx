package demo;
import flash.display.Bitmap;
import flash.display.BitmapData;
import hxlightmask.Direction;
import hxlightmask.FancyLightMask;
import hxlightmask.Light;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

/**
 * ...
 * @author 
 */
class DemoFancyLightMask extends Sprite
{
	private var bmpData:BitmapData;
	
	private var lights:Array<Int>;
	private var walls:Array<Int>;
	
	private var _width:Int = 128;
	private var _height:Int = 128;
	
	private var light:Light;
	private var lightMask:FancyLightMask;
	
	private var mx:Int = 0;
	private var my:Int = 0;
	
	public function new() 
	{
		super();
		
		walls = [for (i in 0..._width * _height) {0; }];
		
		//West
		walls[idx(64 - 10, 64 + 7)] = 1;
		walls[idx(64 - 10, 64 + 6)] = 1;
		walls[idx(64 - 10, 64 + 5)] = 1;
		walls[idx(64 - 10, 64 + 4)] = 1;
		walls[idx(64 - 10, 64 + 3)] = 1;
		walls[idx(64 - 10, 64 + 2)] = 1;
		
		walls[idx(64 - 10, 64 - 7)] = 1;
		walls[idx(64 - 10, 64 - 6)] = 1;
		walls[idx(64 - 10, 64 - 5)] = 1;
		walls[idx(64 - 10, 64 - 4)] = 1;
		walls[idx(64 - 10, 64 - 3)] = 1;
		walls[idx(64 - 10, 64 - 2)] = 1;
		
		//North
		walls[idx(64 - 2, 64 - 10)] = 1;
		walls[idx(64 - 3, 64 - 10)] = 1;
		walls[idx(64 - 4, 64 - 10)] = 1;
		walls[idx(64 - 5, 64 - 10)] = 1;
		walls[idx(64 - 6, 64 - 10)] = 1;
		walls[idx(64 - 7, 64 - 10)] = 1;
		
		walls[idx(64 + 2, 64 - 10)] = 1;
		walls[idx(64 + 3, 64 - 10)] = 1;
		walls[idx(64 + 4, 64 - 10)] = 1;
		walls[idx(64 + 5, 64 - 10)] = 1;
		walls[idx(64 + 6, 64 - 10)] = 1;
		walls[idx(64 + 7, 64 - 10)] = 1;
		
		//East
		walls[idx(64 + 10, 64 + 7)] = 1;
		walls[idx(64 + 10, 64 + 6)] = 1;
		walls[idx(64 + 10, 64 + 5)] = 1;
		walls[idx(64 + 10, 64 + 4)] = 1;
		walls[idx(64 + 10, 64 + 3)] = 1;
		walls[idx(64 + 10, 64 + 2)] = 1;
		
		walls[idx(64 + 10, 64 - 7)] = 1;
		walls[idx(64 + 10, 64 - 6)] = 1;
		walls[idx(64 + 10, 64 - 5)] = 1;
		walls[idx(64 + 10, 64 - 4)] = 1;
		walls[idx(64 + 10, 64 - 3)] = 1;
		walls[idx(64 + 10, 64 - 2)] = 1;
		
		//South
		walls[idx(64 - 2, 64 + 10)] = 1;
		walls[idx(64 - 3, 64 + 10)] = 1;
		walls[idx(64 - 4, 64 + 10)] = 1;
		walls[idx(64 - 5, 64 + 10)] = 1;
		walls[idx(64 - 6, 64 + 10)] = 1;
		walls[idx(64 - 7, 64 + 10)] = 1;
		
		walls[idx(64 + 2, 64 + 10)] = 1;
		walls[idx(64 + 3, 64 + 10)] = 1;
		walls[idx(64 + 4, 64 + 10)] = 1;
		walls[idx(64 + 5, 64 + 10)] = 1;
		walls[idx(64 + 6, 64 + 10)] = 1;
		walls[idx(64 + 7, 64 + 10)] = 1;
		
		var bw = _width;
		var bh = _height;
		bmpData = new BitmapData(bw, bh, false, 0);
		var bmp = new Bitmap(bmpData);
		addChild(bmp);
		
		bmp.scaleX = 4;
		bmp.scaleY = 4;
		
		lightMask = new FancyLightMask(_width, _height);
		
		light = new Light(64, 64, 1, 0.025);
		lightMask.addLight(light);
		lightMask.computeMask(walls);
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		draw();
	}
	
	private var ticks:Int = 0;
	private var sign:Int = 1;
	private function onEnterFrame(e:Event)
	{
		var _mx = Std.int(mouseX / 4);
		var _my = Std.int(mouseY / 4);
		
		if (_mx < 0) _mx = 0; 
		if (_mx >= bmpData.width) _mx = bmpData.width - 2;
		if (_my < 0) _my = 0;
		if (_my >= bmpData.height) _my = bmpData.height - 2;
		
		ticks++;
		if (ticks >= 60)
		{
			sign *= -1;
			ticks = 0;
		}
		
		mx = _mx;
		my = _my;
		
		light.x = mx;
		light.y = my;
		
		draw();
	}
	
	private function draw()
	{
		bmpData.fillRect(bmpData.rect, 0);
		
		lightMask.reset();
		lightMask.computeMask(walls);
		
		lights = lightMask.mask;
		
		for(i in 0...walls.length)
		{
			if (walls[i] == 1)
			{
				var yy:Int = Std.int(i / _width);
				var xx:Int = i % _width;
				bmpData.setPixel(xx, yy, 0xFF0000);
			}
		}
		
		for (i in 0...lights.length)
		{
			if (lights[i] > 0)
			{
				var yy:Int = Std.int(i / _width);
				var xx:Int = i % _width;
				var c:Int = lights[i];
				c = c << 16 | c << 8 | c;
				bmpData.setPixel(xx, yy, c);
			}
		}
	}
	
	private inline function idx(x:Int, y:Int):Int { return x + (y * _width); }
	
}