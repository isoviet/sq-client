package game.mainGame.entity
{
	public interface ILifeTime
	{
		function get aging():Boolean;
		function set aging(value:Boolean):void;

		function get lifeTime():Number;
		function set lifeTime(value:Number):void;
	}
}