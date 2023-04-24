package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class QuicksandInspector extends Inspector
	{
		public function QuicksandInspector():void
		{
			addWidget(new NumberEditor(gls("Вязкость {0}", "(viscosity)"), "viscosity", 1, 0.1));
		}
	}
}