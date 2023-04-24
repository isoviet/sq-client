package statuses
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	public class StatusAward extends Status
	{
		public function StatusAward(owner:DisplayObject, status:String = "", bold:Boolean = false):void
		{
			super(owner, status, bold);
		}

		override public function setStatus(data:String):void
		{
			if (this.field.text == data)
				return;

			this.field.text = data;
			this.field.width = 246;
			this.field.width = this.field.textWidth + 6;

			draw();
		}

		override protected function onMove(e:MouseEvent):void
		{
			this.x = this.owner.x + int((this.owner.width - this.width - 10) * 0.5);
			this.y = this.owner.y + this.owner.height + 2;
		}

		override protected function onShow(e:MouseEvent):void
		{
			this.x = this.owner.x + int((this.owner.width - this.width - 10) * 0.5);
			this.y = this.owner.y + this.owner.height + 2;

			if (e.type == MouseEvent.MOUSE_UP && Game.gameSprite.contains(this))
				Game.gameSprite.removeChild(this);

			if (Game.gameSprite.contains(this))
				return;
			Game.gameSprite.addChild(this);

			this.visible = true;
		}

		override protected function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xd3e2ec);
			this.graphics.drawRoundRectComplex(0, 0, this.width + 10, this.height + 4, 5, 5, 5, 5);
			this.graphics.endFill();
		}

		override public function changeHeightBy(height:int):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xd3e2ec);
			this.graphics.drawRoundRectComplex(0, 0, this.width + 10, this.height + 4 + height, 5, 5, 5, 5);
			this.graphics.endFill();
		}
	}
}