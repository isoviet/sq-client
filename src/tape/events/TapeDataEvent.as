package tape.events
{
	import flash.events.Event;

	import tape.TapeData;

	public class TapeDataEvent extends Event
	{
		static public const UPDATE:String = "TapeDataEvent.UPDATE";

		public var data:TapeData;

		public function TapeDataEvent(type:String, data:TapeData):void
		{
			super(type);

			this.data = data;
		}
	}
}