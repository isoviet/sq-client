package game.mainGame.entity.editor
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.Perk;
	import game.mainGame.perks.PerkController;
	import sensors.HeroDetector;
	import sensors.events.DetectHeroEvent;

	import utils.starling.StarlingAdapterMovie;

	public class MagicFlow extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		static private const SHAPE1:b2CircleShape = new b2CircleShape(15 / Game.PIXELS_TO_METRE);
		static private const SHAPE2:b2PolygonShape = b2PolygonShape.AsBox(40 / Game.PIXELS_TO_METRE, 8 / Game.PIXELS_TO_METRE);

		static private const FIXTURE_DEF1:b2FixtureDef = new b2FixtureDef(SHAPE1, null, 0.8, 0.1, 2, CollisionGroup.HERO_DETECTOR_CATEGORY, CollisionGroup.HERO_CATEGORY, 0, true);
		static private const FIXTURE_DEF2:b2FixtureDef = new b2FixtureDef(SHAPE2, null, 0.8, 0.1, 3, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		private var view:StarlingAdapterMovie = null;
		private var sensor:HeroDetector = null;

		public function MagicFlow():void
		{
			this.view = new StarlingAdapterMovie(new MagicFlowImg);
			this.view.stop();
			addChildStarling(this.view);

			this.fixed = true;
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF2);

			this.sensor = new HeroDetector(this.body.CreateFixture(FIXTURE_DEF1));
			this.sensor.addEventListener(DetectHeroEvent.DETECTED, onHeroDetected, false, 0, true);

			super.build(world);
			this.view.play();
		}

		override public function dispose():void
		{
			if (this.view)
				this.view.removeFromParent();

			this.view = null;

			if (this.sensor)
				this.sensor.removeEventListener(DetectHeroEvent.DETECTED, onHeroDetected);

			this.sensor = null;

			super.dispose();
		}

		private function onHeroDetected(e:DetectHeroEvent):void
		{
			var hero:Hero = e.hero;

			if (hero.inHollow || hero.isDead || hero.isHare || hero.isDragon)
				return;

			if (e.state != DetectHeroEvent.BEGIN_CONTACT)
				return;

			var controller:PerkController = hero.perkController;
			for (var i:int = controller.perksClothes.length - 1; i >= 0; i--)
				(controller.perksClothes[i] as Perk).currentCooldown = 0;

			for (i = controller.perksCharacter.length - 1; i >= 0; i--)
				(controller.perksClothes[i] as Perk).currentCooldown = 0;
		}
	}
}