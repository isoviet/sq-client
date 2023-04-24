package landing.game.mainGame.entity.editor.inspector
{
	import landing.game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import landing.game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class JointPrismaticInspector extends Inspector
	{
		public function JointPrismaticInspector():void
		{
			addWidget(new CheckBoxWidget("Фиксированное вращение", "fixedRotation"));
			addWidget(new CheckBoxWidget("Мотор", "motorEnabled"));
			addWidget(new CheckBoxWidget("FlipFlop", "flipFlop"));
			addWidget(new NumberEditor("Скорость", "motorSpeed"));
			addWidget(new NumberEditor("Сила", "motorForce"));

			addWidget(new CheckBoxWidget("Ограниченный", "limited"));
			addWidget(new NumberEditor("Минимум", "minLimit", WallShadow.PIXELS_TO_METRE));
			addWidget(new NumberEditor("Максимум", "maxLimit", WallShadow.PIXELS_TO_METRE));
		}
	}
}