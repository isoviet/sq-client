package tape
{
	import flash.display.DisplayObject;

	import game.mainGame.entity.EntityFactory;
	import statuses.Status;

	public class TapeShamanElement extends TapeObject
	{
		static private const BUTTON_WIDTH:int = 48;
		static private const BUTTON_HEIGHT:int = 38;

		protected var button:DisplayObject;
		public var status:Status = null;
		public var className:Class;

		public function TapeShamanElement(className:Class, buttonClassName:Class = null):void
		{
			super();

			this.className = className;

			if (buttonClassName == null)
				buttonClassName = TapeEditButton;

			var icon:DisplayObject = EntityFactory.getIconByClass(className);
			icon.x += int((BUTTON_WIDTH - icon.width) / 2) + ((icon is IceBox1 || icon is IceBox2) ? 4 : 0);
			icon.y += int((BUTTON_HEIGHT - icon.height) / 2) + ((icon is IceBox1 || icon is IceBox2) ? 3 : 0);
			addChild(icon);

			this.button = new buttonClassName() as DisplayObject;
			addChild(this.button);

			this.status = new Status(this, EntityFactory.getTitle(className), false);
		}
	}
}