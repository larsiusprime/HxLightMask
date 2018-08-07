package;

import hxlightmask.FastLightMask;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.ByteArray;
import openfl.Lib;

/**
 * ...
 * @author 
 */
class DemoFastLightMask extends Sprite
{
	static inline var WIDTH:Int = 80;
	static inline var HEIGHT:Int = 60;
	static inline var ZOOM:Int = 10;
	
	private var bmpData:BitmapData;
	private var pixels:ByteArray;
	private var lightmask:FastLightMask;
	private var walls:Array<Float>;
	
	public function new() 
	{
		super();
		
		var back = new Bitmap(new BitmapData(1, 1, false, 0x808080));
		back.scaleX = back.scaleY = ZOOM;
		back.smoothing = false;
		addChild(back);
		
		bmpData = new BitmapData(WIDTH, HEIGHT, true);
		
		var bmp = new Bitmap(bmpData);
		bmp.scaleX = ZOOM;
		bmp.scaleY = ZOOM;
		bmp.smoothing = false;
		addChild(bmp);
		
		demo();
	}
	
	private static inline function OFFSET(x:Int, y:Int)
	{
		return ((WIDTH * 4 * (y)) + (x) * 4);
	}
	
	private function generateNoise(walls:Array<Float>)
	{
		var width:Int = WIDTH;
		var height:Int = HEIGHT;
		
		var num_paths:Int = 20;
		var pathlength:Int = 500;
		var x:Int = Std.int(width / 2);
		var y:Int = Std.int(height / 2);
		
		for (p in 0...num_paths)
		{
			for (i in 0...pathlength)
			{
				var dir:Int = Std.int(Math.random() * 4);
				switch(dir)
				{
					case 0: x -= 1;
					case 1: x += 1;
					case 2: y -= 1;
					case 3: y += 1;
				}
				if (y <= 1 || y >= height-1) y = Std.int(height/2);
				if (x <= 1 || x >= width-1) x = Std.int(width/2);
				
				y = Std.int(Math.min(height - 1, Math.max(1, y)));
				x = Std.int(Math.min(width - 1, Math.max(1, x)));
				walls[x + y * width] = 0.0;
			}
		}
	}
	
	private function demo()
	{
		//var pixels:Array<Int> = [for (i in 0...WIDTH * HEIGHT){0; }];
		var quit = false;
		var mousex = WIDTH / 2;
		var mousey = HEIGHT / 2;
		
		//Init lightmask variables
		
		//The lightmask itself
		lightmask = new FastLightMask(WIDTH, HEIGHT);
		//Intensity: How far light spreads:
		lightmask.setIntensity(40.0);
		//Ambient: Ambient light
		lightmask.setAmbient(0.1);
		
		//Array representing wall opacities (1.0: solid, 0.0:clear)
		walls = [for (i in 0...WIDTH * HEIGHT){1.0; }];
		//Generate cave-like noise using random walk
		generateNoise(walls);
		
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:Event)
	{
		//Get mouse location
		var mousex = Std.int(stage.mouseX / ZOOM);
		var mousey = Std.int(stage.mouseY / ZOOM);
		
		// Lightmask
		
		//Reset the light mask
		lightmask.reset();
		lightmask.addLight(mousex, mousey, 1.0);
		lightmask.addLight(mousex-1, mousey, 1.0);
		lightmask.addLight(mousex+1, mousey, 1.0);
		lightmask.addLight(mousex, mousey-1, 1.0);
		lightmask.addLight(mousex, mousey+1, 1.0);
		lightmask.computeMask(walls);
		
		for (j in 0...WIDTH * HEIGHT)
		{
			var i = j * 4;
			var mask_index = j;
			var brightness = Std.int(lightmask.mask[mask_index] * 255);
			
			var color = brightness | brightness << 8 | Std.int(brightness * walls[mask_index])<< 16 | brightness << 24;
			
			setPix(j, color);
		}
	}
	
	private function setPix(i:Int, color:Int)
	{
		var y:Int = Std.int(i / bmpData.width);
		var x:Int = Std.int(i - (y * bmpData.width));
		bmpData.setPixel(x, y, color);
	}
}