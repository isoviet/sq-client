package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.ColorEditor;

	public class BalloonInspector extends Inspector
	{
		public function BalloonInspector():void
		{
			this.addWidget(new ColorEditor(gls("Цвет {0}:", "(color)"), "color"));
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