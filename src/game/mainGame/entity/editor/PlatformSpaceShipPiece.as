package game.mainGame.entity.editor
{
	import Box2D.Common.Math.b2Vec2;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformSpaceShipPiece extends PlatformGroundBody
	{
		public function PlatformSpaceShipPiece():void
		{
			super();
		}

		override public function get size():b2Vec2
		{
			return super.size;
		}

		override public function set size(value:b2Vec2):void
		{
			resize(value.x * 5, 0);
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new SpaceShipPieceView());
		}

		override protected function initPlatformBD():void
		{
			this.platform = new SpaceShipPieceView();
		}

		override protected function resize(width:int, height:int):void
		{
			width = Math.max(MIN_WIDTH, width);

			this._width = width;
			this._height = 30;

			draw();
		}

		override protected function draw():void
		{
			this._height = 60;
			super.draw();
			this._height = 50;
		}
	}
}