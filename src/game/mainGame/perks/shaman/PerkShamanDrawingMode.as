package game.mainGame.perks.shaman
{
	import game.mainGame.entity.shaman.DrawBlock;

	public class PerkShamanDrawingMode extends PerkShamanCast
	{
		public function PerkShamanDrawingMode(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_DRAWING_MODE;
		}

		override protected function initCastObject():void
		{
			var block:DrawBlock = new DrawBlock();
			block.lifeTime = countBonus() * 1000;
			if (this.isMaxLevel)
				block.useRunCast = true;
			this.castObject = block;
		}
	}
}