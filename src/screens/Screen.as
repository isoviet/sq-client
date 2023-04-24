package screens
{
	import flash.display.Sprite;

	import dialogs.DialogInfo;
	import events.ScreenEvent;

	public class Screen extends Sprite
	{

		public function Screen():void
		{
			super();

			this.visible = false;
		}

		public function firstShow():void
		{}

		public function show():void
		{
			Logger.add("Screen.show " + this);
			this.visible = true;
			dispatchEvent(new ScreenEvent(ScreenEvent.SHOW, this));

			if (Screens.showLazyDialog)
			{
				new DialogInfo(gls("Ты - ленивая Белка, и Шаман прогнал тебя"), gls("Будь активным во время игры и такого больше не повторится")).show();
				Screens.showLazyDialog = false;
			}

			if (Screens.showReportDialog)
			{
				new DialogInfo(gls("Игроки прогнали тебя"), gls("Пять игроков подали жалобу, что ты всех задерживаешь, и выгнали тебя из команды")).show();
				Screens.showReportDialog = false;
			}
		}

		public function hide():void
		{
			Logger.add("Screen.hide " + this);
			this.visible = false;
			dispatchEvent(new ScreenEvent(ScreenEvent.HIDE, this));
		}
	}
}