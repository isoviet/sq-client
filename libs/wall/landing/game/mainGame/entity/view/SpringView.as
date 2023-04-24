package landing.game.mainGame.entity.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	import utils.GeomUtil;

	public class SpringView extends Sprite
	{
		static private const HOOK_HEIGHT:Number = 13;
		private var _start:Point = new Point();
		private var _end:Point = new Point();
		private var initialLength:Number = -1;

		private var startHook:DisplayObject = new SpringHook();
		private var endHook:DisplayObject = new SpringHook();

		private var segmentSprite:Sprite = new Sprite();

		public function SpringView()
		{
			startHook.rotation = 180;
			addChild(startHook);
			endHook.scaleX = -1;
			addChild(endHook);

			segmentSprite.y = -HOOK_HEIGHT;
			addChild(segmentSprite);
		}

		public function set start(value:Point):void
		{
			this._start = value;
			this.x = value.x;
			this.y = value.y;
			calcRotation();
			rescale();
		}

		public function set end(value:Point):void
		{
			this._end = value;
			calcRotation();
			endHook.y = -length;
			rescale();
		}

		private function rescale():void
		{
			if (initialLength == -1)
			{
				while (this.segmentSprite.numChildren > 0)
					this.segmentSprite.removeChildAt(0);

				var needSegments:int = springBodyLength / 35.5;
				needSegments = (needSegments > 0 ? needSegments : 1);

				for (var i:int = 0; i < needSegments; i++)
				{
					var springBody:DisplayObject = this.segmentSprite.addChild(new SpringBody());
					springBody.y = -35.5 * i;
					springBody.rotation = 180;
				}
			}
			this.segmentSprite.height = springBodyLength;
			this.segmentSprite.height += this.segmentSprite.scaleY * 3;
		}

		private function get springBodyLength():Number
		{
			return this.length - HOOK_HEIGHT * 2
		}

		public function get length():Number
		{
			return _start.clone().subtract(_end).length;
		}

		public function initLength():void
		{
			this.initialLength = this.length;
		}

		private function calcRotation():void
		{
			this.rotation = GeomUtil.getAngle(_start, _end);
		}
	}
}