package game.mainGame.entity.cast
{
	import game.mainGame.Cast;

	public interface ICastChange
	{
		function set cast(cast:Cast):void;
		function setCastParams():void;
		function resetCastParams():void;
	}
}