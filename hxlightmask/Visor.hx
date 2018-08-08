package hxlightmask;

/**
 * ...
 * @author 
 */

@:allow(hxlightmask.FancyLightMask)
@:allow(hxlightmask.ShadowMask)
class Visor
{
	public var x:Int;
	public var y:Int;
	
	public var vecX(default, null):Float;
	public var vecY(default, null):Float;
	
	public var destX:Int = -1;
	public var destY:Int = -1;
	
	public var fovRadians(default, set):Float;
	
	public var coneX1:Int = -1;
	public var coneY1:Int = -1;
	
	public var coneX2:Int = -1;
	public var coneY2:Int = -1;
	
	public function new(x:Int, y:Int, vecX:Float, vecY:Float, fovRadians:Float)
	{
		this.x = x;
		this.y = y;
		setLookVector(vecX, vecY);
		this.fovRadians = fovRadians;
	}
	
	public function set_fovRadians(r:Float):Float
	{
		if (r > Math.PI/2) r = Math.PI/2;
		if (r < -Math.PI/2) r = -Math.PI/2;
		fovRadians = r;
		return r;
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
	
	//internal use only:
	private var quadrant:Direction=Direction.NONE;
	
	@:access(hxlightmask.Visor)
	private static function forQuadrant(x:Int, y:Int, quadrant:Direction)
	{
		var v = new Visor(x, y, 0, 0, 0);
		v.quadrant = quadrant;
		return v;
	}
}