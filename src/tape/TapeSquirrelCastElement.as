package tape
{
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import game.mainGame.CastItem;
	import game.mainGame.events.CastItemEvent;

	public class TapeSquirrelCastElement extends TapeCastElement
	{
		private var _count:int = -1;

		private var counterField:GameField = null;

		public function TapeSquirrelCastElement(item:CastItem):void
		{
			super(item);

			var counerArea:CounterCastAreaImage = new CounterCastAreaImage();
			counerArea.x = 28;
			counerArea.y = 23;
			counerArea.mouseEnabled = false;
			counerArea.cacheAsBitmap = true;
			addChild(counerArea);

			var counterFormat:TextFormat = new TextFormat(null, 10, 0xFFFFFF, true);
			counterFormat.align = TextFormatAlign.CENTER;

			this._count = item.count;

			this.counterField = new GameField(this._count.toString(), 27, 23, counterFormat);
			this.counterField.width = 20;
			this.counterField.autoSize = TextFieldAutoSize.CENTER;
			this.counterField.mouseEnabled = false;
			addChild(this.counterField);

			this.castItem.addEventListener(CastItemEvent.ITEM_CHANGE, changeCount);
		}

		override public function dispose():void
		{
			super.dispose();

			this.castItem.removeEventListener(CastItemEvent.ITEM_CHANGE, changeCount);
		}

		public function get count():int
		{
			return this._count;
		}

		public function set count(value:int):void
		{
			if (this._count == value)
				return;

			this._count = value;
			this.counterField.text = this._count.toString();
		}

		private function changeCount(e:CastItemEvent):void
		{
			this.count = e.castItem.count;
			if (this.castItem.type == CastItem.TYPE_ROUND)
				this.icon.alpha = castItem.count > 0 ? 1 : 0.1;
		}
	}
}