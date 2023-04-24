package utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	public class PopUpMessage extends Sprite
	{
		static private const COLOR_FILL:int = 0xECF1F7;

		private var symbol:SimbolMessageImage = new SimbolMessageImage();
		private var innerSymbol:InnerSimbolMessageImage = new InnerSimbolMessageImage();

		private var text:GameField;
		private var image:DisplayObject = null;

		private var windowWidth:int = 0;
		private var windowHeight:int = 0;

		public function PopUpMessage(text:String, toggle:Boolean = false, textWidth:int = 175, image:DisplayObject = null, imageX:int = 0, imageY:int = 0):void
		{
			var textSize:int = 14;
			if (toggle)
			{
				textSize = 12;
				textWidth = 300;

			}
			var textFormat:TextFormat = new TextFormat(null, textSize, 0x193C6D, true);

			if (image != null)
			{
				this.image = image;
				this.image.x = imageX;
				this.image.y = imageY;
				addChild(this.image);
			}

			this.innerSymbol.width = 15;
			addChild(innerSymbol);
			addChild(symbol);

			this.text = new GameField(text, 10, 15, textFormat);
			this.text.width = textWidth;
			this.text.wordWrap = true;
			addChild(this.text);

			draw();
		}

		public function draw():void
		{
			this.windowWidth = Math.floor(super.width);
			this.windowHeight = Math.floor(super.height);

			this.graphics.clear();
			this.graphics.lineStyle(2, 0x193c6d);
			this.graphics.beginFill(COLOR_FILL);
			this.graphics.drawRoundRectComplex(0, 2, this.windowWidth + 10, this.windowHeight + 13, 5, 5, 5, 5);
			this.graphics.endFill();

			this.innerSymbol.x = 0;
			this.innerSymbol.y = int(this.windowHeight - this.symbol.height) - 6;
			this.innerSymbol.width = this.windowWidth + 10;

			this.symbol.x = int(this.windowWidth) + 9;
			this.symbol.y = int(this.windowHeight - this.symbol.height);

			this.filters = [new GlowFilter(0xFFFFAE, 1, 0, 0, 2, 2)];
		}
	}
}