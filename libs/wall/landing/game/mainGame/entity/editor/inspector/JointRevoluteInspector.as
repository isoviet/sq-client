package landing.game.mainGame.entity.editor.inspector
{
	import landing.game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import landing.game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class JointRevoluteInspector extends Inspector
	{
		public function JointRevoluteInspector():void
		{
			addWidget(new CheckBoxWidget("Крепление к миру", "toWorld"));
			addWidget(new CheckBoxWidget("Мотор", "motorEnabled"));
			addWidget(new CheckBoxWidget("FlipFlop", "flipFlop"));
			addWidget(new NumberEditor("Скорость", "motorSpeed"));
			addWidget(new NumberEditor("Крутящий момент", "motorTorque"));
			addWidget(new CheckBoxWidget("Ограниченый", "limited"));
			addWidget(new NumberEditor("Нижний предел", "minLimit", 180 / Math.PI));
			addWidget(new NumberEditor("Верхний предел", "maxLimit", 180 / Math.PI));
		}
	}
}