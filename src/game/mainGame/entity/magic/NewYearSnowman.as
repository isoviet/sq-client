package game.mainGame.entity.magic
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.simple.GameBody;

	import utils.starling.StarlingAdapterSprite;

	public class NewYearSnowman extends GameBody implements IPersonalObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape();
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var view:StarlingAdapterSprite;

		public var lifeTime:Number = 5.0;
		public var isPersonal:Boolean = false;
		public var size:Number = 5.0;

		public function NewYearSnowman(body:b2Body = null):void
		{
			super(body);

			this.fixed = true;
		}

		public function get personalId():int
		{
			if (!this.isPersonal)
				return 0;
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId != playerId;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.body || this.lifeTime <= 0)
				return;
			this.lifeTime -= timeStep;

			if (this.lifeTime <= 0)
				this.gameInst.map.destroyObjectSync(this, true);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			var shape:b2CircleShape = new b2CircleShape(this.size / 2);
			FIXTURE_DEF.shape = shape;
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);

			this.view = new StarlingAdapterSprite(new NewYearSnowManView());
			this.view.scaleXY(this.size / 5.0);
			this.view.y = 5 * this.size;
			addChildStarling(this.view);

			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.playerId, this.isPersonal, this.lifeTime, this.size]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
			this.isPersonal = Boolean(data[1][1]);
			this.lifeTime = data[1][2];
			this.size = data[1][3];
		}
	}
}