package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import game.mainGame.entity.editor.inspector.widgets.VectorEditor;

	public class IGameObjectInspector extends Inspector
	{
		public function IGameObjectInspector():void
		{
			addWidget(new VectorEditor(gls("Позиция {0}:", "(position)"), "position", Game.PIXELS_TO_METRE));
			addWidget(new NumberEditor(gls("Угол {0}:", "(angle)"), "angle", Game.R2D));
		}
	}
}