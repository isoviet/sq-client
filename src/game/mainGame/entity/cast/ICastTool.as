package game.mainGame.entity.cast
{
	import game.mainGame.SquirrelGame;

	public interface ICastTool
	{
		function set game(value:SquirrelGame):void;
		function onCastStart():void;
		function onCastCancel():void;
		function onCastComplete():void;
	}
}