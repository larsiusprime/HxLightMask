package hxlightmask;
import hxlightmask.ShadowMask.Visor;

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
		if (visor.quadrant != Direction.NONE)
		{
			sweepMapQuadrant(walls, visor.x, visor.y, visor.quadrant);
			return;
		}
		
		var visor1 = new Visor(0, 0, 0, 0);
		var visor2 = new Visor(0, 0, 0, 0);
		
		visor.getRotated (-visor.fovRadians/2, visor1);
		visor.getRotated ( visor.fovRadians/2, visor2);
		
		calcVisorDestination(visor);
		calcVisorDestination(visor1);
		calcVisorDestination(visor2);
		
		if (visor1.destY == visor2.destY)
		{
			var lo = visor1.destX;
			var hi = visor2.destX;
			if (visor2.destX < visor1.destX)
			{
				lo = visor2.destX;
				hi = visor1.destX;
			}
			for (x in lo...hi + 1)
			{
				drawLine(walls, visor1.x, visor1.y, x, visor1.destY);
			}
		}
		else if (visor1.destX == visor2.destX)
		{
			var lo = visor1.destY;
			var hi = visor2.destY;
			if (visor2.destY < visor1.destY)
			{
				lo = visor2.destY;
				hi = visor1.destY;
			}
			for (y in lo...hi + 1)
			{
				drawLine(walls, visor1.x, visor1.y, visor1.destX, y);
			}
		}
		else
		{
			var lox = visor1.destX;
			var hix = visor2.destX;
			if (visor2.destX < visor1.destX)
			{
				lox = visor2.destX;
				hix = visor1.destX;
			}
			var loy = visor1.destY;
			var hiy = visor2.destY;
			if (visor2.destY < visor1.destY)
			{
				loy = visor2.destY;
				hiy = visor1.destY;
			}
			
			var destX = 0;
			var destY = 0;
			
			if (visor.destX > visor.x)
			{
				if (visor.destY > visor.y)
				{
					if (visor.destX == visor1.destX)
					{
						destX = visor1.destX;
						destY = visor2.destY;
					}
					else
					{
						if (visor.destY == visor2.destY)
						{
							destX = visor1.destX;
							destY = visor2.destY;
						}
						else
						{
							destX = visor2.destX;
							destY = visor1.destY;
						}
					}
				}
				else if (visor.destY <= visor.y)
				{
					if (visor.destY == visor2.destY)
					{
						destX = visor1.destX;
						destY = visor2.destY;
					}
					else
					{
						if (visor.destX == visor1.destX)
						{
							destX = visor1.destX;
							destY = visor2.destY;
						}
						else
						{
							destX = visor2.destX;
							destY = visor1.destY;
						}
					}
				}
			}
			else
			{
				if (visor.destY < visor.y)
				{
					if (visor.destX == visor2.destX)
					{
						destX = visor2.destX;
						destY = visor1.destY;
					}
					else
					{
						if (visor.destY == visor1.destY)
						{
							destX = visor2.destX;
							destY = visor1.destY;
						}
						else
						{
							destX = visor1.destX;
							destY = visor2.destY;
						}
					}
				}
				else if (visor.destY >= visor.y)
				{
					if (visor.destY == visor2.destY)
					{
						destX = visor1.destX;
						destY = visor2.destY;
					}
					else
					{
						if (visor.destX == visor1.destX)
						{
							destX = visor1.destX;
							destY = visor2.destY;
						}
						else
						{
							destX = visor2.destX;
							destY = visor1.destY;
						}
					}
				}
			}
			
			for (x in lox...hix + 1)
			{
				drawLine(walls, visor.x, visor.y, x, destY);
			}
			for (y in loy...hiy + 1)
			{
				drawLine(walls, visor.x, visor.y, destX, y);
			}
		}
		
		visor.coneX1 = visor1.destX;
		visor.coneY1 = visor1.destY;
		
		visor.coneX2 = visor2.destX;
		visor.coneY2 = visor2.destY;
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
	
	private function sweepMapQuadrant(walls:Array<Int>, ox:Int, oy:Int, direction:Direction)
	{
		switch(direction)
		{
			case Direction.NORTH:
				for (x in 0...width_){
					drawLine(walls, ox, oy, x, 0);
				}
			case Direction.SOUTH:
				for (x in 0...width_){
					drawLine(walls, ox, oy, x, height_ - 1);
				}
			case Direction.WEST:
				for (y in 0...height_){
					drawLine(walls, ox, oy, 0, y);
				}
			case Direction.EAST:
				for (y in 0...height_){
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
			
			if (walls[idx(finalx,y)] == 1) return;
			mask[idx(finalx, y)] = 1;
			
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
			
			if (walls[idx(x,finaly)] == 1) return;
			mask[idx(x, finaly)] = 1;
			
			if (e > 0)
			{
				x = x + xi;
				e = e - 2 * dy;
			}
			e = e + 2 * dx;
		}
	}
}

class Visor
{
	public var x:Int;
	public var y:Int;
	
	public var quadrant:Direction;
	
	public var vecX(default, null):Float;
	public var vecY(default, null):Float;
	
	public var destX:Int = -1;
	public var destY:Int = -1;
	
	public var fovRadians:Float;
	
	public var coneX1:Int = -1;
	public var coneY1:Int = -1;
	
	public var coneX2:Int = -1;
	public var coneY2:Int = -1;
	
	public function new(x:Int, y:Int, vecX:Float, vecY:Float, quadrant:Direction=NONE)
	{
		this.x = x;
		this.y = y;
		this.quadrant = quadrant;
		setLookVector(vecX, vecY);
	}
	
	public function setLookVector(vecX:Float, vecY:Float)
	{
		var magnitude = Math.sqrt(vecX * vecX + vecY * vecY);
		this.vecX = vecX / magnitude;
		this.vecY = vecY / magnitude;
	}
	
	public function getRotated(radians:Float, output:Visor)
	{
		output.x = x;
		output.y = y;
		
		var ca = Math.cos(radians);
		var sa = Math.sin(radians);
		
		output.vecX = ca * vecX - sa * vecY;
		output.vecY = sa * vecX + ca * vecY;
	}
}