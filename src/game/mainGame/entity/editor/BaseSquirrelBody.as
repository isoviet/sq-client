package game.mainGame.entity.editor
{
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.INetHidden;

	import interfaces.IDispose;

	import utils.Rotator;
	import utils.starling.StarlingAdapterSprite;

	public class BaseSquirrelBody extends StarlingAdapterSprite implements IGameObject, ISerialize, IDispose, INetHidden, IEditorDebugDraw
	{
		protected var rotator:Rotator;

		public function BaseSquirrelBody(viewClass:Class):void
		{
			var view:StarlingAdapterSprite = new StarlingAdapterSprite(new viewClass());
			view.y = -view.height / 2;
			view.x = -view.width / 2;
			addChildStarling(view);

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

		public function set showDebug(value:Boolean):void
		{
			this.visible = value;
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
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
			if (this.parentStarling == null)
				return;

			this.parentStarling.removeChildStarling(this);
			this.removeFromParent(true);
			this.rotator = null;
		}
	}
}