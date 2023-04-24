package landing.controllers
{
	import Box2D.Common.Math.b2Vec2;

	public interface IHero
	{
		function wakeUp():void;
		function moveLeft(start:Boolean):void;
		function moveRight(start:Boolean):void;
		function jump(start:Boolean):void;

		function get position():b2Vec2;
		function set position(value:b2Vec2):void;
		function get velocity():b2Vec2;
		function set velocity(value:b2Vec2):void;

		function setController(value:ControllerHero):void;
		function sendLocation(keyCode:int = 0):void;
	}
}