package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class HomingGunInspector extends Inspector
	{
		public function HomingGunInspector():void
		{
			addWidget(new CheckBoxWidget(gls("Активен ({0})", "active"), "active"));
			addWidget(new CheckBoxWidget(gls("Самонаведение ({0})", "selfDirection"), "selfDirection"));
			addWidget(new NumberEditor(gls("Сила ({0})", "power"), "power", 1, 0));
			addWidget(new NumberEditor(gls("Радиус ({0})", "radius"), "radius", 1, 50));
		}
	}
}