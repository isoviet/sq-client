package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.TextEditor;

	public class HelperInspector extends Inspector
	{
		public function HelperInspector():void
		{
			addWidget(new TextEditor(gls("Подсказка {0}", "(message)"), "message", 200, 200));
		}
	}
}