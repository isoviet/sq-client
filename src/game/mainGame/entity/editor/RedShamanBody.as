package game.mainGame.entity.editor
{
	import flash.display.DisplayObject;

	public class RedShamanBody extends ShamanBody
	{
		override protected function get shamanIcon():DisplayObject
		{
			return new RedShamanIcon();
		}
	}
}