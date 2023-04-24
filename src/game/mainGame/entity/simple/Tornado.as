package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.IntUtil;
	import utils.starling.StarlingAdapterMovie;

	public class Tornado extends GameBody implements IPinFree
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(40 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.2, 0, 0.1, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_staticBody);

		static private const ANGLES:Array = [-45, 0, 45];
		static private const DELAY:int = 3 * 1000;

		private var view:StarlingAdapterMovie = null;

		private var sensor:HeroDetector = null;
		protected var squirrels:Dictionary = new Dictionary();

		public var power:Number = 150;

		public function Tornado():void
		{
			super();

			this.view = new StarlingAdapterMovie(new TornadoView());
			this.view.loop = true;
			addChildStarling(this.view);
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.gameInst = world.userData as SquirrelGame;

			this.body = world.CreateBody(BODY_DEF);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			super.build(world);
			this.view.play();
		}

		override public function dispose():void
		{
			for (var id:* in this.squirrels)
				releaseSquirrel(id);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			super.dispose();

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.power]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.power = data[1][0];
		}

		override public function update(timeStep:Number = 0):void
		{
			if (this.body == null)
				return;

			super.update(timeStep);

			for (var id:* in this.squirrels)
			{
				var hero:Hero = this.gameInst.squirrels.get(id);
				if (hero && !hero.isDead && !hero.inHollow)
				{
					if (hero.torqueApplied)
						hero.angle += 1;
				}
			}
		}

		protected function onHeroDetected(e:DetectHeroEvent):void
		{
			var hero:Hero = e.hero;

			if (this.squirrels[hero.id] != null || hero.isDead || hero.inHollow)
				return;

			commandPinSquirrel(hero.id);
		}

		protected function commandPinSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				pinSquirrel(heroId);
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'pinSquirrel': [this.id, heroId]}));
		}

		private function commandFireSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			if (this.gameInst is SquirrelGameEditor)
				fireSquirrel(heroId, IntUtil.randomInt(0, ANGLES.length - 1));
			else
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'fireSquirrel': [this.id, heroId, IntUtil.randomInt(0, ANGLES.length - 1)]}));
		}

		private function pinSquirrel(heroId:int):void
		{
			if (!this.gameInst || this.squirrels[heroId] != null)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || hero.torqueApplied)
				return;

			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.bodyA = this.body;
			hero.bindToRevoluteJointDef(jointDef, false);
			jointDef.collideConnected = false;
			jointDef.localAnchorA = new b2Vec2();
			jointDef.localAnchorB = new b2Vec2();
			this.squirrels[hero.id] = this.body.GetWorld().CreateJoint(jointDef);

			hero.isStoped = true;
			hero.torqueApplied = true;
			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			setTimeout(commandFireSquirrel, 500, hero.id);
		}

		private function fireSquirrel(heroId:int, randomValue:int):void
		{
			if (!this.gameInst || this.squirrels[heroId] == null)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);

			if (!hero || !hero.isExist)
			{
				removeSquirrel(heroId);
				return;
			}

			releaseSquirrel(heroId, true, randomValue);

			setTimeout(removeSquirrel, DELAY, heroId);
		}

		private function removeSquirrel(heroId:int):void
		{
			this.squirrels[heroId] = null;
			delete this.squirrels[heroId];
		}

		private function onEvent(e:Event):void
		{
			releaseSquirrel(e['player']['id']);
			removeSquirrel(e['player']['id']);
		}

		private function releaseSquirrel(heroId:int, fire:Boolean = false, randomValue:int = 0):void
		{
			this.body.GetWorld().DestroyJoint(this.squirrels[heroId] as b2Joint);

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero)
				return;

			if (fire)
			{
				var rotation:Number = this.rotation + ANGLES[randomValue];
				hero.angle = (rotation < 0 ? (360 - Math.abs(rotation)) : rotation) * Game.D2R;
				var impulse:b2Vec2 = hero.rCol2.Copy();
				impulse.Multiply(-hero.mass * this.power);
				hero.applyImpulse(impulse);
			}

			hero.torqueApplied = false;
			hero.isStoped = false;

			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('fireSquirrel' in data)
			{
				if (data['fireSquirrel'][0] != this.id)
					return;

				fireSquirrel(data['fireSquirrel'][1], data['fireSquirrel'][2]);
			}

			if ('pinSquirrel' in data)
			{
				if (data['pinSquirrel'][0] != this.id)
					return;

				pinSquirrel(data['pinSquirrel'][1]);
			}
		}
	}
}