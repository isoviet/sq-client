package events
{
	import flash.events.Event;

	public class LearningEvent extends Event
	{
		static public const NAME:String = "learning";

		public var step:int = 0;

		public function LearningEvent(step:int)
		{
			super(NAME);

			this.step = step;
		}
	}
}