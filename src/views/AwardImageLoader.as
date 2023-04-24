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

	public class AwardImageLoader extends Sprite
	{
		static private var datas:Object = {};

		private var id:int = -1;
		private var loaded:Boolean = false;

		private var movieLoader:MovieClip = null;
		private var image:Loader = new Loader();

		private var urlLoader:URLLoader;

		public function AwardImageLoader(id:int, instant:Boolean = true):void
		{
			this.id = id;

			this.movieLoader = new MoviePreload();
			this.movieLoader.x = (100 - 36) * 0.5;
			this.movieLoader.y = (100 - 36) * 0.5;
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
			return 100 * this.scaleX;
		}

		override public function get height():Number
		{
			return 100 * this.scaleY;
		}

		override public function set width(value:Number):void
		{
			super.scaleX = value / 100;
		}

		override public function set height(value:Number):void
		{
			super.scaleY = value / 100;
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

			this.urlLoader = new URLLoader();
			this.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			this.urlLoader.addEventListener(Event.COMPLETE, onLoaded);
			this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.urlLoader.load(new URLRequest(Config.IMAGES_URL + "award/" + Award.DATA[this.id]['image'] + ".png"));
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