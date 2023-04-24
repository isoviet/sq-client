package game.mainGame.entity.editor
{
	import utils.starling.StarlingAdapterSprite;

	public class PlatformGroundWildBody extends PlatformHerbBody
	{
		public function PlatformGroundWildBody()
		{
			super();
		}

		override protected function initPlatformBD():void
		{
			this.platform = new PlatformGroundWild();
		}

		override protected function get herbClass():Class
		{
			return PlatformGroundWildHerb;
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new PlatformGroundWild());
		}
	}
}