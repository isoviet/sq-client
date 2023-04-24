package statuses
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class StatusFullScreen extends Status
	{
		public function StatusFullScreen(owner:DisplayObject, status:String = "", bold:Boolean = false):void
		{
			super(owner, status, bold);
		}

		override protected function onShow(e:MouseEvent):void
		{
			var gamePoint:Point = new Point(e.stageX, e.stageY);

			this.x = gamePoint.x + 13;
			this.y = gamePoint.y + 10;

			if (this.x + this.width > Game.stage.fullScreenWidth)
				this.x = gamePoint.x - this.width;

			if (this.y + this.height > Game.stage.fullScreenHeight)
				this.y = gamePoint.y - this.height;

			if (e.type == MouseEvent.MOUSE_UP && Game.gameSprite.contains(this))
				Game.stage.removeChild(this);

			if (Game.stage.contains(this))
				return;
			Game.stage.addChild(this);

			this.visible = true;
		}

		override protected function onMove(e:MouseEvent):void
		{
			var gamePoint:Point = new Point(e.stageX, e.stageY);

			this.x = gamePoint.x + 13;
			this.y = gamePoint.y + 10;

			if (this.x + this.width > Game.stage.fullScreenWidth)
				this.x = gamePoint.x - this.width;

			if (this.y + this.height > Game.stage.fullScreenHeight)
				this.y = gamePoint.y - this.height;
		}

		override protected function close(e:MouseEvent = null):void
		{
			this.visible = false;

			if (!Game.stage.contains(this))
				return;
			Game.stage.removeChild(this);
		}
	}
}