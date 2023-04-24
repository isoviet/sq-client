package landing.game.mainGame.entity.editor
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.CollisionGroup;

	public class Island extends Covered
	{
		static private const BODY_DEF:b2BodyDef = new b2BodyDef(true, false, b2Body.b2_dynamicBody);

		static protected const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static protected const MASK_BITS:uint = CollisionGroup.OBJECT_CATEGORY | CollisionGroup.OBJECT_GHOST_CATEGORY | CollisionGroup.HERO_CATEGORY;

		private var fixuterDef:b2FixtureDef;
		private var shape:b2PolygonShape;
		private var width2:int;
		private var height2:int;

		public function Island(width:int, height:int, imageClass:Class, fixuterDef:b2FixtureDef, shape:b2PolygonShape):void
		{
			this.width2 = width;
			this.height2 = height;
			this.fixuterDef = fixuterDef;
			this.shape = shape;

			var view:DisplayObject = new imageClass() as DisplayObject;
			view.x = -this.width2;
			view.y = -this.height2;
			addChild(view);
			this.fixed = true;
		}

		override protected function getShiftPoint():Point
		{
			return new Point(-this.width2, -this.height2);
		}

		override public function build(world:b2World):void
		{
			this.body = world.CreateBody(BODY_DEF);
			this.body.SetUserData(this);
			this.body.CreateFixture(this.fixuterDef);
			super.build(world);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();
			result.push([this.coverId]);
			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			if (3 in data)
			{
				this.coverId = data[3];
				drawCover(this.width2 * 2);
			}
		}
	}
}