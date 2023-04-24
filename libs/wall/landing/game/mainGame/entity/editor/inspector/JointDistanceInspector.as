package landing.game.mainGame.entity.editor.inspector
{
	import landing.game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class JointDistanceInspector extends Inspector
	{
		public function JointDistanceInspector():void
		{
			addWidget(new NumberEditor("Частота", "frequency"));
			addWidget(new NumberEditor("Демпинг", "damping"));
		}
	}
}