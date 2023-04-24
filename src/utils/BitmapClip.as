package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BitmapClip extends Bitmap
	{
		public var frames:Array = null;
		public var currentFrame:int = 0;
		public var loop:Boolean = true;
		public var speed:Number = 1;
		public var isPlaying:Boolean = false;

		private var script:Function = null;
		private var scriptFrame:int = -1;

		static private var point:Point = null;

		/**
		 * заменяет векторный клип растровым, со всеми параметрами исходного
		 * @param _clip исходный векторный клип
		 * @param smoothing размытие
		 * @param transparent прозрачность
		 * @param padding набивка, используется если на клип наложен фильтр
		 * @return растрированный клип
		 */
		static public function replace(_clip:MovieClip, smoothing:Boolean=false, transparent:Boolean = true,
			padding:Number = 0):BitmapClip
		{
			var isPlaying:Boolean = _clip.isPlaying;
			var frame:int = _clip.currentFrame;
			var _visible:Boolean = _clip.visible;
			_clip.visible = true;

			var bitmapClip:BitmapClip = new BitmapClip(_clip, smoothing, transparent, padding);

			if(_clip.parent != null)
			{
				var container:DisplayObjectContainer = _clip.parent as DisplayObjectContainer;
				var index:int = container.getChildIndex(_clip);
				container.removeChild(_clip);
				container.addChildAt(bitmapClip, index);
			}

			var matrix:Matrix = new Matrix();
			matrix.translate(point.x*_clip.scaleX+_clip.x, point.y*_clip.scaleY+_clip.y);
			bitmapClip.transform.matrix = matrix;
			point = null;

			if(_clip.totalFrames == 1)
				bitmapClip.stop();
			else if(isPlaying)
				bitmapClip.gotoAndPlay(frame);
			else
				bitmapClip.gotoAndStop(frame);

			bitmapClip.name = _clip.name;
			bitmapClip.visible = _visible;

			_clip = null;
			return bitmapClip;
		}

		/**
		 * создает растровый клип на основе векторного
		 * @param _clip векторный клип
		 * @param smoothing размытие
		 * @param transparent прозрачность
		 * @param padding набивка, используется если на клип наложен фильтр
		 * @param cut обрезать прямоугольником
		 */
		public function BitmapClip(_clip:MovieClip, smoothing:Boolean = true, transparent:Boolean = true,
			padding:Number = 0, cut:Rectangle = null):void
		{
			if (_clip == null)
				return;

			this.smoothing = smoothing;
			this.pixelSnapping = PixelSnapping.ALWAYS;

			_clip.stop();
			this.scaleX = (_clip.scaleX < 0 ? -Math.abs(this.scaleX) : Math.abs(this.scaleX));
			this.scaleY = (_clip.scaleY < 0 ? -Math.abs(this.scaleY) : Math.abs(this.scaleY));

			if(_clip.totalFrames == 1)
			{
				this.currentFrame = 1;
				bitmapData = rasterizeFrames(_clip, padding, smoothing, transparent, cut)[0];
			}
			else
				this.frames = rasterizeFrames(_clip, padding, smoothing, transparent, cut);

			gotoAndStop(1);
		}

		public function remove():void
		{
			stop();
			this.frames = null;
		}

		public function get totalFrames():int
		{
			return this.frames ? this.frames.length : 1;
		}

		public function play():void
		{
			if(!this.frames || this.isPlaying)
				return;

			gotoAndPlay(this.currentFrame);
		}

		public function stop():void
		{
			gotoAndStop(this.currentFrame);
		}

		public function gotoAndStop(frame:int):void
		{
			if (!this.frames)
				return;

			this.currentFrame = frame;
			updateBmd();

			EnterFrameManager.removeListener(enterFrame);
			this.isPlaying = false;
		}

		public function addFrameScript(frame:int, script:Function):void
		{
			if(!this.frames)
				return;

			this.script = script;
			this.scriptFrame = frame;
		}

		public function gotoAndPlay(frame:int):void
		{
			if(!this.frames)
				return;

			this.currentFrame = frame;
			updateBmd();

			EnterFrameManager.addListener(enterFrame);
			this.isPlaying = true;
		}

		public function enterFrame():void
		{
			if (!this.frames || this.visible == false)
				return;

			this.currentFrame += Math.round(this.speed);

			if (this.currentFrame > this.totalFrames)
			{
				if (loop)
					this.currentFrame = 1;
				else
				{
					this.currentFrame = this.totalFrames;
					stop();
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}

			if (scriptFrame == this.currentFrame && script != null)
				script();

			showFrame(this.currentFrame);
		}

		public function hitTest(point:Point):Boolean
		{
			return (this.frames ? (this.frames[this.currentFrame-1] as BitmapData).hitTest(new Point(),
				0xFF, globalToLocal(point)) : false);
		}

		protected function showFrame(frame:int):void
		{
			if (frame > this.totalFrames)
				frame = this.totalFrames;
			else if (frame < 1)
				frame = 1;

			this.currentFrame = frame;
			updateBmd();

		}

		private function rasterizeFrames(_clip:MovieClip, padding:Number, smoothing:Boolean, transparent:Boolean,
			rect:Rectangle = null):Array
		{
			var r:Rectangle = rect;

			if(rect == null)
			{
				r = _clip.getRect(_clip);
				for (var i:int = 0; i < _clip.totalFrames; i++)
				{
					_clip.gotoAndStop(i + 1);
					var c:Rectangle = _clip.getRect(_clip);
					if (c.width > r.width) r.width = c.width;
					if (c.height > r.height) r.height = c.height;
					if (c.x < r.x) r.x = c.x;
					if (c.y < r.y) r.y = c.y;
				}
			}
			else
				_clip.scrollRect = rect;

			var frames:Array = [];

			var m:Matrix = new Matrix();
			m.translate(-r.x, -r.y);
			m.scale(Math.abs(_clip.scaleX), Math.abs(_clip.scaleY));
			m.translate(padding, padding);
			point = new Point(r.x, r.y);

			for (i = 0; i < _clip.totalFrames; i++)
			{
				_clip.gotoAndStop(i + 1);

				for (var k:int = 0; k < _clip.numChildren; k++)
				{
					var clip:MovieClip = _clip.getChildAt(k) as MovieClip;
					if (clip == null)
						continue;

					clip.nextFrame();
					if(clip.currentFrame == clip.totalFrames)
						clip.gotoAndPlay(1);
				}

				var bitmapData:BitmapData = new BitmapData(r.width * Math.abs(_clip.scaleX) + padding*2,
					r.height * Math.abs(_clip.scaleY) + padding*2, transparent, 0x00000000);

				bitmapData.draw(_clip, m, null, null, rect, smoothing);
				frames.push(bitmapData);
			}
			return frames;
		}

		private function updateBmd():void
		{
			if (!this.frames)
				return;

			bitmapData = this.frames[this.currentFrame-1];

		}
	}
}