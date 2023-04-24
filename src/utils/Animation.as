package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.geom.Point;

	public class Animation extends Bitmap
	{
		public var frames:Array;
		public var loop:Boolean = true;
		public var speed:Number = 1;
		public var isPlaying:Boolean = false;
		private var script:Function = null;
		private var scriptFrame:int = -1;

		private var clip:* = null;
		private var frame:Number = 0;

		public function Animation(_clip:* = null):void
		{
			if (_clip == null)
				return;

			this.smoothing = true;
			this.pixelSnapping = PixelSnapping.ALWAYS;
			buildCacheFromClip(_clip);
		}

		public function remove():void
		{
			stop();
			this.frames = null;
		}

		public function get currentFrame():int
		{
			return int(frame);
		}

		public function set currentFrame(value:int):void
		{
			frame = Number(value);
		}

		public function get totalFrames():int
		{
			return this.frames ? this.frames.length : 0;
		}

		public function buildCacheFromClip(clip:*, rasterAll:Boolean = true, preraster:Boolean = false):void
		{
			this.clip = clip;

			if (clip is MovieClip)
			{
				clip.stop();
				this.scaleX = (clip.scaleX < 0 ? -Math.abs(this.scaleX) : Math.abs(this.scaleX));
				this.scaleY = (clip.scaleY < 0 ? -Math.abs(this.scaleY) : Math.abs(this.scaleY));
			}

			this.frames = AnimationDataCollector.addBitmapData(clip, rasterAll);

			if (preraster && !rasterAll)
				EnterFrameManager.addListener(rasterizeNextFrame, 1);
		}

		public function play():void
		{
			if (this.isPlaying)
				return;

			gotoAndPlay(currentFrame);
		}

		public function stop():void
		{
			gotoAndStop(currentFrame);
		}

		public function gotoAndStop(frame:int):void
		{
			if (!this.frames)
				return;

			currentFrame = frame;
			updateBmd();

			EnterFrameManager.removeListener(enterFrame);
			this.isPlaying = false;
		}

		public function addFrameScript(frame:int, script:Function):void
		{
			this.script = script;
			this.scriptFrame = frame;
		}

		public function gotoAndPlay(frame:int):void
		{
			currentFrame = frame;
			updateBmd();

			EnterFrameManager.addListener(enterFrame);
			this.isPlaying = true;
		}

		public function enterFrame():void
		{
			if (!this.frames)
				return;

			this.frame += this.speed;
			if (currentFrame >= this.totalFrames)
			{
				if (loop)
					currentFrame -= this.totalFrames;
				else
				{
					currentFrame = this.totalFrames - 1;
					stop();
					dispatchEvent(new Event("Complete"));
				}
			}

			if (scriptFrame == currentFrame && script != null)
				script();

			showFrame(currentFrame);
		}

		public function hitTest(point:Point):Boolean
		{
			return (this.frames ? (this.frames[currentFrame] as BitmapData).hitTest(new Point(), 0xFF, globalToLocal(point)) : false);
		}

		protected function showFrame(frame:int):void
		{
			if (frame >= this.totalFrames)
				frame = this.totalFrames - 1;
			else if (frame < 0)
				frame = 0;

			//currentFrame = frame;
			updateBmd();

		}

		private function rasterizeNextFrame():void
		{
			if (!this.frames)
				return;

			if (this.isPlaying)
			{
				EnterFrameManager.removeListener(rasterizeNextFrame);
				return;
			}

			for (var i:int = 0; i < this.totalFrames; i++)
			{
				if (this.frames[i])
					continue;

				AnimationDataCollector.rasterizeFrame(this.clip, i);
				return;
			}

			if (i == this.totalFrames)
				EnterFrameManager.removeListener(rasterizeNextFrame);
		}

		private function updateBmd():void
		{
			if (currentFrame < 0 || currentFrame >= this.totalFrames)
			{
				Logger.add("OUT OF RANGE: Trying to rasterize frame " + currentFrame, this.totalFrames, this.clip);
				return;
			}

			if (this.frames && this.frames[currentFrame] == null) {
				AnimationDataCollector.rasterizeFrame(clip, currentFrame);

			}

			if (!this.frames)
				return;

			bitmapData = this.frames[currentFrame];
			this.smoothing = true;
			this.pixelSnapping = PixelSnapping.ALWAYS;
		}
	}
}