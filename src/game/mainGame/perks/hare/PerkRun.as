package game.mainGame.perks.hare
{
	import flash.events.Event;
	import flash.ui.Keyboard;

	import sounds.GameSounds;

	public class PerkRun extends PerkHare
	{
		public function PerkRun(hero:Hero):void
		{
			super(hero);

			this.code = Keyboard.F15;
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.hareView as HareView).stomp;
		}

		override protected function block():void
		{
			if (!super.available)
				return;

			this.charge = 0;
			this.isBlocked = true;
			dispatchEvent(new Event("STATE_CHANGED"));
		}

		override protected function activate():void
		{
			super.activate();

			GameSounds.playUnrepeatable("hare_speed", HareView.SOUND_PROBABILITY);
			this.hero.runSpeed *= 3;
			(this.hero.heroView.hareView as HareView).walkSpeed += 2;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!(this.hero.heroView.hareView as HareView).walkSpeed >= 2)
				return;

			this.hero.sendLocation(-this.code);

			this.hero.runSpeed /= 3;
			(this.hero.heroView.hareView as HareView).walkSpeed -= 2;
		}
	}
}