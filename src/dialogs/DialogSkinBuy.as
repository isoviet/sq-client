package dialogs
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;

	import buttons.ButtonBase;
	import game.gameData.ClothesManager;
	import loaders.ScreensLoader;
	import screens.ScreenProfile;
	import screens.ScreenWardrobe;
	import views.PackageImageLoader;

	import com.greensock.TweenMax;

	import utils.ColorMatrix;

	public class DialogSkinBuy extends Dialog
	{
		private var id:int = -1;
		private var back:MovieClip = null;
		private var container:MovieClip = null;

		public function DialogSkinBuy(id:int)
		{
			super("", false);

			this.id = id;

			this.back = addChildAt(new DialogSkinBuyBack(), 0) as MovieClip;
			this.back.addFrameScript(30, onStopClip);
			this.back.gotoAndPlay(1);

			addChild(new GameField(ClothesData.getPackageTitleById(this.id), 0, 12, Dialog.FORMAT_CAPTION_18_CENTER, 362)).filters = Dialog.FILTERS_CAPTION;

			var clothesLoader:PackageImageLoader = new PackageImageLoader(this.id);
			this.container = new MovieClip();
			this.container.addChild(clothesLoader);
			this.container.x = 182;
			this.container.y = 185;
			addChild(container);

			clothesLoader.x = - clothesLoader.width/2;
			clothesLoader.y = - clothesLoader.height/2;
			this.container.scaleX = this.container.scaleY = 0;

			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(200, 0, 0, 0);
			this.container.filters = [new ColorMatrixFilter(colorMatrix)];
			this.container.alpha = 0.1;
			//
			var meanFrameRate:Number = 24;

			TweenMax.to(this.container, 21/meanFrameRate, {rotation:2*360, scaleX:1, scaleY:1, alpha:1, colorMatrixFilter:{'brightness': 1}});
			TweenMax.to(this.container, 4/meanFrameRate, {delay:21/meanFrameRate, scaleX:1, scaleY:0.9, y:195, repeat:1, yoyo:true});

			var buttonBuy:ButtonBase = new ButtonBase(gls("Надеть"));
			buttonBuy.x = int((back.width - buttonBuy.width) * 0.5);
			buttonBuy.y = 382;
			buttonBuy.addEventListener(MouseEvent.CLICK, onClick);
			addChild(buttonBuy);

			place();

			this.buttonClose.x -= 15;
			this.buttonClose.y += 5;
		}

		private function onStopClip():void
		{
			this.back.stopAllMovieClips();
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 0;
			this.rightOffset = 0;
			this.topOffset = 0;
			this.bottomOffset = 0;
		}

		private function onClick(e:MouseEvent):void
		{
			ScreenProfile.setPlayerId(Game.selfId);
			ScreensLoader.load(ScreenWardrobe.instance);

			DialogShop.instance.hide();

			hide();

			ClothesManager.wear(ClothesManager.KIND_PACKAGES, this.id);
			ScreenWardrobe.tryOn(ClothesManager.KIND_PACKAGES, this.id);
		}
	}
}