package game.mainGame.perks.shaman
{
	import game.mainGame.entity.shaman.ShamanPointer;

	public class PerkShamanPointer extends PerkShamanCast
	{
		public function PerkShamanPointer(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_POINTER;
		}

		override protected function initCastObject():void
		{
			this.castObject = new ShamanPointer(1 + countBonus() / 100, this.isMaxLevel);
		}
	}
}