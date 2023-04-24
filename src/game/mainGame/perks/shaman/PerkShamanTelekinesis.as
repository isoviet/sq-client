package game.mainGame.perks.shaman
{
	import game.mainGame.entity.cast.DragTool;

	public class PerkShamanTelekinesis extends PerkShamanPassive
	{
		private var radiusBonus:Number;

		public function PerkShamanTelekinesis(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_TELEKINESIS;
		}

		override protected function activate():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			if (this.isMaxLevel)
				this.hero.telekinesisColor = 0xFF0000;

			if (!this.hero.isSelf)
				return;

			this.radiusBonus = this.hero.game.cast.telekinezRadius * (countBonus() / 100);
			this.hero.game.cast.telekinezRadius += this.radiusBonus;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero || !this.hero.isSelf || !this.hero.game || !this.hero.game.cast)
				return;

			if (this.isMaxLevel)
				this.hero.telekinesisColor = DragTool.DEFAULT_DRAG_COLOR;

			this.hero.game.cast.telekinezRadius -= this.radiusBonus;
		}
	}
}