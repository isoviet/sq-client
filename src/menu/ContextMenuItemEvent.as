package menu
{
	import flash.events.Event;

	public class ContextMenuItemEvent extends Event
	{
		static public const NAME:String = "ContextMenuItemSelect";

		public var item:ContextMenuItem;

		public function ContextMenuItemEvent(item:ContextMenuItem):void
		{
			super(NAME);

			this.item = item;
		}
	}
}