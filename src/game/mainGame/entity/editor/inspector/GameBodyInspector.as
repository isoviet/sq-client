package game.mainGame.entity.editor.inspector
{
	import flash.events.Event;

	import game.mainGame.entity.editor.inspector.widgets.CheckBoxWidget;
	import game.mainGame.entity.editor.inspector.widgets.NumberEditor;

	public class GameBodyInspector extends Inspector
	{
		private var ghostWidget:CheckBoxWidget = null;
		private var ghostToObjectWidget:CheckBoxWidget = null;

		private var fixedWidget:CheckBoxWidget = null;
		private var fixedAngleWidget:CheckBoxWidget = null;

		public function GameBodyInspector():void
		{
			this.ghostWidget = new CheckBoxWidget(gls("Призрачный {0}", "(ghost)"), "ghost");
			this.ghostWidget.addEventListener(Event.CHANGE, onGhostActivate);
			addWidget(this.ghostWidget);

			this.ghostToObjectWidget = new CheckBoxWidget(gls("Призрачный к объектам {0}", "(ghostToObject)"), "ghostToObject");
			this.ghostToObjectWidget.addEventListener(Event.CHANGE, onGhostToObjectActivate);
			addWidget(this.ghostToObjectWidget);

			this.fixedWidget = new CheckBoxWidget(gls("Фиксированый {0}", "(fixed)"), "fixed");
			this.fixedWidget.addEventListener(Event.CHANGE, onFixActivate);
			addWidget(fixedWidget);

			this.fixedAngleWidget = new CheckBoxWidget(gls("Фиксированый угол {0}", "(fixedRotation)"), "fixedRotation");
			this.fixedAngleWidget.addEventListener(Event.CHANGE, onFixAngleActivate);
			addWidget(this.fixedAngleWidget);

			addWidget(new NumberEditor(gls("Скорость {0}", "(speed)"), "speed"));
		}

		override public function get height():Number
		{
			return super.widgetsHeight;
		}

		override public function set height(value:Number):void
		{
			super.height = value;
		}

		private function onGhostActivate(e:Event):void
		{
			if (!this.inspectObject['ghostToObject'])
				return;

			this.inspectObject['ghostToObject'] = false;
			this.ghostToObjectWidget.inspectObject = this.inspectObject;
		}

		private function onGhostToObjectActivate(e:Event):void
		{
			if (!this.inspectObject['ghost'])
				return;

			this.inspectObject['ghost'] = false;
			this.ghostWidget.inspectObject = this.inspectObject;
		}

		private function onFixActivate(e:Event):void
		{
			if (!this.inspectObject['fixedRotation'])
				return;

			this.inspectObject['fixedRotation'] = false;
			this.fixedAngleWidget.inspectObject = this.inspectObject;
		}

		private function onFixAngleActivate(e:Event):void
		{
			if (!this.inspectObject['fixed'])
				return;

			this.inspectObject['fixed'] = false;
			this.fixedWidget.inspectObject = this.inspectObject;
		}
	}
}