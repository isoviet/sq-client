package game.mainGame.entity
{
	import flash.geom.Point;

	import utils.starling.StarlingAdapterSprite;

	public interface IShoot
	{
		function get maxVelocity():Number;
		function get aimCursor(): StarlingAdapterSprite;
		function onAim(point:Point):void;
	}
}