package demo.src;
import flash.display.Bitmap;
import flash.display.BitmapData;
import openfl.display.Sprite;

/**
 * ...
 * @author 
 */
class DemoCircle extends Sprite
{
	private var bmpData:BitmapData;
	
	public function new() 
	{
		super();
		
		drawRings(100, 100, 100);
	}
	
	private function drawRings(cx:Int, cy:Int, r:Int)
	{
		bmpData = new BitmapData(r * 2, r * 2, false);
		var bmp = new Bitmap(bmpData);
		bmp.x = 10;
		bmp.y = 10;
		addChild(bmp);
		
		var kinks:Array<Int> = [0];
		
		var c:Int = 0;
		for (i in 1...r+1)
		{
			c = 255 - Std.int(255 * (i / r));
			c = c << 16 | c << 8 | c;
			drawRing(cx, cy, i, c, kinks);
		}
	}
	
	/**
	 * Draw a ring -- for space-filling concentric circles one after another with no overlap
	 * @param	cx	center x point
	 * @param	cy	center y point
	 * @param	r	radius
	 * @param	c	color
	 * @param	k	kinks array
	 */
	private function drawRing(cx:Int, cy:Int, r:Int, c:Int, kinks:Array<Int>)
	{
		var y:Int = r;
		var x:Int = 0;
		var e:Int = 1;
		var kinki = 0;
		
		while (y >= x)
		{
			if (e > 0)
			{
				e -= (y + y - 1);
				y--;
				
				if(x > 0)
				{
					if (kinki < kinks.length && kinks[kinki] != x)
					{
						_setReflectPixel(cx, cy, x-1, y, bmpData, c);
					}
					kinks[kinki] = x;
					kinki++;
				}
			}
			
			_setReflectPixel(cx, cy, x, y, bmpData, c);
			
			e += (x + x + 1);
			x++;
		}
	}
	
	/**
	 * Draw a circle
	 * @param	cx	center x point
	 * @param	cy	center y point
	 * @param	r	radius
	 * @param	c	color
	 */
	private function drawCircle(cx:Int, cy:Int, r:Int, c:Int)
	{
		var y:Int = r;
		var x:Int = 0;
		var e:Int = 1;
		
		while (y >= x)
		{
			if (e > 0)
			{
				e -= (y + y - 1);
				y--;
			}
			
			_setReflectPixel(cx, cy, x, y, bmpData, c);
			
			e += (x + x + 1);
			x++;
		}
	}
	
	private inline function _setReflectPixel(cx:Int, cy:Int, x:Int, y:Int, bmp:BitmapData, l:Int)
	{
		var nx = -(x + 1);
		var ny = -(y + 1);
		
		bmp.setPixel(cx+ x, cy+ y, l);
		bmp.setPixel(cx+ y, cy+ x, l);
		
		bmp.setPixel(cx+nx, cy+ y, l);
		bmp.setPixel(cx+ y, cy+nx, l);
		
		bmp.setPixel(cx+ x, cy+ny, l);
		bmp.setPixel(cx+ny, cy+ x, l);
		
		bmp.setPixel(cx+nx, cy+ny, l);
		bmp.setPixel(cx + ny, cy + nx, l);
	}
	
}