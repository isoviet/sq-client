package game.mainGame.entity.editor
{
	import flash.geom.Matrix;
	import flash.geom.Point;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformSeaShore extends PlatformGroundBody
	{
		public function PlatformSeaShore():void
		{
			super();
		}

		override protected function initPlatformBD():void
		{
			this.platform = new SeaShore();
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new SeaShore());
		}

		override protected function draw():void
		{
			super.draw();

			this.drawSprite.graphics.beginBitmapFill(new SSTop, new Matrix(1, 0, 0, 1, 0, -4), true, true);
			this.drawSprite.graphics.drawRect(0, -4, this._width, 5);
		}

		override protected function getShiftPoint():Point
		{
			return new Point(0, -4);
		}
	}
}