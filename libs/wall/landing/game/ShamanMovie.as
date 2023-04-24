package landing.game
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import events.MovieClipPlayCompleteEvent;

	public class ShamanMovie extends MovieClip
	{
		private var movie:HeroShaman = new HeroShaman();

		private var repeat:int = 4;
		private var count:int = 0;

		public function ShamanMovie():void
		{
			this.movie.stop();
			addChild(this.movie);
		}

		private function onEnterFrame(e:Event):void
		{
			if (this.count >= repeat)
				stop();

			if (this.movie.currentFrame != 11)
				return;

			this.count++;
			this.movie.gotoAndPlay(4);
		}

		override public function play():void
		{
			this.count = 0;

			this.movie.gotoAndStop(0);
			this.movie.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.movie.play();
		}

		override public function stop():void
		{
			this.movie.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			this.movie.gotoAndPlay(12);

			var event:MovieClipPlayCompleteEvent = new MovieClipPlayCompleteEvent(MovieClipPlayCompleteEvent.SHAMAN);
			dispatchEvent(event);
		}
	}
}