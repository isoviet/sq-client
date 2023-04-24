package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class IRatioInspector extends Inspector
	{
		public function IRatioInspector():void
		{
			addWidget(new NumberEditor(gls("Передаточное число {0}:", "(ratio)"), "ratio"));
		}
	}
}