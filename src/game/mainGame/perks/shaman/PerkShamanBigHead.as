package game.mainGame.perks.shaman
{
	public class PerkShamanBigHead extends PerkShamanPassive
	{
		public var scale:Number = 1;

		public function PerkShamanBigHead(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_BIG_HEAD;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero)
				return;

			if (this.isMaxLevel)
			{
				this.scale = 1 + countBonus() / 100;
				this.hero.heroView.scale = this.scale;
			} else
				this.hero.heroView.scaleHead(1 + countBonus() / 100);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			if (this.isMaxLevel)
			{
				this.scale = 1;
				this.hero.heroView.scale = this.scale;
			} else
				this.hero.heroView.scaleHead(1);
		}
	}
}