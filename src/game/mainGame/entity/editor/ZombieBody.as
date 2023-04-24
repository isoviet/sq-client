package game.mainGame.entity.editor
{
	import flash.display.DisplayObject;

	public class ZombieBody extends ShamanBody
	{
		public function ZombieBody()
		{
			super();
		}

		override protected function get shamanIcon():DisplayObject
		{
			return new ZombieBodyImage();
		}
	}
}