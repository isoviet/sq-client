package utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	public class FloatingHint extends Sprite
	{
		private var owner:DisplayObject;

		public var text:GameField;

		public function FloatingHint(owner:DisplayObject, hintText:String = null):void
		{
			this.owner = owner;
			this.visible = false;

			init(hintText);
			setStatus(hintText);
			draw();
		}

		public function set status(status:String):void
		{
			setStatus(status);
		}

		public function remove():void
		{
			this.owner.removeEventListener(MouseEvent.MOUSE_OVER, onShow);
			this.owner.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.owner.removeEventListener(MouseEvent.MOUSE_OUT, close);
			close();
		}

		private function init(status:String):void
		{
			this.owner.addEventListener(MouseEvent.MOUSE_OVER, onShow);
			this.owner.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.owner.addEventListener(MouseEvent.MOUSE_OUT, close);

			this.text = new GameField("", 5, 2, new TextFormat(null, 12, 0x1C1C1C));
			this.text.wordWrap = true;
			addChild(this.text);

			setStatus(status);
		}

		private function setStatus(data:String):void
		{
			if (this.text.text == data)
				return;

			this.text.text = data;
			this.text.width = 145;
			//this.text.width = this.text.textWidth + 5;

			draw();
		}

		private function draw():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1, 0x30AD1F);
			this.graphics.beginFill(0xEBF6D7);
			this.graphics.drawRoundRectComplex(0, 0, int(this.text.textWidth) + 12, int(this.text.textHeight) + 8, 8, 8, 8, 8);
			this.graphics.endFill();
		}

		private function onShow(e:MouseEvent):void
		{
			if (this.text.text == "")
				return;

			if (Game.gameSprite.contains(this))
				return;
			Game.gameSprite.addChild(this);

			draw();

			this.visible = true;
		}

		private function onMove(e:MouseEvent):void
		{
			this.x = e.stageX;
			this.y = e.stageY + 20;

			if (this.x + this.width > Config.GAME_WIDTH)
				this.x = e.stageX - int(this.width);

			if (this.y + this.height > 672)
				this.y = e.stageY - int(this.height);
		}

		private function close(e:MouseEvent = null):void
		{
			this.visible = false;

			if (!Game.gameSprite.contains(this))
				return;
			Game.gameSprite.removeChild(this);
		}
	}
}