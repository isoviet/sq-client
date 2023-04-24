package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;

	public class ComboBoxView extends Sprite
	{
		public var callback:Function = null;

		protected var value:int = 0;

		private var buttonBuy:ButtonBase = null;
		private var arrow:PackageComboBoxArrow = null;

		private var spriteTop:Sprite = new Sprite();
		private var sprite:Sprite = new Sprite();

		private var fieldTime:GameField = null;
		private var fieldPrice:GameField = null;

		private var fieldDiscountValue:GameField = null;
		private var fieldDiscountBack:DisplayObject = null;

		public function ComboBoxView():void
		{

			init();
		}

		public function set inverse(value:Boolean):void
		{
			this.sprite.y = value ? int(4 - this.sprite.height) : 25;
		}

		protected function buy(e:MouseEvent):void
		{
			if (this.callback != null)
				this.callback.apply();
		}

		protected function getPrice(value:int):int
		{
			return 0;
		}

		protected function get names():Array
		{
			return [];
		}

		protected function get discounts():Array
		{
			return [];
		}

		private function init():void
		{
			this.buttonBuy = new ButtonBase(gls("Купить"), 80);
			this.buttonBuy.x = 130;
			this.buttonBuy.addEventListener(MouseEvent.CLICK, buy);
			addChild(this.buttonBuy);

			this.spriteTop.graphics.beginFill(0xFFFFFF);
			this.spriteTop.graphics.lineStyle(1, 0xE2D2B9);
			this.spriteTop.graphics.drawRoundRectComplex(0, 3, 105, 22, 4, 0, 4, 0);
			addChild(this.spriteTop);

			this.fieldTime = new GameField("", 45, 5, new TextFormat(null, 12, 0x9E6D58, true));
			this.spriteTop.addChild(this.fieldTime);

			this.fieldDiscountBack = new ComboBoxDiscountImage();
			this.fieldDiscountBack.x = 72;
			this.fieldDiscountBack.y = 6;
			this.spriteTop.addChild(this.fieldDiscountBack);

			this.fieldDiscountValue = new GameField("", 73, 6, new TextFormat(GameField.PLAKAT_FONT, 11, 0xFFFFFF, true));
			this.spriteTop.addChild(this.fieldDiscountValue);

			var image:ImageIconCoins = new ImageIconCoins();
			image.x = 5;
			image.y = 5;
			image.scaleX = image.scaleY = 0.7;
			this.spriteTop.addChild(image);

			this.fieldPrice = new GameField("", 20, 5, new TextFormat(null, 12, 0x5D3828, true));
			this.spriteTop.addChild(this.fieldPrice);

			this.arrow = new PackageComboBoxArrow();
			this.arrow.x = 105;
			this.arrow.scaleY =  -1;
			this.arrow.y = int(3 + this.arrow.height);
			this.arrow.buttonMode = true;
			this.spriteTop.addChild(this.arrow);

			this.spriteTop.addEventListener(MouseEvent.MOUSE_DOWN, switchView);

			this.sprite.y = 25;
			this.sprite.graphics.beginFill(0xFFFFFF);
			this.sprite.graphics.lineStyle(1, 0xE2D2B9);
			this.sprite.graphics.drawRoundRectComplex(0, 0, 106, this.names.length * 25, 4, 4, 4, 4);
			this.sprite.visible = false;
			addChild(this.sprite);

			for (var i:int = 0; i < this.names.length; i++)
			{
				if (i != 0)
				{
					this.sprite.graphics.moveTo(0, 25 * i);
					this.sprite.graphics.lineTo(106, 25 * i);
				}

				var spriteValue:Sprite = new Sprite();
				spriteValue.mouseChildren = false;
				spriteValue.graphics.beginFill(0xFFFFFF, 0);
				spriteValue.graphics.drawRect(0, 0, 106, 25);

				spriteValue.addChild(new GameField(this.names[i], 45, 5, new TextFormat(null, 12, 0x9E6D58, true)));

				image = new ImageIconCoins();
				image.x = 5;
				image.y = 5;
				image.scaleX = image.scaleY = 0.7;
				spriteValue.addChild(image);

				spriteValue.addChild(new GameField(getPrice(i).toString(), 20, 5, new TextFormat(null, 12, 0x5D3828, true)));
				spriteValue.name = i.toString();

				if (this.discounts[i] != 0)
				{
					var discountImage:ComboBoxDiscountImage = new ComboBoxDiscountImage();
					discountImage.x = 72;
					discountImage.y = 5;
					spriteValue.addChild(discountImage);

					spriteValue.addChild(new GameField("-" + this.discounts[i] + "%", 72, 5, new TextFormat(GameField.PLAKAT_FONT, 11, 0xFFFFFF, true)));
				}

				spriteValue.y = 25 * i;
				this.sprite.addChild(spriteValue);

				spriteValue.buttonMode = true;
				spriteValue.addEventListener(MouseEvent.MOUSE_DOWN, select);
				spriteValue.addEventListener(MouseEvent.MOUSE_OVER, over);
				spriteValue.addEventListener(MouseEvent.MOUSE_OUT, out);
			}

			onChange();

			Game.stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDown);
		}

		private function stageDown(e:MouseEvent):void
		{
			if (this.sprite.visible)
				switchView();
		}

		private function out(e:MouseEvent):void
		{
			var sprite:Sprite = e.currentTarget as Sprite;

			sprite.graphics.clear();
			sprite.graphics.beginFill(0xFFFFFF, 0);
			sprite.graphics.drawRect(0, 0, 106, 25);
		}

		private function over(e:MouseEvent):void
		{
			var sprite:Sprite = e.currentTarget as Sprite;

			sprite.graphics.clear();
			sprite.graphics.beginFill(0xFFDC74, 0.2);
			sprite.graphics.drawRoundRectComplex(0, 0, 106, 25, 2, 2, 2, 2);
		}

		private function select(e:MouseEvent):void
		{
			this.value = int(e.currentTarget.name);

			onChange();

			switchView();
		}

		private function switchView(e:MouseEvent = null):void
		{
			if (e)
				e.stopImmediatePropagation();
			this.sprite.visible = !this.sprite.visible;

			this.arrow.scaleY = this.arrow.scaleY * -1;
			this.arrow.y = int(this.arrow.scaleY > 0 ? 3 : (3 + this.arrow.height));
		}

		private function onChange():void
		{
			this.fieldTime.text = this.names[this.value];
			this.fieldPrice.text = getPrice(this.value).toString();

			this.fieldDiscountValue.text = this.discounts[this.value] != 0 ? ("-" + this.discounts[this.value] + "%") : "";
			this.fieldDiscountBack.visible = this.discounts[this.value] != 0;
		}
	}
}