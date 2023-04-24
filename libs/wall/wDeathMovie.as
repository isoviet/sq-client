package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import events.MovieClipPlayCompleteEvent;

	public class wDeathMovie extends MovieClip
	{
		private var movie:wHeroDead = new wHeroDead();

		public function wDeathMovie():void
		{
			this.movie.stop();
			addChild(movie);
		}
		
		override public function play():void
		{
			this.movie.gotoAndPlay(0);
			this.movie.addEventListener(Event.ENTER_FRAME, onEnterMovieFrame);
		}	

		override public function stop():void
		{
			this.movie.removeEventListener(Event.ENTER_FRAME, onEnterMovieFrame);

			this.movie.stop();

			dispatchEvent(new MovieClipPlayCompleteEvent(MovieClipPlayCompleteEvent.DEATH));
		}

		private function onEnterMovieFrame(e:Event):void
		{
			if (this.movie.currentFrame == 45)
				stop();
		}
	}
}