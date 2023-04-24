package game.mainGame.entity.simple
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.Cast;
	import game.mainGame.CollisionGroup;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.cast.ICastChange;
	import sensors.PortalSensor;

	import utils.starling.IStarlingAdapter;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class Portal extends GameBody implements ICastChange
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(20 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_staticBody);

		private var view:StarlingAdapterMovie;
		private var arrow:StarlingAdapterSprite;
		private var feather: StarlingAdapterSprite;

		private var _useDirection:Boolean = false;

		public var sensor:PortalSensor;
		public var game:SquirrelGame;

		private var _cast:Cast = null;
		private var oldCastRadius:Number;

		public function Portal(view: DisplayObjectContainer , arrow: DisplayObjectContainer = null, feather: DisplayObjectContainer = null):void
		{
			this.view = new StarlingAdapterMovie(view, false);
			this.view.loop = true;
			this.view.play();
			addChildStarling(this.view);

			this.arrow = new StarlingAdapterSprite(arrow);
			this.view.addChildStarling(this.arrow);

			this.useDirection = false;

			this.feather = new StarlingAdapterSprite(feather);
			this.view.addChildStarling(this.feather);

			if (view)
			{
				view.x = view.width / 2;
				view.y = view.height / 2;
				view.mouseEnabled = false;
				addChild(view);
			}

			if (arrow)
			{
				arrow.x = arrow.width / 2;
				arrow.y = arrow.height / 2;
				addChild(arrow);
			}

			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(e: Event): void
		{
			if (this.parentStarling != null || this.parent is IStarlingAdapter)
			{
				removeFlashView();
				this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}

		override public function get angle():Number
		{
			return super.angle;
		}

		override public function set angle(value:Number):void
		{
			super.angle = value;
			useDirection = useDirection;
		}

		override public function get rotation():Number
		{
			return super.rotation;
		}

		override public function set rotation(value:Number):void
		{
			this.view.rotation = -value;
			this.arrow.rotation = value;
			super.rotation = value;
			useDirection = useDirection;
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
			removeFlashView();
			this.game = world.userData;
			this.body = world.CreateBody(BODY_DEF);
			sensor = new PortalSensor(this.body.CreateFixture(FIXTURE_DEF));
			useDirection = useDirection;
			super.build(world);
			this.view.loop = true;
			this.view.play();
		}

		override public function dispose():void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			super.dispose();
			sensor = null;
		}

		public function get useDirection():Boolean
		{
			return this._useDirection;
		}

		private function removeFlashView(): void
		{
			while (this.numberOfChildSprite() > 0)
				this.removeChildAt(0);
		}

		public function set useDirection(value:Boolean):void
		{
			this._useDirection = value;
			this.arrow.visible = value;

			if (!this.sensor)
				return;

			this.sensor.direction = this.angle;
			this.sensor.useDirection = value;
		}

		public function set cast(cast:Cast):void
		{
			this._cast = cast;
		}

		public function setCastParams():void
		{
			this.oldCastRadius = this._cast.castRadius;
			this._cast.castRadius = Cast.CIRCLE_WIDTH / 2;
		}

		public function resetCastParams():void
		{
			if (!this._cast)
				return;

			this._cast.castRadius = this.oldCastRadius;
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORIES_BITS;
		}
	}
}