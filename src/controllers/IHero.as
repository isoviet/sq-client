package controllers
{
	import Box2D.Common.Math.b2Vec2;

	public interface IHero
	{
		function wakeUp():void;
		function moveLeft(start:Boolean):void;
		function moveRight(start:Boolean):void;
		function jump(start:Boolean):void;

		function interpolate(value:b2Vec2):void;

		function get position():b2Vec2;
		function set position(value:b2Vec2):void;
		function get velocity():b2Vec2;
		function set velocity(value:b2Vec2):void;
		function get shaman():Boolean;

		function setController(value:ControllerHero):void;
		function sendLocation(keyCode:int = 0):void;

		function setEmotion(type:int):void;

		function set sendMove(value:Boolean):void
		function get sendMove():Boolean
	}
}