package game.mainGame
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	import utils.GeomUtil;

	public class ShamanDeathAnimation extends Sprite
	{
		static private const DELTA_ROTATION:int = 10;

		private var animationObject:Bitmap = null;

		private var toCoord:Point = null;
		private var speed:int = 0;

		private var isRotating:Boolean = false;

		public function ShamanDeathAnimation(object:Bitmap, speed:int):void
		{
			this.animationObject = object;
			this.animationObject.x = - int(this.animationObject.width / 2);
			this.animationObject.y = - int(this.animationObject.height / 2);
			this.animationObject.scaleX = 0.8;
			this.animationObject.scaleY = 0.8;
			addChild(this.animationObject);

			this.toCoord = new Point(0, 0);
			this.speed = speed;
		}

		public function motionTo(to:Point):void
		{
			this.toCoord = to;
			EnterFrameManager.addListener(onMotion);
		}

		public function setPosition(x:int, y:int):void
		{
			this.x = x;
			this.y = y;
		}

		public function stopMotion():void
		{
			EnterFrameManager.removeListener(onMotion);
			EnterFrameManager.removeListener(onRotation);
			this.isRotating = false;
			dispatchEvent(new Event("Finished"));
		}

		private function onMotion():void
		{
			if (this.animationObject == null)
			{
				stopMotion();
				return;
			}

			var direction:Point = toCoord.subtract(new Point(this.x, this.y));

			this.isRotating = (direction.length < 3 * this.speed);

			if (this.isRotating)
				EnterFrameManager.addListener(onRotation);

			var l:int = direction.length;

			direction.normalize(isRotating ? l / 2 : speed);

			this.x += direction.x;
			this.y += direction.y;

			if (this.isRotating)
				return;

			this.rotation = GeomUtil.getAngle(new Point(this.x, this.y), this.toCoord);
			EnterFrameManager.removeListener(onRotation);
		}

		private function onRotation():void
		{
			if (this.rotation == 0)
			{
				stopMotion();
				return;
			}

			if (Math.abs(this.rotation) < 2 * DELTA_ROTATION)
			{
				this.rotation = 0;
				return;
			}

			this.rotation += (this.rotation > 0 ? -DELTA_ROTATION : DELTA_ROTATION);
		}
	}
}