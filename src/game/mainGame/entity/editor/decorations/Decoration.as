package game.mainGame.entity.editor.decorations
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IReflect;
	import game.mainGame.ISerialize;
	import game.mainGame.entity.ICache;
	import game.mainGame.entity.IGameObject;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class Decoration extends StarlingAdapterSprite implements IGameObject, ISerialize, IDispose, IReflect, ICache
	{
		public function Decoration(decorationObject: Class = null, dY:int = 0): void {
			super();
			if (decorationObject)
			{
				var sprite: StarlingAdapterSprite = new StarlingAdapterSprite(new decorationObject());
				sprite.alignPivot();
				sprite.y = -sprite.height / 2 + dY;
				addChildStarling(sprite);
			}
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function get cacheBitmap():Boolean
		{
			return true;
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return this.rotation * Game.D2R;
		}

		public function set angle(value:Number):void
		{
			this.rotation = value / (Game.D2R);
		}

		public function get orientation():Boolean
		{
			return this.scaleX > 0;
		}

		public function set orientation(value:Boolean):void
		{
			this.scaleX = Math.abs(this.scaleX) * (value ? 1 : -1);
		}

		public function build(world:b2World):void {}

		public function serialize():*
		{
			return [[this.position.x, this.position.y], this.angle, this.orientation];
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.angle = data[1];

			if (data.length < 3)
				return;

			this.orientation = Boolean(data[2]);
		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				this.removeChildStarlingAt(0, true);

			if (this.parentStarling)
				this.parentStarling.removeChildStarling(this);

			this.removeFromParent(true);
		}
	}
}