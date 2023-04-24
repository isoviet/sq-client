package game.mainGame.entity.simple
{
	import utils.starling.StarlingAdapterSprite;

	public class SquareBody extends CacheVolatileBody
	{
		protected var view:StarlingAdapterSprite;

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			//this.view.opaqueBackground = 0x666666;
		}

		override public function set cacheAsBitmap(value:Boolean):void
		{
			//this.view.cacheAsBitmap = value;
		}
	}
}