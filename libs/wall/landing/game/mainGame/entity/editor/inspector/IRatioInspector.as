package landing.game.mainGame.entity.editor.inspector
{
	import landing.game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class IRatioInspector extends Inspector
	{
		public function IRatioInspector():void
		{
			addWidget(new NumberEditor("Передаточное число:", "ratio"));
		}
	}
}