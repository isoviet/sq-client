package game.mainGame
{
	public interface ISerialize
	{
		function serialize():*;
		function deserialize(data:*):void;
	}
}