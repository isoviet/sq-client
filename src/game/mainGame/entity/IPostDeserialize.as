package game.mainGame.entity
{
	import game.mainGame.GameMap;

	public interface IPostDeserialize
	{
		function OnPostDeserialize(map:GameMap):void
	}
}