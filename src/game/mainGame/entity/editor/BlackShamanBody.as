package game.mainGame.entity.editor
{
	import flash.display.DisplayObject;

	public class BlackShamanBody extends ShamanBody
	{
		override protected function get shamanIcon():DisplayObject
		{
			return new BlackShamanIcon();
		}
	}
}