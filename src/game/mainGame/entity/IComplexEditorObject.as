package game.mainGame.entity
{
	import game.mainGame.GameMap;
	import game.mainGame.gameEditor.Selection;

	public interface IComplexEditorObject
	{
		function onAddedToMap(map:GameMap):void
		function onRemovedFromMap(map:GameMap):void
		function onSelect(selection:Selection):void
	}
}