package game.mainGame.perks.shaman
{
	import Box2D.Common.Math.b2Vec2;

	public class PerkShamanInspired extends PerkShamanPassive
	{
		static public const JUMP_BONUS_FACTOR:Number = 10;
		static public const MAX_LEVEL_JUMP_FACTOR:Number = 5;

		static private const RADIUS:Number = 200 / Game.PIXELS_TO_METRE;

		private var inspiredHeroes:Object = {};
		private var radius:Number;

		public function PerkShamanInspired(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_INSPIRED;
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

			for (var id:String in this.inspiredHeroes)
			{
				var hero:Hero = this.hero.game.squirrels.get(int(id));
				if (!hero)
					continue;

				hero.jumpVelocity -= this.inspiredHeroes[id];

				if (hero.id != this.hero.id)
				{
					hero.heroView.hidePassiveAura();
					hero.removeBuff(this.buff);
				}

				delete this.inspiredHeroes[hero.id];
			}

			this.inspiredHeroes = {};
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
					if (hero.id in this.inspiredHeroes)
					{
						hero.jumpVelocity -= this.inspiredHeroes[hero.id];

						if (hero.id != this.hero.id)
						{
							hero.heroView.hidePassiveAura();
							hero.removeBuff(this.buff);
						}

						delete this.inspiredHeroes[hero.id];
					}
					continue;
				}

				if (hero.id in this.inspiredHeroes)
					continue;

				var jumpBonus:int = (JUMP_BONUS_FACTOR + (this.isMaxLevel ? MAX_LEVEL_JUMP_FACTOR : 0)) / 100 * hero.jumpVelocity;

				this.inspiredHeroes[hero.id] = jumpBonus;

				hero.jumpVelocity += jumpBonus;

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