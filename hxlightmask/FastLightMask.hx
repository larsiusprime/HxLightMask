package hxlightmask;

/**
 * A tiny flood-fill lighting engine based on @_npaul's original
 * See: https://github.com/nick-paul/LightMask for the original C++ version
 * @author 
 */
class FastLightMask
{
	////////////////////
	//  Data Members  //
	////////////////////
	
	/**The mask: All values range from 0.0 to 1.0**/
	public var mask:Array<Float>;
	
	public function new(width:Int, height:Int) 
	{
		mask = [for (i in 0...(width * height)){0.0; }];
		width_ = width;
		height_ = height;
		intensity_ = 50.0;
		falloff_ = 1.0 / intensity_;
		max_blur_rad_ = 2;
		ambient_ = 0.0;
	}
	
	/**
	 * Reset the mask for redrawing
	 */
	public function reset()
	{
		for (i in 0...mask.length)
		{
			mask[i] = ambient_;
		}
	}
	
	/**
	 * Add a light to the mask
	 * @param	x
	 * @param	y
	 * @param	br
	 */
	public function addLight(x:Int, y:Int, br:Float)
	{
		mask[idx(x, y)] = Math.max(mask[idx(x, y)], br);
	}
	
	/**
	 * Compute the mask
	 * Compute light intensity of a given tile given its neighbors
	 * Apply smoothing functions to make the light less uniform
	 * @param	walls
	 */
	public function computeMask(walls:Array<Float>)
	{
		// Add walls
		for(i in 0...mask.length)
		{
			mask[i] = Math.max(0.0, mask[i] - walls[i]);
		}
		
		// 2 Iterations of forward and backward propagation
		forwardProp(walls);
		backwardProp(walls);
		forwardProp(walls);
		backwardProp(walls);
		
		// Add a small amount of light to all lit walls
		for (i in 0...walls.length)
		{
			if (walls[i] > 0.0 && mask[i] > 0.0) mask[i] = Math.min(1.0, mask[i] + 0.1);
		}
		
		// Max blur
		// To light walls and solid objects
		// To smooth out dark borders between lights
		// Prevents tiles near walls from getting dimmer
		var blurMask1:Array<Float> = [for (i in 0...mask.length){0.0;}];
		blur(mask, blurMask1, max_blur_rad_);
		for (i in 0...mask.length)
		{
			mask[i] = Math.max(mask[i], blurMask1[i]);
		}
		
		// Standard blur
		// To smooth out lighting
		var blurMask2:Array<Float> = [for (i in 0...mask.length){0.0;}];
		blur(mask, blurMask2, 1);
		for (i in 0...mask.length)
		{
			mask[i] = blurMask2[i];	//Apply blur
		}
		
		// All open space should be at least ambient
		for (i in 0...mask.length)
		{
			if (walls[i] == 0.0)
			{
				mask[i] = Math.max(ambient_, mask[i]);
			}
		}
	}
	
	/**
	 * Set global intensity of the light sources
	 * Intensity is a measure of how far lights preads
	 */
	public function setIntensity(i:Float)
	{
		//Must be at least 1
		i = Math.max(1.0, i);
		intensity_ = i;
		falloff_ = 1 / i;
	}
	
	/**
	 * Set ambient light level
	 * All open tiles will be at least this bright
	 */
	public function setAmbient(a:Float)
	{
		//Clip between 0.0 and 1.0
		ambient_ = Math.max(0.0, Math.min(1.0, a));
	}
	 
	private var width_:Int;			// width of the height mask
	private var height_:Int;		// height of the light mask
	private var intensity_:Float;	// how far light spreads
	private var falloff_:Float;		// 1 / intensity
	private var max_blur_rad_:Int;	// blur radius of initial max blur
	private var ambient_:Float;		// 0.0-1.0, Ambient light level, all open tiles will be at least this bright
	
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
	
	/**
	 * Compute light intensity of a given tile given its neighbors
	 * @param	here
	 * @param	neighbor1
	 * @param	neighbor2
	 * @param	wall
	 */
	private function computeIntensity(here:Float, neighbor1:Float, neighbor2:Float, wall:Float)
	{
		var local_falloff:Float = Math.min(1.0, falloff_ + (wall / 10.0));
		
		if (Math.isNaN(neighbor1)) neighbor1 = 0.0;
		if (Math.isNaN(neighbor2)) neighbor2 = 0.0;
		
		neighbor1 = Math.max(here, neighbor1);
		neighbor2 = Math.max(here, neighbor2);
		
		var value = Math.max(0.0, Math.max(neighbor1, neighbor2) - local_falloff);
		return value;
	}
	
	/**
	 * Propogate down and to the right
	 * @param	walls
	 */
	private function forwardProp(walls:Array<Float>)
	{
		for (x in 1...width_)
		{
			//Only compare to pixel on the left
			mask[idx(x, 0)] = computeIntensity(mask[idx(x, 0)], mask[idx(x - 1, 0)], 0.0, walls[idx(x, 0)]);
		}
		for (y in 1...height_)
		{
			//First pixel
			//Only compare to pixel above
			mask[idx(0, y)] = computeIntensity(mask[idx(0, y)], mask[idx(0, y - 1)], 0.0, walls[idx(0, y)]);
			
			//All other pixels: compare to pixel above and to the left
			for (x in 1...width_)
			{
				mask[idx(x, y)] = computeIntensity(
					mask[ idx(x,     y)],
					mask[ idx(x - 1, y)],
					mask[ idx(x,     y - 1)],
					walls[idx(x,     y)]);
			}
		}
	}
	
	/**
	 * Propagate up and to the left
	 * @param	walls
	 */
	private function backwardProp(walls:Array<Float>)
	{
		//Backward prop
		//First (bottom) row
		var x:Int = width_ -1;
		while (x >= 0)
		{
			var y = height_ - 1;
			// Only compare to pixel on the left
			mask[idx(x, y)] = computeIntensity(mask[idx(x, y)], mask[idx(x + 1, y)], 0.0, walls[idx(x, y)]);
			x--;
		}
		var y:Int = height_ -2;
		while (y >= 0)
		{
			var fx:Int = width_ - 1; //first x
			// Last pixel
			// Only compare to the pixel below
			mask[idx(fx, y)] = computeIntensity(mask[idx(fx, y)], mask[idx(fx, y + 1)], 0.0, walls[idx(fx, y)]);
			
			//All other pixels: compare to below and to the right
			var x:Int = width_ -2;
			while (x >= 0)
			{
				mask[idx(x, y)] = computeIntensity(
					mask[ idx(x,     y)],
					mask[ idx(x + 1, y)],
					mask[ idx(x,     y + 1)],
					walls[idx(x,     y)]);
				x--;
			}
			y--;
		}
	}
	
	/**
	 * Apply a simple average blur of `from` onto `to`
	 * @param	from
	 * @param	to
	 * @param	rad
	 */
	private function blur(from:Array<Float>, to:Array<Float>, rad:Int)
	{
		// Number of tiles in the kernel
		var numtiles:Int = ((2 * rad) + 1) * ((2 * rad) + 1);
		
		//Array<Float> blur(width*height, 0.0)
		for(i in rad...width_-rad)
		{
			for(j in rad...height_-rad)
			{
				// Compute the sum of all values in the kernel
				var sum:Float = 0.0;
				for(kx in i-rad...i+rad)
				{
					for(ky in j-rad...j+rad)
					{
						sum += from[kx + ky * width_];
					}
					
					//Average the value
					var avg:Float = sum / numtiles;
					to[i + j * width_] = avg;
				}
			}
		}
	}
}