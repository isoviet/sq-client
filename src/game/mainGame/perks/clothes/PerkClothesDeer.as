package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateDeer;

	public class PerkClothesDeer extends PerkClothes
	{
		private var state:StateDeer = null;

		public function PerkClothesDeer(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_FLYING;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override protected function activate():void
		{
			super.activate();

			this.state = new StateDeer(0);
			this.hero.behaviourController.addState(this.state);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.state)
				this.hero.behaviourController.removeState(this.state);
			this.state = null;
		}
	}
}