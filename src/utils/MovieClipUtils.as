package utils
{
	import flash.display.MovieClip;

	import utils.MovieClipUtils;

	public class MovieClipUtils
	{
		static public function playAll(clip:MovieClip, playFrame:int = 1):void
		{
			for (var k:int = 0; k < clip.numChildren; k++)
			{
				var innerClip:MovieClip = clip.getChildAt(k) as MovieClip;
				if (innerClip)
					playAll(innerClip, playFrame);
			}
			clip.gotoAndPlay(playFrame);
		}

		static public function playOnceAndStop(clip:MovieClip, stopFrame:int = -1, callback:Function = null):void
		{
			clip.addFrameScript(clip.totalFrames-1, function():void
			{
				stopAll(clip, stopFrame == -1 ? clip.totalFrames-1 : stopFrame);
				if(callback != null)
					callback();
			});

			playAll(clip, 1);
		}

		static public function stopAll(clip:MovieClip, stopFrame:int = 1):void
		{
			clip.stopAllMovieClips();
			clip.gotoAndStop(stopFrame);
			for (var k:int = 0; k < clip.numChildren; k++)
			{
				var innerClip:MovieClip = clip.getChildAt(k) as MovieClip;
				if (innerClip)
				{

					MovieClipUtils.stopAll(innerClip, stopFrame);
				}

			}
		}
	}
}