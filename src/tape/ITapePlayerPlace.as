package tape
{
	import com.api.Player;

	public interface ITapePlayerPlace
	{
		function setPlayer(player:Player):void;
		function setPhoto(player:Player):void;
		function isPlayerChanged(player:Player):Boolean;
	}
}