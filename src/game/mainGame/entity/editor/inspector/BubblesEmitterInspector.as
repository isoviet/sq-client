package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class BubblesEmitterInspector extends Inspector
	{
		public function BubblesEmitterInspector():void
		{
			addWidget(new NumberEditor(gls("Интервал пузырения {0}", "(bubbleDelay)"), "bubbleDelay", 0.001, 1000));
			addWidget(new NumberEditor(gls("Скорость подъема пузырей {0}", "(bubbleSpeed)"), "bubbleSpeed", -1, -50, -1));
			addWidget(new NumberEditor(gls("Лимит соприкосновений {0}", "(bubbleTouchLimit)"), "bubbleTouchLimit", 1, 1));
		}
	}
}