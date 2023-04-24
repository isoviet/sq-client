package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class TrapInspector extends Inspector
	{
		public function TrapInspector():void
		{
			addWidget(new NumberEditor(gls("Длина верёвки {0}", "(ropeLength)"), "ropeLength", 1, 5));
		}
	}
}