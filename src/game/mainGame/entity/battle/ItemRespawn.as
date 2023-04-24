package game.mainGame.entity.battle
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.FlyingObjectAnimation;
	import game.mainGame.CollisionGroup;
	import game.mainGame.SideIconView;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.gameBattleNet.HeroBattle;
	import game.mainGame.gameBattleNet.SquirrelGameBattleNet;
	import game.mainGame.gameNet.GameMapNet;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundCommand;

	import utils.Rotator;
	import utils.starling.StarlingAdapterMovie;

	public class ItemRespawn extends GameBody
	{
		static private const RESPAWN_TIME:int = 5000;
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var movie:StarlingAdapterMovie;
		private var rotator:Rotator;

		private var sended:Boolean = false;
		private var respawnTimer:Timer = null;

		protected var timeRespawn:int = RESPAWN_TIME;
		protected var view:FlyingObjectAnimation = null;

		public var sensor:HeroDetector;

		public function ItemRespawn():void
		{
			initView();
			this.movie = new StarlingAdapterMovie(new PoiseContactMovie());
			this.movie.loop = false;
			this.movie.visible = false;
			this.movie.stop();
			this.movie.x = -21;
			this.movie.y = -48;
			this.movie.addEventListener(Event.COMPLETE, stopPoiseMovie);
			this.fixed = true;
			this.rotator = new Rotator(view, new Point);
			this.filters = [new GlowFilter(0xFFFFFF, 1, 10, 10, 5, 1, true)];
			Connection.listen(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
		}

		override public function get alpha():Number
		{
			return this.view.alpha;
		}

		override public function set alpha(value:Number):void
		{
			this.view.alpha = value;
		}

		override public function get ghost():Boolean
		{
			return false;
		}

		override public function set ghost(value:Boolean):void
		{
			if (value) {/*unused*/}
			super.ghost = false;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);

			this.view.play();
			addChildStarling(this.movie);
			addChildStarling(this.view);
		}

		override public function dispose():void
		{
			super.dispose();

			this.view.stop();
			if (this.sensor == null)
				return;

			this.view.dispose();

			if (this.respawnTimer != null)
				this.respawnTimer.stop();

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
			this.rotator = null;

			Connection.forget(onPacket, PacketRoundCommand.PACKET_ID);
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORIES_BITS;
		}

		public function onPickUp(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId && e.hero.id > 0)
				return;

			if (e.hero.isDead || e.hero.isHare || e.hero.isDragon)
				return;

			if (this.sended || !this.canPickUp(e))
				return;

			this.movie.playAndStop(0, 35);
			this.movie.visible = true;

			if (!e.hero.isHare)
			{
				var index:int = Math.random() * SoundConstants.ACORN_SOUNDS.length;
				GameSounds.play(SoundConstants.ACORN_SOUNDS[index]);
			}

			if (!(e.hero.game is SquirrelGameBattleNet))
			{
				toggleRespawn(false);
				editorEffect(e);
				return;
			}

			pickUpCommand(e);
			this.sended = true;
		}

		public function get sideIcon():DisplayObject
		{
			return new SideIconView(SideIconView.COLOR_GREEN, SideIconView.ICON_POISE_RESPAWN);
		}

		public function get showIcon():Boolean
		{
			return this.alpha > 0;
		}

		protected function initView():void
		{}

		protected function canPickUp(e:DetectHeroEvent):Boolean
		{
			return true;
		}

		protected function editorEffect(e:DetectHeroEvent):void
		{}

		protected function gameEffect(hero:HeroBattle):void
		{}

		protected function pickUpCommand(e:DetectHeroEvent):void
		{}

		protected function respawnCommand():void
		{}

		protected function pickUpData(data:Object):Array
		{
			return data as Array;
		}

		protected function respawnData(data:Object):Array
		{
			return data as Array;
		}

		private function stopPoiseMovie(e:Event):void
		{
			/*if (this.movie.currentFrame != 35)
				return;
			*/

			this.movie.stop();
			this.movie.visible = false;
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if (this.view.alpha == 0)
				return;

			onPickUp(e);
		}

		private function onRespawn(e:TimerEvent):void
		{
			if (this.gameInst && this.gameInst.map is GameMapNet && (this.gameInst.map as GameMapNet).syncCollection.doSync)
			{
				respawnCommand();
				toggleRespawn(true);
			}
		}

		private function toggleRespawn(active:Boolean):void
		{
			if (active)
			{
				this.alpha = 1;

				if (this.sensor.onDetect.length != 0)
					this.sensor.dispatchEvent(new DetectHeroEvent(this.sensor.onDetect[0]));

				if (this.respawnTimer != null)
					this.respawnTimer.stop();
				return;
			}

			this.alpha = 0;

			if (this.respawnTimer == null)
			{
				this.respawnTimer = new Timer(this.timeRespawn);
				this.respawnTimer.addEventListener(TimerEvent.TIMER, onRespawn);
			}

			this.respawnTimer.reset();
			this.respawnTimer.start();
		}

		private function onPacket(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;

			if (pickUpData(data) != null)
			{
				if (pickUpData(data)[0] != this.id)
					return;

				if (this.alpha == 0)
					return;

				toggleRespawn(false);

				this.sended = false;
				var hero:HeroBattle = this.gameInst.squirrels.get(pickUpData(data)[1]) as HeroBattle;
				if (!Hero.self)
					return;
				gameEffect(hero);
			}

			if (respawnData(data) != null)
			{
				if (respawnData(data)[0] != this.id)
					return;

				toggleRespawn(true);
			}
		}
	}
}