package game.mainGame.entity.iceland
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Timer;

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
	import protocol.packages.server.PacketNyModePlace;

	import utils.starling.StarlingAdapterSprite;

	public class NYSnowReceiver extends GameBody implements IPinFree
	{
		static private const VIEWS:Array = [];// [SnowManView0, SnowManView1, SnowManView2, SnowManView3, SnowManView4];
		static private const COORDS:Array = [[25, -50], [40, -60], [35, -75], [35, -75], [35, -75]];
		static private const TEXTS:Array = [gls("Спасибо!"), gls("Круто!"), gls("Класс!"), gls("Отлично!"), gls("Снежок!")];
		static private const COUNTS:Array = [0, 20, 40, 60, 80, 100];

		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(40 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var field:GameField;
		private var sprite:Sprite;
		private var currentLevel:int = 0;
		private var timer:Timer = new Timer(3000, 1);

		public var sensor:HeroDetector;
		public var views:Array = [];

		public var count:int = 0;

		public function NYSnowReceiver():void
		{
			for (var i:int = 0; i < VIEWS.length; i++)
			{
				var viewClass:Class = VIEWS[i];
				this.views.push(addChildStarling(new StarlingAdapterSprite(new viewClass)));
				this.views[i].visible = false;
				this.views[i].y += 35;
			}
			this.views[0].visible = true;

			this.sprite = new Sprite();
			this.sprite.visible = false;
			this.field = new GameField("", 18, 5, new TextFormat(null, 10, 0x394DA3));
			//this.sprite.addChild(new SnowmanTextWindow);
			this.sprite.addChild(this.field);
			addChild(this.sprite);

			this.fixed = true;

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, hide);
			Connection.listen(onPacket, [PacketNyModePlace.PACKET_ID]);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);

			this.gameInst = world.userData as SquirrelGame;
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(onPacket, [PacketNyModePlace.PACKET_ID]);

			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, hide);

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

			if (!(e.hero as HeroIceland).haveSnow)
				return;

			if (e.hero.isDead || e.hero.shaman)
				return;

			Connection.sendData(PacketClient.NY_MODE_PLACE);
			(e.hero as HeroIceland).haveSnow = false;
		}

		protected function onPacket(packet:PacketNyModePlace):void
		{
			if (packet.status == 1)
				return;

			var hero:Hero = this.gameInst.squirrels.get(packet.playerId);
			if (hero != null && hero is HeroIceland)
				(hero as HeroIceland).haveSnow = false;

			this.count = packet.count;

			for (var i:int = 0; i < this.views.length; i++)
			{
				this.views[i].visible = COUNTS[i + 1] > this.count && this.count >= COUNTS[i];
				if (this.views[i].visible)
					this.currentLevel = i;
			}

			if (packet.playerId == Game.selfId)
				showText();
		}

		private function showText():void
		{
			this.field.text = TEXTS[int(TEXTS.length * Math.random())];
			this.sprite.x = COORDS[this.currentLevel][0];
			this.sprite.y = COORDS[this.currentLevel][1];
			this.sprite.visible = true;

			this.timer.reset();
			this.timer.start();
		}

		private function hide(e:TimerEvent):void
		{
			this.sprite.visible = false;
		}
	}
}