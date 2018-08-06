package demo.src;
import flash.display.Bitmap;
import flash.display.BitmapData;
import hxlightmask.Direction;
import hxlightmask.ShadowMask;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

/**
 * ...
 * @author 
 */
class DemoShadowMask extends Sprite
{
	private var bmpData:BitmapData;
	
	private var map:Array<Int>;
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
		
		visor = new Visor(64, 64, 1, 1);
		visor.fovRadians = Math.PI / 5;
		shadowMask.addVisor(visor);
		shadowMask.computeMask(walls);
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
		
		//visor.fovRadians += (Math.PI / 360) * sign;
		//visor.getRotated((Math.PI / 360), visor);
		
		/*if (_mx == mx && _my == my)
		{
			return;
		}*/
		
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
		
		map = shadowMask.mask;
		
		for (i in 0...map.length)
		{
			if (map[i] == 1)
			{
				var yy:Int = Std.int(i / _width);
				var xx:Int = i % _width;
				bmpData.setPixel(xx, yy, 0xFFFFFF);
			}
		}
		
		for (i in 0...shadowMask.visors.length)
		{
			var v = shadowMask.visors[i];
			bmpData.setPixel(v.destX,  v.destY,  0xFF0000);
			bmpData.setPixel(v.coneX1, v.coneY1, 0xFF00FF);
			bmpData.setPixel(v.coneX2, v.coneY2, 0xFF00FF);
		}
	}
	
	private inline function idx(x:Int, y:Int):Int { return x + (y * _width); }
	/*
	private function idx(x:Int, y:Int):Int
	{
		return (_width * y) + x;
	}
	
	private function sweepMapQuadrant(ox:Int, oy:Int, direction:Direction)
	{
		switch(direction)
		{
			case Direction.NORTH:
				for (x in 0..._width){
					drawLine(ox, oy, x, 0);
				}
			case Direction.SOUTH:
				for (x in 0..._width){
					drawLine(ox, oy, x, _height - 1);
				}
			case Direction.WEST:
				for (y in 0..._height){
					drawLine(ox, oy, 0, y);
				}
			case Direction.EAST:
				for (y in 0..._height){
					drawLine(ox, oy, _width - 1, y);
				}
		}
	}
	
	private function drawLine(x1:Int, y1:Int, x2:Int, y2:Int)
	{
		if (Math.abs(y2 - y1) < Math.abs(x2 - x1))
		{
			if (x1 > x2)
				drawLineEast(x1, y1, x2, y2, true);
			else
				drawLineEast(x1, y1, x2, y2, false);
		}
		else
		{
			if (y1 > y2)
				drawLineSouth(x1, y1, x2, y2, true);
			else
				drawLineSouth(x1, y1, x2, y2, false);
		}
	}
	
	private function drawLineEast(x1:Int, y1:Int, x2:Int, y2:Int, flip:Bool)
	{
		if (flip)
		{
			x2 = x1 - (x2 - x1);
		}
		
		var dx = x2 - x1;
		var dy = y2 - y1;
		var yi = 1;
		
		if (dy < 0)
		{
			yi = -1;
			dy = -dy;
		}
		
		var y = y1;
		var e = 2 * dy - dx;
		
		for (x in x1...x2 + 1)
		{
			var finalx = x;
			
			if (flip)
			{
				finalx = x1 - (x - x1);
			}
			
			if (walls[idx(finalx,y)] == 1) return;
			map[idx(finalx, y)] = 1;
			
			if (e > 0)
			{
				y = y + yi;
				e = e - 2 * dx;
			}
			e = e + 2 * dy;
		}
	}
	
	private function drawLineSouth(x1:Int, y1:Int, x2:Int, y2:Int, flip:Bool)
	{
		if (flip)
		{
			y2 = y1 - (y2 - y1);
		}
		
		var dx = x2 - x1;
		var dy = y2 - y1;
		var xi = 1;
		
		var x = x1;
		
		if (dx < 0)
		{
			xi = -1;
			dx = -dx;
		}
		
		var e = 2 * dx - dy;
		
		for (y in y1...y2 + 1)
		{
			var finaly = y;
			
			if (flip)
			{
				finaly = y1 - (y - y1);
			}
			
			if (walls[idx(x,finaly)] == 1) return;
			map[idx(x, finaly)] = 1;
			
			if (e > 0)
			{
				x = x + xi;
				e = e - 2 * dy;
			}
			e = e + 2 * dx;
		}
	}
	*/
}