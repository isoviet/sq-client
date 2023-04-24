package game.mainGame.entity.editor
{
	import utils.starling.StarlingAdapterSprite;

	public class PlatformDesertSandBody extends PlatformGroundBody
	{
		public function PlatformDesertSandBody():void
		{
			super();
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new Sand());
		}

		override protected function initPlatformBD():void
		{
			this.platform = new Sand();
		}
	}
}