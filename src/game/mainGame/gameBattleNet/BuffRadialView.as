package game.mainGame.gameBattleNet
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;

	import statuses.Status;

	import utils.Sector;

	public class BuffRadialView extends Sprite
	{
		private var sector:Sector = new Sector();

		public function BuffRadialView(image:DisplayObject, scale:Number = 1.0, alpha:Number = 0.5, name:String = "", dX:int = 0, dY:int = 0):void
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000);
			shape.graphics.drawCircle(18, 18, 18);
			shape.graphics.drawCircle(18, 18, 16);
			shape.graphics.beginFill(0x000000, 0.2);
			shape.graphics.drawCircle(18, 18, 16);
			shape.cacheAsBitmap = true;
			addChild(shape);

			image.scaleX = scale;
			image.scaleY = scale;
			image.x = 18 - int(image.width * 0.5) + dX;
			image.y = 18 - int(image.height * 0.5) + dY;
			image.cacheAsBitmap = true;
			addChild(image);

			this.sector.start = 0;
			this.sector.radius = 18;
			this.sector.x = this.sector.radius;
			this.sector.y = this.sector.radius;
			this.sector.color = 0x00FF00;
			this.sector.alpha = alpha;
			addChild(this.sector);

			if (name != "")
				new Status(this, "<body>" + name + "</body>", false, true);
		}

		public function update(count:int):void
		{
			this.sector.end = Math.PI * 2 - count / 100 * Math.PI * 2;
		}
	}
}