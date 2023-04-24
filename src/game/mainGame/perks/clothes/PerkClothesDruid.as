package game.mainGame.perks.clothes
{
	import game.mainGame.behaviours.StateDruid;

	public class PerkClothesDruid extends PerkClothes
	{
		private var state:StateDruid = null;

		public function PerkClothesDruid(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override public function get activeTime():Number
		{
			return 7;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override protected function activate():void
		{
			super.activate();

			this.state = new StateDruid(0);
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