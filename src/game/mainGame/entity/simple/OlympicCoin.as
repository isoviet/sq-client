package game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CameraController;
	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.events.SquirrelEvent;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	import utils.starling.StarlingAdapterSprite;

    public class OlympicCoin extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var playersMark:Array = [];
		private var view:StarlingAdapterSprite;

		public var sensor:HeroDetector;

		public function OlympicCoin():void
		{
			this.view = new StarlingAdapterSprite(new OlympicCoinView());
			addChildStarling(this.view);

			this.fixed = true;

			CameraController.dispatcher.addEventListener("CAMERA_CHANGE", onCamera);
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push(this.playersMark);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playersMark = data[1] == null ? [] : data[1];
		}

		override public function dispose():void
		{
			super.dispose();

			CameraController.dispatcher.removeEventListener("CAMERA_CHANGE", onCamera);
			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);
		}

		private function onCamera(e:SquirrelEvent):void
		{
			if (e.player == null)
				return;
			this.visible = this.playersMark.indexOf(CameraController.heroId) == -1;
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if ((e.hero.id != Game.selfId && e.hero.id > 0) || e.hero.isDead)
				return;
			if (this.playersMark.indexOf(Game.selfId) != -1)
				return;
			this.playersMark.push(Game.selfId);
			this.visible = false;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.OLYMPIC_COIN, e.hero));
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'olympicCoin': this.id}));
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;
			if ("olympicCoin" in data && data['olympicCoin'] == this.id)
			{
				this.playersMark.push(packet.playerId);
				this.visible = this.playersMark.indexOf(CameraController.heroId) == -1;
			}
		}
	}
}