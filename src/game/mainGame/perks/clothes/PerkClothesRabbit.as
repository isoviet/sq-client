package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateRabbit;

	public class PerkClothesRabbit extends PerkClothes
	{
		private var state:StateRabbit = null;

		public function PerkClothesRabbit(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override protected function activate():void
		{
			super.activate();

			this.state = new StateRabbit(0, 50);
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