package game.mainGame.entity.simple
{
	import flash.events.Event;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.ISideObject;
	import game.mainGame.SideIconView;
	import game.mainGame.events.SquirrelEvent;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import utils.Rotator;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class AcornBody extends CacheVolatileBody implements ISideObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var movie:StarlingAdapterMovie = new StarlingAdapterMovie(new AcornContactMovie());
		private var rotator:Rotator;

		private var _scale:Number = 1;
		private var fixture:b2Fixture = null;
		private var _isVisible: Boolean = false;

		private var effectLight:StarlingAdapterMovie = new StarlingAdapterMovie(new AcornEffectLight());
		private var view:StarlingAdapterSprite = new StarlingAdapterSprite(new AcornsVector());

		public var sensor: HeroDetector;

		public function AcornBody():void
		{
			this.effectLight.maxFPS = 16;
			this.effectLight.stop();
			this.effectLight.loop = false;
			this.effectLight.y = -10;

			this.movie.visible = false;
			this.movie.loop = false;
			this.movie.stop();
			this.movie.x = -11;
			this.movie.y = -48;
			this.movie.addEventListener(Event.COMPLETE, stopAcornMovie);

			this.fixed = true;
			this.rotator = new Rotator(view, new Point);
			addChildStarling(this.view);
			addChildStarling(this.effectLight);
		}

		static private function createFixtureDef(scale:Number):b2FixtureDef
		{
			var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox(scale * 46 / 2 / Game.PIXELS_TO_METRE, scale * 32 / 2 / Game.PIXELS_TO_METRE, new b2Vec2(scale * 25 / 2 / Game.PIXELS_TO_METRE, scale * 21 / 2 / Game.PIXELS_TO_METRE));
			return new b2FixtureDef(shape, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
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
			this.effectLight.loop = true;
			this.effectLight.play();

			this.body = world.CreateBody(BODY_DEF);
			this.fixture = this.body.CreateFixture(createFixtureDef(this._scale));
			this.sensor = new HeroDetector(this.fixture);
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);

			addChildStarling(this.movie);
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

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push(this._scale);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			if (!(1 in data))
				return;

			this.scale = data[1];
		}

		public function set scale(scale:Number):void
		{
			if (this._scale == scale)
				return;

			this._scale = scale;

			this.scaleX = this.scaleY = scale;

			if (!this.body)
				return;

			if (this.fixture)
				this.body.DestroyFixture(this.fixture);

			this.fixture = this.body.CreateFixture(createFixtureDef(scale));

			if (this.fixture)
				this.sensor.setFixture(this.fixture);
		}

		public function onAcorn(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId && e.hero.id > 0)
				return;
			if (e.hero.hasNut || e.hero.inHollow || e.hero.isDead)
				return;

			dispatchEvent(new SquirrelEvent(SquirrelEvent.ACORN, e.hero));

			e.hero.setMode(Hero.NUT_MOD);

			if (e.showMovie)
			{
				this.movie.gotoAndPlay(0);
				this.movie.visible = true;
			}

			if (!e.hero.isHare)
				GameSounds.play(SoundConstants.ACORN_SOUNDS[0]);
				var index:int = Math.random() * SoundConstants.ACORN_SOUNDS.length;
				GameSounds.play(SoundConstants.ACORN_SOUNDS[index]);
		}

		public function get sideIcon(): StarlingAdapterSprite
		{
			return new SideIconView(SideIconView.COLOR_GREEN, SideIconView.ICON_ACORN);
		}

		public function get showIcon():Boolean
		{
			return this.alpha > 0;
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

		private function stopAcornMovie(e:Event):void
		{
			this.movie.stop();
			this.movie.visible = false;
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			if (this.alpha == 0)
				return;

			onAcorn(e);
		}
	}
}