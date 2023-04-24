package game.mainGame.perks.ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;

	public class PerkCostView extends Sprite
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 14, 0xFFFFFF, true);
		static private const FILTER:DropShadowFilter = new DropShadowFilter(0, 0 ,0x032750, 8, 8, 4);

		private var icon:DisplayObject = null;
		private var field:GameField = null;

		public function PerkCostView(iconClass:Class, scale:Number):void
		{
			this.field = new GameField("0", 0, -2, FORMAT);
			this.field.filters = [FILTER];
			addChild(this.field);

			this.icon = new iconClass();
			this.icon.scaleX = this.icon.scaleY = scale;
			addChild(this.icon);
		}

		public function set text(value:String):void
		{
			this.field.text = value;
			this.field.x = 0;//-int((this.field.textWidth + this.icon.width + 5) * 0.5);
			this.icon.x = this.field.x + this.field.textWidth + 5;
		}

		public function set color(value:int):void
		{
			var textFormat:TextFormat = this.field.getTextFormat();
			textFormat.color = value;
			this.field.defaultTextFormat = textFormat;
			this.field.setTextFormat(textFormat);
		}

		public function set textFilters(value:Array):void
		{
			this.field.filters = value;
		}

	}
}