package game.mainGame.entity.simple
{
	public class SunflowerBody extends InvisibleBody
	{
		public function SunflowerBody():void
		{
			super(Sunflower);
		}

		override public function get cacheBitmap():Boolean
		{
			return true;
		}
	}
}