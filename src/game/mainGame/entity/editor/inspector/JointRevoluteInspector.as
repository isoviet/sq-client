package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class JointRevoluteInspector extends Inspector
	{
		public function JointRevoluteInspector():void
		{
			addWidget(new CheckBoxWidget(gls("Крепление к миру {0}", "(toWorld)"), "toWorld"));
			addWidget(new CheckBoxWidget(gls("Мотор {0}", "(motorEnabled)"), "motorEnabled"));
			addWidget(new CheckBoxWidget("Flip-Flop (flipFlop)", "flipFlop"));
			addWidget(new NumberEditor(gls("Скорость {0}", "(motorSpeed)"), "motorSpeed"));
			addWidget(new NumberEditor(gls("Крутящий момент {0}", "(motorTorque)"), "motorTorque"));
			addWidget(new CheckBoxWidget(gls("Ограниченый {0}", "(limited)"), "limited"));
			addWidget(new NumberEditor(gls("Нижний предел {0}", "(minLimit)"), "minLimit", Game.R2D));
			addWidget(new NumberEditor(gls("Верхний предел {0}", "(maxLimit)"), "maxLimit", Game.R2D));
		}
	}
}