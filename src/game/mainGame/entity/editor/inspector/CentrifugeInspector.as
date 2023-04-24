package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class CentrifugeInspector extends Inspector
	{
		public function CentrifugeInspector():void
		{
			addWidget(new NumberEditor("Время постэффекта (effectTime)", "effectTime", 0.001, 1000));
			addWidget(new NumberEditor("Скорость диска (discMotorSpeed)", "discMotorSpeed"));
		}
	}
}