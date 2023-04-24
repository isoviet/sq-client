package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	public class CentrifugeDisc extends GameBody implements ILifeTime, IPinFree
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY;

		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const SHAPE1:b2CircleShape = new b2CircleShape(25 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF1:b2FixtureDef = new b2FixtureDef(SHAPE1, null, 0.8, 0.1, 0.5, CATEGORIES_BITS, MASK_BITS, 0);

		static private const SHAPE2:b2CircleShape = new b2CircleShape(10 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF2:b2FixtureDef = new b2FixtureDef(SHAPE2, null, 0.2, 0.1, 1, CATEGORIES_BITS, CollisionGroup.OBJECT_CATEGORY, 0);

		private var disc:b2Body = null;
		private var joint:b2RevoluteJoint = null;
		private var jointToHero:b2RevoluteJoint = null;

		private var deserializedId:int = -1;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 30 * 1000;
		private var disposed:Boolean = false;

		public var hero:Hero = null;
		public var boostDir:b2Vec2 = null;
		public var motorSpeed:Number = 10;

		public function CentrifugeDisc()
		{
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF2);
			this.fixedRotation = true;
			super.build(world);

			this.disc = world.CreateBody(BODY_DEF);
			this.disc.CreateFixture(FIXTURE_DEF1);
			this.disc.SetPositionAndAngle(this.position, this.angle);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(this.body, this.disc, this.body.GetWorldCenter());
			jointDef.collideConnected = false;
			jointDef.enableMotor = true;
			jointDef.motorSpeed = this.motorSpeed;
			jointDef.maxMotorTorque = 100000000;
			this.joint = this.body.GetWorld().CreateJoint(jointDef) as b2RevoluteJoint;

			if (this.deserializedId != -1)
				pinSquirrel(this.deserializedId);
			else if (this.hero)
				pinSquirrel(this.hero.id);

			if (this.boostDir != null)
			{
				var impulse:b2Vec2 = this.boostDir.Copy();
				impulse.Multiply(1000);
				this.disc.ApplyImpulse(impulse, this.disc.GetWorldCenter());
				this.boostDir = null;

				this.motorSpeed = Math.abs(this.motorSpeed) * (impulse.x > 0 ? 1 : -1);
				this.joint.SetMotorSpeed(this.motorSpeed);
			}

			if (!(this.hero && this.hero.isSelf))
				return;

			Game.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		override public function dispose():void
		{
			releaseHero();

			if (this.joint)
			{
				this.body.GetWorld().DestroyJoint(this.joint);
				this.joint = null;
			}

			if (this.disc)
			{
				for (var fixture:b2Fixture = this.disc.GetFixtureList(); fixture; fixture = fixture.GetNext())
					fixture.SetUserData(null);

				this.disc.SetUserData(null);
				this.disc.GetWorld().DestroyBody(this.disc);

				this.disc = null;
			}

			Game.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			var extraData:Array = [this.lifeTime, this.motorSpeed];
			extraData.push(this.boostDir ? [this.boostDir.x, this.boostDir.y] : null);
			if (this.hero != null)
				extraData.push(this.hero.id);

			result.push(extraData);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			var extraData:Array = data[1];
			this.lifeTime = extraData[0];
			this.motorSpeed = extraData[1];
			this.boostDir = extraData[2] != null ? new b2Vec2(extraData[2][0], extraData[2][1]) : null;
			if (3 in extraData)
				this.deserializedId = extraData[3];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body)
			{
				if (!this.aging || this.disposed)
					return;

				this._lifeTime -= timeStep * 1000;

				if (lifeTime <= 0)
					destroy();
			}
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			this.disposed = true;

			if (!(this.gameInst && this.gameInst.squirrels.isSynchronizing))
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}

		private function pinSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || hero.hasJoints("centrifugeDisc"))
				return;

			this.hero = hero;
			this.hero.changeView(new CentrifugeHero);
			this.hero.isStoped = true;
			this.hero.perksAvailable = false;

			hero.perkController.deactivateClothesPerks();
			hero.perkController.deactivateManaPerks();

			for (var i:int = hero.perkController.perksCharacter.length - 1; i >= 0; i--)
			{
				if (!(hero.perkController.perksCharacter[i].active))
					continue;
				hero.perkController.perksCharacter[i].active = false;
				hero.sendLocation(-hero.perkController.perksCharacter[i].code);
			}

			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);
			hero.addEventListener(Hero.EVENT_TELEPORT, onEvent);
			hero.addEventListener(Hero.EVENT_REMOVE, onEvent);

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyA = this.disc;
			hero.bindToRevoluteJointDef(jointDef, false);
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2();
			jointDef.localAnchorB = new b2Vec2();
			this.jointToHero = this.body.GetWorld().CreateJoint(jointDef) as b2RevoluteJoint;
			this.jointToHero.SetUserData("centrifugeDisc");
		}

		private function onEvent(e:Event):void
		{
			releaseHero();

			setTimeout(destroy, 0);
		}

		private function releaseHero():void
		{
			if (!this.hero)
				return;

			this.hero.changeView();
			this.hero.isStoped = false;
			this.hero.perksAvailable = true;

			this.hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			this.hero.removeEventListener(Hero.EVENT_TELEPORT, onEvent);
			this.hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
			this.hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			this.hero.removeEventListener(Hero.EVENT_REMOVE, onEvent);
			this.hero = null;

			if (this.jointToHero)
			{
				this.body.GetWorld().DestroyJoint(this.jointToHero);
				this.jointToHero = null;
			}
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (Game.chat.hasFocus())
				return;

			switch(e.keyCode)
			{
				case Keyboard.LEFT:
				case Keyboard.A:
					if (this.motorSpeed < 0)
						return;
					commandSwitchDirection();
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					if (this.motorSpeed > 0)
						return;
					commandSwitchDirection();
					break;
			}
		}

		private function commandSwitchDirection():void
		{
			if (!this.hero || !this.hero.isSelf)
				return;

			if (this.gameInst is SquirrelGameEditor)
				switchDirection(this.position);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'switchDirection': [this.id, [this.position.x, this.position.y]]}));
		}

		private function switchDirection(position:b2Vec2):void
		{
			this.position = position;
			this.disc.SetLinearVelocity(new b2Vec2(- this.disc.GetLinearVelocity().x, this.disc.GetLinearVelocity().y));
			this.joint.SetMotorSpeed(this.joint.GetMotorSpeed() * (-1));
			this.motorSpeed = this.joint.GetMotorSpeed();
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('switchDirection' in data)
			{
				if (data['switchDirection'][0] != this.id)
					return;

				switchDirection(new b2Vec2(data['switchDirection'][1][0], data['switchDirection'][1][1]));
			}
		}
	}
}