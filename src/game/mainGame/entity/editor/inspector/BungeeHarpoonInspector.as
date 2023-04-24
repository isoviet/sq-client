package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class BungeeHarpoonInspector extends Inspector
	{
		public function BungeeHarpoonInspector():void
		{
			addWidget(new NumberEditor(gls("Длина тарзанки {0}", "(bungeeLength)"), "bungeeLength", 1, 1));
			addWidget(new NumberEditor(gls("Интервал выстрела {0}", "(shootDelay)"), "shootDelay",  0.001, 1000));
		}
	}
}