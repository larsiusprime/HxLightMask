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
}