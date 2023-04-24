package utils.starling
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;

	import avmplus.getQualifiedClassName;

	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.textures.Texture;

	import utils.starling.collections.DisplayObjectManager;
	import utils.starling.collections.ImageCollection;
	import utils.starling.collections.TextureCollection;
	import utils.starling.extensions.virtualAtlas.AssetManager;
	import utils.starling.utils.StarlingConverter;

	public class StarlingAdapterMovie extends StarlingAdapterSprite
	{
		static public const MAX_FPS:int = 30;
		public var frames:Array;
		public var currentFrame:Number = 0;
		public var loop:Boolean = true;
		public var isPlaying:Boolean = false;
		public var _maxFPS:int = MAX_FPS;
		private var frameStop:int = -1;
		private var clip:* = null;
		private var currentFrameCounter:Number = 0;
		private var globalFrameRate:int = Game.stage.frameRate;
		private var _offsetFrameCount:int = 0;
		private var _collectionImage:ImageCollection = ImageCollection.getInstance();
		private var _collectionTexture:TextureCollection = TextureCollection.getInstance();
		private var _className:String;
		private var quadBatch:QuadBatch = new QuadBatch();
		private var itemCache:Vector.<StarlingItem>;
		private var _dispose: Boolean = true;

		public function StarlingAdapterMovie(_clip:* = null, dispose: Boolean = false):void
		{
			super();
			if (_clip == null)
				return;

			this.clip = _clip;
			createMovieClip(dispose);
		}

		public function reload(): void
		{
			stop();
			removeCache();
			createMovieClip(_dispose);
		}

		override public function removeFromParent(dispose:Boolean = true): void
		{
			if (dispose)
			{
				removeCache();
				itemCache = null;
			}

			stop();
			super.removeFromParent(dispose);
		}

		public function get offsetFrameCount():int
		{
			return _offsetFrameCount;
		}

		public function set offsetFrameCount(value:int):void
		{
			_offsetFrameCount = value;
		}

		public function get totalFrames():Number
		{
			return this.itemCache ? this.itemCache.length : 0;
		}

		public function buildCacheFromClip(clip:*, rasterAll:Boolean = true):void
		{
			if (clip is MovieClip)
			{
				clip.stop();
				this.scaleX = (clip.scaleX < 0 ? -Math.abs(this.scaleX) : Math.abs(this.scaleX));
				this.scaleY = (clip.scaleY < 0 ? -Math.abs(this.scaleY) : Math.abs(this.scaleY));
			}

			this.frames = AnimationDataCollector.addBitmapData(clip, rasterAll);
		}

		public function set maxFPS(value:int):void
		{
			if (value < 0) value = 0;
			if (value > MAX_FPS) value = MAX_FPS;
			_maxFPS = value;
		}

		public function get maxFPS():int
		{
			return _maxFPS;
		}

		public function play():void
		{
			if (this.isPlaying)
				return;

			gotoAndPlay(this.currentFrame);
		}

		public function stop():void
		{
			gotoAndStop(this.currentFrame);
		}

		public function gotoAndStop(frame:int):void
		{
			if (!totalFrames)
				return;

			this.currentFrame = frame;

			EnterFrameManager.removeListener(enterFrame);
			this.isPlaying = false;
			showFrame(this.currentFrame);
		}

		public function gotoAndPlay(frame:int):void
		{
			this.currentFrame = frame;

			EnterFrameManager.addListener(enterFrame);
			this.isPlaying = true;
		}

		public function playAndStop(frameStart:int, frameStop:int):void
		{
			if (frameStop < 0) frameStop = 0;

			this.currentFrame = frameStart;
			this.frameStop = frameStop;
			EnterFrameManager.addListener(enterFrame);
			this.isPlaying = true;
		}

		public function enterFrame():void
		{
			if (!totalFrames)
				return;

			currentFrameCounter += (maxFPS / globalFrameRate);
			if (currentFrameCounter >= 1)
			{
				currentFrameCounter--;
				this.currentFrame++;
			}

			if (this.currentFrame >= this.totalFrames)
			{
				if (loop)
				{
					this.currentFrame -= this.totalFrames;
					if (_offsetFrameCount > 0) this.currentFrame = _offsetFrameCount;
				}
				else
				{
					this.currentFrame = this.totalFrames - 1;
					stop();
					dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
			}

			if (frameStop > -1 && frameStop == Math.round(this.currentFrame))
			{
				stop();
				dispatchEvent(new Event(Event.COMPLETE));
				frameStop = -1;
				return;
			}

			showFrame(this.currentFrame);
			dispatchEvent(new Event(Event.ENTER_FRAME));
		}

		public function hitTest(point:Point):Boolean
		{
			return (this.frames ? (this.frames[this.currentFrame] as BitmapData).hitTest(new Point(), 0xFF, globalToLocal(point)) : false);
		}

		protected function showFrame(frame:Number):void
		{
			if (frame >= this.totalFrames)
				frame = this.totalFrames - 1;
			else if (frame < 0)
				frame = 0;

			this.currentFrame = Math.round(frame);

			if (this.totalFrames > 0 && quadBatch)
			{
				quadBatch.reset();
				quadBatch.addImage(this.itemCache[this.currentFrame].item);
			}
		}

		private function removeCache(): void
		{
			this.frames = [];
			var removedItems: Vector.<StarlingItem> = new Vector.<StarlingItem>();
			if (itemCache) {
				for (var i:int = 0, j: int = itemCache.length; i < j; i++) {
					if (itemCache[i].dispose) {
						removedItems.push(itemCache[i]);
						DisplayObjectManager.getInstance().remove(itemCache[i].item);
						itemCache[i].item.removeFromParent(true);
					}
				}
				for(i = 0, j = removedItems.length; i < j; i++) {
					var index: int = itemCache.indexOf(removedItems[i]);
					if (index > -1) {
						itemCache.splice(itemCache.indexOf(removedItems[i]), 1);
					}
				}
			}
			removedItems = null;
		}

		private function createMovieClip(dispose: Boolean = false): void
		{
			var texture: Texture = AssetManager.instance.getTexture(this.clip);
			if (texture != null)
			{
				this.addChildStarling(new Image(texture));
				_dispose = true;
			}
			else
			{
				_dispose = dispose;
				convertToStarling();
			}

			this.addChildStarling(quadBatch);
		}

		private function convertToStarling():void
		{
			this._className = getQualifiedClassName(this.clip);
			itemCache = _collectionImage.getItem(this._className);
			var textures: Vector.<StarlingItem> = _collectionTexture.getItem(this._className);
			var image: Image;
			var texture: Texture;

			if (!itemCache.length || !textures.length)
			{
				if (!textures.length || itemCache.length > textures.length)
				{
					itemCache = new Vector.<StarlingItem>();
					_collectionImage.remove(this._className, null);
				}

				buildCacheFromClip(this.clip);
				for (var i:int = 0, j: int = this.frames.length; i < j; i++)
				{
					if (textures.length > 0 && i < textures.length)
					{
						image = new Image(textures[i].item);
					}
					else
					{
						texture = StarlingConverter.textureFromBitmapData(this.frames[i]);
						image = new Image(texture);
						_collectionTexture.add(this._className, texture, false, StarlingConverter.getCallee());
					}

					image.scaleX = image.scaleY = 1 / StarlingConverter.scaleFactor;
					_collectionImage.add(this._className, image, _dispose);
				}

				itemCache = _collectionImage.getItem(this._className);
			}

			if (itemCache.length > 0)
				quadBatch.addImage(itemCache[0].item);

			quadBatch.pivotX = -(this.clip as MovieClip).getBounds(this.clip).x;
			quadBatch.pivotY = -(this.clip as MovieClip).getBounds(this.clip).y;

			this.currentFrame = 0;
		}
	}
}