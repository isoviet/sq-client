package game.mainGame.entity.simple
{
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.ILimitedAngles;
	import game.mainGame.entity.IPinFree;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameEditor.SquirrelGameEditor;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class NutsDisintegrator extends GameBody implements ILimitedAngles, IPinFree
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(30 / Game.PIXELS_TO_METRE, 32 / Game.PIXELS_TO_METRE, new b2Vec2(0, -43 / Game.PIXELS_TO_METRE));
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.2, 0, 0.1, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_staticBody);
		static private const PARTICLES_NUMBER: int = 7;

		private var sensor:HeroDetector = null;
		private var squirrels:Array = [];

		private var view: StarlingAdapterMovie = null;
		private var particles: StarlingAdapterSprite = new StarlingAdapterSprite();

		private var _active:Boolean = true;
		private var effectCollection: CollectionEffects = CollectionEffects.instance;
		private var effectDisintergrator: ParticlesEffect;

		public function NutsDisintegrator():void
		{
			this.view = new StarlingAdapterMovie(new Disintegrator);
			addChildStarling(particles);
			addChildStarling(this.view);
		}

		override public function set angle(value:Number):void
		{
			super.angle = checkAngle(value * Game.R2D) * Game.D2R;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			effectDisintergrator = effectCollection.getEffectByName(CollectionEffects.EFFECT_DISINTEGRATOR);
			effectDisintergrator.start();
			particles.getStarlingView().addChild(effectDisintergrator.view);
			effectDisintergrator.view.emitterX = 0;
			effectDisintergrator.view.emitterY = -this.view.height / 2;
			super.build(world);
		}

		override public function dispose():void
		{
			if (effectDisintergrator)
			{
				effectDisintergrator.stop();
				effectDisintergrator.removeFromParent(true);
				effectDisintergrator = null;
			}
			particles.removeFromParent(true);
			particles = null;

			for each (var hero:Hero in this.squirrels)
			{
				if (!hero || !hero.isExist)
					continue;

				removeSquirrel(hero);
			}

			this.squirrels = null;

			if (this.sensor)
				this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;

			super.dispose();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push(this.active);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.active = Boolean(data[1]);
		}

		public function set active(value:Boolean):void
		{
			if (this._active == value)
				return;

			this._active = value;
			this.view.gotoAndStop(value ? 0 : 1);
			particles.visible = value;
			if (!value)
				return;

			checkSquirrels();
		}

		public function get active():Boolean
		{
			return this._active;
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
				takeAcorn(hero);
				hero.addEventListener(SquirrelEvent.RESET, onEvent);
				hero.addEventListener(SquirrelEvent.DIE, onEvent);
				hero.addEventListener(HollowEvent.HOLLOW, onEvent);
				hero.addEventListener(SquirrelEvent.ACORN, onAcorn);
			}
			else if (e.state == DetectHeroEvent.END_CONTACT)
			{
				removeSquirrel(hero);
				if (index != -1)
					this.squirrels.splice(index, 1);
			}
		}

		private function onEvent(e:Event):void
		{
			removeSquirrel(e['player']);
			var index:int = this.squirrels.indexOf(e['player']);
			if (index != -1)
				this.squirrels.splice(index, 1);
		}

		private function removeSquirrel(hero:Hero):void
		{
			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
			hero.removeEventListener(SquirrelEvent.ACORN, onAcorn);
		}

		private function onAcorn(e:SquirrelEvent):void
		{
			takeAcorn(e.player);
		}

		private function takeAcorn(hero:Hero):void
		{
			if (!hero.hasNut || !this.active || !hero.isSelf)
				return;

			hero.setMode(Hero.NUDE_MOD);
			createMissNut(hero);

			if (!(this.gameInst is SquirrelGameEditor))
				Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_LOST);
		}

		private function createMissNut(hero: Hero): void
		{
			var nutReleaseMove: StarlingAdapterMovie = new StarlingAdapterMovie(new DisintegratorMissNut());
			hero.heroView.addChildStarling(nutReleaseMove);
			nutReleaseMove.x = 0;
			nutReleaseMove.y = -hero.heroView.height / 2 - nutReleaseMove.height / 2;
			nutReleaseMove.loop = false;
			nutReleaseMove.play();
			nutReleaseMove.addEventListener(Event.COMPLETE, onCompleteAnimationNut)
		}

		private function onCompleteAnimationNut(e: Event = null): void
		{
			if (!e.target)
				return;

			var movie: StarlingAdapterMovie = e.target as StarlingAdapterMovie;
			if (movie)
			{
				movie.stop();
				movie.removeFromParent(true);
				movie = null;
			}
		}

		private function checkSquirrels():void
		{
			var hero:Hero = null;

			for (var i:int = this.squirrels.length - 1; i >= 0; i--)
			{
				hero = this.squirrels[i];
				if (hero && hero.hasNut)
					takeAcorn(hero);
			}
		}

		public function checkAngle(gradAngle:Number):Number
		{
			var grad:int = gradAngle < 0 ? (360 + gradAngle) : gradAngle;

			if (grad >= 0 && grad < 45 || grad >= 315)
				grad = 0;
			else if (grad >= 45 && grad < 135)
				grad = 90;
			else if (grad >= 135 && grad < 225)
				grad = 180;
			else
				grad = 270;

			return grad;
		}
	}
}