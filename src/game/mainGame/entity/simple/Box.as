package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILandSound;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.PinUtil;
	import screens.ScreenGame;
	import screens.Screens;

	import protocol.PacketClient;

	import utils.starling.StarlingAdapterSprite;

	public class Box extends SquareBody implements IPinable, ILandSound, IPersonalObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(20 / Game.PIXELS_TO_METRE, 20 / Game.PIXELS_TO_METRE, new b2Vec2());
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
		static private const PINS:Array = [[-20 / Game.PIXELS_TO_METRE, 0], [0, 0], [20 / Game.PIXELS_TO_METRE, 0]];

		public function Box():void
		{
			this.view = new StarlingAdapterSprite(new Box1());
			this.view.x = -20;
			this.view.y = -20;
			addChildStarling(this.view);
		}

		public function get personalId():int
		{
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId != playerId && this.castType == PacketClient.CAST_SQUIRREL && Screens.active is ScreenGame;
		}

		public function get landSound():String
		{
			return "land_wood";
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);

			if (breakContact(Game.selfId))
				this.alpha = 0.2;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			if (breakContact(Game.selfId))
				this.alpha = 0.2;
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}
	}
}