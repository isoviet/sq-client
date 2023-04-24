package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import statuses.Status;

	import com.api.Services;

	public class DialogOfferQuest extends Dialog
	{
		static private const FILTER:Array = [new GlowFilter(0xFFFFCC, 1, 12, 12, 2, BitmapFilterQuality.MEDIUM)];

		private var offer:Object = null;

		private var bannerLoader:Loader = new Loader();
		private var urlLoader:URLLoader;

		protected var banner:Sprite;

		protected var success:Function;

		protected var bannerWidth:int = 288;
		protected var bannerHeight:int = 256;

		protected var frame:DisplayObject;

		public function DialogOfferQuest():void
		{
			super("", false, false);

			this.bannerLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBanerLoaded);
			this.bannerLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.bannerLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			init();
		}

		override public function show():void
		{
			update();
			super.show();

			if (!this.contains(this.frame))
				addChild(this.frame);
		}

		public function setOffers(offers:Array, success:Function):void
		{
			this.offer = offers[0];

			this.success = success;
			loadPhoto(this.offer['Banner']);
		}

		public function update():void
		{
			place();

			this.width = 620;
			this.height = 455;
			this.x += 40;
		}

		override protected function effectOpen():void
		{}

		protected function loadPhoto(url:String):void
		{
			this.urlLoader = new URLLoader();
			this.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			this.urlLoader.addEventListener(Event.COMPLETE, onLoaded);
			this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.urlLoader.load(new URLRequest(url));
		}

		private function init():void
		{
			var background:DialogOfferQuestBackground = new DialogOfferQuestBackground();
			background.scaleX = background.scaleY = 1.1;
			background.x = -5;
			background.y = -28;
			addChildAt(background, 0);

			var buttonCross:ButtonCross = new ButtonCross();
			buttonCross.x = 470;
			buttonCross.y = 82;
			buttonCross.addEventListener(MouseEvent.CLICK, hide);
			addChild(buttonCross);

			this.banner = new Sprite();
			this.banner.x = 168;
			this.banner.y = 129;
			this.banner.addEventListener(MouseEvent.CLICK, showOffer);
			this.banner.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.banner.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			this.banner.buttonMode = true;
			new Status(this.banner, gls("Заработать монетки"), true);
			addChild(this.banner);

			this.frame = new OfferFrameImage();
			this.frame.x = 121;
			this.frame.y = 86;
		}

		protected function showOffer(e:MouseEvent):void
		{
			Services.showOfferBox(this.offer['LeadID']);
		}

		private function onOver(e:MouseEvent):void
		{

			this.banner.filters = FILTER;
		}

		private function onOut(e:MouseEvent):void
		{
			this.banner.filters = null;
		}

		private function onLoaded(e:Event):void
		{
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

			this.bannerLoader.loadBytes((e.currentTarget as URLLoader).data, context);
		}

		private function onBanerLoaded(e:Event):void
		{
			this.bannerLoader.width = this.bannerWidth;
			this.bannerLoader.height = this.bannerHeight;

			this.banner.addChild(this.bannerLoader);
			this.success();
		}

		private function onError(e:Event):void
		{
			Logger.add("Failed to load banner:" + e.toString());
		}
	}
}