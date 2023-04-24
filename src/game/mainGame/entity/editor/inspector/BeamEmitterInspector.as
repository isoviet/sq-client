package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class BeamEmitterInspector extends Inspector
	{
		public function BeamEmitterInspector():void
		{
			addWidget(new NumberEditor(gls("Время работы {0}", "(workTime)"), "workTime", 0.001, 1000));
			addWidget(new NumberEditor(gls("Время мерцания {0}", "(blinkTime)"), "blinkTime", 0.001, 0));
		}
	}
}