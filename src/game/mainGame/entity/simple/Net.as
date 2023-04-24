package game.mainGame.entity.simple
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IDragable;
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.controllers.ClimbController;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;

	import starling.display.Sprite;

	import utils.starling.StarlingAdapterSprite;
	import utils.starling.utils.StarlingConverter;

	public class Net extends GameBody implements ISizeable, IDragable
	{
		static private const MIN_WIDTH:int = 20;
		static private const MIN_HEIGHT:int = 20;

		static private const BLOCK_WIDTH:int = 53;
		static private const BLOCK_HEIGHT:int = 56;

		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.2, 0, 0.1, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_staticBody);

		private var icon:StarlingAdapterSprite = null;
		private var mcIcon: flash.display.Sprite = new NetIcon();
		private var beginPoint:Point;
		private var scale:Number;

		private var _width:Number;
		private var _height:Number;

		private var isFixed:Boolean = false;

		private var sensor:HeroDetector = null;
		private var controller:ClimbController = null;

		private var squirrels:Array = [];
		private var image:MovieClip;

		public function Net():void
		{
			this.icon = new StarlingAdapterSprite(this.mcIcon);
			this.image = new NetIcon();

			addChildStarling(this.icon);
			this.fixed = true;
		}

		override public function set rotation(value:Number):void
		{
			if (value) {/*unused*/}
			super.rotation = 0;
		}

		override public function set angle(value:Number):void
		{}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			FIXTURE_DEF.shape = b2PolygonShape.AsOrientedBox((this._width / 2) / Game.PIXELS_TO_METRE, (this._height / 2) / Game.PIXELS_TO_METRE, new b2Vec2((this._width / 2) / Game.PIXELS_TO_METRE, (this._height / 2) / Game.PIXELS_TO_METRE));

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			super.build(world);

			this.controller = new ClimbController();
			this.controller.squirrelsArray = this.squirrels;
			world.AddController(this.controller);
		}

		override public function dispose():void
		{
			this.mcIcon = null;
			this.image = null;
			if (this.controller)
			{
				this.controller.squirrelsArray = null;
				this.controller.GetWorld().RemoveController(this.controller);
				this.controller = null;
			}

			super.dispose();

			this.removeFromParent();

			for each (var hero:Hero in this.squirrels)
			{
				if (!hero || !hero.isExist)
					continue;

				releaseSquirrel(hero);
			}
			this.squirrels = null;

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this._width, this._height, true]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			if ((data[1] as Array).length == 2)
			{
				data[1][0] *= (64 / 60);
				data[1][1] *= (64 / 60);
			}
			resize(data[1][0], data[1][1]);

			draw();
		}

		public function init(scale:Number):void
		{
			this.scale = scale;
			Game.stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		public function get size():b2Vec2
		{
			return new b2Vec2(_width / 5, _height / 5);
		}

		public function set size(value:b2Vec2):void
		{
			value.x = value.x - value.x % (BLOCK_WIDTH / Game.PIXELS_TO_METRE);
			value.y = value.y - value.y % (BLOCK_HEIGHT / Game.PIXELS_TO_METRE);

			resize(value.x * 5, value.y * 5);
		}

		private function resize(width:int, height:int):void
		{
			width = Math.max(MIN_WIDTH, width);
			height = Math.max(MIN_HEIGHT, height);

			this._width = width;
			this._height = height;

			draw();
		}

		private function draw():void
		{
			this._width -= _width % BLOCK_WIDTH;
			this._height -= _height % BLOCK_HEIGHT;
			this._width = Math.max(_width, BLOCK_WIDTH);
			this._height = Math.max(_height, BLOCK_HEIGHT);

			if (containsStarling(this.icon))
				removeChildStarling(this.icon);

			while (numChildren > 0)
				removeChildStarlingAt(0);

			var img: starling.display.Sprite = StarlingConverter.imageWithTextureFill(image,
				this._width, this._height
			);
			addChildStarling(img);
		}

		private function onClick(e:MouseEvent):void
		{
			if (this.isFixed)
			{
				Game.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				Game.stage.removeEventListener(MouseEvent.CLICK, onClick);
				return;
			}

			this.isFixed = true;

			Game.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.beginPoint = new Point(e.stageX, e.stageY);
			resize(MIN_WIDTH, MIN_HEIGHT);

			if (containsStarling(this.icon))
				removeChildStarling(this.icon);
		}

		private function onMove(e:MouseEvent):void
		{
			resize((e.stageX - this.beginPoint.x) / this.scale, (e.stageY - this.beginPoint.y) / this.scale);
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			var hero:Hero = e.hero;

			if (hero.inHollow)
				return;

			if(hero.ghost)
				return;

			var index:int = this.squirrels.indexOf(hero);

			if (e.state == DetectHeroEvent.BEGIN_CONTACT && index == -1)
			{
				this.squirrels.push(hero);
				hero.climbing = true;
				hero.addEventListener(SquirrelEvent.RESET, onEvent);
				hero.addEventListener(SquirrelEvent.DIE, onEvent);
				hero.addEventListener(SquirrelEvent.GHOST, onEvent);
				hero.addEventListener(HollowEvent.HOLLOW, onEvent);
				if(hero.id == Game.selfId)
					GameSounds.play('stairs');
			}
			else if (e.state == DetectHeroEvent.END_CONTACT)
			{
				releaseSquirrel(hero);
				if (index != -1)
					this.squirrels.splice(index, 1);
			}
		}

		private function onEvent(e:Event):void
		{
			releaseSquirrel(e['player']);
			var index:int = this.squirrels.indexOf(e['player']);
			if (index != -1)
					this.squirrels.splice(index, 1);
		}

		private function releaseSquirrel(hero:Hero):void
		{
			hero.climbing = false;
			hero.removeEventListener(SquirrelEvent.RESET, onEvent);
			hero.removeEventListener(SquirrelEvent.DIE, onEvent);
			hero.removeEventListener(SquirrelEvent.GHOST, onEvent);
			hero.removeEventListener(HollowEvent.HOLLOW, onEvent);
		}
	}
}