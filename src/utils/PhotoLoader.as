package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public class PhotoLoader extends Sprite
	{
		private var loader:Loader = null;
		private var url:String = "";

		private var imageWidth:int = 50;
		private var imageHeight:int = 50;

		private var currentImage:DisplayObject = null;

		private var defaultImageClass:Class = null;

		private var rasterized:Boolean = false;

		public function PhotoLoader(url:String, x:int, y:int, width:int, height:int, defaultImageClass:Class = null, rasterize:Boolean = false):void
		{
			if (defaultImageClass != null)
			{
				this.defaultImageClass = defaultImageClass;

				this.rasterized = rasterize;

				var defaultImage:DisplayObject = new this.defaultImageClass();

				var rastredImage:Bitmap = null;
				if (this.rasterized)
				{
					var bitmapData:BitmapData = new BitmapData(width + 1, height + 1, true, 0x00FFFFFF);
					bitmapData.draw(defaultImage, new Matrix(width / defaultImage.width, 0, 0, height / defaultImage.height, 0, 0));

					rastredImage = new Bitmap(bitmapData);
					rastredImage.smoothing = true;

					Logger.add("rastredImage");
					this.currentImage = rastredImage;
				}
				else
				{
					defaultImage.width = width;
					defaultImage.height = height;

					Logger.add("defaultImage");
					this.currentImage = defaultImage;
				}

				addChild(this.currentImage);
			}

			this.imageWidth = width;
			this.imageHeight = height;

			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFail);
			this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFail);

			this.url = url;

			if (this.url != "")
				this.loader.load(new URLRequest(this.url), new LoaderContext(true));

			this.x = x;
			this.y = y;
		}

		public function loadBytes(bytes:ByteArray):void
		{
			reset();

			this.url = "loaded_from_bytes";

			this.loader.loadBytes(bytes);
		}

		public function load(url:String):void
		{
			if (url.indexOf('http:') > -1)
				url = url.replace('http', 'https');

			if (url == this.url)
				return;

			reset();

			if (url == "")
				return;

			this.url = url;
			try
			{
				this.loader.load(new URLRequest(this.url), new LoaderContext(true));
			}
			catch(e: Error)
			{
				Logger.add('PhotoLoader->load:' + e.message);
				Logger.add('this.url: ' + this.url);
			}
		}

		public function reset():void
		{
			this.url = "";

			Logger.add("reset");
			if (this.defaultImageClass == null)
			{
				if (this.currentImage != null)
				{
					removeChild(this.currentImage);
					this.currentImage = null;
				}

				return;
			}

			if ((this.currentImage != null) && !(this.currentImage is this.defaultImageClass))
			{
				removeChild(this.currentImage);
				this.currentImage = null;
			}

			if (this.currentImage != null)
				return;

			var defaultImage:DisplayObject = new this.defaultImageClass();
			defaultImage.width = this.imageWidth;
			defaultImage.height = this.imageHeight;

			var rastredImage:Bitmap = null;
			if (this.rasterized)
			{
				var bitmapData:BitmapData = new BitmapData(defaultImage.width + 1, defaultImage.height + 1, true, 0x00FFFFFF);
				bitmapData.draw(defaultImage);

				rastredImage = new Bitmap(bitmapData);
				rastredImage.smoothing = true;

				this.currentImage = rastredImage;
			}
			else
				this.currentImage = defaultImage;

			addChild(this.currentImage);
		}

		private function onLoad(e:Event):void
		{
			try
			{
				this.loader.content.width = Math.min(loader.content.width, this.imageWidth);
				this.loader.content.height = Math.min(loader.content.height, this.imageHeight);
				this.loader.content.scaleY = this.loader.content.scaleX = Math.min(this.loader.content.scaleX, this.loader.content.scaleY);
				this.loader.content.x = (this.imageWidth - this.loader.content.width) / 2;
				this.loader.content.y = (this.imageHeight - this.loader.content.height) / 2;

				Logger.add("onLoad", this.currentImage, this.currentImage ? contains(this.currentImage) : "null");
				if (this.currentImage != null && contains(this.currentImage))
					removeChild(this.currentImage);

				(this.loader.content as Bitmap).smoothing = true;
				this.currentImage = this.loader;
				addChild(this.currentImage);
			}
			catch(error: Error)
			{
				Logger.add('PhotoLoader->onLoad' + error.message);
			}
		}

		private function onFail(e:Event):void
		{
			Logger.add("PhotoLoader: Fail to load url: ", this.url);

			reset();
		}
	}
}