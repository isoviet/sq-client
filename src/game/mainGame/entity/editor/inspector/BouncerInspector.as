package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class BouncerInspector extends Inspector
	{
		public function BouncerInspector():void
		{
			addWidget(new NumberEditor(gls("Сила {0}", "(bouncingFactor)"), "bouncingFactor", 1, 0));
		}
	}
}