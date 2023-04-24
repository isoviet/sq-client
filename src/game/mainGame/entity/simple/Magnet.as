package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2JointEdge;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IMagnetizable;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Magnet extends GameBody implements ISensor
	{
		static private const RADIUS:int = 64;

		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(RADIUS / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.2, 0, 0.001, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		private var view:StarlingAdapterMovie = null;
		private var radius:StarlingAdapterSprite = null;

		public function Magnet():void
		{
			this.view = new StarlingAdapterMovie(new MagnetImg);
			this.view.loop = true;
			this.view.stop();
			this.view.y = this.view.height / 2;
			addChildStarling(this.view);

			this.radius = new StarlingAdapterSprite(new PerkRadius());
			this.radius.scaleXY((RADIUS * 2) / this.radius.height);
			addChildStarling(this.radius);

			this.fixed = true;

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);

			this.view.play();
		}

		override public function dispose():void
		{
			if (this.view)
				this.view.removeFromParent();
			this.view = null;

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function set showDebug(value:Boolean):void
		{
			super.showDebug = value;

			this.radius.visible = this.debugDraw;
		}

		public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = null;

			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureA().GetBody().GetUserData();
			if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = contact.GetFixtureB().GetBody().GetUserData();

			if (!hero || hero.isDead || hero.inHollow)
				return;

			var magnetizeBodies:Array = [];

			for (var list:b2JointEdge = hero.body.GetJointList(); list; list = list.next)
			{
				if (list.joint.GetBodyA().GetUserData() is IMagnetizable)
				{
					magnetizeBodies.push([hero.id, (list.joint.GetBodyA().GetUserData() as GameBody).id]);
				}
				else if (list.joint.GetBodyB().GetUserData() is IMagnetizable)
				{
					magnetizeBodies.push([hero.id, (list.joint.GetBodyB().GetUserData() as GameBody).id]);
				}
			}

			for (var i:int = magnetizeBodies.length - 1; i >= 0; i --)
				commandMagnetize(magnetizeBodies[i][0], magnetizeBodies[i][1]);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function commandMagnetize(heroId:int, bodyId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				magnetize(bodyId);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'magnetize': [this.id, bodyId]}));
		}

		private function magnetize(bodyId:int):void
		{
			if (this.gameInst == null)
				return;

			var body:IMagnetizable = this.gameInst.map.getObject(bodyId) as IMagnetizable;
			if (!body)
				return;

			body.magnetize(this);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('magnetize' in data)
			{
				if (data['magnetize'][0] != this.id)
					return;
				if (data['magnetize'][1])
					magnetize(data['magnetize'][1]);
			}
		}
	}
}