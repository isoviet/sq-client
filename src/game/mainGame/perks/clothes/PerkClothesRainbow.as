package game.mainGame.perks.clothes
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import protocol.Connection;
	import protocol.PacketClient;

	public class PerkClothesRainbow extends PerkClothes
	{
		public function PerkClothesRainbow(hero:Hero):void
		{
			super(hero);

			this.code = PerkClothesFactory.PERK_RAINBOW;
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.running) && !this.active;
		}

		override protected function activate():void
		{
			super.activate();

			var rainbow:RainbowView = new RainbowView();

			this.hero.addView(rainbow);

			if (this.hero.id != Game.selfId)
				return;

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
			Game.stage.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);

		}

		override protected function deactivate():void
		{
			super.deactivate();
			this.hero.changeView();

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			Game.stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
		}

		private function onKey(e:KeyboardEvent):void
		{
			if (Game.chat.hasFocus())
				return;

			switch (e.keyCode)
			{
				case Keyboard.W:
				case Keyboard.SPACE:
				case Keyboard.UP:
				case Keyboard.A:
				case Keyboard.LEFT:
				case Keyboard.D:
				case Keyboard.RIGHT:
					this.active = false;
					Connection.sendData(PacketClient.ROUND_SKILL, code, false, 0, "");
					break;
			}
		}
	}
}