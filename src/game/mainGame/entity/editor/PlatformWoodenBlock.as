package game.mainGame.entity.editor
{
	import utils.starling.StarlingAdapterSprite;

	public class PlatformWoodenBlock extends PlatformBlockBody
	{
		public function PlatformWoodenBlock():void
		{
			super();

			this.restitution = 0.1;
			this.density = 1;
		}

		override protected function initPlatformBD():void
		{
			this.platform = new WoodenBlock;
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new WoodenBlock());
		}

		override protected function draw():void
		{
			super.draw();
		}
	}
}