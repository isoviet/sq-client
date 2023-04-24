package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import game.mainGame.entity.editor.inspector.widgets.TextEditor;

	public class ScriptedTimerInspector extends Inspector
	{
		public function ScriptedTimerInspector():void
		{
			addWidget(new CheckBoxWidget(gls("Запущен {0}", "(running)"), "running"));
			addWidget(new NumberEditor(gls("Задержка {0}", "(delay)"), "delay"));
			addWidget(new NumberEditor(gls("Кол-во повторов {0}", "(repeatCount)"), "repeatCount"));

			addWidget(new CheckBoxWidget("HaXe (haxeScript)", "haxeScript"));
			addWidget(new CheckBoxWidget("onTickEnabled (onTickEnabled)", "onTickEnabled"));
			addWidget(new TextEditor("tickScript (tickScript):", "tickScript", 200, 200));

			addWidget(new CheckBoxWidget("onCompleteEnabled (onCompleteEnabled)", "onCompleteEnabled"));
			addWidget(new TextEditor("completeScript (completeScript)", "completeScript", 200, 200));
		}
	}
}