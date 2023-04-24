package game.mainGame.entity.magic
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IShoot;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.view.RopeView;
	import game.mainGame.gameEditor.SquirrelCollectionEditor;
	import sensors.ISensor;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class HarpoonBody extends GameBody implements IShoot, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(3 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 0.5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static public const MAX_VELOCITY:int = 120;

		protected var view: StarlingAdapterMovie;
		protected var controller:b2ConstantAccelController;

		protected var world:b2World;

		protected var joint:b2DistanceJoint;
		protected var jointDef:b2DistanceJointDef;
		protected var rope:RopeView;

		protected var hero:Hero;

		protected var lifeTime:Number = 1000;

		protected var _maxVelocity:Number = MAX_VELOCITY;
		protected var _aimCursor:StarlingAdapterSprite = null;

		public var ropeShrinkFactor:Number = 10;

		public function HarpoonBody():void
		{
			this.view = getView();
			this.view.visible = false;
			addChildStarling(this.view);

			this.rope = getRopeView();
			this.rope.start = new Point(0, 0);
			this.rope.visible = false;
			addChildStarling(this.rope);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetBullet(true);

			this.world = world;

			super.build(world);

			if (!this.builded)
				this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(200, 0)));

			if (this.gameInst.squirrels is SquirrelCollectionEditor)
				this.hero = (this.gameInst.squirrels as SquirrelCollectionEditor).self;
			else
				this.hero = this.gameInst.squirrels.get(this.playerId);
			this.view.rotation = 90;
			this.view.visible = true;
			this.view.loop = true;
			this.view.play();

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body && !this.fixed)
			{
				this.lifeTime -= timeStep * 1000;

				if (this.lifeTime <= 0)
				{
					breakJoint();
					return;
				}
			}

			if (!this.hero || this.hero.isDead)
			{
				breakJoint();
				return;
			}

			if (!this.joint)
				return;

			if (this.joint.GetLength() <= 1)
			{
				breakJoint();
				return;
			}

			if (this.joint.GetLength() > this.minLength)
				this.joint.SetLength(this.joint.GetLength() - timeStep * this.ropeShrinkFactor);

			var vec:b2Vec2 = this.body.GetLocalPoint(b2Math.AddVV(this.hero.position, new b2Vec2(-1, 0)));
			vec.Multiply(Game.PIXELS_TO_METRE);

			this.rope.end = new Point(vec.x, vec.y);
		}

		override public function dispose():void
		{
			breakJoint();

			this._aimCursor = null;

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push(this.ropeShrinkFactor);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.ropeShrinkFactor = data[1];
		}

		public function beginContact(contact:b2Contact):void
		{
			this.fixed = true;
			this.view.stop();

			setTimeout(createJoint, 100);
		}

		public function get minLength():Number
		{
			return 0;
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function get maxVelocity():Number
		{
			return _maxVelocity;
		}

		public function set maxVelocity(value:Number):void
		{
			this._maxVelocity = value;
		}

		public function get aimCursor():StarlingAdapterSprite
		{
			if (this._aimCursor == null)
			{
				this._aimCursor = new StarlingAdapterSprite(new AimCursor());
			}

			return this._aimCursor;
		}

		public function onAim(point: Point):void
		{
			//var pos:Point = this.aimCursor.parentStarling.globalToLocal(new Point(Game.stage.mouseX, Game.stage.mouseY));
			this._aimCursor.x = point.x;
			this._aimCursor.y = point.y;
		}

		protected function getView():StarlingAdapterMovie
		{
			return null;
		}

		protected function getRopeView():RopeView
		{
			return new RopeView();
		}

		protected function createJoint():void
		{
			if (!this.hero || !this.body)
				return;

			var pos:b2Vec2 = this.position.Copy();
			pos.Subtract(this.hero.position);

			this.jointDef = new b2DistanceJointDef();
			this.jointDef.length = pos.Length();
			this.jointDef.frequencyHz = 10;
			this.jointDef.localAnchorA = new b2Vec2();
			this.jointDef.rope = true;

			this.jointDef.bodyA = this.body;
			this.hero.bindToDistanceJointDef(this.jointDef, false);

			this.rope.end = new Point(0, 0);
			this.rope.visible = true;

			this.joint = this.world.CreateJoint(this.jointDef) as b2DistanceJoint;

			this.hero.addEventListener(Hero.EVENT_BREAK_JOINT, breakJoint);
			this.hero.hangOnRope = true;
		}

		public function breakJoint(e:Event = null):void
		{
			if (this.joint)
				this.body.GetWorld().DestroyJoint(this.joint);

			this.rope.visible = false;
			this.joint = null;
			this.jointDef = null;
			if (this.hero)
			{
				this.hero.removeEventListener(Hero.EVENT_BREAK_JOINT, breakJoint);
				this.hero.hangOnRope = false;
			}

			if (this.body != null)
				this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}