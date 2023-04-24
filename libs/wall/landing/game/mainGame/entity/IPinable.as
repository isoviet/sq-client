package landing.game.mainGame.entity
{
	import Box2D.Common.Math.b2Vec2;

	public interface IPinable
	{
		function get pinPositions():Vector.<b2Vec2>
	}
}