package game.mainGame.perks.shaman
{
	public class PerkShamanRunningCast extends PerkShamanPassive
	{
		private var oldRunCastRadius:Number;

		public function PerkShamanRunningCast(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_RUNNING_CAST;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.hero.useRunningCast = this.active && !this.hero.swim;
		}

		override protected function activate():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			this.hero.useRunningCast = true;

			if (!this.hero.isSelf)
				return;

			this.oldRunCastRadius = this.hero.game.cast.runCastRadius;
			this.hero.game.cast.runCastRadius = (1 + countBonus() / 100) * this.hero.game.cast.castRadius * 0.5;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.useRunningCast = false;

			if (!this.hero.isSelf || !this.hero.game || !this.hero.game.cast)
				return;

			this.hero.game.cast.runCastRadius = this.oldRunCastRadius;
		}
	}
}