package game.mainGame
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import statuses.Status;

	public class KickButton extends Sprite
	{
		static public const IMAGE_X:int = -12;
		static public const IMAGE_Y:int = -105;

		private var button:KickButtonCustom = new KickButtonCustom();

		private var _clickFunction:Function;

		private var hero:Hero = null;

		public function KickButton():void
		{
			this.button.x = IMAGE_X;
			this.button.y = IMAGE_Y;
			this.addChild(this.button);

			this.button.gotoAndStop(1);

			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);

			new Status(this, gls("Пожаловаться на белку"));

			this.mouseEnabled = true;
			this.buttonMode = true;
		}

		private function onRollOver(e:MouseEvent):void
		{
			if (this.parent is Hero)
			{
				this.hero = this.parent as Hero;

				this.x = this.hero.x;
				this.y = this.hero.y + this.height * 0.7 ;
				this.rotation = this.hero.rotation;
				this.hero.game.map.addChild(this);
			}

			this.button.gotoAndStop(2);
		}

		private function onRollOut(e:MouseEvent = null):void
		{
			if (this.hero)
			{
				this.x = 0;
				this.y = this.height * 0.7;//this.hero.heroView.y;
				this.rotation = 0;
				this.hero.addChild(this);
			}
			this.hero = null;

			this.button.gotoAndStop(1);
		}

		public function reset():void
		{
			onRollOut();

			if (this.parent)
				this.parent.removeChild(this);
		}
	}
}