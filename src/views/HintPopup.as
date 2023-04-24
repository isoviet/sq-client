package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class HintPopup extends Sprite
	{
		static public const INVERTED_NONE:int = 0;
		static public const INVERTED_X:int = 1;
		static public const INVERTED_Y:int = 2;
		static public const INVERTED_ALL:int = 3;

		static private const TEXT_OFFSET:Number = 90;
		static private const ARROW_OFFSET:Number = 100;

		private var background:MovieClip = null;
		private var shamanImage:MovieClip = null;
		private var arrowCloud:MovieClip = null;

		private var field:GameField;

		private var _inverted:int = 0;

		public var arrowOffsetX:Number = 0;
		public var arrowOffsetY:Number = 0;

		public function HintPopup(fontSize:int = 12):void
		{
			super();

			var format:TextFormat = new TextFormat(null, fontSize, 0x1B3B68, true);
			format.align = TextFormatAlign.CENTER;

			this.background = new EducationCloud();
			addChild(this.background);

			this.shamanImage = new LearningShamanImage();
			this.shamanImage.y = -30;
			addChild(this.shamanImage);

			this.field = new GameField("", TEXT_OFFSET, 25, format);
			addChild(this.field);

			this.arrowCloud = new CloudArrow();
			this.arrowCloud.x = ARROW_OFFSET;
			addChild(this.arrowCloud);
		}

		public function set text(value:String):void
		{
			this.field.text = value;

			update();
		}

		public function set inverted(value:int):void
		{
			this._inverted = value;

			update();
		}

		public function update():void
		{
			this.background.width = Math.floor(this.field.width + TEXT_OFFSET) + 40;
			this.background.height = Math.floor(this.field.height) + 50;

			this.arrowCloud.scaleX = (this._inverted == INVERTED_X || this._inverted == INVERTED_ALL) ? -1 : 1;
			this.arrowCloud.scaleY = (this._inverted >= INVERTED_Y) ? -1 : 1;

			this.arrowCloud.x = ((this._inverted == INVERTED_X || this._inverted == INVERTED_ALL) ? this.background.width - ARROW_OFFSET : ARROW_OFFSET) + this.arrowOffsetX;
			this.arrowCloud.y = ((this._inverted >= INVERTED_Y) ? 0 : this.background.height) + this.arrowOffsetY;
		}
	}
}