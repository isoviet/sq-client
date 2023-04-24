package game.mainGame.entity.simple
{
	import game.mainGame.entity.ICacheVolatile;

	public class CacheVolatileBody extends GameBody implements ICacheVolatile
	{
		protected var prevRotation:Number = 0;

		public function CacheVolatileBody():void
		{
			super();
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.prevRotation = this.rotation;
		}

		override public function get cacheBitmap():Boolean
		{
			var result:Boolean = super.cacheBitmap || (Math.abs(this.rotation - this.prevRotation) < 0.01) && (this.scaleX == 1) && (this.scaleY == 1);
			this.prevRotation = this.rotation;
			return result;
		}
	}
}