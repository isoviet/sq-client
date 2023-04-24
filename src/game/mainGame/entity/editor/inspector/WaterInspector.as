package game.mainGame.entity.editor.inspector
{
	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.ColorEditor;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;
	import game.mainGame.entity.editor.inspector.widgets.VectorEditor;

	public class WaterInspector extends Inspector
	{
		public function WaterInspector():void
		{
			addWidget(new VectorEditor(gls("Течение {0}", "(velocity)"), "velocity", Game.PIXELS_TO_METRE));
			addWidget(new NumberEditor(gls("Коэффициент пузырения {0}", "(bubblingFactor)"), "bubblingFactor", 1, 0, 0.5));
			addWidget(new CheckBoxWidget(gls("Разрешено плавать {0}", "(allowSwim)"), "allowSwim"));
			addWidget(new ColorEditor(gls("Цвет {0} {1}", 1, "(color0)"), "color0"));
			addWidget(new ColorEditor(gls("Цвет {0} {1}", 2, "(color1)"), "color1"));
			addWidget(new ColorEditor(gls("Цвет {0} {1}", 3, "(color2)"), "color2"));
			if (Game.editor_access)
			{
				addWidget(new CheckBoxWidget(gls("Волны вкл. {0}", "(waveEnabled)"), "waveEnabled"));
				addWidget(new NumberEditor(gls("Длина Волны {0}", "(waveLength)"), "waveLength"));
				addWidget(new NumberEditor(gls("Амплитуда {0}", "(waveAmplitude)"), "waveAmplitude"));
				addWidget(new NumberEditor(gls("Кол-во связей {0}", "(particlesCount)"), "particlesCount"));
			}
		}
	}
}