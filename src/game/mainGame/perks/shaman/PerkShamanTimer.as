package game.mainGame.perks.shaman
{
	import game.mainGame.entity.shaman.LifeTimeBalkLong;
	import game.mainGame.entity.shaman.LifetimeBalk;

	public class PerkShamanTimer extends PerkShamanCast
	{
		public function PerkShamanTimer(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_TIMER;
		}

		override protected function initCastObject():void
		{
			if (!this.hero || !this.hero.game)
			{
				this.active = false;
				return;
			}

			var balk:* = this.isMaxLevel ? new LifeTimeBalkLong() : new LifetimeBalk();
			balk.lifeTime = countBonus() * 1000;

			this.castObject = balk;
		}
	}
}