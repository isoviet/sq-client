package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class PlatformInspector extends Inspector
	{
		public function PlatformInspector():void
		{
			addWidget(new NumberEditor(gls("Трение {0}", "(friction)"), "friction"));
			addWidget(new NumberEditor(gls("Упругость {0}", "(restitution)"), "restitution"));
			addWidget(new NumberEditor(gls("Плотность {0}", "(density)"), "density", 1, 1));
		}

		override public function get height():Number
		{
			return super.widgetsHeight;
		}

		override public function set height(value:Number):void
		{
			super.height = value;
		}
	}
}