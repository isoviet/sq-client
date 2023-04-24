package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateFlightCat;

	public class PerkClothesFairyCat extends PerkClothes
	{
		private var state:StateFlightCat = null;

		public function PerkClothesFairyCat(hero:Hero)
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
			return 15;
		}

		override protected function activate():void
		{
			super.activate();

			this.state = new StateFlightCat(0, 5);
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