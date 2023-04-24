package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class ConveyorInspector extends Inspector
	{
		public function ConveyorInspector()
		{
			addWidget(new NumberEditor(gls("Скорость {0}", "(velocity)"), "velocity"));
			addWidget(new NumberEditor(gls("Время работы {0}", "(workTime)"), "workTime", 0.001, 1000));
			addWidget(new NumberEditor(gls("Время паузы {0}", "(delayTime)"), "delayTime", 0.001, 0));
		}
	}
}