package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class PlanetBodyInspector extends Inspector
	{
		public function PlanetBodyInspector():void
		{
			addWidget(new NumberEditor(gls("Сила притяжения {0}", "(gravity)"), "gravity"));
			addWidget(new NumberEditor(gls("Макс. диcтанция {0}", "(maxDistance)"), "maxDistance"));
			addWidget(new NumberEditor(gls("Плотность {0}", "(density)"), "density", 1, 1));
			addWidget(new NumberEditor(gls("Скин {0}", "(skin)"), "skin"));
			addWidget(new CheckBoxWidget("InvSqr (invSqr)", "invSqr"));
			addWidget(new CheckBoxWidget(gls("Притягивать объекты {0}", "(affectObjects)"), "affectObjects"));
			addWidget(new CheckBoxWidget(gls("Притягивать белок {0}", "(affectHero)"), "affectHero"));
			addWidget(new CheckBoxWidget(gls("Изменять направление белок {0}", "(addExtGrav)"), "addExtGrav"));
			addWidget(new CheckBoxWidget(gls("Двунаправленное притяжение {0}", "(biDirectional)"), "biDirectional"));
			addWidget(new CheckBoxWidget(gls("Отключение глобальной гравитации {0}", "(disableGlobalGravity)"), "disableGlobalGravity"));
		}
	}
}