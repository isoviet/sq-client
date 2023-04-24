package game.mainGame.entity.editor
{
	import flash.display.BitmapData;

	import game.mainGame.entity.ILandSound;

	import utils.ImageUtil;
	import utils.starling.StarlingAdapterSprite;

	public class CoverIce extends Cover implements ILandSound
	{
		private var bitmapData:BitmapData;

		public function CoverIce():void
		{
			super();
		}

		public function get landSound():String
		{
			return "land_ice";
		}

		override public function getImage():BitmapData
		{
			if (this.bitmapData == null)
				bitmapData = ImageUtil.getBitmapData(new Ice());
			return bitmapData;
		}

		override protected function initImage():void
		{
			addChildStarling(new StarlingAdapterSprite(new Ice()));
		}
	}
}