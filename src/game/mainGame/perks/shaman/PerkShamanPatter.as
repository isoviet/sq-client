package game.mainGame.perks.shaman
{
	public class PerkShamanPatter extends PerkShamanPassive
	{
		private var timeBonus:Number;

		public function PerkShamanPatter(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_PATTER;
		}

		override protected function activate():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			if (!this.hero.isSelf)
				return;

			this.timeBonus = this.hero.game.cast.castTime * countBonus() / 100;
			this.hero.game.cast.castTime -= this.timeBonus;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero.isSelf || !this.hero.game || !this.hero.game.cast)
				return;

			this.hero.game.cast.castTime += this.timeBonus;
		}
	}
}