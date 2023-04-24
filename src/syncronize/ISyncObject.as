package syncronize
{
	import Box2D.Common.Math.b2Vec2;

	public interface ISyncObject
	{
		function get id():int;
		function set id(value:int):void;

		function get position():b2Vec2;
		function set position(value:b2Vec2):void;

		function get angle():Number;
		function set angle(value:Number):void;

		function get linearVelocity():b2Vec2;
		function set linearVelocity(value:b2Vec2):void;

		function get angularVelocity():Number;
		function set angularVelocity(value:Number):void;

		function get personalId():int;

		function dispose():void;
	}
}