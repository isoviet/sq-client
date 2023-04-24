package landing.game.mainGame
{
	import Box2D.Dynamics.b2ContactFilter;
	import Box2D.Dynamics.b2Fixture;

	import landing.game.mainGame.entity.simple.GameBody;

	public class ContactFilter extends b2ContactFilter
	{
		override public function ShouldCollide(fixtureA:b2Fixture, fixtureB:b2Fixture):Boolean
		{
			var body0:* = fixtureA.GetBody().GetUserData();
			var body1:* = fixtureB.GetBody().GetUserData();

			if (body0 is GameBody && body1 is GameBody && (body0 as GameBody).fixed && (body1 as GameBody).fixed)
				return false;

			return super.ShouldCollide(fixtureA, fixtureB);
		}
	}

}