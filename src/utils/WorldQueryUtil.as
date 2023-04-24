package utils
{
	import flash.geom.Point;

	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.IGameObject;

	public class WorldQueryUtil
	{
		static private var queryBodyResult:Array;
		static private var queryClass:Class;

		static public function p2v(point:Point):b2Vec2
		{
			return new b2Vec2(point.x, point.y);
		}

		static public function GetWorldPoint(object:IGameObject, location:b2Vec2):b2Vec2
		{
			var mXf:b2Transform = new b2Transform();
			mXf.R.Set(object.angle);
			mXf.position.SetV(object.position);

			return b2Math.MulX(mXf, location);
		}

		static public function findBodiesAtPoint(world:b2World, position:b2Vec2, queryClass:Class):Array
		{
			if (!world || !position || !queryClass)
			{
				Logger.add('Error: findBodiesAtPoint:', world, position, queryClass);
				return [];
			}

			WorldQueryUtil.queryBodyResult = [];
			WorldQueryUtil.queryClass = queryClass;

			world.QueryPoint(queryToBody, position);

			var result:Array = WorldQueryUtil.queryBodyResult;

			WorldQueryUtil.queryBodyResult = null;
			WorldQueryUtil.queryClass = null;

			return result;
		}

		static public function findBodiesOverABB(world:b2World, area:b2AABB):Array
		{
			var result:Array = [];

			for (var body:b2Body = world.GetBodyList(); body != null; body = body.GetNext())
			{
				for (var fixture:b2Fixture = body.GetFixtureList(); fixture != null; fixture = fixture.GetNext())
				{
					if (fixture.GetAABB().Contains(area) || fixture.GetAABB().TestOverlap(area))
						result.push(body);
				}
			}
			return result;
		}

		static public function findEmptyAreas(world:b2World, areas:Array, count:int):Array
		{
			var result:Array = [];
			var index:int;
			var area:b2AABB = null;
			var fixtureArea:b2AABB = null;
			var badArea:Boolean = false;

			while (areas.length)
			{
				index = Math.random() * areas.length;
				area = areas[index];

				badArea = false;

				for (var body:b2Body = world.GetBodyList(); body != null; body = body.GetNext())
				{
					for (var fixture:b2Fixture = body.GetFixtureList(); fixture != null; fixture = fixture.GetNext())
					{
						fixtureArea = fixture.GetAABB();
						if (fixtureArea.Contains(area) || fixtureArea.TestOverlap(area))
						{
							areas.splice(index, 1);
							badArea = true;
							break;
						}
					}
					if (badArea)
						break;
				}

				if (badArea)
					continue;

				result.push(area.upperBound);
				areas.splice(index, 1);
				if (result.length == count)
					return result;
			}
			return result;
		}

		static private function queryToBody(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is WorldQueryUtil.queryClass)
				queryBodyResult.push(queryBody);

			return true;
		}
	}
}