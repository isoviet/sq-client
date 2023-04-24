package tape
{
	import flash.display.DisplayObject;

	import game.mainGame.entity.EntityFactory;
	import statuses.Status;

	public class TapeEditElement extends TapeObject
	{
		static private const BUTTON_WIDTH:int = 50;
		static private const BUTTON_HEIGHT:int = 40;

		public var className:Class;

		public function TapeEditElement(className:Class, statusWidth:int = 145):void
		{
			this.className = className;

			super();

			addChild(new TapeEditButton);

			var icon:DisplayObject = EntityFactory.getIconByClass(className);
			icon.x += int((BUTTON_WIDTH - icon.width) / 2) + ((icon is IceBox1 || icon is IceBox2) ? 4 : 0);
			icon.y += int((BUTTON_HEIGHT - icon.height) / 2) + ((icon is IceBox1 || icon is IceBox2) ? 3 : 0);
			addChild(icon);

			var status:Status = new Status(this, EntityFactory.getTitle(className));
			status.maxWidth = statusWidth;
		}
	}
}