package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	import sounds.GameSounds;

	public class DeathSkull extends Sprite
	{
		public var scale:Number = 1;

		private var view:MovieClip = null;
		private var hero:Hero = null;

		private var toCoord:Point = null;
		private var speed:int = 0;

		private var onCompleteSound:String = null;

		public function DeathSkull(hero:Hero, _view:Class, _onCompleteSound:String, speed:int = 20):void
		{
			this.hero = hero;

			this.view = new _view();
			this.view.play();
			this.view.visible = true;
			this.addChild(this.view);

			this.onCompleteSound = _onCompleteSound;

			this.speed = speed;
			this.toCoord = new Point(0, 0);
			addEventListener(Event.ENTER_FRAME, onMotion);
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

		private function onMotion(e:Event):void
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
			removeEventListener(Event.ENTER_FRAME, onMotion);

			if (this.view && contains(this.view))
				removeChild(this.view);

			if (!this.hero || !this.hero.isExist)
				return;

			this.hero.setCurseView(new this.view.constructor());

			GameSounds.play(this.onCompleteSound);
		}
	}
}