package dialogs.site
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import loaders.ScreensLoader;
	import screens.ScreenProfile;
	import screens.ScreenWardrobe;
	import views.PackageImageLoader;

	public class DialogDailyBonusPackageSite extends Dialog
	{
		public function DialogDailyBonusPackageSite(packageIds:Array):void
		{
			super(gls("Поздравляем!"));

			init(packageIds);
		}

		private function init(packageIds:Array):void
		{
			addChild(new GameField(gls("Ты получил костюмы: {0}, {1} на 24 часа.\nЗайди в гардероб и скорее примерь их!",
				ClothesData.getPackageTitleById(packageIds[0]), ClothesData.getPackageTitleById(packageIds[1])), 20, 0,
				new TextFormat(null, 12, 0x000000, false, null, null, null, null, "center")));

			var back:DialogDailyBonusBack = new DialogDailyBonusBack();
			back.x = 140;
			back.y = 135;
			addChild(back);

			var image:PackageImageLoader = new PackageImageLoader(packageIds[0]);
			image.scaleX = image.scaleY = 0.9;
			image.x = 130;
			image.y = 25;
			addChild(image);

			image= new PackageImageLoader(packageIds[1]);
			image.scaleX = -0.9;
			image.scaleY = 0.9;
			image.x = 245;
			image.y = 25;
			addChild(image);

			var button:ButtonBase = new ButtonBase(gls("Гардероб"));
			button.addEventListener(MouseEvent.CLICK, showWardrobe);

			place(button);

			this.height += 50;

			back.x = this.width/2-28;
			back.y = 138;
		}

		private function showWardrobe(e:MouseEvent):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenWardrobe.instance);
		}
	}
}