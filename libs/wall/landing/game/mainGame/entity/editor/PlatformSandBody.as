package landing.game.mainGame.entity.editor
{
	import utils.ImageUtil;

	public class PlatformSandBody extends PlatformGroundBody
	{
		public function PlatformSandBody():void
		{
			super();
		}

		override protected function initIcon():void
		{
			this.icon = new Send();
		}

		override protected function initPlatformBD():void
		{
			this.platform = ImageUtil.getBitmapData(new Send());
		}
	}
}