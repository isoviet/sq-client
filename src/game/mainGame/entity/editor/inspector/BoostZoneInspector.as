package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class BoostZoneInspector extends Inspector
	{
		public function BoostZoneInspector():void
		{
			addWidget(new NumberEditor(gls("Коэффициент ускорения {0}", "(boostFactor)"), "boostFactor", 1, 1));
			addWidget(new NumberEditor(gls("Время ускорения {0}", "(boostTime)"), "boostTime", 0.001, 1000));
		}
	}
}