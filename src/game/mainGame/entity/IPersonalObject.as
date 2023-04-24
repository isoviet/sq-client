package game.mainGame.entity
{
	public interface IPersonalObject
	{
		function get personalId():int
		function breakContact(playerId:int):Boolean
	}
}