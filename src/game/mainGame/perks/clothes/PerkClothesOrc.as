package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateOrc;

	public class PerkClothesOrc extends PerkClothes
	{
		private var state:StateOrc = null;

		public function PerkClothesOrc(hero:Hero)
		{
			super(hero);

			this.activateSound = "orc";
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
			return 5;
		}

		override protected function activate():void
		{
			super.activate();

			this.state = new StateOrc(0, this.hero.heroView.direction);
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