package game.mainGame.entity.editor
{
	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinFree;

	public class PlatformLiquidAcidBody extends PlatformAcidBody implements IPinFree
	{
		public function PlatformLiquidAcidBody():void
		{
			super();
		}

		override protected function draw():void
		{
			super .draw();

			this.drawStarlingSprite.alpha = 0.5;
		}

		override protected function get maskBits():uint
		{
			return CollisionGroup.HERO_CATEGORY;
		}

		override protected function get categories():uint
		{
			return CollisionGroup.HERO_DETECTOR_CATEGORY;
		}
	}
}