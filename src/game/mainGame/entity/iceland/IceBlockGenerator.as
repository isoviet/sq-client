package game.mainGame.entity.iceland
{
	import flash.display.MovieClip;

	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CastItem;
	import game.mainGame.CollisionGroup;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.simple.GameBody;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import utils.starling.StarlingAdapterSprite;

	public class IceBlockGenerator extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.HERO_DETECTOR_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const SHAPE:b2CircleShape = new b2CircleShape(35 / Game.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 1, CATEGORIES_BITS, MASK_BITS, 0, false);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var sensor:HeroDetector;
		private var view:StarlingAdapterSprite;

		public function IceBlockGenerator():void
		{
			this.view = new StarlingAdapterSprite(new MovieClip());////new SnowBlockRespawnView());
			this.view.y += 40;
			addChildStarling(this.view);

			this.fixed = true;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);
			super.build(world);

			this.gameInst = world.userData as SquirrelGame;
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.sensor == null)
				return;

			this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);
			this.sensor = null;
		}

		override protected function get categoriesBits():uint
		{
			return CATEGORIES_BITS;
		}

		protected function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId && e.hero.id > 0)
				return;

			if (e.hero.isDead || e.hero.shaman)
				return;

			var item:CastItem = e.hero.castItems.getItem(IceBlock, CastItem.TYPE_SQUIRREL);
			if ((item != null) && (item.count >= 0))
				return;
			e.hero.castItems.add(new CastItem(IceBlock, CastItem.TYPE_SQUIRREL, 1));
		}
	}
}