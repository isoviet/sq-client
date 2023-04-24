package dialogs
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;

	import tape.list.ListElement;
	import tape.list.ListFragsData;
	import tape.list.ListFragsElement;
	import tape.list.ListPlayersView;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DialogBattleWinners extends Dialog
	{
		static private const OFFSET_X:int = 0;
		static private const OFFSET_Y:int = 10;
		static private const WIDTH:int = 340;

		static private const FORMAT_RED:TextFormat = new TextFormat(null, 35, 0xFF0000, true, null, null, null, null, "center");
		static private const FORMAT_BLUE:TextFormat = new TextFormat(null, 35, 0x0D43BC, true, null, null, null, null, "center");

		static private const FORMAT_TEXT:TextFormat = new TextFormat(null, 16, 0x663C0D, true, null, null, null, null, "center");
		static private const FORMAT_RESULT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0x0E3180, null, null, null, null, null, "center");

		private var blueWinImage:BlueTeamWinImage;
		private var blueLoseImage:BlueTeamLoseImage;
		private var drawWinImage:DrawTeamWinImage;

		private var fieldScoreBlue:GameField = null;
		private var fieldScoreRed:GameField = null;

		private var winnerTeamField:GameField;
		private var prizeSprite:Sprite = new Sprite();
		private var prizeBackground:PrizeBg;

		private var redTeamFragsList:ListPlayersView = new ListPlayersView();
		private var blueTeamFragsList:ListPlayersView = new ListPlayersView();

		private var fragsSprite:Sprite = null;

		public function DialogBattleWinners():void
		{
			super("");

			init();
		}

		override public function hide(e:MouseEvent = null):void
		{
			if (!Game.gameSprite.contains(this))
				return;
			Game.gameSprite.removeChild(this);
		}

		override public function show():void
		{
			super.show();

			Connection.sendData(PacketClient.COUNT, PacketClient.CAN_REPOST, Game.self['type']);
		}

		public function setScore(results:Array, selfTeam:int):void
		{
			var redScore:int = results[0];
			var blueScore:int = results[1];

			if (selfTeam != Hero.TEAM_NONE)
				selfTeam = Hero.TEAM_BLUE;

			var blueWins:Boolean = (redScore < blueScore);
			var redWins:Boolean = (redScore > blueScore);
			var selfWin:Boolean = (selfTeam != Hero.TEAM_NONE) && blueWins;

			this.winnerTeamField.visible = (selfWin || (selfTeam == Hero.TEAM_NONE)) && (redWins || blueWins);
			this.winnerTeamField.text = (redWins ? gls("Участники красной команды получают") : gls("Участники синей команды получают"));

			this.prizeSprite.visible = (selfWin || (selfTeam == Hero.TEAM_NONE)) && (redWins || blueWins);

			this.blueWinImage.visible = blueWins && (selfWin || (selfTeam == Hero.TEAM_NONE));
			this.blueLoseImage.visible = redWins && !(selfWin || (selfTeam == Hero.TEAM_NONE));
			this.drawWinImage.visible = !redWins && !blueWins;

			this.fieldScoreBlue.text = blueScore.toString();
			this.fieldScoreRed.text = redScore.toString();

			if (selfWin || (selfTeam == Hero.TEAM_NONE))
			{
				this.winnerTeamField.y = this.fragsSprite.y + this.fragsNumRows * ListFragsElement.HEIGHT + 45;
				this.prizeSprite.y = this.winnerTeamField.y + 20;
				this.height = this.prizeSprite.y + this.prizeSprite.height + 55;

				if (blueWins)
				{
					this.fieldScoreBlue.x = this.blueLoseImage.x + 78;
					this.fieldScoreRed.x = this.blueLoseImage.x + 134;
					this.fieldScoreBlue.y = this.blueLoseImage.y + 223;
					this.fieldScoreRed.y = this.blueLoseImage.y + 217;
					return;
				}
			}

			this.height = this.fragsSprite.y + this.fragsNumRows * ListFragsElement.HEIGHT + 50 + this.topOffset;

			if (redWins)
			{
				this.fieldScoreBlue.x = this.blueLoseImage.x + 79;
				this.fieldScoreRed.x = this.blueLoseImage.x + 131;
				this.fieldScoreBlue.y = this.blueLoseImage.y + 225;
				this.fieldScoreRed.y = this.blueLoseImage.y + 219;
				return;
			}

			this.fieldScoreBlue.x = this.blueLoseImage.x + 67;
			this.fieldScoreRed.x = this.blueLoseImage.x + 124;
			this.fieldScoreBlue.y = this.blueLoseImage.y + 133;
			this.fieldScoreRed.y = this.blueLoseImage.y + 126;
		}

		public function setPrize(exp:int, nuts:int):void
		{
			while (this.prizeSprite.numChildren > 0)
				this.prizeSprite.removeChildAt(0);

			this.prizeSprite.addChild(this.prizeBackground);

			var format:TextFormat = new TextFormat(null, 14, 0x000000, true);
			var values:Array = [nuts, exp];
			var images:Array = [new ImageIconNut, new ImageIconExp];
			var offset:int = 110;

			for (var i:int = 0; i < values.length; i++)
			{
				if (values[i] == 0)
					continue;
				var field:GameField = new GameField(values[i], offset, 15, format);
				field.filters = [new DropShadowFilter(0, 0, 0xFFFFFF, 0.9, 4, 4, 7)];
				this.prizeSprite.addChild(field);

				offset += field.textWidth + 10;

				var image:DisplayObject = images[i];
				image.scaleX = image.scaleY = 0.7;
				image.x = offset;
				image.y = 15;
				this.prizeSprite.addChild(image);

				offset += image.width + 5;
			}
		}

		public function setFrags(redTeam:Vector.<ListElement>, blueTeam:Vector.<ListElement>):void
		{
			var redFragsData:ListFragsData = new ListFragsData();
			redFragsData.setData(redTeam);

			var blueFragsData:ListFragsData = new ListFragsData();
			blueFragsData.setData(blueTeam);

			this.blueTeamFragsList.setData(blueFragsData);
			this.redTeamFragsList.setData(redFragsData);
		}

		private function init():void
		{
			this.blueWinImage = new BlueTeamWinImage();
			this.blueWinImage.addChild(new GameField(gls("Твоя команда"), 0, 0, FORMAT_TEXT, 308));
			this.blueWinImage.addChild(new GameField(gls("Победила"), 0, 28, FORMAT_RESULT, 308));
			this.blueWinImage.x = int((WIDTH - this.blueWinImage.width) / 2);
			this.blueWinImage.y = OFFSET_Y;
			addChild(this.blueWinImage);

			this.blueLoseImage = new BlueTeamLoseImage();
			this.blueLoseImage.addChild(new GameField(gls("Твоя команда"), 0, 0, FORMAT_TEXT, 308));
			this.blueLoseImage.addChild(new GameField(gls("Проиграла"), 0, 28, FORMAT_RESULT, 308));
			this.blueLoseImage.x = int((WIDTH - this.blueLoseImage.width) / 2);
			this.blueLoseImage.y = OFFSET_Y;
			addChild(this.blueLoseImage);

			this.drawWinImage = new DrawTeamWinImage();
			this.drawWinImage.addChild(new GameField(gls("Ничья"), 0, 0, FORMAT_TEXT, 308));
			this.drawWinImage.x = int((WIDTH - this.drawWinImage.width) / 2);
			this.drawWinImage.y = OFFSET_Y;
			addChild(this.drawWinImage);

			this.fieldScoreBlue = new GameField("", 0, 0, FORMAT_BLUE, 106);
			this.fieldScoreBlue.rotation = -5;
			addChild(this.fieldScoreBlue);

			this.fieldScoreRed = new GameField("", 0, 0, FORMAT_RED, 106);
			this.fieldScoreRed.rotation = -5;
			addChild(this.fieldScoreRed);

			this.winnerTeamField = new GameField("", 0, 0, new TextFormat(null, 13, 0x673D0E, true, null, null, null, null, "center"));
			this.winnerTeamField.width = WIDTH;
			this.winnerTeamField.wordWrap = true;
			this.winnerTeamField.multiline = true;
			this.winnerTeamField.mouseEnabled = false;
			addChild(this.winnerTeamField);

			addChild(this.prizeSprite);

			this.prizeBackground = new PrizeBg();
			this.prizeBackground.x = int((WIDTH - this.prizeBackground.width) / 2);
			this.prizeSprite.addChild(this.prizeBackground);

			this.fragsSprite = new Sprite();
			this.fragsSprite.addChild(new GameField(gls("Заработанные очки:"), 90, 0, new TextFormat(null, 13, 0x663C0D, true)));
			this.fragsSprite.addChild(new GameField(gls("Красная команда"), 173, 19, new TextFormat(null, 13, 0xFA1D1D, true)));
			this.fragsSprite.addChild(new GameField(gls("Синяя команда"), 3, 19, new TextFormat(null, 13, 0x2857C1, true)));

			this.redTeamFragsList.x = 172;
			this.redTeamFragsList.y = 37;
			this.fragsSprite.addChild(this.redTeamFragsList);

			this.blueTeamFragsList.y = 37;
			this.fragsSprite.addChild(this.blueTeamFragsList);

			this.fragsSprite.x = OFFSET_X;
			this.fragsSprite.y = OFFSET_Y + 290;
			addChild(this.fragsSprite);

			place();
		}

		private function get fragsNumRows():int
		{
			return Math.max(this.redTeamFragsList.numElements, this.blueTeamFragsList.numElements);
		}
	}
}