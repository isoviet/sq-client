package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import events.ScreenEvent;
	import loaders.RuntimeLoader;
	import screens.ScreenLocation;
	import screens.Screens;

	public class DialogDiscountPackage extends Dialog
	{
		static private var showed:Boolean = false;

		public function DialogDiscountPackage():void
		{
			super(null, false, false, null, false);

			init();
		}

		private function init():void
		{
			var view:DialogPackageBack = new DialogPackageBack();
			view.buttonShop.addEventListener(MouseEvent.CLICK, showShop);
			addChild(view);

			addChild(new GameField(gls("Теперь ты можешь выбрать любой костюм\nв магазине и носить его абсолютно\nбесплатно. Для этого нажми на значок\nвешалки в правом верхнем углу костюма."), 25, 220, new TextFormat(null, 14, 0x000000, true)));

			place();
		}

		override public function show():void
		{
			if (showed)
				return;

			if (ScreenLocation._firstShow)
				Screens.instance.addEventListener(ScreenEvent.SHOW, onScreenChanged);
			else
			{
				super.show();
				showed = true;
			}
		}

		private function onScreenChanged(e:ScreenEvent):void
		{
			Screens.instance.removeEventListener(ScreenEvent.SHOW, onScreenChanged);

			if (showed)
				return;
			super.show();
			showed = true;
		}

		private function showShop(e:MouseEvent):void
		{
			hide();

			RuntimeLoader.load(function():void
			{
				DialogShop.selectTape(DialogShop.PACKAGES);
			});
		}
	}
}