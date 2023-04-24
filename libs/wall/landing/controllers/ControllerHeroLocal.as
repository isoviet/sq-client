package landing.controllers
{
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;

	public class ControllerHeroLocal extends ControllerHero
	{
		static private const TIME_KICK:int = 30;

		private var leftDown:Boolean = false;
		private var rightDown:Boolean = false;
		private var upDown:Boolean = false;
		private var sendPackets:Boolean = false;

		public function ControllerHeroLocal(hero:IHero, sendPackets:Boolean = true):void
		{
			super(hero);

			this.sendPackets = sendPackets;

			hero.setController(this);

			WallShadow.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
			WallShadow.stage.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
		}

		override public function remove():void
		{
			super.remove();

			WallShadow.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			WallShadow.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);

			this.hero = null;
		}

		private function onKey(e:KeyboardEvent):void
		{
			if (this.hero == null)
				return;

			if (e.type != KeyboardEvent.KEY_DOWN && e.type != KeyboardEvent.KEY_UP)
				return;

			var down:Boolean = (e.type == KeyboardEvent.KEY_DOWN);
			switch (e.keyCode)
			{
				case Keyboard.W:
				case Keyboard.SPACE:
				case Keyboard.UP:
					if (this.upDown == down)
						return;
					this.upDown = down;

					this.hero.jump(down);
					break;
				case Keyboard.A:
				case Keyboard.LEFT:
					if (this.leftDown == down)
						return;
					this.leftDown = down;

					this.hero.moveLeft(down);
					break;
				case Keyboard.D:
				case Keyboard.RIGHT:
					if (this.rightDown == down)
						return;
					this.rightDown = down;

					this.hero.moveRight(down);
					break;
			}
		}
	}
}