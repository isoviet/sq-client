package game.mainGame.entity.editor
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.INetHidden;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class CollectionPoint extends StarlingAdapterSprite implements IGameObject, ISerialize, IDispose, INetHidden, IEditorDebugDraw
	{
		public function CollectionPoint():void
		{
			var sprite:StarlingAdapterSprite = new StarlingAdapterSprite(new ButterflyImage1());
			sprite.scaleXY(0.5, 0.5);
			sprite.x = -(sprite.width * 0.5);
			sprite.y = -(sprite.height * 0.5);
			addChildStarling(sprite);
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

		public function set showDebug(value:Boolean):void
		{
			this.visible = value;
		}

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
		}
	}
}