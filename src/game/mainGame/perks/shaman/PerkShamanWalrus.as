package game.mainGame.perks.shaman
{
	import Box2D.Common.Math.b2Vec2;

	public class PerkShamanWalrus extends PerkShamanPassive
	{
		static public const SWIM_BONUS_FACTOR:Number = 10;

		static private const RADIUS:Number = 200 / Game.PIXELS_TO_METRE;

		private var walrusHeroes:Object = {};
		private var radius:Number;

		public function PerkShamanWalrus(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_WALRUS;
			this.radius = RADIUS * (1 + countBonus() / 100);
		}

		override protected function activate():void
		{
			super.activate();

			EnterFrameManager.addListener(updateSquirrels);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero || !this.hero.game)
				return;

			EnterFrameManager.removeListener(updateSquirrels);

			for (var id:String in this.walrusHeroes)
			{
				var hero:Hero = this.hero.game.squirrels.get(int(id));
				if (!hero)
					continue;

				hero.swimFactor -= this.walrusHeroes[id];
				if (hero.id != this.hero.id)
				{
					hero.heroView.hidePassiveAura();
					hero.removeBuff(this.buff);
				}
				delete this.walrusHeroes[hero.id];
			}

			this.walrusHeroes = {};
		}

		private function updateSquirrels():void
		{
			if (!this.active)
				return;

			if (!this.hero || !this.hero.game)
				return;

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				var distance:b2Vec2 = this.hero.position.Copy();
				distance.Subtract(hero.position);

				if (!checkHero(hero) || (distance.Length() > this.radius && !this.isMaxLevel))
				{
					if (hero.id in this.walrusHeroes)
					{
						hero.swimFactor -= this.walrusHeroes[hero.id];
						if (hero.id != this.hero.id)
						{
							hero.heroView.hidePassiveAura();
							hero.removeBuff(this.buff);
						}
						delete this.walrusHeroes[hero.id];
					}
					continue;
				}

				if (hero.id in this.walrusHeroes)
					continue;

				var swimBonus:Number = SWIM_BONUS_FACTOR / 100 * hero.swimFactor;
				this.walrusHeroes[hero.id] = swimBonus;
				hero.swimFactor += swimBonus;
				if (hero.id == this.hero.id)
					continue;

				hero.heroView.showPassiveAura();
				hero.addBuff(this.buff);
			}
		}

		private function checkHero(hero:Hero):Boolean
		{
			return !(!hero || !hero.isExist || hero.isDead || hero.inHollow || hero.isHare || hero.isDragon) && (hero.shaman && (hero.id == this.hero.id) || !hero.shaman);
		}
	}
}