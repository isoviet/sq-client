package game.mainGame.entity.editor
{
	import utils.starling.StarlingAdapterSprite;

	public class PlatformSandBody extends PlatformGroundBody
	{
		public function PlatformSandBody():void
		{
			super();
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new Sand1());
		}

		override protected function initPlatformBD():void
		{
			this.platform = new Sand1();
		}
	}
}