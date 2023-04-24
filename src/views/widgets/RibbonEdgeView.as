package views.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextFormat;

	import utils.FiltersUtil;

	public class RibbonEdgeView extends Sprite
	{
		static private const TEXTS:Array = [gls("Куплен"), gls("Закрыт"), gls("Надет")];
		static private const FILTER:Array = [null, [FiltersUtil.ribbonEdgeRed], null];

		static public const SKIN_BOUGHT:int = 0;
		static public const SKIN_CLOSED:int = 1;
		static public const SKIN_WEARED:int = 2;

		private var ribbon:DisplayObject = null;
		private var field:GameField = null;

		private var _type:int = -1;

		public function RibbonEdgeView(type:int):void
		{
			this.type = type;
		}

		public function set type(value:int):void
		{
			if (this.type == value)
				return;
			this._type = value;

			if (this.ribbon)
				removeChild(this.ribbon);
			if (this.field)
				removeChild(this.field);

			this.ribbon = new RibbonEdge();
			if (FILTER[this.type] != null)
				this.ribbon.filters = FILTER[this.type];
			addChild(this.ribbon);

			this.field = new GameField(TEXTS[this.type], 0, 5, new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF));
			this.field.x = 50 - int(this.field.textWidth * 0.5);
			addChild(this.field);
		}

		public function get type():int
		{
			return this._type;
		}
	}
}