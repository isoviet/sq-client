package views
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class NewNotice extends Sprite
	{
		static public const EVENT_UPDATE:String = "EVENT_UPDATE";

		private var count:int = 0;
		private var textField:TextField = null;
		private var imageEvent:ImageEventGame = null;

		public function NewNotice():void
		{
			super();
			init();
		}

		public function set countNotice(value:int):void
		{
			if (value <= 0)
			{
				this.count = 0;
				this.visible = false;
				return;
			}

			this.count = value;
			this.textField.text = String(value > 99 ? "99+" : value);
			this.imageEvent.scaleX = ((value > 99) ? 1.2 : 1);
			this.imageEvent.scaleY = ((value > 99) ? 1.2 : 1);

			if (!this.visible)
				dispatchEvent(new Event(NewNotice.EVENT_UPDATE));

			centering();
		}

		public function get countNotice():int
		{
			return this.count;
		}

		private function init():void
		{
			var sprite:Sprite = new Sprite();
			addChild(sprite);

			this.imageEvent = new ImageEventGame();
			sprite.addChild(this.imageEvent);

			var format:TextFormat = new TextFormat(null, 11, 0x2D1B00, true);
			format.align = "center";

			this.textField = new GameField(String(countNotice), -3, imageEvent.y, format);
			this.textField.width = 25;
			this.textField.wordWrap = true;
			sprite.addChild(this.textField);
		}

		private function centering():void
		{
			this.textField.width = ((this.count > 99) ? 30 : 25);
			this.textField.y = imageEvent.y + ((this.count > 99) ? 4 : 2);
		}
	}
}