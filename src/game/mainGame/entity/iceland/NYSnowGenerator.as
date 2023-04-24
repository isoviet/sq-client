package game.mainGame.entity.iceland
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameIceland.HeroIceland;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketNyModeTake;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class NYSnowGenerator extends GameBody implements IPinFree
	{
		static private const MAX_COUNT:int = 20;

		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(25 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector;
		private var movie:StarlingAdapterMovie = new StarlingAdapterMovie(new MovieClip());//new SnowContactMovie());
		private var view:StarlingAdapterSprite;
		public var index:int = 0;

		public var sended:Boolean = false;

		public var count:int = MAX_COUNT;

		public function NYSnowGenerator():void
		{
			this.view = new StarlingAdapterSprite(new MovieClip());
			this.view.x = -45;
			this.view.y = -20;
			addChildStarling(this.view);

			this.movie.visible = false;
			this.movie.loop = false;
			this.movie.stop();
			this.movie.x = -25;
			this.movie.y = -55;
			this.movie.addEventListener(Event.COMPLETE, stopAcornMovie);

			this.fixed = true;

			Connection.listen(onPacket, [PacketNyModeTake.PACKET_ID]);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);

			this.gameInst = world.userData as SquirrelGame;
			addChildStarling(this.movie);
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(onPacket, [PacketNyModeTake.PACKET_ID]);

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORIES_BITS;
		}

		protected function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId && e.hero.id > 0)
				return;

			if (e.hero.isDead || e.hero.shaman)
				return;

			if (this.count <= 0)
				return;

			if (this.sended || (e.hero as HeroIceland).haveSnow)
				return;

			this.movie.gotoAndPlay(0);
			this.movie.visible = true;

			Connection.sendData(PacketClient.NY_MODE_TAKE, this.index);
			(e.hero as HeroIceland).haveSnow = true;
			this.sended = true;
		}

		protected function onPacket(packet:PacketNyModeTake):void
		{
			if (packet.status == 1)
				return;

			if (this.index != packet.index)
				return;

			if (packet.playerId == Game.selfId)
				this.sended = false;
			else
			{
				var hero:Hero = this.gameInst.squirrels.get(packet.packetId);
				if (hero != null && hero is HeroIceland)
					(hero as HeroIceland).haveSnow = true;
			}

			this.count = packet.count;
			this.visible = this.count > 0;
		}

		private function stopAcornMovie(e:Event):void
		{
			this.movie.stop();
			this.movie.visible = false;
		}
	}
}