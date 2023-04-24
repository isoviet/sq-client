package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class PusherInspector extends Inspector
	{
		public function PusherInspector():void
		{
			addWidget(new NumberEditor(gls("Сила {0}", "(force)"), "force"));
			addWidget(new NumberEditor(gls("Максимальная скорость {0}", "(maxVelocity)"), "maxVelocity"));
		}
	}
}