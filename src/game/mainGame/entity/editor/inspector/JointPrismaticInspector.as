package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class JointPrismaticInspector extends Inspector
	{
		public function JointPrismaticInspector():void
		{
			addWidget(new CheckBoxWidget(gls("Фиксированное вращение {0}", "(fixedRotation)"), "fixedRotation"));
			addWidget(new CheckBoxWidget(gls("Мотор {0}", "(motorEnabled)"), "motorEnabled"));
			addWidget(new CheckBoxWidget("FlipFlop (flipFlop)", "flipFlop"));
			addWidget(new NumberEditor(gls("Скорость {0}", "(motorSpeed)"), "motorSpeed"));
			addWidget(new NumberEditor(gls("Сила {0}", "(motorForce)"), "motorForce"));

			addWidget(new CheckBoxWidget(gls("Ограниченный {0}", "(limited)"), "limited"));
			addWidget(new NumberEditor(gls("Минимум {0}", "(minLimit)"), "minLimit", Game.PIXELS_TO_METRE));
			addWidget(new NumberEditor(gls("Максимум {0}", "(maxLimit)"), "maxLimit", Game.PIXELS_TO_METRE));
		}
	}
}