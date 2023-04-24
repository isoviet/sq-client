package tape
{
	import flash.display.Sprite;

	import tape.events.TapeElementEvent;

	public class TapeObject extends Sprite
	{
		public function TapeObject():void
		{}

		public function get loaded():Boolean
		{
			return true;
		}

		public function onShow():void
		{}

		public function onClick():void
		{}

		public function listen(listener:Function):void
		{
			addEventListener(TapeElementEvent.CHANGED, listener);
		}

		public function forget(listener:Function):void
		{
			removeEventListener(TapeElementEvent.CHANGED, listener);
		}
	}
}