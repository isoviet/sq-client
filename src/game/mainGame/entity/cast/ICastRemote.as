package game.mainGame.entity.cast
{
	import flash.geom.Point;

	public interface ICastRemote
	{
		function resolve(globalPos:Point):Boolean;
		function get playerId():int;
	}
}