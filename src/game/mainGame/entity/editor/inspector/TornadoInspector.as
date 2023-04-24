package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class TornadoInspector extends Inspector
	{
		public function TornadoInspector():void
		{
			addWidget(new NumberEditor(gls("Сила {0}", "(power)"), "power", 1, 0));
		}
	}
}