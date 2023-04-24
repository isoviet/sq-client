package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import game.mainGame.entity.editor.inspector.widgets.TextEditor;

	public class DisplayObjectInspector extends Inspector
	{
		public function DisplayObjectInspector():void
		{
			addWidget(new TextEditor(gls("Имя {0}", "(name)"), "name", 100, 20, false));
			if (Game.editor_access)
				addWidget(new NumberEditor(gls("Непрозрачность в % {0}", "(alpha)"), "alpha", 100));
		}
	}
}