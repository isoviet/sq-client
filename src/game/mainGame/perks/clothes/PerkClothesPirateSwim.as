package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateBearFish;

	public class PerkClothesPirateSwim extends PerkClothes
	{
		static private const PIRATE_SWIM_FACTOR:Number = 0.5;

		private var state:StateBearFish = null;

		public function PerkClothesPirateSwim(hero:Hero):void
		{
			super(hero);

			this.activateSound = "bubble";
			this.soundOnlyHimself = true;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override protected function activate():void
		{
			super.activate();

			this.state = new StateBearFish(0, PIRATE_SWIM_FACTOR, false);
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