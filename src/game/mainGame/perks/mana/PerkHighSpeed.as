package game.mainGame.perks.mana
{
	import clans.PerkTotems;
	import clans.TotemsData;
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkHighSpeed extends PerkMana
	{
		private var buff:BuffRadialView = null;
		private var bonusSpeed:Number;

		public function PerkHighSpeed(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_BOLT;
		}

		override protected function activate():void
		{
			super.activate();

			var bonus:Number = 0.2;
			for each (var totem:PerkTotems in this.hero.perkController.perksTotem)
			{
				if (totem.id != TotemsData.SPEED)
					continue;
				bonus += (totem.bonus / 100);
			}

			this.bonusSpeed = this.hero.runSpeed * bonus;
			this.hero.runSpeed += this.bonusSpeed;

			if (!this.buff)
				this.buff = new BuffRadialView((new HighSpeedButton).upState, 1.0, 0, gls("Белка-молния"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.runSpeed -= this.bonusSpeed;

			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}