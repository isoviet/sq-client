package statuses
{
	import flash.display.DisplayObject;
	import flash.text.StyleSheet;

	public class StatusCurrency extends Status
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #1B120E;
			}
			.bold {
				font-weight: bold;
			}
		]]>).toString();

		private var energyText:GameField = null;
		private var maxwidth:int;

		public function StatusCurrency(owner:DisplayObject, caption:String, text:String, maxwidth:int = 185):void
		{
			super(owner);

			this.maxwidth = maxwidth;

			init(caption, text);
		}

		public function setStatusCurrency(caption:String, text:String):void
		{
			text = caption != "" ? "\n" + text : text;
			this.energyText.text = "<body><span class='bold'>" + caption + "</span>" + text + "</body>";
			this.energyText.width = (caption == "" ? this.energyText.textWidth + 10 : this.maxwidth);

			draw();
		}

		private function init(caption:String, text:String):void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			text = caption != "" ? "\n" + text : text;
			this.energyText = new GameField("<body><span class='bold'>" + caption + "</span>" + text + "</body>", 7, 2, style);
			this.energyText.wordWrap = true;
			this.energyText.multiline = true;
			this.energyText.width = this.maxwidth;
			addChild(this.energyText);

			draw();
		}
	}
}