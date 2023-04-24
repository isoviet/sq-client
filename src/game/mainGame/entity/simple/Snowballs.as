package game.mainGame.entity.simple
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.events.SquirrelEvent;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	public class Snowballs extends GameBody implements ISensor
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(4 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.1, 0.1, 4, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		public var scale:Number = 1;

		private var view:MovieClip;
		private var viewKick:MovieClip;
		private var star:MovieClip;

		private var disposed:Boolean = false;
		private var wasContact:Boolean = false;
		private var sended:Boolean = false;
		private var controller:b2ConstantAccelController;
		private var fly:Boolean = true;
		private var mainFixture:b2Fixture = null;

		private var starView:Array = null;

		public function Snowballs():void
		{
			this.view = new SnowballAnimation();
			this.view.play();
			this.addChild(this.view);
			this.view.visible = false;
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			setTimeout(onShot, 300, world);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
			{
				this.body.SetBullet(this.body.GetLinearVelocity().Length() > 30);

				if (!this.fly || this.body.GetLinearVelocity().Length() < 30)
					destroyController();
			}
		}

		override public function dispose():void
		{
			destroyController();
			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId, this.scale]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
			this.scale = data[1][1];
		}

		public function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			setTimeout(death, 1 * 1000);
		}

		public function beginContact(contact:b2Contact):void
		{
			var hero:Hero = null;
			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			else if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			if ((hero != null && hero.id == this.playerId) || this.wasContact)
				return;

			this.wasContact = true;

			if (this.view.parent)
				this.view.parent.removeChild(this.view);

			this.viewKick = new SnowKick();
			this.viewKick.gotoAndPlay(0);
			this.viewKick.addEventListener(Event.CHANGE, onSnowKick);
			this.addChild(this.viewKick);

			if (hero == null)
			{
				destroy();
				return;
			}

			if (hero.isSelf)
				setHeroOnSnow(hero);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var hero:Hero = null;
			if (contact.GetFixtureA().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureA().GetBody().GetUserData() as Hero);
			else if (contact.GetFixtureB().GetBody().GetUserData() is Hero)
				hero = (contact.GetFixtureB().GetBody().GetUserData() as Hero);

			contact.SetEnabled(!(hero != null && hero.id == this.playerId));
		}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		private function onShot(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.SetBullet(true);
			this.mainFixture = this.body.CreateFixture(FIXTURE_DEF);
			this.mainFixture.SetUserData(this);
			super.build(world);
			this.fixedRotation = true;

			setScale(this.scale);

			if (!this.builded)
				this.body.SetLinearVelocity(this.body.GetWorldVector(new b2Vec2(-50, 0)));

			this.view.visible = true;

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			this.controller.AddBody(this.body);
			world.AddController(this.controller);

			setTimeout(stopFly, 1000, this);
		}

		private function stopFly(snowball:Snowballs):void
		{
			if (snowball)
				snowball.fly = false;
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if (!("OnSnowballs" in data))
				return;

			if (data['OnSnowballs'][0] != this.id)
				return;

			var hero:Hero = this.gameInst.squirrels.get(data['OnSnowballs'][1]) as Hero;

			if (hero == null)
				return;

			if (this.starView == null)
				this.starView = [];

			this.star = new this.starView[int(Math.random() * this.starView.length)];
			this.star.x = 8;
			this.star.y = -13;

			hero.heroView.addChild(this.star);

			destroy();
			hero.addEventListener(SquirrelEvent.DIE, removeStar);
			setTimeout(removeStar, 8 * 1000);
		}

		private function destroyController():void
		{
			if (!this.controller)
				return;

			this.gameInst.world.RemoveController(this.controller);
			this.controller.Clear();
			this.controller = null;
		}

		private function removeStar(e:SquirrelEvent = null):void
		{
			if (e != null)
				e.player.removeEventListener(SquirrelEvent.DIE, removeStar);

			if (this.star.parent)
				this.star.parent.removeChild(this.star);
		}

		private function setScale(value:Number):void
		{
			var shape:b2CircleShape = new b2CircleShape((3 / Game.PIXELS_TO_METRE) * value);
			this.mainFixture.GetShape().Set(shape);

			this.view.scaleX = this.view.scaleY = value;
		}

		private function setHeroOnSnow(hero:Hero):void
		{
			if (!this.gameInst || hero.isDragon || hero.isHare || hero.isScrat || hero.shaman || hero.id == this.playerId)
			{
				destroy();
				return;
			}

			if (!this.sended)
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'OnSnowballs': [this.id, hero.id]}));

			this.sended = true;
		}

		private function onSnowKick(e:Event):void
		{
			this.viewKick.removeEventListener(Event.CHANGE, onSnowKick);

			if (this.viewKick.parent)
				this.viewKick.parent.removeChild(this.viewKick);
		}

		private function death():void
		{
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}