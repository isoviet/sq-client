package landing.game.mainGame.entity.editor.inspector
{
	import fl.controls.CheckBox;

	import landing.game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;

	public class GameBodyInspector extends Inspector
	{
		private var fixedBox:CheckBox = new CheckBox();
		private var ghostBox:CheckBox = new CheckBox();
		private var noCollisionBox:CheckBox = new CheckBox();

		public function GameBodyInspector():void
		{
			addWidget(new CheckBoxWidget("Зафиксированный", "fixed"));
			addWidget(new CheckBoxWidget("Призрачный", "ghost"));
			addWidget(new CheckBoxWidget("Без столкновений", "noCollision"));
			addWidget(new CheckBoxWidget("Без вращения", "fixedRotation"));
		}
	}
}