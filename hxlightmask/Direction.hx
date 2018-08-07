package hxlightmask;

/**
 * ...
 * @author 
 */
@:enum abstract Direction(Int) from Int to Int {
	
	var NORTH:Int = 0;
	var EAST:Int = 1;
	var SOUTH:Int = 2;
	var WEST:Int = 3;
	var NONE:Int = -1;
	
	public static function countSpan(left:Direction, right:Direction):Int
	{
		if (left == right) return 0;
		left = clamp(left);
		right = clamp(right);
		if (Std.int(left) < Std.int(right))
		{
			return right - left;
		}
		else
		{
			return clamp(right - left);
		}
		return 0;
	}
	
	public function toString():String
	{
		return switch(this){
			case NORTH: "north";
			case WEST: "west";
			case EAST: "east";
			case SOUTH: "south";
			default: "none";
		}
	}

	public static function clamp(i:Int):Direction
	{
		if(i >= 0)
		{
			return (i % 4);
		}
			
		else
		{
			return (i % 4) + 4;
		}
	}
}