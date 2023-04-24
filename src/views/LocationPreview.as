package views
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class LocationPreview extends Sprite
	{
		private var _selectedName:String = "";
		private var moviePreload:MovieClip = null;
		private var loader:Loader = null;
		private var context:LoaderContext;

		public function LocationPreview():void
		{
			this.moviePreload = new MoviePreload();
			this.moviePreload.x = int((320 - this.moviePreload.width) * 0.5);
			this.moviePreload.y = int((145 - this.moviePreload.height) * 0.5);
			addChild(this.moviePreload);

			this.context = new LoaderContext(false, ApplicationDomain.currentDomain);

			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
			this.addChild(this.loader);
		}

		public function set previewClip(previewName:String):void
		{

			if (previewName == "")
			{
				this.visible = false;
				return;
			}

			this.visible = true;

			this._selectedName = previewName;
			this.moviePreload.visible = true;

			trace(previewName);

			this.loader.load(new URLRequest(Config.PREVIEWS_URL + previewName + ".swf?36"), context);

		}

		private function onLoad(e:Event):void
		{
			this.moviePreload.visible = false;
		}

		public function get selectedName():String
		{
			return _selectedName;
		}
	}
}