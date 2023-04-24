package game.mainGame.perks.shaman
{
	import game.mainGame.entity.simple.AcornBody;

	public class PerkShamanBigAcorn extends PerkShamanPassive
	{
		static private var bonuses:Object = {};
		static private var minBonus:Number = 1;

		private var acorns:Array = null;
		private var heroId:int;

		public function PerkShamanBigAcorn(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_BIG_ACORN;
			this.heroId = hero.id;
		}

		static private function getBonus():Number
		{
			var maxBonus:Number = minBonus;

			for each (var bonus:Number in bonuses)
				maxBonus = (maxBonus < bonus) ? bonus: maxBonus;

			return maxBonus;
		}

		override public function resetRound():void
		{
			super.resetRound();

			minBonus = 1;
		}

		override protected function activate():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			this.acorns = this.hero.game.map.get(AcornBody);

			bonuses[this.heroId] = 1 + countBonus() / 100;

			setAcornsScale();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.isMaxLevel)
				minBonus = bonuses[this.heroId];

			delete bonuses[this.heroId];

			setAcornsScale();
		}

		private function setAcornsScale():void
		{
			if (!this.acorns)
				return;

			var scale:Number = getBonus();

			for each (var acorn:AcornBody in this.acorns)
			{
				if (!acorn)
					continue;

				acorn.scale = scale;
			}
		}
	}
}