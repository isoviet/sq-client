package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.ISideObject;
	import game.mainGame.IUpdate;
	import game.mainGame.SideIconView;
	import game.mainGame.SquirrelGame;
	import game.mainGame.events.HollowEvent;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;

	import utils.Rotator;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class HollowBody extends GameBody implements ISideObject, IUpdate
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2PolygonShape = b2PolygonShape.AsOrientedBox(43 / 2/ Game.PIXELS_TO_METRE, 53 / 2 / Game.PIXELS_TO_METRE, new b2Vec2(42 / 2 / Game.PIXELS_TO_METRE, 46 / 2 / Game.PIXELS_TO_METRE));
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector;
		private var movie:StarlingAdapterMovie = new StarlingAdapterMovie(new HollowContactMovie());
		private var hollowWow:StarlingAdapterMovie = new StarlingAdapterMovie(new HollowWow());

		private var selfHero:Hero;
		private var rotator:Rotator;
		private var _isVisible: Boolean = false;

		private var hollowDoor:StarlingAdapterSprite = new StarlingAdapterSprite(new HollowDoor());
		private var hollowEyes:StarlingAdapterMovie = new StarlingAdapterMovie(new HollowEyes());

		protected var type:int;

		public var game: SquirrelGame;

		public function HollowBody():void
		{
			var view:StarlingAdapterSprite = new StarlingAdapterSprite();
			view.x = -20;
			view.y = -20;

			view.addChildStarling(new StarlingAdapterSprite(this.hollowIcon));
			view.addChildStarling(this.hollowEyes);
			view.addChildStarling(this.hollowDoor);
			this.hollowDoor.x = 20;
			this.hollowDoor.y = 16;
			addChildStarling(view);

			this.hollowEyes.maxFPS = 5;
			this.hollowEyes.loop = true;

			this.movie.x = 21;
			this.movie.y = 44;
			this.movie.visible = false;
			this.movie.stop();

			this.hollowWow.x = -28;
			this.hollowWow.y = -27;
			this.hollowWow.loop = false;
			this.hollowWow.visible = false;

			this.rotator = new Rotator(view, new Point);
			this.fixed = true;
		}

		override public function get cacheBitmap():Boolean
		{
			return false;
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
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected);

			addChildStarling(this.hollowWow);
			addChildStarling(this.movie);

			super.build(world);
		}

		override public function dispose():void
		{
			super.dispose();

			this.selfHero = null;
			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
			this.rotator = null;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.hollowDoor.visible = !(Hero.self && (!Hero.self.isDead && !Hero.self.isHare && Hero.self.hasNut && (!Hero.self.shaman || (Hero.self.team == this.type) && Hero.self.shaman && !this.game.squirrels.hasActiveSquirrel())));

			if (this.hollowEyes.visible == this.hollowDoor.visible)
			{
				this.hollowEyes.visible = !this.hollowDoor.visible;
				if (this.hollowEyes.visible)
					hollowEyes.gotoAndPlay(0);
				else
					hollowEyes.gotoAndStop(0);
			}

			//TODO WTF
			if ((this.selfHero == null) || this.selfHero.inHollow)
				return;

			this.selfHero.setMode(Hero.NUDE_MOD);
			this.selfHero.onHollow(this.type);
		}

		public function get sideIcon(): StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_GREEN, SideIconView.ICON_HOLLOW);
		}

		public function get showIcon():Boolean
		{
			return true;
		}

		public function get isVisible():Boolean {
			return _isVisible;
		}

		public function set isVisible(value: Boolean): void {
			_isVisible = false;
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORIES_BITS;
		}

		protected function get hollowIcon():DisplayObject
		{
			return new Hollow();
		}

		protected function onHeroDetected(e:DetectHeroEvent):void
		{
			if (!e.hero.hasNut || e.hero.inHollow || e.hero.isDead || e.state != DetectHeroEvent.BEGIN_CONTACT)
				return;

			if (e.hero.isHare)
				return;

			if (e.hero.shaman && this.game.squirrels.hasActiveSquirrel())
				return;

			this.hollowWow.visible = true;
			this.hollowWow.gotoAndPlay(0);

			if (e.hero['id'] != Game.selfId && e.hero['id'] > 0)
				return;

			this.selfHero = e.hero;
			this.selfHero.setMode(Hero.NUDE_MOD);

			this.movie.gotoAndPlay(0);
			this.movie.visible = true;

			//GameSounds.play("game_win");

			dispatchEvent(new HollowEvent(e.hero, this.type));
		}
	}
}