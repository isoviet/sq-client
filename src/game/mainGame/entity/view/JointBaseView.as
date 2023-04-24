package game.mainGame.entity.view
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	import interfaces.IDispose;

	import utils.GeomUtil;
	import utils.starling.StarlingAdapterSprite;

	public class JointBaseView extends StarlingAdapterSprite implements IDispose
	{
		private var startSprite:StarlingAdapterSprite;
		private var endSprite:StarlingAdapterSprite;
		private var middleSprite:StarlingAdapterSprite;
		private var middleWidth:Number;
		private var revertMiddle:Boolean;
		private var _lastScale: Number = 1;
		private var currentHero:Hero = null;
		private var _point: Point = new Point();
		private var _myJointSprite: StarlingAdapterSprite;

		public function JointBaseView(startSprite:DisplayObject, endSprite:DisplayObject, middleSprite:DisplayObject, middleWidth:Number):void
		{
			this.startSprite = new StarlingAdapterSprite(startSprite);
			this.endSprite = new StarlingAdapterSprite(endSprite);
			this.middleSprite = new StarlingAdapterSprite(middleSprite);
			this.middleWidth = middleWidth;
			this.middleSprite.useRescaleOriginalImage = false;

			addChildStarling(this.startSprite);
			addChildStarling(this.endSprite);
			addChildStarling(this.middleSprite);
		}

		override public function get alpha():Number
		{
			return super.alpha;
		}

		override public function set alpha(value:Number):void
		{
			this.startSprite.alpha = this.endSprite.alpha = this.middleSprite.alpha = super.alpha = value;
		}

		override public function set filters(value:Array):void
		{
			this.startSprite.filters = this.endSprite.filters = this.middleSprite.filters = super.filters = value;
		}

		public function setHeroes(h0:Hero, h1:Hero):void
		{
			this.middleSprite.y = this.endSprite.y = this.startSprite.y = -20;
			h0.heroView.addChildStarling(this.endSprite);
			h1.heroView.addChildStarling(this.startSprite);

			if (h1.parentStarling.getChildStarlingIndex(h1) > h0.parentStarling.getChildStarlingIndex(h0))
			{
				this.revertMiddle = false;
				h1.heroView.addChildStarling(this.middleSprite);
				this.currentHero = h1;
				_myJointSprite = this.startSprite;
			}
			else
			{
				this.revertMiddle = true;
				h0.heroView.addChildStarling(this.middleSprite);
				this.currentHero = h0;
				_myJointSprite = this.endSprite;
			}

			Game.stage.addEventListener(Event.EXIT_FRAME, onUpdate, false, 0, true);
		}

		public function dispose():void
		{
			if (this.middleSprite.parentStarling)
				this.middleSprite.parentStarling.removeChildStarling(this.middleSprite);

			if (this.endSprite.parentStarling)
				this.endSprite.parentStarling.removeChildStarling(this.endSprite);

			if (this.startSprite.parentStarling)
				this.startSprite.parentStarling.removeChildStarling(this.startSprite);
		}

		private function redraw():void
		{
			if (!this.middleSprite.parentStarling)
				return;

			_point.setTo(0, 0);
			var start:Point = startSprite.localToGlobal(_point);
			_point.setTo(0, 0);
			var end:Point = endSprite.localToGlobal(_point);

			var dif:Point = start.subtract(end);
			this.middleSprite.getStarlingView().scaleX = (dif.length - 5) / this.middleWidth;
			this.middleSprite.getStarlingView().scaleY = dif.x > 0 ? -1 : 1;

			if (this.currentHero != null && this.currentHero.scale != _lastScale)
			{
				_lastScale = this.currentHero.scale;
				this.middleSprite.y = this._myJointSprite.y = -20 * this.currentHero.scale;
			}

			this.middleSprite.rotation = GeomUtil.getAngle(start, end) - 90 + (this.revertMiddle ? 180 : 0) - this.middleSprite.parentStarling.parentStarling.rotation;
		}

		private function onUpdate(e:Event):void
		{
			redraw();
		}
	}
}