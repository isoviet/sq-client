package landing.game.mainGame.entity.editor
{
	import flash.display.BitmapData;

	import utils.ImageUtil;

	public class CoverIce extends Cover
	{
		public function CoverIce():void
		{
			super();
		}

		override public function getImage():BitmapData
		{
			return ImageUtil.getBitmapData(new Ice());
		}

		override protected function initImage():void
		{
			addChild(new Ice());
		}
	}
}