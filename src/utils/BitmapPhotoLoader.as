package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	import starling.display.Image;

	import utils.starling.StarlingAdapterSprite;

	public class BitmapPhotoLoader extends StarlingAdapterSprite
	{
		private var loader:Loader = null;
		private var url:String = "";

		private var imageWidth:int = 50;
		private var imageHeight:int = 50;

		private var currentImage:Bitmap = null;

		private var defaultImage:BitmapData = null;
		private var currentImageStarling:StarlingAdapterSprite = new StarlingAdapterSprite();

		public function BitmapPhotoLoader(url:String, x:int, y:int, width:int, height:int, defaultImage:BitmapData):void
		{
			super();
			this.currentImage = new Bitmap();
			this.currentImage.smoothing = true;
			addChildAt(this.currentImage, 0);
			addChildStarling(this.currentImageStarling);

			this.imageWidth = width;
			this.imageHeight = height;

			this.x = x;
			this.y = y;

			this.url = url;
			this.defaultImage = defaultImage;

			if (checkCollector(url))
				return;

			this.currentImageBitmapData = defaultImage;

			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFail);
			this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFail);

			try
			{
				if (this.url != "")
					this.loader.load(new URLRequest(this.url), new LoaderContext(true));
			}
			catch (e: Error)
			{
				Logger.add('BitmapPhotoLoader->super: ' + e.message);
			}
		}

		public function dispose():void
		{
			currentImageStarling.removeFromParent(true);
		}

		public function load(url:String):void
		{
			if (url == this.url)
				return;

			reset();

			if (url == "")
				return;

			this.url = url;

			if (checkCollector(url))
				return;
			try
			{
				this.loader.load(new URLRequest(this.url), new LoaderContext(true));
			}
			catch (e: Error)
			{
				Logger.add('BitmapPhotoLoader->load: ' + e.message);
			}
		}

		private function reset():void
		{
			this.url = "";

			currentImageStarling.removeFromParent(true);

			while (currentImageStarling.numChildren > 0)
			{
				currentImageStarling.removeChildStarlingAt(0);
			}

			if (this.currentImage.bitmapData == this.defaultImage)
				return;

			removeChild(this.currentImage);

			this.currentImageBitmapData = this.defaultImage;
			addChildAt(this.currentImage, 0);
		}

		private function onLoad(e:Event):void
		{
			if (this.currentImage != null && contains(this.currentImage))
				removeChild(this.currentImage);

			try
			{
				this.currentImageBitmapData = BitmapPhotoCollector.addBitmapData(this.url, (this.loader.content as Bitmap).bitmapData);
				if (this.currentImage != null)
					addChildAt(this.currentImage, 0);
			}
			catch (error:Error)
			{
				Logger.add('BitmapPhotoLoader->onLoad:' + error.message);
			}
		}

		private function set currentImageBitmapData(bitmapData:BitmapData):void
		{
			this.currentImage.bitmapData = bitmapData;

			this.currentImage.width = Math.min(this.currentImage.width, this.imageWidth);
			this.currentImage.height = Math.min(this.currentImage.height, this.imageHeight);

			this.currentImage.scaleY = this.currentImage.scaleX = Math.min(this.currentImage.scaleX, this.currentImage.scaleY);

			this.currentImage.x = int((this.imageWidth - this.currentImage.width) / 2);
			this.currentImage.y = int((this.imageHeight - this.currentImage.height) / 2);

			currentImageStarling.removeFromParent(true);

			currentImageStarling = new StarlingAdapterSprite();
			currentImageStarling.getStarlingView().addChild(Image.fromBitmap(new Bitmap(bitmapData)));
			addChildStarling(currentImageStarling);
		}

		private function checkCollector(url:String):Boolean
		{
			var bitmapData:BitmapData = BitmapPhotoCollector.addBitmapData(url);
			if (!bitmapData)
				return false;

			this.currentImageBitmapData = bitmapData;
			return true;
		}

		private function onFail(e:Event):void
		{
			Logger.add("PhotoLoader: Fail to load url: ", this.url);

			reset();
		}
	}
}