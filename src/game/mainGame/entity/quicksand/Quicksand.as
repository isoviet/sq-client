package game.mainGame.entity.quicksand
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.editor.inspector.ITerminal;
	import game.mainGame.entity.water.Water;

	import utils.ImageUtil;
	import utils.starling.StarlingAdapterSprite;

	public class Quicksand extends Water implements ITerminal
	{
		static private const MIN_SIZE_Y:int = 100;

		public var viscosity:Number = 1.4;

		protected var _bottomY:int = 0;
		protected var bottomLayer:Shape = null;
		protected var bottomLayerStarling: StarlingAdapterSprite = null;

		public function Quicksand():void
		{
			super();

			this._alpha0 = 0.7;
			this._alpha1 = 0.7;
			this._alpha2 = 1;

			this.color0 = this.color0;
			this.color1 = this.color1;
			this.color2 = this.color2;
			resize();
		}

		override public function get color0():int
		{
			return 0xF0D184;
		}

		override public function get color1():int
		{
			return 0xB67817;
		}

		override public function get color2():int
		{
			return 0x7E581F;
		}

		override public function build(world:b2World):void
		{
			this.controller = new QuicksandController(this);
			(this.controller as QuicksandController).viscosity = this.viscosity;
			this.controller.angularDrag = 5;

			world.AddController(this.controller);

			this.graphics.clear();
			this.game = world.userData as SquirrelGame;

			clearBottomLayer();
		}

		override public function serialize():*
		{
			return (super.serialize() as Array).concat([this.viscosity]);
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			if (13 in data)
				this.viscosity = data[13];
		}

		override public function set size(value:b2Vec2):void
		{
			value.y = (value.y > 0 ? -1 : 1) * Math.max(MIN_SIZE_Y / Game.PIXELS_TO_METRE, Math.abs(value.y));

			super.size = value;
			drawForStarling();
		}

		override public function dispose():void
		{
			super.dispose();

			clearBottomLayer();
		}

		public function get bottomY():Number
		{
			return _bottomY;
		}

		override protected function drawForStarling():void
		{
			var offset:Point = new Point(this.x, this.y);

			if (this.bottomLayer)
				clearBottomLayer();

			while(numChildren > 0)
				removeChildStarlingAt(0);

			super.drawForStarling();

			this.bottomLayer = new Shape();
			var coverImage:BitmapData = ImageUtil.getBitmapData(this.spikesClass());
			this.bottomLayer.graphics.beginBitmapFill(coverImage, null, true);
			this.bottomLayer.graphics.drawRect(0, 0, this._size.x, coverImage.height);
			this.bottomLayer.graphics.endFill();
			this.bottomLayer.x = 0;
			this.bottomLayer.y = -coverImage.height;
			_bottomY = offset.y - coverImage.height;

			if (bottomLayerStarling)
				removeChildStarling(bottomLayerStarling);

			bottomLayerStarling = new StarlingAdapterSprite(this.bottomLayer);
			bottomLayerStarling.alpha = 0.4;

			addChildStarling(bottomLayerStarling);
		}

		protected function spikesClass():DisplayObject
		{
			return new QuicksandBones;
		}

		private function clearBottomLayer():void
		{
			if (!this.bottomLayer)
				return;

			if (this.bottomLayer.parent)
				this.bottomLayer.parent.removeChild(this.bottomLayer);

			this.bottomLayer.graphics.clear();
			this.bottomLayer = null;
		}
	}
}