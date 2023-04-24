package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.OutfitData;
	import loaders.ScreensLoader;
	import screens.ScreenProfile;
	import screens.ScreenWardrobe;
	import views.ProfileHero;

	public class DialogDailyBonusPackage extends Dialog
	{
		public function DialogDailyBonusPackage(packageId:int):void
		{
			super(gls("Поздравляем!"));

			init(packageId);
		}

		private function init(packageId:int):void
		{
			addChild(new GameField(gls("Ты получил {0} на 24 часа.\nЗайди в гардероб и скорее примерь его!", ClothesData.getPackageTitleById(packageId)), 20, 0, new TextFormat(null, 12, 0x000000, false, null, null, null, null, "center")));

			var back:DialogDailyBonusBack = new DialogDailyBonusBack();
			back.x = 140;
			back.y = 135;
			addChild(back);

			var hero:ProfileHero = new ProfileHero();
			hero.setClothes([packageId]);
			hero.view = OutfitData.getOwnerById(packageId);
			hero.enableUpdate = false;
			hero.x = 145;
			hero.y = 215;
			addChild(hero);

			var button:ButtonBase = new ButtonBase(gls("Гардероб"));
			button.addEventListener(MouseEvent.CLICK, showWardrobe);

			place(button);

			this.height += 50;
		}

		private function showWardrobe(e:MouseEvent):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenWardrobe.instance);
		}
	}
}