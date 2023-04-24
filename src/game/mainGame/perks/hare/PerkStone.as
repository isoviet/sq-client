package game.mainGame.perks.hare
{
	import flash.events.Event;
	import flash.ui.Keyboard;

	public class PerkStone extends PerkHare
	{
		public function PerkStone(hero:Hero):void
		{
			super(hero);

			this.code = Keyboard.F14;
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

			this.hero.colideWithSquirrels = true;
			(this.hero.heroView.hareView as HareView).rock = true;
			this.hero.mass *= 4;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!(this.hero.heroView.hareView as HareView).rock)
				return;

			this.hero.sendLocation(-this.code);

			this.hero.colideWithSquirrels = false;
			(this.hero.heroView.hareView as HareView).rock = false;
			this.hero.mass /= 4;
		}
	}
}