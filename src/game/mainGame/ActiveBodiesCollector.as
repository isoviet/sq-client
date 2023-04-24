package game.mainGame
{
	import Box2D.Dynamics.b2Body;

	public class ActiveBodiesCollector
	{
		static public var bodies:Array = [];

		static public function addBody(body:b2Body):void
		{
			if (bodies.indexOf(body) != -1)
				return;

			bodies.push(body);
		}

		static public function removeBody(body:b2Body):void
		{
			var index:int = bodies.indexOf(body);
			if (index == -1)
				return;

			bodies.splice(index, 1);
		}

		static public function clear():void
		{
			bodies.splice(0);
		}
	}
}