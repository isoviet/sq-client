package utils
{
	import Box2D.Collision.b2WorldManifold;
	import flash.geom.Point;

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
		static private var fraction:Number;

		static public function p2v(point:Point):b2Vec2
		{
			return new b2Vec2(point.x, point.y);
		}

		static public function GetWorldPoint(object:IGameObject, location:b2Vec2):b2Vec2
		{
			var m_xf:b2Transform = new b2Transform();
			m_xf.R.Set(object.angle);
			m_xf.position.SetV(object.position);

			return b2Math.MulX(m_xf, location);
		}

		static public function findBodiesAtPoint(world:b2World, position:b2Vec2, queryClass:Class):Array
		{
			WorldQueryUtil.queryBodyResult = new Array();
			WorldQueryUtil.queryClass = queryClass;

			world.QueryPoint(queryToBody, position);

			return WorldQueryUtil.queryBodyResult;
			WorldQueryUtil.queryBodyResult = null;
			WorldQueryUtil.queryClass = null;
		}

		static public function rayCast(point0:b2Vec2, point1:b2Vec2, world:b2World):Number
		{
			world.RayCast(rayCastCallBack, point0, point1);
			return fraction;
		}

		static private function queryToBody(fixture:b2Fixture):Boolean
		{
			var queryBody:b2Body = fixture.GetBody();
			if (queryBody.GetUserData() is WorldQueryUtil.queryClass)
				queryBodyResult.push(queryBody);
			return true;
		}

		static private function rayCastCallBack(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number
		{
			WorldQueryUtil.fraction = fraction;
			return fraction;
		}
	}
}