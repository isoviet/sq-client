package events
{
	import flash.events.Event;

	public class EditNewElementEvent extends Event
	{
		static public const NEW:String = "EditElement.new";
		static public const ADD:String = "EditElement.add";
		static public const REMOVE:String = "EditElement.remove";
		static public const SELECT:String = "EditElement.select";
		static public const CHANGE:String = "EditElement.change";

		public var className:*;

		public function EditNewElementEvent(className:*, type:String = NEW):void
		{
			super(type);

			this.className = className;
		}
	}
}