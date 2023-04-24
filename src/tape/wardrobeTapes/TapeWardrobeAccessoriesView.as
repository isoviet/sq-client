package tape.wardrobeTapes
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import dialogs.DialogShop;
	import game.gameData.ClothesManager;
	import loaders.RuntimeLoader;
	import screens.ScreenWardrobe;
	import tape.TapeData;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;
	import tape.shopTapes.TapeShopClothes;

	public class TapeWardrobeAccessoriesView extends TapeSelectableView
	{
		//private var fieldEmpty:GameField = null;
		private var type:int = 0;

		public function TapeWardrobeAccessoriesView(type:int)
		{
			super(6, 1, 10, 0, 10, 0, 110, 120);

			this.type = type;

			var buttonShop:SimpleButton = new ButtonWardrobeBuyClothes();
			var array:Array = [buttonShop.upState, buttonShop.overState, buttonShop.downState];
			for (var i:int = 0 ; i < array.length; i++)
			{
				var sprite:Sprite = new Sprite();
				sprite.addChild(array[i]);
				array[i] = sprite;

				var field:GameField = new GameField(gls("Купить"), 0, -57, new TextFormat(GameField.PLAKAT_FONT, 16, 0xF54C38));
				field.x = -field.textWidth * 0.5;
				array[i].addChild(field);

				field = new GameField(gls("ещё больше\nаксессуаров"), 0, -37, new TextFormat(GameField.PLAKAT_FONT, 10, 0x663300));
				field.x = -field.textWidth * 0.5;
				array[i].addChild(field);
			}

			buttonShop = new SimpleButton(array[0], array[1], array[2], array[2]);
			buttonShop.x = -55;
			buttonShop.y = 60;
			buttonShop.addEventListener(MouseEvent.CLICK, showShop);
			addChild(buttonShop);

			/*this.fieldEmpty = new GameField(gls("У тебя ещё нет ни одного предмета этого типа"), 0, 50, new TextFormat(GameField.PLAKAT_FONT, 16, 0xFFFFFF));
			this.fieldEmpty.x = 450 - int(this.fieldEmpty.textWidth * 0.5);
			addChild(this.fieldEmpty);
		}

		override public function setData(data:TapeData):void
		{
			super.setData(data);

			this.fieldEmpty.visible = this.data.objects.length == 0;*/
		}

		override protected function placeButtons():void
		{
			super.placeButtons();

			this.buttonPrevious.x = -this.buttonPrevious.width - 121;
			this.buttonPrevious.y = this.topMargin + (this.numRows * (this.objectHeight + this.offsetY) - this.offsetY) * 0.5
			- this.buttonPrevious.height * 0.5;
			this.buttonNext.x = this.leftMargin * 2 + this.numColumns * (this.objectWidth + this.offsetX)
			- this.offsetX + 1;
			this.buttonNext.y = this.topMargin + (this.numRows * (this.objectHeight + this.offsetY) - this.offsetY) * 0.5
			- this.buttonNext.height * 0.5;
		}

		override protected function updateInfo(selected:TapeSelectableObject):void
		{
			if (selected == null)
				return;
			ScreenWardrobe.tryOn(ClothesManager.KIND_ACCESORIES, selected.id);
		}

		private function showShop(e:MouseEvent):void
		{
			RuntimeLoader.load(function ():void
			{
				TapeShopClothes.selectType(type);
				DialogShop.selectTape(DialogShop.ACCESSORIES);
			});
		}
	}
}