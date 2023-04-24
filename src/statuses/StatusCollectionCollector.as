package statuses
{
	import flash.display.DisplayObject;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import statuses.Status;

	import utils.FieldUtils;

	public class StatusCollectionCollector extends Status
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #000000;
				text-align: justify;
			}
			a {
				font-weight: bold;
			}
			.red {
				color: #F71C00;
			}
		]]>).toString();

		static private const STATUS_WIDTH:int = 207;

		private var fieldTitle:GameField;
		private var fieldAward:GameField;

		private var style:StyleSheet;

		public function StatusCollectionCollector(owner:DisplayObject, header:String, status:String, award:String):void
		{
			super(owner, status);

			this.visible = false;

			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.field.styleSheet = this.style;
			this.field.width = STATUS_WIDTH - 13;
			this.field.htmlText = "<body>" + status + "</body>";

			init(header, award);
		}

		override protected function draw():void
		{
			var newHeight:int = int(this.field.textHeight) + 33;

			if (this.fieldAward != null)
				newHeight += this.fieldAward.textHeight;

			this.graphics.clear();
			this.graphics.lineStyle(2, 0x744C0C);
			this.graphics.beginFill(0xFFFCDB);
			this.graphics.drawRoundRectComplex(0, 0, STATUS_WIDTH, newHeight, 5, 5, 5, 5);
			this.graphics.endFill();
		}

		private function init(header:String, award:String):void
		{
			var titleFormat:TextFormat = new TextFormat(null, 12, 0xB48000, true);
			titleFormat.align = TextFormatAlign.CENTER;

			this.fieldTitle = new GameField(header, 0, 2, titleFormat);
			this.fieldTitle.width = STATUS_WIDTH;
			this.fieldTitle.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.fieldTitle);

			this.field.y = 20;

			if (award == "")
			{
				draw();
				return;
			}

			this.fieldAward = new GameField(gls("<body><a>Награда:  <span class='red'>{0}</span></a></body>", award), 95, int(this.field.y + this.field.textHeight + 5), this.style);
			addChild(this.fieldAward);

			FieldUtils.replaceSign(this.fieldAward, "^", ImageIconExp, 0.7, 0.7, this.fieldAward.x - 188, -this.fieldAward.y + 3, false, false);

			draw();
		}
	}
}