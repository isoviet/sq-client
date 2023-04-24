package utils
{
	import flash.geom.Point;

	public class GeomUtil
	{
		static public function getAngle(from:Point, to:Point):Number
		{
			var direction:Point = new Point(to.x - from.x, to.y - from.y);

			var angle:Number = Math.atan(direction.y / direction.x);
			angle *= (Game.R2D);
			angle += ((direction.x < 0) ? -1 : 1) * 90;

			return angle;

		}
	}
}