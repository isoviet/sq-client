package game.mainGame.perks
{
	public interface ICounted
	{
		function get charge():int;
		function get count():int;
		function resetTimer():void;
	}
}