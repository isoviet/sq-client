package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import game.mainGame.entity.editor.inspector.widgets.VectorEditor;

	public class HydrantInspector extends Inspector
	{
		public function HydrantInspector():void
		{
			addWidget(new CheckBoxWidget("Активен(active)", "active"));
			addWidget(new VectorEditor("Объем воды(waterVolume)", "waterVolume", Game.PIXELS_TO_METRE, 0.1));
			addWidget(new NumberEditor("Время воды(waterTime)", "waterTime", 0.001, 1000));
		}
	}
}