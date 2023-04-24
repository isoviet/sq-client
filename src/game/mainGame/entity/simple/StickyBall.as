package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.FlyToHeroAnimation;
	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IMagnetizable;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.ISensor;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class StickyBall extends GameBody implements IMagnetizable, IPinFree, ISensor
	{
		static private const RADIUS:int = 64;

		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE_BIG:b2CircleShape = new b2CircleShape(RADIUS / Game.PIXELS_TO_METRE);
		static private const SHAPE_SMALL:b2CircleShape = new b2CircleShape(11 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE_BIG, null, 0.2, 0, 0.001, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		static private const SPEED_SLOWDOWN_FACTOR:int = 20;

		private var view:StarlingAdapterMovie = null;
		private var radius:StarlingAdapterSprite = null;
		private var hopAnimation:FlyToHeroAnimation = null;

		private var hero:Hero = null;
		private var speedBonus:Number;
		private var jointToHero:b2Joint = null;

		private var deserializedId:int = -1;
		private var spawnPlace:b2Vec2 = null;
		private var prevSquirrel:Hero = null;

		public function StickyBall():void
		{
			this.view = new StarlingAdapterMovie(new StickyImg);
			this.view.loop = true;
			this.view.stop();
			this.view.y = 10;
			addChildStarling(this.view);

			this.radius = new StarlingAdapterSprite(new PerkRadius());
			this.radius.scaleXY((RADIUS * 2) / this.radius.width);

			addChildStarling(this.radius);

			this.fixed = true;

			this.hopAnimation = new FlyToHeroAnimation(new StarlingAdapterSprite(new StickyIcon));

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF).SetUserData(this);
			super.build(world);

			this.view.play();

			if (this.spawnPlace == null)
				this.spawnPlace = this.position.Copy();

			if (this.deserializedId != -1)
				pinSquirrel(this.deserializedId);
		}

		override public function dispose():void
		{
			if (this.view)
				this.view.removeFromParent();

			this.view = null;

			if (this.hopAnimation)
				this.hopAnimation.dispose();
			this.hopAnimation = null;

			releaseHero();

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			this.prevSquirrel = null;

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push(this.spawnPlace == null ? this.spawnPlace : [this.spawnPlace.x, this.spawnPlace.y]);

			if (this.hero != null)
				result.push(this.hero.id);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.spawnPlace = data[1] != null ? new b2Vec2(data[1][0], data[1][1]) : null;

			if (2 in data)
				this.deserializedId = data[2];
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

			if (!hero || hero.isDead || hero.inHollow || hero.hasJoints("sticky") || this.hero == hero || this.prevSquirrel == hero)
				return;

			commandPinSquirrel(hero.id);
		}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		public function magnetize(magnet:Magnet):void
		{
			if (this.hero == null)
				return;

			releaseHero();
			this.fixed = true;

			setTimeout(setSpawnPlace, 0);

			this.view.visible = false;
			this.view.stop();
			if (magnet && magnet.parentStarling && this.hopAnimation)
			{
				this.hopAnimation.show(FlyToHeroAnimation.FROM_HERO, this.prevSquirrel, 5, magnet.parentStarling.globalToLocal(magnet.localToGlobal(new Point(0, -25))), new Point(), onCompleteFrom);
			}
		}

		private function setSpawnPlace():void
		{
			if (this.spawnPlace != null)
				position = this.spawnPlace.Copy();
		}

		private function commandPinSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				pinSquirrel(heroId);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'pinSquirrel': [this.id, heroId]}));
		}

		private function pinSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || hero.hasJoints("sticky"))
				return;

			if (this.hero)
				releaseHero();

			this.hero = hero;

			this.view.stop();
			this.view.visible = false;

			this.hopAnimation.show(FlyToHeroAnimation.TO_HERO, this.hero, 5, new Point(this.position.x * Game.PIXELS_TO_METRE, this.position.y * Game.PIXELS_TO_METRE), new Point(0, Hero.Y_POSITION_COEF), onCompleteTo);

			this.speedBonus = this.hero.runSpeed * SPEED_SLOWDOWN_FACTOR / 100;
			this.hero.runSpeed -= this.speedBonus;

			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);
			hero.addEventListener(Hero.EVENT_REMOVE, onEvent);
			hero.addEventListener(Hero.EVENT_SCALE, onScale);

			this.body.GetFixtureList().GetShape().Set(SHAPE_SMALL);

			this.fixed = false;

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyB = this.body;
			hero.bindToRevoluteJointDef(jointDef);
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2();
			jointDef.localAnchorB = new b2Vec2();
			this.jointToHero = this.body.GetWorld().CreateJoint(jointDef);
			this.jointToHero.SetUserData("sticky");
		}

		private function releaseHero():void
		{
			if (!this.hero)
				return;

			this.hero.runSpeed += this.speedBonus;
			this.prevSquirrel = this.hero;
			setTimeout(resetPrev, 3 * 1000);
			this.hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			this.hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
			this.hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			this.hero.removeEventListener(Hero.EVENT_REMOVE, onEvent);
			this.hero.removeEventListener(Hero.EVENT_SCALE, onScale);
			this.hero = null;

			this.body.GetFixtureList().GetShape().Set(SHAPE_BIG);

			if (this.jointToHero)
			{
				this.body.GetWorld().DestroyJoint(this.jointToHero);
				this.jointToHero = null;
			}

			if (this.hopAnimation)
				this.hopAnimation.remove();

			if (!this.view)
				return;

			this.view.gotoAndPlay(0);
			this.view.visible = true;
		}

		private function resetPrev():void
		{
			this.prevSquirrel = null;
		}

		private function onCompleteFrom():void
		{
			setTimeout(onMagnetize, 3 * 1000);
		}

		private function onMagnetize():void
		{
			if (this.hero != null || !this.view || !this.hopAnimation)
				return;

			this.hopAnimation.remove();
			this.view.visible = true;
			this.view.gotoAndPlay(0);
		}

		private function onCompleteTo():void
		{
			this.hopAnimation.x = 0;
			this.hopAnimation.y = 0;
			this.hero.heroView.addChildStarling(this.hopAnimation);
		}

		private function onEvent(e:Event):void
		{
			releaseHero();
			this.position = this.spawnPlace.Copy();
			this.fixed = true;
		}

		private function onScale(e:Event):void
		{
			this.body.GetFixtureList().GetShape().Set(new b2CircleShape(RADIUS / Game.PIXELS_TO_METRE * this.hero.scale));
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('pinSquirrel' in data)
			{
				if (data['pinSquirrel'][0] != this.id)
					return;

				pinSquirrel(data['pinSquirrel'][1]);
			}
		}
	}
}