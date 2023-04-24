package game.mainGame.perks.shaman
{
	import game.mainGame.entity.shaman.Rune;

	public class PerkShamanRune extends PerkShamanCast
	{
		static public const SPEED_BONUS_FACTOR:int = 50;

		public function PerkShamanRune(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_RUNE;
		}

		override protected function initCastObject():void
		{
			var rune:Rune = new Rune();
			rune.force *= (1 + countBonus() / 100);
			if (this.isMaxLevel)
				rune.velocity *= (1 + SPEED_BONUS_FACTOR / 100);

			this.castObject = rune;
		}
	}
}