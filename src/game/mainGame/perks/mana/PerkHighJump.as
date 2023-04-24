package game.mainGame.perks.mana
{
	import clans.PerkTotems;
	import clans.TotemsData;
	import game.mainGame.gameBattleNet.BuffRadialView;

	public class PerkHighJump extends PerkMana
	{
		private var buff:BuffRadialView = null;
		private var bonusJump:int;

		public function PerkHighJump(hero:Hero):void
		{
			super(hero);

			this.code = PerkFactory.SKILL_HIGH_JUMP;
		}

		override protected function activate():void
		{
			super.activate();

			var bonus:Number = 0.2;
			for each (var totem:PerkTotems in this.hero.perkController.perksTotem)
			{
				if (totem.id != TotemsData.HIGH_JUMP)
					continue;
				bonus += (totem.bonus / 100);
			}

			this.bonusJump = this.hero.jumpVelocity * bonus;
			this.hero.jumpVelocity += this.bonusJump;

			if (!this.buff)
				this.buff = new BuffRadialView((new HighJumpButton).upState, 1.0, 0, gls("Высокий прыжок"));

			this.hero.addBuff(this.buff);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.jumpVelocity -= this.bonusJump;

			this.hero.removeBuff(this.buff);

			this.hero.heroView.hidePerkAnimation();
		}
	}
}