package game.mainGame.entity.editor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.ILags;
	import game.mainGame.entity.IPinable;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.PinUtil;
	import game.mainGame.entity.controllers.PlanetController;
	import game.mainGame.entity.simple.GameBody;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class PlanetBody extends GameBody implements ISizeable, IPinable, ILags
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 3, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		static private const DEFAULT_WIDTH:Number = 228 / Game.PIXELS_TO_METRE;
		static private const DEFAULT_HEIGHT:Number = 229 / Game.PIXELS_TO_METRE;

		static private const MIN_SIZE:Number = 10 / Game.PIXELS_TO_METRE;
		static private const MAX_SIZE:Number = Number.MAX_VALUE;

		static private const PINS:Array = [[0, 0]];

		protected var _size:b2Vec2 = new b2Vec2(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		protected var _gravity:Number = 10;
		protected var _invSqr:Boolean = true;
		protected var view:StarlingAdapterSprite;
		protected var gravitySprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var directionShape:StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var _skin:int = 0;

		protected var _affectHero:Boolean = true;
		protected var _affectObjects:Boolean = true;
		protected var _maxDistance:Number = 150;
		protected var _addExtGrav:Boolean = true;
		protected var _biDirectional:Boolean = false;
		protected var _density:Number = 3;
		protected var _disableGlobalGravity:Boolean;

		protected var controller:PlanetController;
		protected var bitmapData:BitmapData = null;

		protected var skins:Array = null;
		private var defSize: int = 1;
		private var gravitySpriteGraph: Shape = new Shape();
		private var gravitySpriteGraphStarling: StarlingAdapterSprite = new StarlingAdapterSprite();
		private var _collectionEffects: CollectionEffects = CollectionEffects.instance;
		private var _effectGravity: ParticlesEffect;
		private var _effectLayer: StarlingAdapterSprite = new StarlingAdapterSprite();

		public function PlanetBody():void
		{
			_effectLayer.alignPivot();
			this.addChildStarling(this._effectLayer);

			this.gravitySprite.touchable = false;
			addChildStarling(this.gravitySprite);

			this.directionShape.touchable = false;
			addChildStarling(this.directionShape);

			this.view = new StarlingAdapterSprite(new Planet1());

			addChildStarling(this.view);

			drawGravity();
			this.touchable = false;
		}

		override public function set cacheAsBitmap(value:Boolean):void
		{
			this.view.cacheAsBitmap = value;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			var shape:b2CircleShape = new b2CircleShape(this.size.x / 2);
			this.fixture.density = _density;
			this.fixture.shape = shape;
			this.fixture.friction = skin == 2 ? 0.1 : 0.8;
			this.body.SetLinearDamping(1.5);
			this.body.SetAngularDamping(1.5);
			this.body.SetUserData(this);
			this.body.CreateFixture(this.fixture);
			super.build(world);

			if (!this.cacheBitmap)
				rasterize();

			this.controller = new this.controllerClass();
			controller.body = this.body;
			this.controller.invSqr = this._invSqr;
			world.AddController(this.controller);
			gravity = gravity;
			affectObjects = affectObjects;
			affectHero = affectHero;
			maxDistance = maxDistance;
			addExtGrav = addExtGrav;
			disableGlobalGravity = disableGlobalGravity;

			_effectGravity = _collectionEffects.getEffectByName(CollectionEffects.EFFECT_PLANET_GRAVITY);
			if (_effectGravity && _effectLayer)
			{
				_effectGravity.start();
				_effectGravity.view.alignPivot();
				_effectGravity.view.emitterX = 0;
				_effectGravity.view.emitterY = 0;

				this._effectLayer.getStarlingView().addChild(_effectGravity.view);
				drawGravity();
			}

		}

		protected function get controllerClass():Class
		{
			return PlanetController;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([[size.x, size.y], this.gravity, this.invSqr, this.affectObjects, this.affectHero, this.maxDistance, addExtGrav, biDirectional, density, this.disableGlobalGravity, this.skin]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			var index:int = GameBody.isOldStyle(data) ? 3 : 1;
			this.size = new b2Vec2(data[index][0][0], data[index][0][1]);
			this.gravity = data[index][1];
			this.invSqr = Boolean(data[index][2]);
			this.affectObjects = Boolean(data[index][3]);
			this.affectHero = Boolean(data[index][4]);
			this.maxDistance = data[index][5];
			this.addExtGrav = Boolean(data[index][6]);
			this.biDirectional = Boolean(data[index][7]);
			this.density = data[index][8];
			this.disableGlobalGravity = Boolean(data[index][9]);
			this.skin = data[index][10];
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);
		}

		public function get size():b2Vec2
		{
			return _size;
		}

		public function set size(value:b2Vec2):void
		{
			value.x = value.y = Math.max(Math.min(Math.max(value.x, value.y), MAX_SIZE), MIN_SIZE);
			_size = value;
			this.view.scaleXY(this.size.x / DEFAULT_WIDTH);

			drawGravity();

			if (!this.controller)
				return;

			this.controller.maxDistance = _maxDistance / Game.PIXELS_TO_METRE + this.size.x;
		}

		public function get pinPositions():Vector.<b2Vec2>
		{
			return PinUtil.convertToVector(PINS);
		}

		public function get gravity():Number
		{
			return _gravity;
		}

		public function set gravity(value:Number):void
		{
			_gravity = value;

			drawGravity();

			if (!this.controller)
				return;

			this.controller.G = value;
		}

		public function get invSqr():Boolean
		{
			return _invSqr;
		}

		public function set invSqr(value:Boolean):void
		{
			_invSqr = value;

			if (!this.controller)
				return;

			this.controller.invSqr = value;
		}

		public function get affectHero():Boolean
		{
			return _affectHero;
		}

		public function set affectHero(value:Boolean):void
		{
			_affectHero = value;

			if (!this.controller)
				return;

			this.controller.affectHero = value;
		}

		public function get affectObjects():Boolean
		{
			return _affectObjects;
		}

		public function set affectObjects(value:Boolean):void
		{
			_affectObjects = value;

			if (!this.controller)
				return;

			this.controller.affectObjects = value;
		}

		public function get maxDistance():Number
		{
			return _maxDistance;
		}

		public function set maxDistance(value:Number):void
		{
			_maxDistance = value;

			drawGravity();
			if (!this.controller)
				return;

			this.controller.maxDistance = _maxDistance / Game.PIXELS_TO_METRE + this.size.x / 2;
		}

		public function get addExtGrav():Boolean
		{
			return _addExtGrav;
		}

		public function set addExtGrav(value:Boolean):void
		{
			_addExtGrav = value;

			if (!this.controller)
				return;

			this.controller.addExtGrav = value;
		}

		public function get biDirectional():Boolean
		{
			return _biDirectional;
		}

		public function set biDirectional(value:Boolean):void
		{
			_biDirectional = value;

			if (!this.controller)
				return;

			this.controller.biDirectional = value;
		}

		public function get density():Number
		{
			return _density;
		}

		public function set density(value:Number):void
		{
			_density = value;
		}

		public function get disableGlobalGravity():Boolean
		{
			return _disableGlobalGravity;
		}

		public function set disableGlobalGravity(value:Boolean):void
		{
			_disableGlobalGravity = value;

			if (!this.controller)
				return;

			this.controller.disableGlobalGravity = value;
		}

		public function get skin():int
		{
			return _skin;
		}

		public function set skin(value:int):void
		{
			if (this.skins == null)
				this.skins = [Planet1, Planet2, Planet3, Planet4];

			if (value > this.skins.length -1)
				value = this.skins.length -1;
			_skin = value;
			var filters:Array = this.view.filters;

			if (this.view.parentStarling)
				this.removeChildStarling(view);
			this.view = new StarlingAdapterSprite(new this.skins[value]());
			this.view.filters = filters;
			addChildStarling(this.view);
			this.size = this.size;
		}

		override public function dispose():void
		{
			if (_effectGravity)
			{
				this._effectGravity.stop();
				this._effectGravity.removeFromParent(true);
			}

			if (this._effectLayer)
			{
				this._effectLayer.getStarlingView().removeFromParent(true);
				this._effectLayer.removeFromParent(true);
			}

			this.gravitySprite.removeFromParent();
			this.directionShape.removeFromParent();
			this.view.removeFromParent();
			this._effectGravity = null;

			super.dispose();

			if (this.bitmapData != null)
			{
				this.bitmapData.dispose();
				this.bitmapData = null;
			}

			if (!this.controller || !this.controller.GetWorld())
				return;

			this.controller.body = null;
			this.controller.GetWorld().RemoveController(this.controller);
		}

		public function estimateLags():Number
		{
			return 0.5 * int(this.affectObjects);
		}

		protected function get fixture():b2FixtureDef
		{
			return FIXTURE_DEF;
		}

		private function rasterize():void
		{
			var rotation:Number = this.rotation;
			this.rotation = 0;

			var ghost:Boolean = this.ghost;
			this.ghost = false;

			var bounds:Rectangle = this.getBounds(this);
			this.bitmapData = new BitmapData(this.width, this.height, true, 0x00FFFFFF);

			var s:Sprite = new Sprite();
			s.addChild(this.view);
			this.bitmapData.draw(s, new Matrix(1, 0, 0, 1, this.width / 2, this.height / 2));

			var bitmap:Bitmap = new Bitmap(this.bitmapData);
			bitmap.x = bounds.x;
			bitmap.y = bounds.y;
			bitmap.smoothing = true;

			addChildStarling(new StarlingAdapterSprite(bitmap));
			this.rotation = rotation;
			this.ghost = ghost;
		}

		private function drawGravity():void
		{
			if (gravitySpriteGraph.scaleX != _maxDistance + this.size.x * Game.PIXELS_TO_METRE / 2)
			{
				while (this.gravitySprite.numChildren > 0)
					this.gravitySprite.removeChildStarlingAt(0);

				var color:int = 0xDBFAFF;
				var m: Matrix = new Matrix();
				m.createGradientBox(2, 2, 0, -1, -1);

				gravitySpriteGraph.graphics.clear();
				gravitySpriteGraph.graphics.beginGradientFill(GradientType.RADIAL, [color, color, color, color], [0, 0.1, 0.5, 0], [0, 222, 250, 255], m, SpreadMethod.PAD, InterpolationMethod.RGB, 0);

				gravitySpriteGraph.graphics.drawCircle(0, 0, 1);
				gravitySpriteGraph.graphics.endFill();
				gravitySpriteGraph.scaleX = gravitySpriteGraph.scaleY = _maxDistance + this.size.x * Game.PIXELS_TO_METRE / 2;

				gravitySpriteGraphStarling.removeFromParent();
				gravitySpriteGraphStarling = new StarlingAdapterSprite(gravitySpriteGraph);
				this.gravitySprite.addChildStarling(gravitySpriteGraphStarling);
			}
			if (this._effectGravity)
			{
				if (_effectGravity.view.maxRadius != _maxDistance + this.size.x * Game.PIXELS_TO_METRE / 2 ||
					_effectGravity.view.rotatePerSecond != Math.abs(Math.min(180, _density + _gravity) / 180 * Math.PI))
				{
					_effectGravity.view.maxRadius = _maxDistance + this.size.x * Game.PIXELS_TO_METRE / 2;
					_effectGravity.view.rotatePerSecond = Math.abs(Math.min(180, _density + _gravity) / 180 * Math.PI);
				}
			}

		}
	}
}