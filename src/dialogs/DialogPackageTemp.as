package dialogs
{
	import flash.events.MouseEvent;

	import loaders.ScreensLoader;
	import screens.ScreenProfile;
	import screens.ScreenWardrobe;
	import views.PackageImageLoader;

	public class DialogPackageTemp extends Dialog
	{
		private var id:int = 0;

		public function DialogPackageTemp(id:int):void
		{
			super(null, false, false, null, false);

			this.id = id;

			init();
		}

		private function init():void
		{
			var view:DialogPackageTempBack = new DialogPackageTempBack();
			view.buttonClose.addEventListener(MouseEvent.CLICK, hide);
			view.buttonWardrobe.addEventListener(MouseEvent.CLICK, showWardrobe);
			addChild(view);

			var image:PackageImageLoader = new PackageImageLoader(this.id);
			image.x = 40;
			image.y = 100;
			addChild(image);

			place();
		}

		private function showWardrobe(event:MouseEvent):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenWardrobe.instance);
		}
	}
}