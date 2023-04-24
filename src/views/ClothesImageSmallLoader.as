package views
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class ClothesImageSmallLoader extends Sprite
	{
		static private var datas:Object = {};

		private var id:int = -1;
		private var loaded:Boolean = false;

		private var movieLoader:MovieClip = null;
		private var image:Loader = new Loader();

		private var urlLoader:URLLoader;

		public function ClothesImageSmallLoader(id:int, instant:Boolean = true):void
		{
			this.id = id;

			this.movieLoader = new MoviePreload();
			this.movieLoader.x = (70 - 36) * 0.5;
			this.movieLoader.y = (60 - 36) * 0.5;
			addChild(this.movieLoader);

			this.image.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			this.image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.image.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			addChild(this.image);

			if (instant)
				load();
		}

		override public function get width():Number
		{
			return 70 * this.scaleX;
		}

		override public function get height():Number
		{
			return 60 * this.scaleY;
		}

		public function load():void
		{
			if (this.loaded)
				return;
			this.loaded = true;

			if (this.id in datas)
			{
				var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				this.image.loadBytes(datas[this.id], context);
				return;
			}

			var cache:String = this.id in ClothesData.IMAGES_CACHE_SMALL ? ClothesData.IMAGES_CACHE_SMALL[this.id] : "";

			this.urlLoader = new URLLoader();
			this.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			this.urlLoader.addEventListener(Event.COMPLETE, onLoaded);
			this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.urlLoader.load(new URLRequest(Config.IMAGES_URL + "clothes/accessories_small/ImageAccessorySmall_" + this.id + cache + ".png"));
		}

		private function onLoaded(e:Event):void
		{
			if ((e.currentTarget as URLLoader).data.length == 0)
				return;

			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			this.image.loadBytes((e.currentTarget as URLLoader).data, context);

			datas[this.id] = (e.currentTarget as URLLoader).data;
		}

		private function onImageLoaded(e:Event):void
		{
			for (var i:int = 0; i < this.image.numChildren; i++)
			{
				if (!(this.image.getChildAt(i) is Bitmap))
					continue;
				(this.image.getChildAt(i) as Bitmap).smoothing = true;
			}
			this.movieLoader.visible = false;
		}

		private function onError(e:Event):void
		{
			Logger.add("Failed to load ClothesImage[Event]:" + e.toString());
		}
	}
}