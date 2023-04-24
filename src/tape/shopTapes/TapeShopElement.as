package tape.shopTapes
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import tape.TapeSelectableObject;

	import utils.FieldUtils;

	public class TapeShopElement extends TapeSelectableObject
	{
		protected var image:*;
		protected var discount:Sprite;
		protected var fieldTitle:GameField = null;
		protected var _bought:Boolean = false;
		protected var buttonArray:Vector.<ButtonBase> = new <ButtonBase>[];

		public function TapeShopElement(itemId:int):void
		{
			super(itemId);

			this.buttonMode = true;

			initImages();

			this.bought = this.isBought;

			if (this.discountValue == 0)
				return;
			initDiscount(this.discountValue);
		}

		protected function get titleFormat():TextFormat
		{
			return new TextFormat(null, 16, 0x663300, true, null, null, null, null, "center");
		}

		protected function get backWidth():int
		{
			return 210;
		}

		protected function get backHeight():int
		{
			return 280;
		}

		protected function get cost():int
		{
			return 0;
		}

		protected function get extraCost():int
		{
			return 0;
		}

		protected function initImages():void
		{
			this.backSelected = new ElementPackageBackSelected();
			this.backSelected.width = this.backWidth;
			this.backSelected.height = this.backHeight;
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
		}

		override public function listen(listener:Function):void
		{}

		override public function forget(listener:Function):void
		{}

		override public function onShow():void
		{
			if (this.image)
				this.image.cacheAsBitmap = true;
		}

		public function set bought(value:Boolean):void
		{
			if (this._bought == value)
				return;
			this._bought = value;
			if (this.discount)
				this.discount.visible = !value;
		}

		protected function get discountValue():Number
		{
			return 0;
		}

		protected function get isBought():Boolean
		{
			return false;
		}

		protected function initDiscount(value:int):void
		{
			if (this.discount)
			{
				removeChild(this.discount);
				this.discount = null;
			}

			if (value == 0)
				return;

			this.discount = new Sprite();
			this.discount.mouseEnabled = false;
			this.discount.mouseChildren = false;
			addChild(this.discount);

			var discountImage:DiscountImage = new DiscountImage();
			this.discount.addChild(discountImage);

			var fieldDiscount:GameField = new GameField("", 0, 20, new TextFormat(null, 14, 0xFFFFFF, true));
			fieldDiscount.text = "-" + value + "%";
			fieldDiscount.x = int((discountImage.width - fieldDiscount.width) * 0.5);
			fieldDiscount.rotation = -10;
			this.discount.addChild(fieldDiscount);
		}

		protected function get title():String
		{
			return "";
		}

		protected function get imageClass():Class
		{
			return null;
		}

		protected function addButton(price:int, iconClass:Class, callback:Function):void
		{
			var button:ButtonBase = new ButtonBase(price + " - ", 80);
			button.y = this.backHeight - int(button.height * 0.5) - 5;
			button.addEventListener(MouseEvent.CLICK, callback, false, 0, true);
			addChild(button);

			FieldUtils.replaceSign(button.field, "-", iconClass, 0.7, 0.7, -button.field.x, -3, false, false);

			this.buttonArray.push(button);
			var offset:int = (this.backWidth - this.buttonArray.length * (button.width + 10) + 10) * 0.5;
			for (var i:int = 0; i < this.buttonArray.length; i++)
				this.buttonArray[i].x = offset + i * (button.width + 10);
		}
	}
}