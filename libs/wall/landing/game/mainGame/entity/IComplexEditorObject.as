package landing.game.mainGame.entity
{
	import landing.game.mainGame.GameMap;
	import landing.game.mainGame.gameEditor.Selection;

	public interface IComplexEditorObject
	{
		function onAddedToMap(map:GameMap):void
		function onRemovedFromMap(map:GameMap):void
		function onSelect(selection:Selection):void
	}
}