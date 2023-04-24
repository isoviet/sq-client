package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class JointDistanceInspector extends Inspector
	{
		public function JointDistanceInspector():void
		{
			addWidget(new NumberEditor(gls("Частота {0}", "(frequency)"), "frequency"));
			addWidget(new NumberEditor(gls("Демпинг {0}", "(damping)"), "damping"));
		}
	}
}