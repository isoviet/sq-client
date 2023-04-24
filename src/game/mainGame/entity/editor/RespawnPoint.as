package game.mainGame.entity.editor
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.IEditorDebugDraw;
	import game.mainGame.ISerialize;
	import game.mainGame.IUpdate;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.INetHidden;
	import game.mainGame.events.SquirrelEvent;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class RespawnPoint extends StarlingAdapterSprite implements IGameObject, ISerialize, IDispose, IUpdate, INetHidden, IEditorDebugDraw
	{
		static private const SIZE:Number = 4;

		private var gameInst:SquirrelGame = null;

		private var isActive:Boolean = true;

		public function RespawnPoint():void
		{
			addChildStarling(new StarlingAdapterSprite(new RespawnPointView()));
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

		public function set showDebug(value:Boolean):void
		{
			this.visible = value;
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

			this.gameInst = world.userData as SquirrelGame;
		}

		public function update(timeStep:Number = 0):void
		{
			if (!this.isActive || !Hero.self)
				return;

			var pos:b2Vec2 = this.position;
			pos.Subtract(Hero.self.position);
			if (pos.Length() >= SIZE)
				return;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.RESPAWN_POINT, Hero.self));
			this.isActive = false;
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