package
{
	import avmplus.getQualifiedClassName;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class MovieClipSync
	{
		private var clip:MovieClip;
		private var fps:Number;
		private var total:uint;
		private var timeBuffer:Number = 0;
		private var frameLength:Number;

		public function MovieClipSync(mc:MovieClip, fps:Number = 60)
		{
			trace("Sync:" + mc.name + " " + getQualifiedClassName(mc));
			this.clip = mc;
			this.fps = fps;
			this.frameLength = 1.0/fps;
			total = getTimer();
			mc.addEventListener(Event.EXIT_FRAME, onEnterFrame);
		}

		static public function sync(root:DisplayObject, fps:Number = 60)
		{
			if(root is MovieClip)
			{
				var clip:MovieClip = root as MovieClip;
				if (clip.totalFrames > 1)
					new MovieClipSync(root as MovieClip, fps);
			}

			if (root is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = root as DisplayObjectContainer;
				for(var i:int = 0; i < container.numChildren; i++)
				{
					sync(container.getChildAt(i), fps);
				}
			}
		}

		private function onEnterFrame(event:Event):void
		{
			var curTime:uint = getTimer();
			var elapsedSeconds:Number = (curTime - total)/1000.0;
			total = curTime;
			timeBuffer += elapsedSeconds;
			var framesElapsed:int = Math.floor(timeBuffer / frameLength);
			timeBuffer -= framesElapsed * frameLength;
			for(var i:int = 1; i < framesElapsed; i++)
			{
				if (clip.isPlaying)
					clip.gotoAndPlay(clip.currentFrame + 1);
			}
		}
	}
}

