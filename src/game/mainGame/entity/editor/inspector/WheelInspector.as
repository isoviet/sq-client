package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class WheelInspector extends Inspector
	{
		public function WheelInspector():void
		{
			addWidget(new NumberEditor(gls("Плотность {0}", "(density)"), "density", 1, 1));
		}
	}
}