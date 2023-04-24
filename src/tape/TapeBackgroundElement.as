package tape
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;

	import game.mainGame.Backgrounds;

	public class TapeBackgroundElement extends TapeObject
	{
		static private const BUTTON_WIDTH:int = 38;
		static private const BUTTON_HEIGHT:int = 33;

		public var id:int;

		public function TapeBackgroundElement(className:String):void
		{
			super();

			this.id = Backgrounds.getId(className);

			addChild(new TapeEditButton);

			var imageClass:Class = getDefinitionByName(className) as Class;

			var icon:DisplayObject = new imageClass();
			icon.width = BUTTON_WIDTH;
			icon.height = BUTTON_HEIGHT;
			icon.x = int((50 - icon.width) / 2);
			icon.y = int((40 - icon.height) / 2);
			addChild(icon);
		}
	}
}