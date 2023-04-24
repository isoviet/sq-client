package game.mainGame.entity.water
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import utils.starling.StarlingAdapterSprite;

	public class WaterParticle extends StarlingAdapterSprite
	{
		private var _level:Number;
		private var drag:Boolean;
		public var velocity:Number;

		public function WaterParticle(height:Number = 0, velocity:Number = 0):void
		{
			this.level = height;
			this.velocity = velocity;
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}

		public function copy():WaterParticle
		{
			return new WaterParticle(level, velocity);
		}

		public function update(timeStep:Number):void
		{
			this.level = -Math.abs(this.level);
			if (drag)
				return;
			this.level += this.velocity * timeStep;
		}

		public function get level():Number
		{
			return _level;
		}

		public function set level(value:Number):void
		{
			_level = value;
			this.y = value;
		}

		private function onUp(e:Event):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			this.drag = false;
			this.velocity = 0;
		}

		private function onDown(e:Event):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.drag = true;
		}

		private function onMove(e:MouseEvent):void
		{
			var point:Point = this.parent.globalToLocal(new Point(e.stageX, e.stageY));
			this.level = point.y;
		}
	}
}