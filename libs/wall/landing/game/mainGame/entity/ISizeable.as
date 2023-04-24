package landing.game.mainGame.entity
{
	import Box2D.Common.Math.b2Vec2;

	public interface ISizeable
	{
		function get size():b2Vec2;
		function set size(value:b2Vec2):void;
	}
}