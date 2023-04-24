package landing.game.mainGame.entity.simple
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.events.SquirrelEvent;
	import landing.sensors.HeroDetector;
	import landing.sensors.events.DetectHeroEvent;

	import utils.Rotator;

	public class AcornBody extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(46 / 2 / WallShadow.PIXELS_TO_METRE, 32 / 2 / WallShadow.PIXELS_TO_METRE, new b2Vec2(25 / 2 / WallShadow.PIXELS_TO_METRE, 21 / 2 / WallShadow.PIXELS_TO_METRE));
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector;
		private var movie:AcornContactMovie = new AcornContactMovie();
		private var rotator:Rotator;

		public function AcornBody():void
		{
			var view:DisplayObject = new Acorns();
			view.x = -20;
			view.y = -20;
			addChild(view);

			this.movie.visible = false;
			this.movie.stop();
			this.movie.x = -11;
			this.movie.y = -48;
			this.movie.addEventListener(Event.ENTER_FRAME, stopAcornMovie);
			addChild(this.movie);

			this.fixed = true;
			this.rotator = new Rotator(view, new Point);
		}

		override public function get ghost():Boolean
		{
			return false;
		}

		override public function set ghost(value:Boolean):void
		{
			super.ghost = false;
		}

		override public function get rotation():Number
		{
			return super.rotation;
		}

		override public function set rotation(value:Number):void
		{
			super.rotation = value;
			this.rotator.rotation = -value;
		}

		private function stopAcornMovie(e:Event):void
		{
			if (this.movie.currentFrame != 50)
				return;

			this.movie.stop();
			this.movie.visible = false;
		}

		override public function get angle():Number
		{
			return 0;
		}

		override public function set angle(value:Number):void
		{
			super.angle = 0;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.id != WallShadow.SELF_ID)
				return;
			if (e.hero.hasAcorn())
				return;

			e.hero.setMode(wHero.ACORN_MOD);

			this.movie.gotoAndPlay(0);
			this.movie.visible = true;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.ACORN, e.hero));
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
			this.rotator = null;
		}
	}
}