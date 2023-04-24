package game.mainGame.perks.shaman
{
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.perks.IPerkWithoutButton;

	public class PerkShamanPassive extends PerkShaman implements IPerkWithoutButton
	{
		public function PerkShamanPassive(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.activateSound = "";
		}

		override public function dispose():void
		{
			this.active = false;

			super.dispose();
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.buff)
				this.buff = createBuff(0);

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.hero)
				this.hero.removeBuff(this.buff);
		}

		override protected function onShaman(e:SquirrelEvent):void
		{
			if (!e.player.shaman || this.active || !this.available)
				return;

			this.active = true;
		}
	}
}