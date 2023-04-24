package events
{
	import flash.events.Event;

	import screens.Screen;

	public class ScreenEvent extends Event
	{
		static public const SHOW:String = "ScreenEvent.show";
		static public const HIDE:String = "ScreenEvent.hide";

		public var screen:Screen;

		public function ScreenEvent(type:String, screen:Screen):void
		{
			super(type);
			this.screen = screen;
		}
	}
}