package game.mainGame.entity.magic
{
	import game.mainGame.entity.simple.InvisibleBodyTemp;

	public class SamuraiSakura extends InvisibleBodyTemp
	{
		public function SamuraiSakura()
		{
			super(SamuraiPerkView, 0, 10);
		}

		override public function get stopInEnd():Boolean
		{
			return true;
		}
	}
}