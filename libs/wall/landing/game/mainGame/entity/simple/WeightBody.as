﻿package landing.game.mainGame.entity.simple
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;

	public class WeightBody extends GameBody
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY ;

		static private const SHAPE:b2CircleShape = new b2CircleShape(15 / WallShadow.PIXELS_TO_METRE);
		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(SHAPE, null, 0.8, 0.1, 15, CATEGORIES_BITS, MASK_BITS, 0);
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(false, false, b2Body.b2_dynamicBody);

		public function WeightBody():void
		{
			addChild(new Weight);
		}

		override public function build(world:b2World):void
		{
			SHAPE.SetLocalPosition(new b2Vec2(0, 0));
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetLinearDamping(1.1);
			this.body.SetAngularDamping(1.1);
			this.body.SetUserData(this);
			this.body.CreateFixture(FIXTURE_DEF);

			SHAPE.SetLocalPosition(new b2Vec2(0, -18 / WallShadow.PIXELS_TO_METRE));
			this.body.CreateFixture(FIXTURE_DEF);

			super.build(world);
		}
	}
}