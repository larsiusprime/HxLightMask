package hxlightmask;
import hxlightmask.FancyLightMask.LightDecay;
import hxlightmask.ShadowMask.Visor;

/**
 * A tiny flood-fill lighting engine based on @_npaul's original
 * See: https://github.com/nick-paul/LightMask for the original C++ version
 * @author 
 */
class FancyLightMask
{
	////////////////////
	//  Data Members  //
	////////////////////
	
	/**The light mask: All values range from 0 to 255**/
	public var mask:Array<Int>;
	
	public var lights:Array<Light>;
	public var visors:Array<Visor>;
	
	public function new(width:Int, height:Int) 
	{
		mask = [for (i in 0...(width * height)){0;}];
		width_ = width;
		height_ = height;
		visors = [];
		lights = [];
	}
	
	/**
	 * Reset the mask for redrawing
	 */
	public function reset()
	{
		for (i in 0...mask.length)
		{
			mask[i] = 0;
		}
	}
	
	public function addLight(l:Light)
	{
		lights.push(l);
	}
	
	public function removeLight(l:Light)
	{
		lights.remove(l);
	}
	
	public function clearLights()
	{
		lights.splice(0, lights.length);
	}
	
	/**
	 * Add a visor to the mask
	 * @param	x
	 * @param	y
	 * @param	br
	 */
	public function addVisor(v:Visor)
	{
		visors.push(v);
	}
	
	public function removeVisor(v:Visor)
	{
		visors.remove(v);
	}
	
	public function clearVisors()
	{
		visors.splice(0, visors.length);
	}
	
	/**
	 * Compute the mask
	 * Compute which tiles are visible from any of the visors
	 * @param	walls
	 */
	public function computeMask(walls:Array<Int>)
	{
		for (l in lights)
		{
			computeLight(l, walls);
		}
	}
	 
	private var width_:Int;			// width of the height mask
	private var height_:Int;		// height of the light mask
	
	///////////////////////////////////////
	// Mask Computation Helper Functions //
	///////////////////////////////////////
	
	/**
	 * Helper function for accessing 1d arrays using 2d coordinates
	 * @param	x
	 * @param	y
	 * @return
	 */
	private inline function idx(x:Int, y:Int):Int { return x + (y * width_); }
	private inline function idxw(x:Int, y:Int, w:Int):Int { return x + (y * w); }
	
	private function clipMap(other:Array<Int>, x:Int, y:Int, width:Int, height:Int, otherw:Int):Array<Int>
	{
		var map = [for (i in 0...width * height){0; }];
		
		for (iy in 0...height){
			for (ix in 0...width){
				map[idxw(ix, iy, width)] = other[idxw(x + ix, y + iy, otherw)];
			}
		}
		return map;
	}
	
	private function computeLight(l:Light, walls:Array<Int>)
	{
		var kinks:Array<Int> = [0];
		
		var intensity:Float = l.intensity;
		var decayType:LightDecay = l.decayType;
		var decay:Float = l.decay;
		
		var max = width_ > height_ ? width_ : height_;
		var radius:Int = l.getRadius(max);
		
		var cx = l.x;
		var cy = l.y;
		
		var ulx = l.x - radius;
		var uly = l.y - radius;
		var lrx = l.x + radius;
		var lry = l.y + radius;
		var lx = cx - ulx;
		var ly = cy - uly;
		
		if (ulx < 0) 
		{
			ulx = 0;
			lx += ulx;
		}
		if (uly < 0)
		{
			uly = 0;
			ly += uly;
		}
		if (lrx >= width_) lrx = width_-1;
		if (lry >= height_) lry = height_-1;
		var myW = lrx - ulx;
		var myH = lry - uly;
		
		var myWalls = clipMap(walls, ulx, uly, myW, myH, width_);
		
		var s:ShadowMask = new ShadowMask(myW, myH);
		s.addVisor(new Visor(lx, ly, 0, 0, Direction.NORTH));
		s.addVisor(new Visor(lx, ly, 0, 0, Direction.EAST));
		s.addVisor(new Visor(lx, ly, 0, 0, Direction.SOUTH));
		s.addVisor(new Visor(lx, ly, 0, 0, Direction.WEST));
		s.computeMask(myWalls);
		
		var myLight = [for (i in 0...myW * myH){0; }];
		
		s.computeMask(myWalls);
		
		drawRings(lx, ly, radius, myLight, myW, intensity, decay, decayType);
		
		for (iy in 0...myH)
		{
			for (ix in 0...myW)
			{
				var xx = ix + ulx;
				var yy = iy + uly;
				
				if (xx < 0) continue;
				if (yy < 0) continue;
				if (xx >= width_) continue;
				if (yy >= height_) continue;
				
				mask[idx(xx, yy)] += (s.mask[idxw(ix, iy, myW)] == 1) ? myLight[idxw(ix, iy, myW)] : 0;
			}
		}
	}
	
	/*************************
	 * Shape drawing functions
	**************************/
	
	private function castRay(walls:Array<Int>, x1:Int, y1:Int, x2:Int, y2:Int, output:Array<Int>, w:Int, intensity:Float, decay:Float, decayType:LightDecay)
	{
		if (Math.abs(y2 - y1) < Math.abs(x2 - x1))
		{
			if (x1 > x2)
				castRayEast(walls, x1, y1, x2, y2, true, output, w, intensity, decay, decayType);
			else
				castRayEast(walls, x1, y1, x2, y2, false, output, w, intensity, decay, decayType);
		}
		else
		{
			if (y1 > y2)
				castRaySouth(walls, x1, y1, x2, y2, true, output, w, intensity, decay, decayType);
			else
				castRaySouth(walls, x1, y1, x2, y2, false, output, w, intensity, decay, decayType);
		}
	}
	
	private function castRayEast(walls:Array<Int>, x1:Int, y1:Int, x2:Int, y2:Int, flip:Bool, output:Array<Int>, w:Int, intensity:Float, decay:Float, decayType:LightDecay)
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
		
		var c:Int = 255;
		
		for (x in x1...x2 + 1)
		{
			c = Std.int(255 * intensity);
			intensity = switch(decayType)
			{
				case LINEAR: intensity - decay;
				case QUADRATIC: intensity * (1 - decay);
				case CUBIC: intensity * (1 - decay) * (1 - decay);
				default: intensity; //donothing
			}
			
			var finalx = x;
			
			if (flip)
			{
				finalx = x1 - (x - x1);
			}
			
			if (walls[idxw(finalx,y,w)] == 1) return;
			output[idxw(finalx, y,w)] = c;
			
			if (e > 0)
			{
				y = y + yi;
				e = e - 2 * dx;
			}
			e = e + 2 * dy;
		}
	}
	
	private function castRaySouth(walls:Array<Int>, x1:Int, y1:Int, x2:Int, y2:Int, flip:Bool, output:Array<Int>, w:Int, intensity:Float, decay:Float, decayType:LightDecay)
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
		
		var c:Int = 255;
		
		for (y in y1...y2 + 1)
		{
			c = Std.int(255 * intensity);
			intensity = switch(decayType)
			{
				case LINEAR: intensity - decay;
				case QUADRATIC: intensity * (1 - decay);
				case CUBIC: intensity * (1 - decay) * (1 - decay);
				default: intensity;//donothing
			}
			
			var finaly = y;
			
			if (flip)
			{
				finaly = y1 - (y - y1);
			}
			
			if (walls[idxw(x,finaly,w)] == 1) return;
			output[idxw(x, finaly,w)] = c;
			
			if (e > 0)
			{
				x = x + xi;
				e = e - 2 * dy;
			}
			e = e + 2 * dx;
		}
	}
	
	private function drawRings(cx:Int, cy:Int, r:Int, map:Array<Int>, w:Int, intensity:Float, decay:Float, decayType:LightDecay)
	{
		var kinks:Array<Int> = [0];
		
		var c:Int = 0;
		for (i in 1...r+1)
		{
			c = Std.int(255 * intensity);
			drawRing(cx, cy, i, w, c, kinks, map);
			intensity = switch(decayType)
			{
				case LINEAR: intensity - decay;
				case QUADRATIC: intensity * (1 - decay);
				case CUBIC: intensity * ((1 - decay) * (1 - decay));
				default: intensity;
			}
		}
	}
	
	private function drawRing(cx:Int, cy:Int, r:Int, w:Int, col:Int, kinks:Array<Int>, map:Array<Int>):Bool
	{
		var y:Int = r;
		var x:Int = 0;
		var e:Int = 1;
		var kinki = 0;
		
		var pixels:Int = 0;
		
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
						pixels += _setReflectPoint(cx, cy, x-1, y, w, col, map);
					}
					kinks[kinki] = x;
					kinki++;
				}
			}
			
			pixels += _setReflectPoint(cx, cy, x, y, w, col, map);
			
			e += (x + x + 1);
			x++;
		}
		
		return pixels > 0;
	}
	
	private inline function _setReflectPoint(cx:Int, cy:Int, x:Int, y:Int, w:Int, col:Int, map:Array<Int>):Int
	{
		var nx = -(x + 1);
		var ny = -(y + 1);
		
		var i = 0;
		
		i += _setMapPt(cx + x,  cy + y, w, map, col);
		i += _setMapPt(cx + y,  cy + x, w, map, col);
		
		i += _setMapPt(cx + nx, cy + y, w, map, col);
		i += _setMapPt(cx + y,  cy + nx,w, map, col);
		
		i += _setMapPt(cx + x,  cy + ny,w, map, col);
		i += _setMapPt(cx + ny, cy + x, w, map, col);
		
		i += _setMapPt(cx + nx, cy + ny,w, map, col);
		i += _setMapPt(cx + ny, cy + nx,w, map, col);
		
		return i;
	}
	
	private inline function _setMapPt(x:Int, y:Int, w:Int, map:Array<Int>, value:Int):Int
	{
		if (x < 0) return 0;
		if (x >= width_) return 0;
		if (y < 0) return 0;
		if (y >= height_) return 0;
		var i = idxw(x, y, w);
		map[i] = value;
		return 1;
	}
}

@:enum abstract LightDecay(Int) from Int to Int
{
	var LINEAR:Int = 0;
	var QUADRATIC:Int = 1;
	var CUBIC:Int = 2;
	var NONE:Int = -3;
}

class Light
{
	public var x:Int;
	public var y:Int;
	
	public var intensity:Float;
	public var decay(default, set):Float;
	public var decayType:LightDecay = LINEAR;
	
	public var visor:Visor;
	
	public function new(x:Int, y:Int, intensity:Float, decay:Float, decayType:LightDecay=LINEAR, ?visor:Visor)
	{
		this.x = x;
		this.y = y;
		this.intensity = intensity;
		this.decay = decay;
		this.decayType = decayType;
		this.visor = visor;
	}
	
	private function set_decay(f:Float):Float
	{
		if (f > 1.0) f = 1.0;
		decay = f;
		return decay;
	}
	
	public function getRadius(max:Int):Int
	{
		if (intensity == 0) return 0;
		var idecay = 1-decay;
		var r = 0;
		var i = intensity;
		for(j in 0...max)
		{
			r++;
			switch(decayType)
			{
				case LINEAR: i -= decay;
				case QUADRATIC: i -= idecay * idecay;
				case CUBIC: i -= idecay * idecay * idecay;
				default://donothing
			}
			if (Std.int(i * 255) < 1) {
				return r;
			}
		}
		return r;
	}
}