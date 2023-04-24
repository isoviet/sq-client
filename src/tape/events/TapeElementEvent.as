package tape.events
{
	import flash.events.Event;

	import tape.TapeObject;

	public class TapeElementEvent extends Event
	{
		static public const SELECTED:String = "SELECTED";
		static public const DESELECTED:String = "DESELECTED";
		static public const STICKED:String = "STICKED";
		static public const CHANGED:String = "CHANGED";

		static public const DRESSED:String = "DRESSED";
		static public const UNDRESSED:String = "UNDRESSED";

		public var element:TapeObject;

		public function TapeElementEvent(element:TapeObject, type:String = SELECTED):void
		{
			super(type);

			this.element = element;
		}
	}
}