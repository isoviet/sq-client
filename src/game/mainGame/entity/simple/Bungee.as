package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.GameMap;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IComplexEditorObject;
	import game.mainGame.entity.joints.JointPoint;
	import game.mainGame.entity.view.RopeView;
	import game.mainGame.gameEditor.Selection;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.RecorderCollection;
	import protocol.packages.server.PacketRoundCommand;

	import utils.IndexUtil;
	import utils.starling.StarlingAdapterSprite;

	public class Bungee extends GameBody implements IComplexEditorObject, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(25 / Game.PIXELS_TO_METRE, 4 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 0.5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		private var queryBodyResult:Array = null;

		private var joint:b2Joint = null;
		private var jointDef:b2DistanceJointDef = null;
		private var _newPoint:Point = new Point();

		private var body0Id:int = -1;

		private var view:StarlingAdapterSprite = null;
		private var rope:RopeView = null;

		private var hero:Hero = null;
		private var jointToHero:b2Joint = null;
		private var _isBullet:Boolean = false;

		public var damping:Number = 0;
		public var frequency:Number = 5;

		public var anchor0:JointPoint = null;
		public var body0:GameBody = null;
		public var pin:StarlingAdapterSprite = null;

		public function Bungee():void
		{
			var icon:StarlingAdapterSprite = new StarlingAdapterSprite(new BungeeIcon());
			icon.x = -25;
			icon.y = -40;
			addChildStarling(icon);

			pin = new StarlingAdapterSprite(new PinUnlimited);
			this.view = new StarlingAdapterSprite(new BungeeBalkImg());
			this.rope = new RopeView();
			this.view.alignPivot();

			this.anchor0 = new JointPoint(this, new StarlingAdapterSprite(new PinUnlimited));

			this.fixedRotation = true;

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function get rotation():Number
		{
			return 0;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		override public function get angle():Number
		{
			return 0;
		}

		override public function set angle(value:Number):void
		{}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);

			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			addChildStarling(this.rope);
			addChildStarling(this.view);
			addChildStarling(this.pin);
			this.pin.alignPivot();
			this.view.alignPivot();

			update();

			if (this.jointDef == null)
			{
				if (this.body0 == null)
					findBody0(world, this.anchor0.position);
			}
			else
				this.body0 = ((world.userData as SquirrelGame).map.getObject(this.body0Id) as GameBody);

			var bBody0:b2Body = this.body0 ? this.body0.body : world.GetGroundBody();

			if (this.jointDef != null)
			{
				this.jointDef.bodyA = bBody0;
				this.jointDef.bodyB = this.body;
				this.jointDef.rope = true;
			}
			else
			{
				this.jointDef = new b2DistanceJointDef();
				this.jointDef.Initialize(bBody0, this.body, this.anchor0.position, this.position);
				this.jointDef.rope = true;
			}

			this.jointDef.dampingRatio = this.damping;
			this.jointDef.frequencyHz = this.frequency;
			this.jointDef.collideConnected = true;

			this.joint = world.CreateJoint(this.jointDef);

			this.visible = true;

			if (this._isBullet)
				this.position = this.anchor0.position.Copy();

			this.anchor0.position = this.jointDef.localAnchorA;

			if (this.body0 != null)
				this.body0.addChildStarling(this.anchor0);
		}

		override public function dispose():void
		{
			if (this.anchor0 != null)
				this.anchor0.dispose();
			this.anchor0 = null;

			if (this.joint != null)
				this.gameInst.world.DestroyJoint(this.joint);
			this.joint = null;

			releaseHero();

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.anchor0.position.x, this.anchor0.position.y]);
			result.push([this.body ? false : this._isBullet, this.frequency, this.damping]);

			if (this.jointDef != null)
				result.push([this.body0 ? this.body0.id : -1, [this.jointDef.localAnchorA.x, this.jointDef.localAnchorA.y], this.jointDef.length]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.anchor0.position = new b2Vec2(data[1][0], data[1][1]);
			this._isBullet = Boolean(data[2][0]);
			this.frequency = data[2][1];
			this.damping = data[2][2];

			if (!(3 in data))
				return;

			this.jointDef = new b2DistanceJointDef();
			this.body0Id = data[3][0];
			this.jointDef.localAnchorA = new b2Vec2(data[3][1][0], data[3][1][1]);
			this.jointDef.localAnchorB = new b2Vec2(0, 0);
			this.jointDef.length = data[3][2];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.rotation = 0;

			var end:b2Vec2 = this.joint ? this.joint.GetAnchorA().Copy() : this.anchor0.position.Copy();
			end.Subtract(this.position);
			end.Multiply(Game.PIXELS_TO_METRE);

			_newPoint.setTo(0, 0);
			this.rope.start = _newPoint;
			_newPoint.setTo(end.x, end.y);
			this.rope.end = _newPoint;

			pin.x = _newPoint.x;
			pin.y = _newPoint.y;
		}

		public function set isBullet(value:Boolean):void
		{
			this._isBullet = value;
			this.visible = !value;
		}

		public function onAddedToMap(map:GameMap):void
		{
			while (this.numChildren > 0)
				removeChildStarlingAt(0, false);

			addChildStarling(this.rope);
			addChildStarling(this.view);

			map.add(this.anchor0);

			if (this.anchor0.position.x != 0 || this.anchor0.position.y != 0)
				return;

			var pos:b2Vec2 = this.position.Copy();
			pos.Add(new b2Vec2(0, -34 / Game.PIXELS_TO_METRE));
			this.anchor0.position = pos;

			update();
		}

		public function onRemovedFromMap(map:GameMap):void
		{
			map.remove(this.anchor0);
			this.anchor0.dispose();
		}

		public function onSelect(selection:Selection):void
		{
			selection.add(this.anchor0);
		}

		public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero || hero.isDead || hero.inHollow || hero.hasJoints("bungee"))
				return;

			if (this.hero != null)
				return;

			commandPinSquirrel(hero.id);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function findBody0(world:b2World, position:b2Vec2):void
		{
			this.queryBodyResult = [];

			world.QueryPoint(queryBody0, position);
			this.body0 = (IndexUtil.getMaxIndex(queryBodyResult, this.anchor0.parentStarling.getChildStarlingIndex(this.anchor0)) as GameBody);

			this.queryBodyResult = null;
		}

		private function queryBody0(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is GameBody && queryBody.GetUserData() != this.body0)
				this.queryBodyResult.push(queryBody.GetUserData());
			return true;
		}

		private function onEvent(e:Event):void
		{
			releaseHero();
		}

		private function commandPinSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				pinSquirrel(heroId);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'pinBungeeSquirrel': [this.id, heroId]}));
		}

		private function pinSquirrel(heroId:int):void
		{
			if (!this.gameInst || this.hero != null)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || hero.hasJoints("bungee"))
				return;

			this.hero = hero;
			this.hero.hangOnRope = true;
			this.hero.addEventListener(Hero.EVENT_BREAK_JOINT, onEvent);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyA = this.body;
			hero.bindToRevoluteJointDef(jointDef, false);
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2();
			jointDef.localAnchorB = new b2Vec2();
			this.jointToHero = this.body.GetWorld().CreateJoint(jointDef);
			this.jointToHero.SetUserData("bungee");

			RecorderCollection.addDataClient(PacketClient.ROUND_COMMAND, [by.blooddy.crypto.serialization.JSON.encode({'pinBungeeSquirrel': [this.id, heroId]})]);
		}

		private function releaseHero():void
		{
			if (!this.hero)
				return;

			this.hero.hangOnRope = false;
			this.hero.removeEventListener(Hero.EVENT_BREAK_JOINT, onEvent);
			setTimeout(deactive, 300);

			if (this.jointToHero)
			{
				this.body.GetWorld().DestroyJoint(this.jointToHero);
				this.jointToHero = null;
			}
		}

		private function deactive():void
		{
			this.hero = null;
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('pinBungeeSquirrel' in data)
			{
				if (data['pinBungeeSquirrel'][0] != this.id)
					return;

				pinSquirrel(data['pinBungeeSquirrel'][1]);
			}
		}
	}
}