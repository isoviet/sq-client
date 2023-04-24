package landing.game.mainGame.entity
{
	import Box2D.Common.Math.b2Vec2;

	public class PinUtil
	{
		static public function convertToVector(array:Array):Vector.<b2Vec2>
		{
			var result:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var vec:Array in array)
				result.push(new b2Vec2(vec[0], vec[1]));
			return result;
		}
	}
}