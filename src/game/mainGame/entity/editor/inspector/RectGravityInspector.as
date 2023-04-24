package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import game.mainGame.entity.editor.inspector.widgets.VectorEditor;

	public class RectGravityInspector extends Inspector
	{
		public function RectGravityInspector():void
		{
			addWidget(new VectorEditor(gls("Направление {0}", "(direction)"), "direction"));
			addWidget(new NumberEditor(gls("Ускорение {0}", "(velocity)"), "velocity"));
			addWidget(new VectorEditor(gls("Внешний размер {0}", "(outSize)"), "outSize", Game.PIXELS_TO_METRE));

			addWidget(new CheckBoxWidget(gls("Притягивать объекты {0}", "(affectObject)"), "affectObject"));
			addWidget(new CheckBoxWidget(gls("Притягивать белок {0}", "(affectHero)"), "affectHero"));
			addWidget(new CheckBoxWidget(gls("Изменять направление белок {0}", "(extGravity)"), "extGravity"));
			addWidget(new CheckBoxWidget(gls("Отключать глоб. гравитацию {0}", "(disableGravity)"), "disableGravity"));
		}
	}
}