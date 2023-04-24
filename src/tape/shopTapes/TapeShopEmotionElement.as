package tape.shopTapes
{
	import flash.text.TextFormat;

	import events.GameEvent;
	import game.gameData.EmotionManager;
	import views.EmotionBarView;
	import views.widgets.RibbonEdgeView;

	public class TapeShopEmotionElement extends TapeShopElement
	{
		protected var ribbonEdgeView:RibbonEdgeView = null;

		public function TapeShopEmotionElement(itemId:int):void
		{
			super(itemId);

			EmotionManager.addEventListener(GameEvent.SMILES_CHANGED, onChange);
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
			this.backSelected = new ElementPackageBackSelectedGreen();
			this.backSelected.width = backWidth;
			this.backSelected.height = backHeight;
			this.backSelected.visible = false;
			addChild(this.backSelected);

			this.back = new ElementPackageBack();
			this.back.width = this.backWidth;
			this.back.height = this.backHeight;
			addChild(this.back);

			this.fieldTitle = new GameField(this.title, 5, 10, this.titleFormat);
			this.fieldTitle.width = this.backWidth - 10;
			this.fieldTitle.wordWrap = true;
			this.fieldTitle.selectable = false;
			addChild(this.fieldTitle);

			this.fieldTitle.y -= 7;

			this.image = new ImageSmilePack0();
			this.image.x = int((this.backWidth - this.image.width) * 0.5);
			this.image.y = int((this.backHeight - this.image.height) * 0.5) + 5;
			addChild(this.image);

			this.ribbonEdgeView = new RibbonEdgeView(RibbonEdgeView.SKIN_BOUGHT);
			this.ribbonEdgeView.x = 13;
			this.ribbonEdgeView.y = 100;
			this.ribbonEdgeView.scaleX = this.ribbonEdgeView.scaleY = 0.8;
			addChild(this.ribbonEdgeView);

			onChange();
		}

		private function onChange(e:GameEvent = null):void
		{
			this.ribbonEdgeView.visible = EmotionBarView.isBoughtPack(this.id);
		}

		override protected function get titleFormat():TextFormat
		{
			return new TextFormat(null, 12, 0x663300, true, null, null, null, null, "center");
		}

		override protected function get title():String
		{
			return EmotionManager.PACKS_NAME[this.id];
		}
	}
}