package landing.game.mainGame.entity.simple
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;
	import landing.game.mainGame.SquirrelGame;
	import landing.game.mainGame.events.SquirrelEvent;
	import landing.sensors.HeroDetector;
	import landing.sensors.events.DetectHeroEvent;

	import utils.Rotator;

	public class HollowBody extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(43 / 2/ WallShadow.PIXELS_TO_METRE, 53 / 2 / WallShadow.PIXELS_TO_METRE, new b2Vec2(42 / 2 / WallShadow.PIXELS_TO_METRE, 46 / 2 / WallShadow.PIXELS_TO_METRE));
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector;
		private var movie:HollowContactMovie = new HollowContactMovie();
		private var hollowWow:HollowWow = new HollowWow();

		private var selfHero:wHero;
		private var rotator:Rotator;

		public var game:SquirrelGame;

		public function HollowBody():void
		{
			var view:DisplayObject = new Hollow();
			view.x = -20;
			view.y = -20;
			addChild(view);

			this.movie.x = 21;
			this.movie.y = 44;
			this.movie.visible = false;
			this.movie.stop();
			addChild(this.movie);

			this.hollowWow.x = -28;
			this.hollowWow.y = -27;
			this.hollowWow.visible = false;
			addChild(this.hollowWow);

			this.rotator = new Rotator(view, new Point);
			this.fixed = true;
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
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected);

			super.build(world);
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if (!e.hero.hasAcorn())
				return;

			if (e.hero.isShaman && this.game.squirrels.hasActiveSquirrel())
				return;

			this.hollowWow.visible = true;
			this.hollowWow.gotoAndPlay(0);

			if (e.hero['id'] != WallShadow.SELF_ID)
				return;

			this.selfHero = e.hero;

			this.movie.gotoAndPlay(0);
			this.movie.visible = true;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.HOLLOW, e.hero));
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

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.selfHero == null)
				return;

			this.selfHero.setMode(wHero.NUDE_MOD);
			this.selfHero.inHollow = true;
			this.selfHero.hide();
			this.selfHero = null;
		}
	}
}