package game
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class SpitAnimation extends MovieClip
	{
		private var bubbleView:SpitAnimationView;

		public function SpitAnimation():void
		{
			this.bubbleView = new SpitAnimationView();
			this.bubbleView.visible = false;
			this.bubbleView.x = 80;
			this.bubbleView.addEventListener(Event.CHANGE, reset);
			addChild(this.bubbleView);

			this.mouseEnabled = false;
			this.mouseChildren = false;
		}

		public function activate():void
		{
			reset();

			this.bubbleView.visible = true;
			this.bubbleView.gotoAndPlay(0);
		}

		public function reset(e:Event = null):void
		{
			this.bubbleView.visible = false;
		}
	}
}