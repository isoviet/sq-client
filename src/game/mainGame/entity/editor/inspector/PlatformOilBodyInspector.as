package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class PlatformOilBodyInspector extends Inspector
	{
		public function PlatformOilBodyInspector():void
		{
			addWidget(new NumberEditor(gls("Время постэффекта {0}", "(effectTime)"), "effectTime",  0.001, 1000));
		}
	}
}