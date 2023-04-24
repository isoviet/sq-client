package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Controllers.b2ConstantAccelController;
	import Box2D.Dynamics.Joints.b2JointEdge;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterMovie;

	public class BoostZone extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsBox(60 / Game.PIXELS_TO_METRE, 25 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.2, 0, 0, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_staticBody);

		private var view:StarlingAdapterMovie = null;
		private var sensor:HeroDetector = null;
		private var controller:b2ConstantAccelController = null;

		private var squirrels:Object = {};

		private var buff:BuffRadialView = null;
		private var timer:Timer = new Timer(10, 100);

		private var deserializedIds:Array = [];

		public var boostFactor:int = 30;
		public var boostTime:int = 5 * 1000;

		public function BoostZone():void
		{
			this.view = new StarlingAdapterMovie(new BoostZoneImg);
			this.view.stop();
			this.view.x = -60;
			this.view.y = -25;
			addChildStarling(this.view);

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function serialize():*
		{
			var ids:Array = [];
			for (var id:String in this.squirrels)
				ids.push(id);

			var result:Array = super.serialize();
			result.push([this.boostFactor, this.boostTime, ids]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.boostFactor = data[1][0];
			this.boostTime = data[1][1];

			this.deserializedIds = data[1][2];
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			this.view.play();

			super.build(world);

			this.controller = new b2ConstantAccelController();
			this.controller.A = world.GetGravity().GetNegative();
			world.AddController(this.controller);

			for (var i:int = 0; i < this.deserializedIds.length; i++)
			{
				var hero:Hero = this.gameInst.squirrels.get(this.deserializedIds[i]);
				if (!hero || hero.isDead || hero.inHollow || (hero.id in this.squirrels))
					return;

				var bonus:Number = hero.runSpeed * (this.boostFactor / 100);
				this.squirrels[hero.id] = {'speed': bonus};
				hero.runSpeed += bonus;
			}

			this.deserializedIds.splice(0);
		}

		override public function dispose():void
		{
			this.view.removeFromParent();
			this.removeFromParent();

			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onComplete);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			for (var id:String in this.squirrels)
				resetSquirrel(int(id));

			this.squirrels = null;

			if (this.controller)
			{
				this.gameInst.world.RemoveController(this.controller);
				this.controller.Clear();
				this.controller = null;
			}

			super.dispose();

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			var hero:Hero = e.hero;

			if (hero.isDead || hero.inHollow)
				return;

			if (e.state == DetectHeroEvent.BEGIN_CONTACT && !(hero.id in this.squirrels))
				commandBoostSquirrel(e.hero.id);
		}

		private function commandBoostSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId)
				return;

			boostSquirrel(heroId);

			if (!(this.gameInst is SquirrelGameEditor))
			{
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'boostSquirrel': [this.id, heroId]}));
				Hero.self.sendLocation();
			}
		}

		private function commandResetSquirrel(heroId:int):void
		{
			if (heroId > 0 && heroId != Game.selfId || !this.gameInst)
				return;

			removeSquirrel(heroId);

			if (!(this.gameInst is SquirrelGameEditor))
			{
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'resetBoostSquirrel': [this.id, heroId]}));
				Hero.self.sendLocation();
			}
		}

		private function boostSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || hero.isDead || hero.inHollow || (hero.id in this.squirrels))
				return;

			var bonus:Number = hero.runSpeed * (this.boostFactor / 100);

			this.squirrels[hero.id] = {'speed': bonus, 'friction': hero.friction};
			hero.runSpeed += bonus;

			hero.velocity = new b2Vec2();
			hero.isStoped = true;
			hero.friction = 1;

			this.controller.AddBody(hero.body);

			var impulse:b2Vec2 = this.body.GetTransform().R.col1.Copy();
			var mass:Number = hero.mass;
			for (var list:b2JointEdge = hero.body.GetJointList(); list; list = list.next)
			{
				if (!(list.joint.GetBodyA().GetUserData() != hero))
					mass += list.joint.GetBodyA().GetMass() * 10;

				if (!(list.joint.GetBodyB().GetUserData() != hero))
					mass += list.joint.GetBodyB().GetMass() * 10;
			}

			impulse.Multiply(mass * 50 * (1 + this.boostFactor / 100));
			hero.applyImpulse(impulse);

			this.view.gotoAndPlay(0);

			setTimeout(onBoostEnd, 100, hero);

			if (!hero.isSelf)
				return;

			hero.addEventListener(SquirrelEvent.RESET, onEvent);
			hero.addEventListener(SquirrelEvent.DIE, onEvent);
			hero.addEventListener(HollowEvent.HOLLOW, onEvent);

			if (!buff)
				buff = new BuffRadialView(new BoostZoneImg, 0.7, 0.5, gls("Белка получила ускорение."));

			hero.addBuff(buff, this.timer);

			this.timer.delay = this.boostTime / 100;
			this.timer.reset();
			this.timer.start();
		}

		private function removeSquirrel(heroId:int):void
		{
			resetSquirrel(heroId);
			delete this.squirrels[heroId];
		}

		private function resetSquirrel(heroId:int):void
		{
			if (!this.gameInst)
				return;

			var hero:Hero = this.gameInst.squirrels.get(heroId);
			if (!hero || !hero.isExist || !(hero.id in this.squirrels))
				return;

			hero.isStoped = false;
			hero.runSpeed -= this.squirrels[hero.id]['speed'];
			if ("friction" in this.squirrels[hero.id])
			{
				if (this.controller && hero.body)
					this.controller.RemoveBody(hero.body);

				hero.friction = this.squirrels[hero.id];
				delete this.squirrels[hero.id]['friction'];
			}

			if (!hero.isSelf)
				return;

			if (this.timer.running)
			{
				this.timer.reset();
				hero.removeBuff(this.buff, this.timer);
			}

			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}

		private function onComplete(e:TimerEvent):void
		{
			commandResetSquirrel(Game.selfId);
		}

		private function onEvent(e:Event):void
		{
			commandResetSquirrel(e['player']['id']);
		}

		private function onBoostEnd(hero:Hero):void
		{
			if (!hero || !hero.isExist || !this.squirrels || !(hero.id in this.squirrels))
				return;

			if (this.squirrels[hero.id]['friction'])
			{
				hero.isStoped = false;
				hero.friction = this.squirrels[hero.id]['friction'];
				if (hero.body)
					this.controller.RemoveBody(hero.body);
				delete this.squirrels[hero.id]['friction'];
			} else {
				Logger.add('Error BoostZone/onBoostEnd-> this.squirrels[hero.id][friction]');
			}
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('boostSquirrel' in data)
			{
				if (data['boostSquirrel'][0] != this.id)
					return;
				if (data['boostSquirrel'][1] == Game.selfId)
					return;

				boostSquirrel(data['boostSquirrel'][1]);
			}

			if ('resetBoostSquirrel' in data)
			{
				if (data['resetBoostSquirrel'][0] != this.id)
					return;
				if (data['resetBoostSquirrel'][1] == Game.selfId)
					return;

				removeSquirrel(data['resetBoostSquirrel'][1]);
			}
		}
	}
}