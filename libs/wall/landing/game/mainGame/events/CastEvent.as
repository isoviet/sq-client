package landing.game.mainGame.events
{
	import flash.events.Event;

	public class CastEvent extends Event
	{
		static public const CASTED:String = "CastEvent.CASTED";
		static public const SELECT:String = "CastEvent.SELECT";

		public var objectId:*;

		public function CastEvent(type:String, objectId:*):void
		{
			super(type);

			this.objectId = objectId;
		}
	}
}