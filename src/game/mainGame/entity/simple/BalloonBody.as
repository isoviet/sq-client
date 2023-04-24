package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.cast.ICastTool;
	import game.mainGame.entity.controllers.BalloonController;
	import game.mainGame.entity.view.RopeView;

	import starling.display.Image;

	import utils.WorldQueryUtil;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class BalloonBody extends CacheVolatileBody implements ICastTool
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;
		static public const GLOW:Array = [new GlowFilter(0xFFFF99, 1, 10, 10, 1, 1, true, true)];
		static private const COLORS:Array =
		[
			0x70D900,
			0x3F00DB,
			0xF29F00,
			0x00D937,
			0xE80072,
			0xDFEA00,
			0x00BAE8,
			0x00DD9A,
			0xD900B3,
			0xAA1238
		];

		private var jointPoint:StarlingAdapterSprite;
		private var rope:RopeView = new RopeView();
		private var joint:b2DistanceJoint;
		private var jointDef:b2DistanceJointDef;
		private var _aim:StarlingAdapterSprite;
		private var _color:int;

		private var toBody:GameBody;
		private var toHero:Hero;
		private var world:b2World;
		private var _game:SquirrelGame;
		private var colorSprite:Image;
		private var overSprite:StarlingAdapterSprite;
		private var controller:Object;

		public var toId:int = -1;
		public var connectToHero:Boolean;
		public var velocityLimit:Number = -10;

		public function BalloonBody():void
		{
			this.colorSprite = StarlingConverter.convertToImage(new BalloonColorImage()) as Image;
			this.colorSprite.x = -15;
			this.colorSprite.y = -20;
			addChildStarling(this.colorSprite);

			this.overSprite = new StarlingAdapterSprite(new BalloonOver());
			this.overSprite.x = -15;
			this.overSprite.y = -20;
			addChildStarling(this.overSprite);

			addChildStarling(this.rope);

			this.rope.start = new Point(0, 17);
			this.rope.end = new Point(0, 50 + 17);

			this.jointPoint = new StarlingAdapterSprite(new PinUnlimited());
			this.jointPoint.alignPivot();

			this.jointPoint.x = this.rope.end.x;
			this.jointPoint.y = this.rope.end.y;
			var dot: StarlingAdapterSprite = new StarlingAdapterSprite(new JointDot());
			dot.alignPivot();
			dot.x = this.jointPoint.width / 2;
			dot.y = this.jointPoint.height / 2;
			this.jointPoint.addChildStarling(dot);
			addChildStarling(jointPoint);

			ropeEnabled = false;

			this.jointDef = new b2DistanceJointDef();
			this.jointDef.length = 5;
			this.jointDef.frequencyHz = 3;
			this.jointDef.localAnchorA = new b2Vec2(0 / Game.PIXELS_TO_METRE, 17 / Game.PIXELS_TO_METRE);
			this.jointDef.localAnchorB = null;

			this.color = COLORS[int(Math.random() * COLORS.length)];
		}

		override public function getRect(targetCoordinateSpace:DisplayObject):Rectangle
		{
			if (this.rope.visible)
				return super.getRect(targetCoordinateSpace);
			return this.overSprite.getRect(targetCoordinateSpace);
		}

		override public function set cacheAsBitmap(value:Boolean):void
		{
			this.overSprite.cacheAsBitmap = value;
		}

		override public function build(world:b2World):void
		{
			this.controller = new BalloonController();
			(controller as BalloonController).balloon = this;
			world.AddController(this.controller as BalloonController);

			this.world = world;
			this._game = world.userData as SquirrelGame;
			var bodyDef:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);
			this.body = world.CreateBody(bodyDef);

			var defaultShape:b2CircleShape = new b2CircleShape(20 / Game.PIXELS_TO_METRE);
			var fixtureDef:b2FixtureDef = new b2FixtureDef(defaultShape, null, 0, 0, 1, CATEGORIES_BITS, MASK_BITS, -5);
			this.body.CreateFixture(fixtureDef);
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);

			super.build(world);
			this.aim = null;

			if (!ropeEnabled)
				return;

			buildRope();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			if (this.jointDef == null || this.jointDef.localAnchorB == null || this.jointDef.localAnchorA == null)
			{
				result.push([color]);
				return result;
			}

			result.push([color, (toHero ? toHero.id : toBody.id),
							toHero != null,
							[this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y],
							[this.jointDef.localAnchorB.x, this.jointDef.localAnchorB.y],
							this.jointDef.length, color]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.ropeEnabled = false;
			var index:int = isOldStyle(data) ? 3 : 1;
			if (!(index in data))
				return;

			this.color = data[index][0];

			if (!(1 in data[index]))
				return;

			this.jointDef = new b2DistanceJointDef();
			this.toId = data[index][1];
			this.connectToHero = Boolean(data[index][2]);

			this.jointDef.localAnchorA = new b2Vec2(data[index][3][0], data[index][3][1]);
			this.jointDef.localAnchorB = new b2Vec2(data[index][4][0], data[index][4][1]);
			this.jointDef.length = data[index][5];
			this.ropeEnabled = true;
		}

		override public function dispose():void
		{
			breakJoint();
			super.dispose();

			this._game = null;
			this.rope = null;
			this.aim = null;

			if (this.controller)
			{
				this.controller.active = false;
				this.controller.balloon = null;
				this.controller.GetWorld().RemoveController(this.controller);
				this.controller = null;
			}
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			updateAim();

			if (body == null)
				return;

			if (this.controller)
				this.controller.active = this.body.GetLinearVelocity().y > this.velocityLimit && (this.toBody && this.toBody.body && this.toBody.body.IsActive() || !this.toBody || !this.toBody.body);

			this.jointPoint.visible = this.rope.visible = (this.joint != null && joint.GetUserData() != "destroyed");

			if (!this.joint || this.joint.GetUserData() == "destroyed")
				return;

			var vec:b2Vec2 = this.body.GetLocalPoint(this.toHero ? b2Math.AddVV(this.toHero.position, new b2Vec2(0, -1)) : this.joint.GetAnchorB());
			vec.Multiply(Game.PIXELS_TO_METRE);

			this.rope.end = new Point(vec.x, vec.y);
			this.jointPoint.x = this.rope.end.x;
			this.jointPoint.y = this.rope.end.y;
		}

		public function get ropeEnabled():Boolean
		{
			return this.rope.visible;
		}

		public function set ropeEnabled(value:Boolean):void
		{
			this.rope.visible = value;
			this.jointPoint.visible = value;
			if (value)
				updateAim();
		}

		public function set game(value:SquirrelGame):void
		{
			_game = value;
		}

		public function get aim():StarlingAdapterSprite
		{
			return _aim;
		}

		public function set aim(value: StarlingAdapterSprite):void
		{
			if (_aim == value)
				return;

			clearAimFilters();
			_aim = value;

			if (_aim == null)
				return;

			if (_aim is Hero)
				return;

			_aim.filters = GLOW;
		}

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			this.colorSprite.color = value;
		}

		public function onCastStart():void
		{
			updateAim();

			if (aim == null)
			{
				onCastCancel();
				return;
			}

			var anchorPoint:b2Vec2 = new b2Vec2(0 / Game.PIXELS_TO_METRE, (50 + 17) / Game.PIXELS_TO_METRE);

			if (aim is Hero)
				(aim as Hero).bindToJointDef(this.jointDef, WorldQueryUtil.GetWorldPoint(this, anchorPoint), false);
			else
				this.jointDef.localAnchorB = (aim as GameBody).body.GetLocalPoint(WorldQueryUtil.GetWorldPoint(this, anchorPoint));

			this.toId = (aim is Hero) ? (aim as Hero).id : (aim as GameBody).id;
			this.connectToHero = (aim is Hero);
		}

		public function onCastCancel():void
		{
			if (this.jointDef)
				this.jointDef.localAnchorB = null;
			this.toId = -1;
			this.connectToHero = false;
		}

		public function onCastComplete():void
		{}

		public function duplicate():void
		{
			if (!this.body)
				return;

			var balloonCopy:BalloonBody = new BalloonBody();
			balloonCopy.deserialize(this.serialize());
			balloonCopy.playerId = this.playerId;
			balloonCopy.castType = this.castType;
			balloonCopy.velocityLimit = this.velocityLimit;
			balloonCopy.build(this.world);
			this._game.map.add(balloonCopy);
		}

		private function getToBody(world:b2World, pos:b2Vec2):Object
		{
			pos = WorldQueryUtil.GetWorldPoint(this, pos);

			var heroes:Array = WorldQueryUtil.findBodiesAtPoint(world, pos, Hero);
			if (heroes.length != 0)
			{
				for (var i:int = 0; i < heroes.length; i++)
				{
					if ((heroes[i].GetUserData() as Hero).isSelf)
						return heroes[i].GetUserData();
				}

				return heroes[0].GetUserData();
			}

			var bodies:Array = WorldQueryUtil.findBodiesAtPoint(world, pos, GameBody);
			if (bodies.length != 0)
			{
				for (var j:int = 0; j < bodies.length; j++)
					if (!(bodies[j].GetUserData() is IPinFree))
						return bodies[j].GetUserData();
			}

			return null;
		}

		private function findBodies(world:b2World, pos:b2Vec2):void
		{
			var result:Object = getToBody(world, pos);

			this.toHero = null;
			this.toBody = null;
			if (result is Hero)
				this.toHero = result as Hero;
			else if (result is GameBody)
				this.toBody = result as GameBody;
		}

		private function onBreak(e:Event):void
		{
			breakJoint();
		}

		private function breakJoint():void
		{
			if (this.joint)
				this.body.GetWorld().DestroyJoint(this.joint);

			this.ropeEnabled = false;
			this.joint = null;
			this.jointDef = null;
			if (toHero)
			{
				toHero.removeEventListener(Hero.EVENT_BREAK_JOINT, onBreak);
				toHero.hangOnRope = false;
			}
		}

		private function updateAim():void
		{
			if (this.body != null)
				return;
			if (this._game == null)
				return;
			if (!this.ropeEnabled)
			{
				aim = null;
				return;
			}

			var anchorPoint:b2Vec2 = new b2Vec2(0 / Game.PIXELS_TO_METRE, (50 + 17) / Game.PIXELS_TO_METRE);
			findBodies(this._game.world, anchorPoint);
			this.aim = (toBody ? toBody : toHero ? toHero : null) as StarlingAdapterSprite;
		}

		private function clearAimFilters():void
		{
			var dObject: StarlingAdapterSprite = aim != null ? aim : (toBody ? toBody : toHero ? toHero : null);
			if (dObject == null)
				return;

			if (dObject is Hero)
				return;

			dObject.filters = [];
		}

		private function buildRope():void
		{
			if (toId != -1)
			{
				if (connectToHero)
					this.toHero = (this.world.userData as SquirrelGame).squirrels.get(toId);
				else
					this.toBody = (this.world.userData as SquirrelGame).map.getObject(toId) as GameBody;
			}

			if (this.toBody ? (this.toBody.body == null) : this.toHero ? !this.toHero.isExist : true)
			{
				this.ropeEnabled = false;
				return;
			}

			this.jointDef.bodyA = this.body;
			if (this.toBody)
				this.jointDef.bodyB = this.toBody.body;
			else
				this.toHero.bindToDistanceJointDef(this.jointDef, false);

			if (this.toHero)
			{
				this.toHero.addEventListener(Hero.EVENT_BREAK_JOINT, onBreak);
				this.toHero.hangOnRope = true;
			}

			this.jointDef.rope = true;
			this.joint = world.CreateJoint(this.jointDef) as b2DistanceJoint;
		}
	}
}