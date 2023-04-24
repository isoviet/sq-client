package tape.shopTapes
{
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import dialogs.Dialog;
	import tape.TapeData;
	import tape.TapeSelectableObject;
	import tape.TapeSelectableView;

	public class TapeShopDrink extends TapeSelectableView
	{
		public var fieldName:GameField = null;
		public var fieldInfo:GameField = null;

		private var spriteDescription:Sprite = new Sprite();

		public function TapeShopDrink():void
		{
			super(4, 1, 25, 65, 10, 10, 210, 280);
		}

		override public function setData(data:TapeData):void
		{
			super.setData(data);

			if (data.objects.length != 0)
				select(data.objects[0] as TapeSelectableObject);
			else
				select(null);
		}

		override protected function updateInfo(selected:TapeSelectableObject):void
		{
			if (selected == null)
				return;

			this.fieldName.text = DrinkItemsData.getTitle(selected.id);
			this.fieldInfo.text = DrinkItemsData.getDescription(selected.id);

			while (this.spriteDescription.numChildren > 0)
				this.spriteDescription.removeChildAt(0);
		}

		override protected function init():void
		{
			super.init();

			addChildAt(new ImageShopPotionBack(), 0);

			this.fieldName = new GameField("", 30, 400, Dialog.FORMAT_CAPTION_16);
			this.fieldName.filters = Dialog.FILTERS_CAPTION;
			addChild(this.fieldName);

			this.fieldInfo = new GameField("", 30, 430, new TextFormat(null, 14, 0x68361B, true));
			addChild(this.fieldInfo);

			addChild(this.spriteDescription);
		}
	}
}