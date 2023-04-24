package utils
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Animation extends Bitmap
	{
		public var frames:Array;
		public var currentFrame:Number = 0;

		public function Animation(_clip:MovieClip = null):void
		{
			if (_clip == null)
				return;

			this.smoothing = true;
			buildCacheFromClip(_clip);
		}

		public function get totalFrames():Number
		{
			return frames.length;
		}

		public function buildCacheFromClip(clip:MovieClip):void
		{
			this.smoothing = true;
			this.scaleX = (clip.scaleX < 0 ? -Math.abs(this.scaleX) : Math.abs(this.scaleX));
			this.scaleY = (clip.scaleY < 0 ? -Math.abs(this.scaleY) : Math.abs(this.scaleY));

			this.frames = AnimationDataCollector.addBitmapData(clip);
		}

		public function play():void
		{
			gotoAndStop(currentFrame);
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}

		public function stop():void
		{
			gotoAndStop(currentFrame);
			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}

		public function gotoAndStop(frame:Number):void
		{
			currentFrame = Math.round(frame);
			bitmapData = frames[currentFrame];

			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}

		public function gotoAndPlay(frame:Number):void
		{
			currentFrame = Math.round(frame);
			bitmapData = frames[currentFrame];

			addEventListener(Event.ENTER_FRAME, enterFrame);
		}

		public function enterFrame(e:Event):void
		{
			currentFrame++;
			if (currentFrame >= totalFrames)
				currentFrame = 0;
			showFrame(currentFrame);
		}

		private function showFrame(frame:Number):void
		{
			currentFrame = Math.round(frame);
			bitmapData = frames[currentFrame];
		}
	}
}