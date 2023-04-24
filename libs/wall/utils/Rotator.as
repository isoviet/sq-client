package utils
{
	import flash.geom.Point;
	/**
	 * @author Bartek Drozdz (http://www.everydayflash.com)
	 * @version 1.0
	 */

	public class Rotator
	{
		private var target:Object;
		private var offset:Number;
		private var point:Point;
		private var dist:Number;

		public function Rotator(target:Object, registrationPoint:Point = null):void
		{
			set(target, registrationPoint);
		}

		public function set(target:Object, registrationPoint:Point = null):void
		{
			this.target = target;

			setRegistrationPoint(registrationPoint);
		}

		public function setRegistrationPoint(registrationPoint:Point=null):void
		{
			if (registrationPoint == null)
				this.point = new Point(this.target.x, this.target.y);
			else
				this.point = registrationPoint;

			var dx:Number = this.point.x - this.target.x;
			var dy:Number = this.point.y - this.target.y;

			var a:Number = Math.atan2(dy, dx) * 180 / Math.PI;

			this.dist = Math.sqrt(dx * dx + dy * dy);
			this.offset = 180 - a + this.target.rotation;
		}

		public function set rotation(angle:Number):void
		{
			var tp:Point = new Point(this.target.x, this.target.y);

			var ra:Number = (angle - this.offset) * Math.PI / 180;

			this.target.x = this.point.x + Math.cos(ra) * dist;
			this.target.y = this.point.y + Math.sin(ra) * dist;

			this.target.rotation = angle;
		}

		public function get rotation():Number
		{
			return this.target.rotation;
		}

		public function rotateBy(angle:Number):void
		{
			var tp:Point = new Point(this.target.x, this.target.y);

			var ra:Number = (this.target.rotation + angle - this.offset) * Math.PI / 180;

			this.target.x = this.point.x + Math.cos(ra) * this.dist;
			this.target.y = this.point.y + Math.sin(ra) * this.dist;

			this.target.rotation = this.target.rotation + angle;
		}
	}
}