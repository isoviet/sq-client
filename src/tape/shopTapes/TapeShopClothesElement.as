package tape.shopTapes
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.ClothesManager;
	import game.gameData.GameConfig;
	import views.ClothesImageSmallLoader;
	import views.widgets.RibbonEdgeView;

	import utils.FieldUtils;

	public class TapeShopClothesElement extends TapeShopElement
	{
		protected var imageLoader:ClothesImageSmallLoader = null;
		protected var spritePrice:Sprite = null;
		protected var ribbonEdgeView:RibbonEdgeView = null;

		public function TapeShopClothesElement(itemId:int):void
		{
			super(itemId);

			ClothesManager.addEventListener(GameEvent.CLOTHES_STORAGE_CHANGE, update);
		}

		override protected function get backWidth():int
		{
			return 110;
		}

		override protected function get backHeight():int
		{
			return 115;
		}

		override protected function initImages():void
		{
			super.initImages();

			this.fieldTitle.y -= 7;
			this.spritePrice = new Sprite();
			addChild(this.spritePrice);

			var field:GameField = new GameField(this.cost + " -", 0, this.backHeight - 25, new TextFormat(null, 14, 0x8C5736, true));
			field.x = int((this.width - field.textWidth) * 0.5);
			this.spritePrice.addChild(field);

			FieldUtils.replaceSign(field, "-", ImageIconCoins, 0.55, 0.55, -field.x, -field.y - 1, false, false);

			this.ribbonEdgeView = new RibbonEdgeView(RibbonEdgeView.SKIN_BOUGHT);
			this.ribbonEdgeView.x = 13;
			this.ribbonEdgeView.y = 100;
			this.ribbonEdgeView.scaleX = this.ribbonEdgeView.scaleY = 0.8;
			addChild(this.ribbonEdgeView);

			update();
		}

		private function update(e:GameEvent = null):void
		{
			this.ribbonEdgeView.visible = ClothesManager.accessoriesIds.indexOf(this.id) != -1;
			this.spritePrice.visible = ClothesManager.accessoriesIds.indexOf(this.id) == -1;
		}

		override public function onShow():void
		{
			if (this.imageLoader)
				return;
			this.imageLoader = new ClothesImageSmallLoader(this.id);
			this.imageLoader.x = 20;
			this.imageLoader.y = 35;
			addChild(this.imageLoader);
		}

		override protected function get titleFormat():TextFormat
		{
			return new TextFormat(null, 12, 0x663300, true, null, null, null, null, "center");
		}

		override protected function get isBought():Boolean
		{
			return ClothesManager.accessoriesIds.indexOf(this.id) != -1;
		}

		override protected function get title():String
		{
			return ClothesData.getTitleById(this.id);
		}

		override protected function get cost():int
		{
			return GameConfig.getAccessoryCoinsPrice(this.id);
		}
	}
}