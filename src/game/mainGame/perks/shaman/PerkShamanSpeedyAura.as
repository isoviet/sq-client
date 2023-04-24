package game.mainGame.perks.shaman
{
	import Box2D.Common.Math.b2Vec2;

	public class PerkShamanSpeedyAura extends PerkShamanPassive
	{
		static public const MAX_LEVEL_SPEED_BONUS_FACTOR:Number = 5;
		static public const SPEED_BONUS_FACTOR:Number = 10;

		static private const RADIUS:Number = 200 / Game.PIXELS_TO_METRE;

		private var speedyHeroes:Object = {};
		private var radius:Number;

		public function PerkShamanSpeedyAura(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_SPEEDY_AURA;
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

			for (var id:String in this.speedyHeroes)
			{
				var hero:Hero = this.hero.game.squirrels.get(int(id));
				if (!hero)
					continue;

				hero.runSpeed -= this.speedyHeroes[hero.id];

				if (hero.id != this.hero.id)
				{
					hero.heroView.hidePassiveAura();
					hero.removeBuff(this.buff);
				}

				delete this.speedyHeroes[hero.id];
			}

			this.speedyHeroes = {};
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

				if (!checkHero(hero) || distance.Length() > this.radius)
				{
					if (hero.id in this.speedyHeroes)
					{
						if (hero.id != this.hero.id)
						{
							hero.heroView.hidePassiveAura();
							hero.removeBuff(this.buff);
						}

						hero.runSpeed -= this.speedyHeroes[hero.id];
						delete this.speedyHeroes[hero.id];
					}
					continue;
				}

				if (hero.id in this.speedyHeroes)
					continue;

				var speedBonus:Number = (SPEED_BONUS_FACTOR + (this.isMaxLevel ? MAX_LEVEL_SPEED_BONUS_FACTOR : 0)) / 100 * hero.runSpeed;

				this.speedyHeroes[hero.id] = speedBonus;

				hero.runSpeed += speedBonus;

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