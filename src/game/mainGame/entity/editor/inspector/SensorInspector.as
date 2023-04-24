package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.TextEditor;

	public class SensorInspector extends Inspector
	{
		public function SensorInspector():void
		{
			addWidget(new CheckBoxWidget("HaXe (haxeScript)", "haxeScript"));
			addWidget(new CheckBoxWidget(gls("Активный при входе {0}", "(onBeginEnabled)"), "onBeginEnabled"));
			addWidget(new TextEditor(gls("Выполнить при входе {0}", "(beginContactScript):"), "beginContactScript", 200, 200));

			addWidget(new CheckBoxWidget(gls("Активный при выходе {0}", "(onEndEnabled)"), "onEndEnabled"));
			addWidget(new TextEditor(gls("Выполнить при выходе {0}", "(endContactScript):"), "endContactScript", 200, 200));

			addWidget(new CheckBoxWidget(gls("Активный {0}", "(enabled)"), "enabled"));

			addWidget(new CheckBoxWidget(gls("Реагировать на белку {0}", "(activateOnHero)"), "activateOnHero"));
			addWidget(new CheckBoxWidget(gls("Реагировать на объекты {0}", "(activateOnObject)"), "activateOnObject"));
		}
	}
}