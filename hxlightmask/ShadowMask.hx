package hxlightmask;

/**
 * A tiny flood-fill lighting engine based on @_npaul's original
 * See: https://github.com/nick-paul/LightMask for the original C++ version
 * @author 
 */
class ShadowMask
{
	////////////////////
	//  Data Members  //
	////////////////////
	
	/**The shadow mask: All values range from 0 to 1**/
	public var mask:Array<Int>;
	public var visors:Array<Visor>;
	
	private var visorPool:VisorPool = new VisorPool();
	
	public function new(width:Int, height:Int) 
	{
		mask = [for (i in 0...(width * height)){0;}];
		width_ = width;
		height_ = height;
		visors = [];
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
		for (v in visors)
		{
			sweepVisor(walls, v);
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
	
	private function sweepVisor(walls:Array<Int>, visor:Visor)
	{
		var oldFovRadians = visor.fovRadians;
		if (Math.abs(visor.fovRadians - Math.PI / 2) < 0.0001 && Math.abs(visor.vecX - visor.vecY) < 0.0001)
		{
			//If the visor angle is EXACTLY 90 degrees AND the look vector is exactly 45 degrees, then there will be a glitch unless we adjust one of the values
			//add a ridiculously tiny amount to the field of view
			visor.fovRadians += 0.000000000001; 
			//we will reset to the original value at the end of the function
		}
		if (visor.quadrant != Direction.NONE)
		{
			//We're sweeping a quadrant rather than a fixed field of view:
			sweepMapQuadrant(walls, visor, visor.quadrant, true);
			return;
		}
		else
		{
			//If our field of view is too broad, split it up and sweep it in pieces:
			var fov = Math.abs(visor.fovRadians);
			
			if (fov > Math.PI / 2)
			{
				var fovEach = visor.fovRadians / 2;
				var visor1 = visorPool.get(visor.x, visor.y, visor.vecX, visor.vecY, fov / 2);
				var visor2 = visorPool.get(visor.x, visor.y, visor.vecX, visor.vecY, fov / 2);
				visor.getRotated( -fov/4, visor1);
				visor.getRotated( fov/4, visor2);
				
				//If either of these is still too broad it will be handled recursively:
				sweepVisor(walls, visor1);
				sweepVisor(walls, visor2);
				
				visorPool.put(visor1);
				visorPool.put(visor2);
				return;
			}
			
			//Do the normal sweeping
			var visor1 = new Visor(0, 0, 0, 0, 0);
			var visor2 = new Visor(0, 0, 0, 0, 0);
			
			visor.getRotated (-visor.fovRadians/2, visor1);
			visor.getRotated ( visor.fovRadians/2, visor2);
			
			calcVisorDestination(visor);
			calcVisorDestination(visor1);
			calcVisorDestination(visor2);
			
			var quadrant1:Direction = NONE;
			var quadrant2:Direction = NONE;
			var quadrant3:Direction = NONE;
			
			     if (visor1.destX == 0) quadrant1 = Direction.WEST;
			else if (visor1.destY == 0) quadrant1 = Direction.NORTH;
			else if (visor1.destX == width_-1) quadrant1 = Direction.EAST;
			else if (visor1.destY == height_ -1) quadrant1 = Direction.SOUTH;
			
			     if (visor2.destX == 0) quadrant2 = Direction.WEST;
			else if (visor2.destY == 0) quadrant2 = Direction.NORTH;
			else if (visor2.destX == width_-1) quadrant2 = Direction.EAST;
			else if (visor2.destY == height_ -1) quadrant2 = Direction.SOUTH;
			
			     if (visor.destX == 0) quadrant3 = Direction.WEST;
			else if (visor.destY == 0) quadrant3 = Direction.NORTH;
			else if (visor.destX == width_-1) quadrant3 = Direction.EAST;
			else if (visor.destY == height_ -1) quadrant3 = Direction.SOUTH;
			
			visor.coneX1 = visor1.destX;
			visor.coneY1 = visor1.destY;
			visor.coneX2 = visor2.destX;
			visor.coneY2 = visor2.destY;
			
			sweepMapQuadrant(walls, visor, quadrant1, false);
			sweepMapQuadrant(walls, visor, quadrant2, false);
			
			if (quadrant3 != quadrant1 && quadrant3 != quadrant2)
			{
				sweepMapQuadrant(walls, visor, quadrant3, true);
				if (Math.abs(quadrant1 - quadrant3) == 2 || Math.abs(quadrant2 - quadrant3) == 2)
				{
					var quadrant4:Direction = (Direction.NORTH + Direction.WEST + Direction.EAST + Direction.SOUTH) - (Std.int(quadrant1) + Std.int(quadrant2) + Std.int(quadrant3));
					sweepMapQuadrant(walls, visor, quadrant4, true);
				}
			}
		}
		visor.fovRadians = oldFovRadians;
	}
	
	/**
	 * Given a visor (location & look vector), calculate the coordinate touching a boundary wall the gaze will terminate on
	 * @param	visor
	 */
	private function calcVisorDestination(visor:Visor)
	{
		var destX:Float = -1;
		var destY:Float = -1;
		
		if(visor.vecX == 0)
		{
			destX = visor.x;
			
			if(visor.vecY > 0) destY = height_-1;
			else if(visor.vecY < 0) destY = 0;
		}
		else if(visor.vecY == 0)
		{
			destY = visor.y;
			
			if(visor.vecX > 0) destX = width_-1;
			else if(visor.vecX < 0) destX = 0;
		}
		else
		{
			var slope = visor.vecY / visor.vecX;
			var invSlope = visor.vecX / visor.vecY;
			
			if (visor.vecX > 0)
			{
				destY = visor.y + (((width_-1) - visor.x) * slope);
			}
			else
			{
				destY = visor.y + (visor.x * -slope);
			}

			if (destY > 0 && destY < height_)
			{
				destX = visor.x + (destY - visor.y) * invSlope;
			}
			else
			{
				if (visor.vecY > 0)
				{
					destX = visor.x + (((height_-1) - visor.y) * invSlope);
				}
				else
				{
					destX = visor.x + (visor.y * -invSlope);
				}
				
				destY = visor.y + (destX - visor.x) * slope;
			}
		}
		
		visor.destX = Math.round(destX);
		visor.destY = Math.round(destY);
	}
	
	private function sweepMapQuadrant(walls:Array<Int>, visor:Visor, direction:Direction, full:Bool)
	{
		var ox = visor.x;
		var oy = visor.y;
		var start = 0;
		var max = 0;
		switch(direction)
		{
			case Direction.NORTH:
				if (full)
				{
					max = width_;
				}
				else if (visor.coneY1 == 0 && visor.coneY2 == 0)
				{
					start = visor.coneX1;
					max = visor.coneX2;
				}
				else if (visor.coneY1 == 0)
				{
					start = visor.coneX1;
					max = width_;
				}
				else if (visor.coneY2 == 0)
				{
					start = 0;
					max = visor.coneX2;
				}
				else
				{
					max = width_;
				}
				for (x in start...max){
					drawLine(walls, ox, oy, x, 0);
				}
			case Direction.SOUTH:
				if (full)
				{
					max = width_;
				}
				else if (visor.coneY1 == height_-1 && visor.coneY2 == height_-1)
				{
					start = visor.coneX2;
					max = visor.coneX1;
				}
				else if (visor.coneY1 == height_-1)
				{
					start = 0;
					max = visor.coneX1;
				}
				else if (visor.coneY2 == height_-1)
				{
					start = visor.coneX2;
					max = width_;
				}
				else
				{
					max = width_;
				}
				for (x in start...max){
					drawLine(walls, ox, oy, x, height_ - 1);
				}
			case Direction.WEST:
				if (full)
				{
					max = height_;
				}
				if (visor.coneX1 == 0 && visor.coneX2 == 0)
				{
					start = visor.coneY2;
					max = visor.coneY1;
				}
				else if (visor.coneX1 == 0)
				{
					start = 0;
					max = visor.coneY1;
				}
				else if (visor.coneX2 == 0)
				{
					start = visor.coneY2;
					max = height_;
				}
				else
				{
					max = height_;
				}
				for (y in start...max){
					drawLine(walls, ox, oy, 0, y);
				}
			case Direction.EAST:
				if (full)
				{
					max = height_;
				}
				if (visor.coneX1 == width_-1 && visor.coneX2 == width_-1)
				{
					start = visor.coneY1;
					max = visor.coneY2;
				}
				else if (visor.coneX1 == width_-1)
				{
					start = visor.coneY1;
					max = height_;
				}
				else if (visor.coneX2 == width_-1)
				{
					start = 0;
					max = visor.coneY2;
				}
				else
				{
					max = height_;
				}
				for (y in start...max){
					drawLine(walls, ox, oy, width_ - 1, y);
				}
			default://donothing
		}
	}
	
	/*************************
	 * Shape drawing functions
	**************************/
	private function drawLine(walls:Array<Int>, x1:Int, y1:Int, x2:Int, y2:Int)
	{
		if (Math.abs(y2 - y1) < Math.abs(x2 - x1))
		{
			if (x1 > x2)
				drawLineEast(walls, x1, y1, x2, y2, true);
			else
				drawLineEast(walls, x1, y1, x2, y2, false);
		}
		else
		{
			if (y1 > y2)
				drawLineSouth(walls, x1, y1, x2, y2, true);
			else
				drawLineSouth(walls, x1, y1, x2, y2, false);
		}
	}
	
	private function drawLineEast(walls:Array<Int>, x1:Int, y1:Int, x2:Int, y2:Int, flip:Bool)
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
			
			mask[idx(finalx, y)] = 1;
			if (walls[idx(finalx,y)] == 1) return;
			
			if (e > 0)
			{
				y = y + yi;
				e = e - 2 * dx;
			}
			e = e + 2 * dy;
		}
	}
	
	private function drawLineSouth(walls:Array<Int>, x1:Int, y1:Int, x2:Int, y2:Int, flip:Bool)
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
			
			mask[idx(x, finaly)] = 1;
			if (walls[idx(x,finaly)] == 1) return;
			
			if (e > 0)
			{
				x = x + xi;
				e = e - 2 * dy;
			}
			e = e + 2 * dx;
		}
	}
}

/**
* Based on HaxeFlixel's FlxPool
*/
class VisorPool
{
	public var length(get, never):Int;
	
	/**
	 * Objects aren't actually removed from the array in order to improve performance.
	 * _count keeps track of the valid, accessible pool objects.
	 */
	var _count:Int = 0;
	var _pool:Array<Visor>;
	
	public function new()
	{
		_pool = [];
		_count = 0;
	}
	
	public function get(x:Int, y:Int, vecX:Float, vecY:Float, fovRadians:Float):Visor
	{
		if (_count == 0)
		{
			return new Visor(x, y, vecX, vecY, fovRadians);
		}
		var v:Visor = _pool[--_count];
		v.x = x;
		v.y = y;
		v.vecX = vecX;
		v.vecY = vecY;
		v.fovRadians = fovRadians;
		return v;
	}
	
	public function put(v:Visor):Void
	{
		// we don't want to have the same object in the accessible pool twice (ok to have multiple in the inaccessible zone)
		if (v != null)
		{
			var i:Int = _pool.indexOf(v);
			// if the object's spot in the pool was overwritten, or if it's at or past _count (in the inaccessible zone)
			if (i == -1 || i >= _count)
			{
				_pool[_count++] = v;
			}
		}
	}
	
	public function putUnsafe(v:Visor):Void
	{
		if (v != null)
		{
			_pool[_count++] = v;
		}
	}
	
	public function clear():Array<Visor>
	{
		_count = 0;
		var oldPool = _pool;
		_pool = [];
		return oldPool;
	}
	
	inline function get_length():Int
	{
		return _count;
	}
}