package;

import flash.display.Bitmap;
import flash.display.BitmapData;
import hxlightmask.Direction;
import hxlightmask.ShadowMask;
import hxlightmask.Visor;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

/**
 * ...
 * @author 
 */
class DemoShadowMask extends Sprite implements IDestroyable
{
	private var bmpData:BitmapData;
	
	private var shadows:Array<Int>;
	private var lights:Array<Int>;
	private var walls:Array<Int>;
	
	private var _width:Int = 128;
	private var _height:Int = 128;
	
	private var visor:Visor;
	private var shadowMask:ShadowMask;
	
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
		
		shadowMask = new ShadowMask(_width, _height);
		
		visor = new Visor(64, 64, 1, 1, Math.PI / 5);
		shadowMask.addVisor(visor);
		shadowMask.computeMask(walls);
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	public function destroy()
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onKeyDown(e:KeyboardEvent)
	{
		if (e.keyCode == 37) 
		{
			visor.getRotated((-Math.PI / 180), visor);
		}
		else if (e.keyCode == 39)
		{
			visor.getRotated((Math.PI / 180), visor);
		}
		
		if (e.keyCode == 38)
		{
			visor.fovRadians += (Math.PI / 180);
		}
		else if (e.keyCode == 40)
		{
			visor.fovRadians -= (Math.PI / 180);
		}
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
		
		visor.x = mx;
		visor.y = my;
		
		shadowMask.reset();
		
		shadowMask.computeMask(walls);
		
		
		draw();
	}
	
	private function draw()
	{
		bmpData.fillRect(bmpData.rect, 0);
		
		for(i in 0...walls.length)
		{
			if (walls[i] == 1)
			{
				var yy:Int = Std.int(i / _width);
				var xx:Int = i % _width;
				bmpData.setPixel(xx, yy, 0xFF0000);
			}
		}
		
		shadows = shadowMask.mask;
		
		for (i in 0...shadows.length)
		{
			if (shadows[i] == 1)
			{
				var yy:Int = Std.int(i / _width);
				var xx:Int = i % _width;
				bmpData.setPixel(xx, yy, 0xFFFFFF);
			}
		}
		
		bmpData.setPixel(visor.coneX1, visor.coneY1, 0xFF0000);
		bmpData.setPixel(visor.coneX2, visor.coneY2, 0x00FF00);
		bmpData.setPixel(visor.destX, visor.destY, 0xFF00FF);
	}
	
	private inline function idx(x:Int, y:Int):Int { return x + (y * _width); }
	
}