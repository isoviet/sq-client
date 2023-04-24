package screens
{
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;

	import buttons.ButtonBaseMultiLine;
	import views.LoadGameAnimation;

	public class ScreenDisconnected extends Screen
	{
		public function ScreenDisconnected():void
		{
			super();

			init();
		}

		override public function show():void
		{
			super.show();

			LoadGameAnimation.instance.visible = false;
		}

		private function init():void
		{
			var backgroundDisconnect:ScreenDisconnectBackground = new ScreenDisconnectBackground();
			backgroundDisconnect.mouseEnabled = false;
			addChild(backgroundDisconnect);

			var field:GameField = new GameField(gls("Извините, соединение раззззззорвано..."), 0, 25, new TextFormat(GameField.PLAKAT_FONT, 30, 0xFFFFFF));
			field.x = int((Config.GAME_WIDTH - field.textWidth) * 0.5);
			field.filters = [new DropShadowFilter(4, 45, 0x000000, 1, 4, 4)];
			addChild(field);

			var button:ButtonBaseMultiLine = new ButtonBaseMultiLine(gls("Обновить страницу"), 0, 21, reconnect, 2);
			button.x = int((Config.GAME_WIDTH - button.width) * 0.5);
			button.y = 555;
			addChild(button);
		}

		private function reconnect(e:MouseEvent):void
		{
			ExternalInterface.call("window.location.reload");
		}
	}
}