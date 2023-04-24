package game.mainGame.entity.editor
{
	import Box2D.Common.Math.b2Vec2;

	import utils.starling.StarlingAdapterSprite;

	public class PlatformBlockBody extends PlatformGroundBody
	{
		static private const BLOCK_WIDTH:int = 64;
		static private const BLOCK_HEIGHT:int = 32;

		public function PlatformBlockBody():void
		{
			super();
		}

		override public function get size():b2Vec2
		{
			return super.size;
		}

		override public function set size(value:b2Vec2):void
		{
			value.x = value.x - value.x % (this.blockWidth / Game.PIXELS_TO_METRE);
			value.y = value.y - value.y % (this.blockHeight / Game.PIXELS_TO_METRE);
			super.size = value;
		}

		override protected function initPlatformBD():void
		{
			this.platform = new Block;
		}

		override protected function initIcon():void
		{
			this.icon = new StarlingAdapterSprite(new Block());
		}

		override protected function draw():void
		{
			this._width -= _width % this.blockWidth;
			this._height -= _height % this.blockHeight;
			this._width = Math.max(_width, this.blockWidth);
			this._height = Math.max(_height, this.blockHeight);

			super.draw();
		}

		protected function get blockWidth():int
		{
			return BLOCK_WIDTH;
		}

		protected function get blockHeight():int
		{
			return BLOCK_HEIGHT;
		}
	}
}