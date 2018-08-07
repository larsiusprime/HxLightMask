package hxlightmask;

/**
 * ...
 * @author 
 */

class Light
{
	public var x:Int;
	public var y:Int;
	
	public var intensity:Float;
	public var decay(default, set):Float;
	
	public var visor:Visor;
	
	public function new(x:Int, y:Int, intensity:Float, decay:Float, ?visor:Visor)
	{
		this.x = x;
		this.y = y;
		this.intensity = intensity;
		this.decay = decay;
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
		r = Math.ceil(intensity/decay);
		return r;
	}
}