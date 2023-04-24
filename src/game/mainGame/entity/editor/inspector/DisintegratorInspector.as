package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;

	public class DisintegratorInspector extends Inspector
	{
		public function DisintegratorInspector():void
		{
			addWidget(new CheckBoxWidget("Активен(active)", "active"));
		}
	}
}