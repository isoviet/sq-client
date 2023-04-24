package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.VectorEditor;

	public class ISizeableInspector extends Inspector
	{
		public function ISizeableInspector():void
		{
			addWidget(new VectorEditor(gls("Размер {0}", "(size)"), "size", Game.PIXELS_TO_METRE, 0.1));
		}
	}
}