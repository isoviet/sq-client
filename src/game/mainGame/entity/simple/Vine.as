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
	import game.mainGame.entity.ISizeable;
	import game.mainGame.entity.controllers.ClimbController;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;

	import starling.display.Sprite;

	import utils.starling.utils.StarlingConverter;

	public class Vine extends GameBody implements ISizeable
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.2, 0, 0.1, CATEGORIES_BITS, MASK_BITS, 0, true);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_staticBody);

		static private const MIN_LENGTH:int = 64;

		private var _size:b2Vec2 = new b2Vec2();

		private var sensor:HeroDetector = null;
		private var controller:ClimbController = null;

		private var squirrels:Array = [];
		private var image: VineSegment;

		public function Vine():void
		{
			image = new VineSegment();
			this.size = new b2Vec2(0, 2 * image.height / Game.PIXELS_TO_METRE);
		}

		override public function set rotation(value:Number):void
		{
			super.rotation = 0;
		}

		override public function set angle(value:Number):void
		{}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.size.x, this.size.y]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.size = new b2Vec2(data[1][0], data[1][1]);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			FIXTURE_DEF.shape = b2PolygonShape.AsOrientedBox(this._size.x / 2, this._size.y / 2, new b2Vec2(this._size.x / 2, this._size.y / 2));
			this.body.SetUserData(this);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			super.build(world);

			this.controller = new ClimbController();
			this.controller.squirrelsArray = this.squirrels;
			world.AddController(this.controller);
		}

		override public function dispose():void
		{
			if (this.controller)
			{
				this.controller.squirrelsArray = null;
				this.controller.GetWorld().RemoveController(this.controller);
				this.controller = null;
			}
			this.image = null;
			while(numChildren > 0)
				removeChildStarlingAt(0);

			super.dispose();

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

		public function set size(value:b2Vec2):void
		{
			value.y = (value.y / 2 * Game.PIXELS_TO_METRE);

			value.y = Math.ceil(value.y  / image.height) * image.height;
			this._size.y = Math.max(value.y, MIN_LENGTH);
			this._size.y /= Game.PIXELS_TO_METRE;
			this._size.x = image.width / Game.PIXELS_TO_METRE;

			draw();
		}

		public function get size():b2Vec2
		{
			return new b2Vec2(this._size.x, this._size.y * 2);
		}

		private function draw():void
		{
			try
			{
				while(numChildren > 0)
					removeChildStarlingAt(0);

				var img: starling.display.Sprite = StarlingConverter.imageWithTextureFill(image,
					this._size.x * Game.PIXELS_TO_METRE, this._size.y * Game.PIXELS_TO_METRE
				);

				addChildStarling(img);
			}
			catch (e:Error)
			{}
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

				if (hero.id == Game.selfId)
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