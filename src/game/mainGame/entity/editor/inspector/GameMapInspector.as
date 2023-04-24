package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.VectorEditor;

	public class GameMapInspector extends Inspector
	{
		public function GameMapInspector():void
		{
			addWidget(new VectorEditor(gls("Размер {0}", "(size)"), "size", 1));
			addWidget(new VectorEditor(gls("Гравитация {0}", "(gravity)"), "gravity", 1));
		}
	}
}