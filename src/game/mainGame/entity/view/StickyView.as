package game.mainGame.entity.view
{
	import flash.events.Event;
	import flash.geom.Point;

	import game.mainGame.entity.simple.GameBody;

	import interfaces.IDispose;

	import utils.GeomUtil;
	import utils.starling.StarlingAdapterSprite;

	public class StickyView extends StarlingAdapterSprite implements IDispose
	{
		private var startSprite:StarlingAdapterSprite;
		private var endSprite:StarlingAdapterSprite;
		private var middleSprite:StarlingAdapterSprite;
		private var middleWidth:Number;
		private var revertMiddle:Boolean;

		private var _lastScale: Number = 1;
		private var _point: Point = new Point();
		private var _myJointSprite: StarlingAdapterSprite;

		private var hero:Hero = null;

		public function StickyView(endClass:Class = null, middleClass:Class = null):void
		{
			if (endClass == null)
				endClass = StickyEnd;
			if (middleClass == null)
				middleClass = StickyMiddle;

			this.endSprite = new StarlingAdapterSprite(new endClass());
			this.middleSprite = new StarlingAdapterSprite(new middleClass());
			this.middleWidth = 90.50;
			this.middleSprite.useRescaleOriginalImage = false;

			addChildStarling(this.endSprite);
			addChildStarling(this.middleSprite);
		}

		override public function get alpha():Number
		{
			return super.alpha;
		}

		override public function set alpha(value:Number):void
		{
			this.endSprite.alpha = this.middleSprite.alpha = super.alpha = value;
		}

		/*override public function set filters(value:Array):void
		{
			this.startSprite.filters = this.endSprite.filters = this.middleSprite.filters = super.filters = value;
		}*/

		public function dispose():void
		{
			if (this.middleSprite.parentStarling)
				this.middleSprite.parentStarling.removeChildStarling(this.middleSprite);

			if (this.endSprite.parentStarling)
				this.endSprite.parentStarling.removeChildStarling(this.endSprite);
		}

		public function setView(body:GameBody, hero:Hero):void
		{
			this.startSprite = body as StarlingAdapterSprite;

			this.middleSprite.y = this.endSprite.y = -20;
			hero.heroView.addChildStarling(this.endSprite);
			_myJointSprite = this.endSprite;

			this.revertMiddle = true;
			hero.heroView.addChildStarling(this.middleSprite);
			this.hero = hero;

			Game.stage.addEventListener(Event.EXIT_FRAME, onUpdate, false, 0, true);
		}

		protected function redraw():void
		{
			if (!this.middleSprite.parentStarling)
				return;

			_point.setTo(0, 0);
			var start:Point = startSprite.localToGlobal(_point);
			_point.setTo(0, 0);
			var end:Point = endSprite.localToGlobal(_point);

			var dif:Point = start.subtract(end);
			this.middleSprite.getStarlingView().scaleX = (dif.length - 5) / this.middleWidth / this.hero.scale;
			this.middleSprite.getStarlingView().scaleY = dif.x > 0 ? -1 : 1;

			if (this.hero != null && this.hero.scale != _lastScale)
			{
				_lastScale = this.hero.scale;
				this.middleSprite.y = this._myJointSprite.y = -20 * this.hero.scale;
			}

			this.middleSprite.rotation = GeomUtil.getAngle(start, end) - 90 + (this.revertMiddle ? 180 : 0) - this.middleSprite.parentStarling.parentStarling.rotation;
		}

		protected function onUpdate(e:Event):void
		{
			redraw();
		}
	}
}