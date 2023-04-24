package game.mainGame.entity.editor
{
	import utils.starling.StarlingAdapterSprite;

	public class PlatformMetalBlock extends PlatformBlockBody
	{
		public function PlatformMetalBlock():void
		{
			super();

			this.restitution = 0.1;
			this.density = 3;
		}

		override public function get landSound():String
		{
			return "metal";
		}

		override protected function initPlatformBD():void
		{
			this.platform = new MetalBlock;
		}

		override protected function initIcon():void
		{
			this.icon =  new StarlingAdapterSprite(new MetalBlock());
		}

		override protected function draw():void
		{
			super.draw();
		}
	}
}