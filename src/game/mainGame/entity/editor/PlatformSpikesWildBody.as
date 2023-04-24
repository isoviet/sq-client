package game.mainGame.entity.editor
{
	import utils.starling.StarlingAdapterSprite;

	public class PlatformSpikesWildBody extends PlatformSpikesBody
	{
		public function PlatformSpikesWildBody()
		{
			super();
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new SpikesWild());
		}

		override protected function initPlatformBD():void
		{
			this.platform = new SpikesWild();
		}
	}
}