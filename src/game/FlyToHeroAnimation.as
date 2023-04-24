package game
{
	import flash.geom.Point;

	import utils.starling.StarlingAdapterSprite;

	public class FlyToHeroAnimation extends StarlingAdapterSprite
	{
		static public const TO_HERO:int = 0;
		static public const FROM_HERO:int = 1;

		private var view:StarlingAdapterSprite = null;

		private var direction:int;
		private var hero:Hero = null;
		private var framesCount:int = 0;
		private var toCoord:Point = null;
		private var offset:Point = null;
		private var onComplete:Function = null;

		public function FlyToHeroAnimation(view:StarlingAdapterSprite):void
		{
			this.view = view;
			this.view.cacheAsBitmap = true;
			this.view.x = -int(view.width * 0.5);
			this.view.y = -int(view.height * 0.5);
			addChildStarling(this.view);
		}

		public function show(direction:int, hero:Hero, framesCount:int, point:Point, offset:Point, onComplete:Function):void
		{
			this.direction = direction;
			this.hero = hero;
			this.framesCount = framesCount;
			this.offset = offset;
			this.onComplete = onComplete;

			if (direction == TO_HERO)
			{
				this.x = point.x;
				this.y = point.y;

				this.view.scaleX = this.view.scaleY = this.hero.scale;
				this.view.x = -int(view.width * 0.5);
				this.view.y = -int(view.height * 0.5);

				this.toCoord = new Point(this.hero.x + offset.x, this.hero.y + offset.y);
			}
			else
			{
				this.x = hero.x + offset.x;
				this.y = hero.y + offset.y;

				this.toCoord = point;
			}

			this.hero.game.foreground.addChild(this);
			EnterFrameManager.addListener(onEnterFrame);
		}

		public function remove():void
		{
			EnterFrameManager.removeListener(onEnterFrame);
			this.hero = null;

			this.removeFromParent(false)
		}

		public function dispose():void
		{
			remove();

			this.removeFromParent(true);

			this.offset = null;
			this.toCoord = null;
			this.view = null;
			this.onComplete = null;
		}

		private function onEnterFrame():void
		{
			var direction:Point = this.toCoord.subtract(new Point(this.x, this.y));
			direction.normalize(direction.length / (this.framesCount--));

			if (this.direction == TO_HERO)
			{
				this.x += direction.x;
				this.y += direction.y;

				this.toCoord = new Point(this.hero.x + offset.x, this.hero.y + offset.y);
			}
			else
			{
				this.x += direction.x;
				this.y += direction.y;
			}

			if (this.framesCount > 0)
				return;

			if (this.onComplete != null)
				onComplete();
			EnterFrameManager.removeListener(onEnterFrame);
		}
	}
}