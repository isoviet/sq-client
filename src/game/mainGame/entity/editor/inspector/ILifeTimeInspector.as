package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class ILifeTimeInspector extends Inspector
	{
		public function ILifeTimeInspector():void
		{
			addWidget(new CheckBoxWidget(gls("Стареющий {0}", "(aging)"), "aging"));
			addWidget(new NumberEditor(gls("Время жизни в мсек {0}", "(lifeTime)"), "lifeTime", 1, 0));
		}
	}
}