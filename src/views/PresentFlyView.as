package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;

	import utils.Animation;

	public class PresentFlyView extends Sprite
	{
		static private const COORD_X:int = -18;
		static private const COORD_Y:int = -18;

		public var scale:Number = 1;

		private var view:Sprite = new Sprite();
		private var hero:Hero = null;

		private var toCoord:Point = null;
		private var speed:int = 5;

		public function PresentFlyView(hero:Hero, present:MovieClip):void
		{
			this.hero = hero;

			var animation:Animation = new Animation(present);
			this.view.addChild(animation);
			animation.x = COORD_X;
			animation.y = COORD_Y;
			animation.play();

			this.view.visible = true;
			this.addChild(this.view);

			this.toCoord = new Point(0, 0);
			EnterFrameManager.addListener(onMotion);
		}

		public function setPosition(x:int, y:int):void
		{
			this.x = x;
			this.y = y;
		}

		public function dispose():void
		{
			if (this.hero)
				this.hero.setCurseView(null);

			this.hero = null;
		}

		private function onMotion():void
		{
			var direction:Point = toCoord.subtract(new Point(this.x, this.y));

			if (!this.hero || !this.hero.isExist || direction.length < this.speed)
			{
				stopMotion();
				return;
			}

			direction.normalize(direction.length < 3 * this.speed ? direction.length / 2 : this.speed);

			this.x += direction.x;
			this.y += direction.y;
			this.toCoord = new Point(this.hero.x, this.hero.y - 55);
		}

		private function stopMotion():void
		{
			EnterFrameManager.removeListener(onMotion);

			if (this.view && contains(this.view))
				removeChild(this.view);

			if (!this.hero || !this.hero.isExist)
				return;

			this.hero.setCurseView(this.view);
		}
	}
}