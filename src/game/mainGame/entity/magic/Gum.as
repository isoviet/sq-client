package game.mainGame.entity.magic
{
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.PinUtil;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameNet.SquirrelGameNet;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.GeomUtil;
	import utils.starling.StarlingAdapterSprite;

	public class Gum extends GameBody implements IPinable, ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(6 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 0.5, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const PINS:Array = [[0, 0]];

		private var joint:b2RevoluteJoint;

		private var view:StarlingAdapterSprite;
		private var viewStick:StarlingAdapterSprite;

		private var active:Boolean = true;
		private var sended:Boolean = false;
		private var fly:Boolean = true;
		private var buildPos:b2Vec2;
		private var controller:b2ConstantAccelController;

		public function Gum():void
		{
			this.view = new StarlingAdapterSprite(new GumInAir());
			this.view.visible = false;
			addChildStarling(this.view);

			this.viewStick = new StarlingAdapterSprite(new GumSticked());
			addChildStarling(this.viewStick);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			this.body.SetBullet(true);
			super.build(world);

			if (!this.builded)
				this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(-50, 0)));

			this.view.visible = true;
			this.viewStick.visible = false;
			this.buildPos = this.position.Copy();

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);

			setTimeout(stopFly, 2000, this);
		}

		override public function get position():b2Vec2
		{
			return super.position;
		}

		override public function set position(value:b2Vec2):void
		{
			super.position = value;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
			{
				this.body.SetBullet(this.body.GetLinearVelocity().Length() > 10);

				if (!this.fly || this.body.GetLinearVelocity().Length() < 10)
					destroyController();

				checkJoint();
			}
		}

		override public function dispose():void
		{
			destroyController();
			destroyJoint();
			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.playerId]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			if (data is Object || data is Array)
			{
				super.deserialize(data);

				this.playerId = data[1][0];
			}
		}

		public function beginContact(contact:b2Contact):void
		{
			var otherBody:b2Body = contact.GetFixtureA().GetBody().GetUserData() == this ? contact.GetFixtureB().GetBody() : contact.GetFixtureA().GetBody();

			if (otherBody.GetUserData() is Gum)
				return;

			if (otherBody.GetUserData() is Hero)
			{
				if ((otherBody.GetUserData() as Hero).isSelf && !(otherBody.GetUserData() as Hero).isHare && !((otherBody.GetUserData() as Hero).isDead) && !(otherBody.GetUserData() as Hero).inHollow)
					setTimeout(infect, 1, (otherBody.GetUserData() as Hero));

				return;
			}
			createJoint(contact);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var otherBody:b2Body = contact.GetFixtureA().GetBody().GetUserData() == this ? contact.GetFixtureB().GetBody() : contact.GetFixtureA().GetBody();
			if (otherBody.GetUserData() is Hero || otherBody.GetUserData() is Gum)
			{
				contact.SetEnabled(false);
			}
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function stopFly(gum:Gum):void
		{
			if (gum)
				gum.fly = false;
		}

		private function checkJoint():void
		{
			if (!this.joint)
				return;

			if (b2Math.SubtractVV(this.joint.GetAnchorA(), this.joint.GetAnchorB()).Length() > 1)
				destroyJoint();
		}

		private function createJoint(contact:b2Contact):void
		{
			if (!this.gameInst)
				return;
			if (this.joint)
				return;

			var manifold:b2WorldManifold = new b2WorldManifold();
			contact.GetWorldManifold(manifold);
			var dir:Point = new Point(manifold.m_normal.x, manifold.m_normal.y);

			if (contact.GetFixtureA().GetBody().GetUserData() == this)
			{
				dir.x = -dir.x;
				dir.y = -dir.y;
			}
			this.viewStick.rotation = GeomUtil.getAngle(new Point, dir) - this.rotation + 90;

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(contact.GetFixtureA().GetBody(), contact.GetFixtureB().GetBody(), this.position);
			jointDef.collideConnected = false;
			jointDef.enableLimit = true;
			jointDef.upperAngle = 0;
			jointDef.lowerAngle = 0;
			this.joint = this.gameInst.world.CreateJoint(jointDef) as b2RevoluteJoint;
			this.viewStick.visible = true;
			this.view.visible = false;
			this.fly = false;
		}

		private function destroyJoint():void
		{
			if (!this.gameInst)
				return;
			if (!joint)
				return;
			this.gameInst.world.DestroyJoint(this.joint);
			this.joint = null;

			this.viewStick.visible = false;
			this.view.visible = true;
		}

		private function infect(hero:Hero, force:Boolean = false):void
		{
			if (!this.gameInst)
				return;

			if (hero.gummed)
				return;

			if (!this.active)
				return;

			if (hero.game is SquirrelGameNet && !force)
			{
				if (!this.sended)
				{
					Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'Gummed': [this.id, hero.id, this.playerId]}));
					if (this.playerId == Game.selfId)
						Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.HARE_GUM, 1);
				}
				this.sended = true;
				return;
			}

			hero.gummed = true;
			this.active = false;
			if (hero.isSelf)
				this.gameInst.map.destroyObjectSync(this, true);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			if (!this.active)
				return;

			var data:Object = packet.dataJson;
			if (!('Gummed' in data))
				return;

			if (data['Gummed'][0] != this.id)
				return;

			infect(this.gameInst.squirrels.get(data['Gummed'][1]), true);
			if (data['Gummed'][2] == Game.selfId)
				Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.HARE_GUM, 1);
		}

		private function destroyController():void
		{
			if (!this.controller)
				return;

			this.gameInst.world.RemoveController(this.controller);
			this.controller.Clear();
			this.controller = null;
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}
	}
}