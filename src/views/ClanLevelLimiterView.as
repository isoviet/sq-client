package views
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import game.gameData.GameConfig;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.EditField;

	public class ClanLevelLimiterView extends Sprite
	{
		private var levelField:EditField;

		public function ClanLevelLimiterView()
		{
			var buyPlaceBg:BuyPlaceBackground = new BuyPlaceBackground();
			buyPlaceBg.height -= 40;
			addChild(buyPlaceBg);

			var format:TextFormat = new TextFormat(null, 14, 0x47342A, false);
			format.align = TextFormatAlign.CENTER;
			format.leading = 2.5;

			var textField:GameField = new GameField(gls("Минимальный уровень для\nвступления в клан"), 0 , 10, format);
			textField.x = (buyPlaceBg.width >> 1) - (textField.width >> 1);
			addChild(textField);

			var levelFormat:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 14, 0x000000, true);

			var editSprite:Sprite = new Sprite();
			editSprite.y = textField.y + textField.height + 5;

			this.levelField = new EditField("", 0, 0, 30, 20, levelFormat, levelFormat, GameConfig.maxLevel.toString().length);
			this.levelField.restrict = "0-9";
			editSprite.addChild(this.levelField);

			var button:ButtonBase = new ButtonBase(gls("Ок"));
			button.x = this.levelField.x + this.levelField.width + 10;
			button.y = this.levelField.y - 4;
			button.addEventListener(MouseEvent.CLICK, onClick);
			editSprite.addChild(button);

			editSprite.x = (buyPlaceBg.width >> 1) - (editSprite.width >> 1);
			addChild(editSprite);
		}

		public function get minLevel():int
		{
			return int(this.levelField.text);
		}

		public function set minLevel(value:int):void
		{
			this.levelField.text = Math.max(Math.min(value, GameConfig.maxLevel), Game.LEVEL_TO_OPEN_CLANS).toString();
		}

		private function onClick(e:MouseEvent):void
		{
			this.minLevel = int(this.levelField.text);

			Connection.sendData(PacketClient.CLAN_LEVEL_LIMITER, this.minLevel);
		}
	}
}