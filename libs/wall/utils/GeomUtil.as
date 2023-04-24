package utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class GeomUtil
	{
		static public function getAngle(from:Point, to:Point):Number
		{
			var direction:Point = new Point(to.x - from.x, to.y - from.y);

			var angle:Number = Math.atan(direction.y / direction.x);
			angle *= (180 / Math.PI);
			angle += ((direction.x < 0) ? -1 : 1) * 90;

			return angle;

		}

		static public function getCenter(sprite:DisplayObject):Point
		{
			return new Point(sprite.x + int(sprite.width / 2), sprite.y + int(sprite.height / 2));
		}

		static public function setCenter(sprite:DisplayObject, center:Point):void
		{
			sprite.x = center.x - int(sprite.width / 2);
			sprite.y = center.y - int(sprite.width / 2);
		}
	}

}