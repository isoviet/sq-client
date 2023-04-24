package game.mainGame.entity.simple
{
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;

	public class HomingGun extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsVector(vertices, 0);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 2, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const ROTATION_STEP:Number = 0.1;
		static private const RELOAD_TIME:int = 1 * 1000;

		private var view:StarlingAdapterSprite = null;
		private var radiusView:StarlingAdapterSprite = null;

		private var _radius:Number = 200 / Game.PIXELS_TO_METRE;

		private var sensor:HeroDetector = null;
		private var squirrels:Array = [];

		private var waitTime:Number = 0;
		private var aimHero:Hero = null;
		private var radiusDefSize: Number = 0;

		public var power:Number = 200;
		public var active:Boolean = true;
		public var selfDirection:Boolean = true;

		public function HomingGun():void
		{
			this.view = new StarlingAdapterSprite(new HomingGunImg());
			addChildStarling(this.view);

			this.radiusView = new StarlingAdapterSprite(new PerkRadius());
			radiusDefSize = this.radiusView.width;

			addChildStarling(this.radiusView);

			this.radius = 200;

			this.fixed = true;

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		static private function get vertices():Vector.<b2Vec2>
		{
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			vertices.push(new b2Vec2(0.4, -1.2));
			vertices.push(new b2Vec2(2.2, -1.2));
			vertices.push(new b2Vec2(4, -0.9));
			vertices.push(new b2Vec2(4, 0.9));
			vertices.push(new b2Vec2(2.2, 1.2));
			vertices.push(new b2Vec2(0.4, 1.2));
			vertices.push(new b2Vec2(-1, 0));
			return vertices;
		}

		override public function set showDebug(value:Boolean):void
		{
			super.showDebug = value;

			this.radiusView.visible = this.debugDraw;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);
			super.build(world);

			this.sensor = new HeroDetector(this.body.CreateFixture(new b2FixtureDef(new b2CircleShape(this.radius / Game.PIXELS_TO_METRE), null, 0.8, 0.1, 2, CollisionGroup.HERO_DETECTOR_CATEGORY, CollisionGroup.HERO_CATEGORY, 0, true)));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
		}

		override public function dispose():void
		{
			for (var i:int = this.squirrels.length - 1; i >= 0; i--)
				removeSquirrel(this.squirrels[i]);

			this.squirrels = null;

			if (this.sensor)
				this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;

			this.aimHero = null;

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.radius, this.power, this.active, this.waitTime, this.selfDirection]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.radius = data[1][0];
			this.power = data[1][1];
			this.active = Boolean(data[1][2]);
			this.waitTime = data[1][3];

			if (4 in data[1])
				this.selfDirection = data[1][4];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.body == null)
				return;

			if (this.waitTime > 0)
			{
				this.waitTime -= timeStep * 1000;
				return;
			}

			if (!this.active)
				return;

			if (this.squirrels.length == 0)
				return;

			if (this.aimHero != null)
				return;

			var aimHero:Hero = this.squirrels[0];
			if (aimHero == null || aimHero.isDead || aimHero.inHollow)
				return;

			var angle:Number = Math.atan2(aimHero.position.y - this.position.y, aimHero.position.x - this.position.x);
			var diff:Number = angle - this.angle;
			if (Math.abs(diff) > Math.PI)
				diff += Math.PI * 2 * ((angle <= 0) ? 1 : -1);

			if (Math.abs(diff) < ROTATION_STEP)
			{
				this.aimHero = aimHero;
				commandShoot(aimHero.id);
				return;
			}

			if (!this.selfDirection)
				return;

			this.fixed = false;
			this.angle += (diff > 0 ? 1 : - 1) * ROTATION_STEP;
			this.fixed = true;
		}

		public function set radius(value:Number):void
		{
			this._radius = value / Game.PIXELS_TO_METRE;
			this.radiusView.scaleXY((value * 2) / radiusDefSize);
		}

		public function get radius():Number
		{
			return this._radius * Game.PIXELS_TO_METRE;
		}

		private function commandShoot(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				shoot(this.angle);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'cannonShoot': [this.id, this.angle]}));
		}

		private function shoot(angle:Number):void
		{
			this.fixed = false;
			this.angle = angle;
			this.fixed = true;

			this.waitTime = RELOAD_TIME;
			this.aimHero = null;

			if (this.gameInst && !this.gameInst.squirrels.isSynchronizing)
				return;

			var poise:GunPoise = new GunPoise();
			poise.angle = angle;
			poise.position = this.body.GetWorldPoint(new b2Vec2(6, 0));
			poise.velocity = this.power;
			this.gameInst.map.createObjectSync(poise, true);
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			var hero:Hero = e.hero;

			if (hero.inHollow)
				return;

			var index:int = this.squirrels.indexOf(hero);

			if (e.state == DetectHeroEvent.BEGIN_CONTACT && index == -1)
			{
				this.squirrels.push(hero);
				hero.addEventListener(SquirrelEvent.RESET, onEvent);
				hero.addEventListener(SquirrelEvent.DIE, onEvent);
				hero.addEventListener(HollowEvent.HOLLOW, onEvent);
			}
			else if (e.state == DetectHeroEvent.END_CONTACT)
				removeSquirrel(hero);
		}

		private function removeSquirrel(hero:Hero):void
		{
			var index:int = this.squirrels.indexOf(hero);
			if (index == -1)
				return;

			this.squirrels.splice(index, 1);
			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}

		private function onEvent(e:Event):void
		{
			removeSquirrel(e['player']);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('cannonShoot' in data)
			{
				if (data['cannonShoot'][0] != this.id)
					return;

				shoot(data['cannonShoot'][1]);
			}
		}
	}
}