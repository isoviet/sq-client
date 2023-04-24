package game.mainGame.entity.simple
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.behaviours.StateContused;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;

	import by.blooddy.crypto.serialization.JSON;

	import com.greensock.TweenMax;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	public class Bomb extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(140 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector;
		private var activated:Boolean = false;

		private var view:MovieClip;

		public function Bomb():void
		{
			this.view = new RemboMine();
			this.view.gotoAndStop(0);
			addChild(this.view);

			this.fixed = true;

			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);

			super();
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			super.build(world);

			this.view.addEventListener("Explode", onExplode);
			this.view.addEventListener(Event.CHANGE, onComplete);
		}

		override public function dispose():void
		{
			super.dispose();

			if (contains(this.view))
				removeChild(this.view);

			this.view.removeEventListener("Explode", onExplode);
			this.view.removeEventListener(Event.CHANGE, onComplete);

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[1][0];
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if (!this.gameInst.squirrels.isSynchronizing)
				return;

			if (e.hero.isDead || e.hero.isHare || e.hero.shaman || e.hero.inHollow)
				return;

			if (e.hero.perkController.getPerkLevel(PerkClothesFactory.RAMBO) == -1)
				return;

			if (!this.activated)
				Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'bomb': [this.playerId]}));

			this.activated = true;
		}

		private function onExplode(e:Event):void
		{
			this.view.stop();
			this.view.removeEventListener("Explode", onExplode);

			contuse();
		}

		private function onComplete(e:Event):void
		{
			this.view.visible = false;
			this.view.removeEventListener(Event.CHANGE, onComplete);

			if (!this.gameInst.squirrels.isSynchronizing)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if ('bomb' in data)
			{
				if (data['bomb'][0] != this.playerId)
					return;

				this.view.gotoAndPlay(1);
			}
			else if ('contused' in data)
			{
				if (data['contused'][0] != this.playerId)
					return;

				if (!this.gameInst || !this.gameInst.squirrels)
					return;

				this.view.gotoAndPlay(61);

				var whiteScreen:Shape = new Shape();
				whiteScreen.graphics.beginFill(0xFFFFFF, 0.5);
				whiteScreen.graphics.drawRect(0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT);
				whiteScreen.graphics.endFill();
				this.gameInst.addChild(whiteScreen);

				TweenMax.to(whiteScreen, 0.6, {'delay': 0.2, 'alpha': 0, 'onComplete': function():void
				{
					if (whiteScreen.parent == null)
						return;
					if (!whiteScreen.parent.contains(whiteScreen))
						return;

					whiteScreen.parent.removeChild(whiteScreen);
				}});

				for each (var id:int in data['contused'][1])
				{
					var hero:Hero = this.gameInst.squirrels.get(id);
					if (hero.isDead || hero.isHare || hero.shaman || hero.isDragon || hero.isScrat)
						continue;

					hero.behaviourController.addState(new StateContused(10));
				}
			}
		}

		private function contuse():void
		{
			if (!this.gameInst || !this.gameInst.squirrels || !this.gameInst.squirrels.isSynchronizing)
				return;

			var contused:Array = [];

			GameSounds.play("bomb");

			for each (var hero:Hero in this.sensor.onDetect)
			{
				if (hero.isDead || hero.isHare || hero.shaman || hero.isDragon || hero.isScrat)
					continue;

				if (hero.perkController.getPerkLevel(PerkClothesFactory.RAMBO) != -1)
					continue;

				contused.push(hero.id);
			}

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'contused': [this.playerId, contused]}));
		}
	}
}