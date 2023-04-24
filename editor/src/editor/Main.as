package editor
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class Main extends Sprite
	{
		public function Main():void
		{
			if (this.stage != null)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			var form:MainForm = new MainForm();
			this.stage.addChild(form);
		}
	}
}