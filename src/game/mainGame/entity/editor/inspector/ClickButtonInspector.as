package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import game.mainGame.entity.editor.inspector.widgets.TextEditor;

	public class ClickButtonInspector extends Inspector
	{
		public function ClickButtonInspector():void
		{
			addWidget(new CheckBoxWidget("HaXe (haxeScript)", "haxeScript"));
			addWidget(new TextEditor(gls("Выполнить при Нажатии {0}:", "(onScript)"), "onScript", 200, 200));
			addWidget(new TextEditor(gls("Выполнить при Отжатии {0}:", "(offScript)"), "offScript", 200, 200));

			addWidget(new NumberEditor(gls("Задержка между кликами {0}", "(clickDelay)"), "clickDelay"));
			addWidget(new CheckBoxWidget(gls("Активный {0}", "(enabled)"), "enabled"));
			addWidget(new CheckBoxWidget(gls("Нажатый {0}", "(toggle)"), "toggle"));
		}
	}
}