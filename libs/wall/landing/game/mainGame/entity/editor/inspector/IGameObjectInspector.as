package landing.game.mainGame.entity.editor.inspector
{
	import landing.game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import landing.game.mainGame.entity.editor.inspector.widgets.VectorEditor;

	public class IGameObjectInspector extends Inspector
	{
		public function IGameObjectInspector():void
		{
			addWidget(new VectorEditor("Позиция:", "position", WallShadow.PIXELS_TO_METRE));
			addWidget(new NumberEditor("Угол:", "angle", 180 / Math.PI));
		}
	}
}