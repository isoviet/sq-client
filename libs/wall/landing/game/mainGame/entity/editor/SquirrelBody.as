package landing.game.mainGame.entity.editor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.ISerialize;
	import landing.game.mainGame.entity.IGameObject;

	import utils.Rotator;

	public class SquirrelBody extends Sprite implements IGameObject, ISerialize, IDispose
	{
		private var rotator:Rotator;

		public function SquirrelBody():void
		{
			var view:DisplayObject = new HeroIcon();
			view.y = -view.height + 21;
			view.x = -view.width / 2;
			addChild(view);

			this.rotator = new Rotator(view, new Point);
		}

		override public function get rotation():Number
		{
			return super.rotation;
		}

		override public function set rotation(value:Number):void
		{
			super.rotation = value;
			this.rotator.rotation = -value;
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / WallShadow.PIXELS_TO_METRE, this.y / WallShadow.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * WallShadow.PIXELS_TO_METRE;
			this.y = value.y * WallShadow.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return 0;
		}

		public function set angle(value:Number):void
		{}

		public function build(world:b2World):void
		{
			this.visible = false;
		}

		public function serialize():*
		{
			return [this.position.x, this.position.y];
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0], data[1]);
		}

		public function dispose():void
		{
			if (this.parent == null)
				return;
			this.parent.removeChild(this);
			this.rotator = null;
		}
	}
}