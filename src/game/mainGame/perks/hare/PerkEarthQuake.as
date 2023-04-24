package game.mainGame.perks.hare
{
	import flash.events.Event;
	import flash.ui.Keyboard;

	import game.mainGame.events.SquirrelEvent;

	public class PerkEarthQuake extends PerkHare
	{
		public function PerkEarthQuake(hero:Hero):void
		{
			super(hero);

			this.code = Keyboard.F13;
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.hareView as HareView).rock;
		}

		override protected function activate():void
		{
			super.activate();

			(this.hero.heroView.hareView as HareView).stomp = true;
			this.hero.isStoped = true;
			this.hero.addEventListener(SquirrelEvent.DIE, onDie);
			Game.stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!(this.hero.heroView.hareView as HareView).stomp)
				return;

			this.hero.sendLocation(-this.code);

			(this.hero.heroView.hareView as HareView).stomp = false;
			this.hero.isStoped = false;
			Game.stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}

		override protected function block():void
		{
			if (!super.available)
				return;

			this.charge = 0;
			this.isBlocked = true;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		private function enterFrame(e:Event):void
		{
			if (this.hero == null)
			{
				Game.stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
				return;
			}

			this.hero.earthQuake();
		}

		private function onDie(e:SquirrelEvent):void
		{
			this.active = false;
		}
	}
}