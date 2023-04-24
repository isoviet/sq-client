package
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;

	public class TimeSyncMovieClip extends MovieClip
	{
		public function TimeSyncMovieClip()
		{
			super();
			this.gotoAndPlay(0);
			MovieClipSync.sync(this);
		}
	}
}
