package landing.game.mainGame.entity
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	public interface IGameObject
	{
		function get position():b2Vec2;
		function set position(value:b2Vec2):void;

		function get angle():Number;
		function set angle(value:Number):void;

		function build(world:b2World):void;
	}
}