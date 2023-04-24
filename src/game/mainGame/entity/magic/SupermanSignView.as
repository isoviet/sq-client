package game.mainGame.entity.magic
{
	import game.mainGame.entity.simple.InvisibleBodyTemp;

	public class SupermanSignView extends InvisibleBodyTemp
	{
		public function SupermanSignView()
		{
			super(SupermanPerkView, 0, -30);
		}

		override public function get stopInEnd():Boolean
		{
			return true;
		}
	}
}