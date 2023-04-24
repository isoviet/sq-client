package events
{
	import flash.events.Event;

	import buttons.ButtonTab;

	public class ButtonTabEvent extends Event
	{
		static public const SELECT:String = "ButtonRadioSelect";
		static public const CHANGE:String = "ButtonRadioChange";
		static public const CLICK:String = "ButtonRadioClick";

		public var button:ButtonTab;

		public function ButtonTabEvent(name:String, button:ButtonTab = null):void
		{
			super(name);

			this.button = button;
		}
	}
}