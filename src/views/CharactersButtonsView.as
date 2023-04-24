package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonEditableText;
	import events.DiscountEvent;
	import game.gameData.FlagsManager;
	import screens.ScreenGame;
	import statuses.Status;

	import com.api.Services;

	import interfaces.IStandby;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBuy;
	import protocol.packages.server.PacketDiscountUse;
	import protocol.packages.server.PacketRoomRound;

	import utils.FieldUtils;
	import utils.FiltersUtil;

	public class CharactersButtonsView extends Sprite implements IStandby
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
			}
			a {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
			}
			a:hover {
				text-decoration: none;
			}
			.bold {
				font-weight: bold;
			}
		]]>).toString();

		private var style:StyleSheet;

		private static const BUTTON_POSITION_X:Number = -16;
		private static const BUTTON_POSITION_X2:Number = 47;
		private static const BUTTON_POSITION_Y:Number = 66;
		private static const TEXT_CHAR_POSITION:Point = new Point(-23, -80);

		private static const SHAMAN_POSITION:Point = new Point(56, 150);
		private static const DRAGON_POSITION:Point = new Point(56, 270);
		private static const HARE_POSITION:Point = new Point(56, 392);

		static private const ICON_POSITION:Point = new Point(-16, -58);

		static private const TEXT_FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 18,
			0xDEFFCD);
		static private const NAME_CHAR_FORMAT:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 14,
			0x7E5836, true, null, null, null, null, TextFormatAlign.CENTER);

		private var shamanAcornButton:ButtonEditableText = null;
		private var shamanCoinsButton:ButtonEditableText = null;
		private var shamanFreeButton:ButtonEditableText = null;
		private var hareAcornButton:ButtonEditableText = null;
		private var hareCoinsButton:ButtonEditableText = null;
		private var dragonAcornButton:ButtonEditableText = null;
		private var dragonCoinsButton:ButtonEditableText = null;

		private var status:GameField = null;
		private var status_position:Number = 0;

		private var shamanImage:ImageShamanCharacterIcon;
		private var hareImage:ImageHareCharacterIcon;
		private var dragonImage:ImageDragonCharacterIcon;

		private var shamanContainer:Sprite = null;
		private var hareContainer:Sprite = null;
		private var dragonContainer:Sprite = null;

		private var statusCertificate:Status = null;
		private var statusDragon:Status = null;
		private var statusNewbie:Status = null;

		private var bg:MovieClip = null;

		private var modeId:int;

		public function CharactersButtonsView(ribbornText:GameField, bg:MovieClip):void
		{
			super();

			this.status = ribbornText;
			this.status_position = this.status.y;
			this.bg = bg;

			init();

			standby(false);
		}

		public function set statusField(value:String):void
		{
			this.status.text = value;
			this.status.y = this.status_position + 25 - this.status.textHeight/2;
		}

		public function standby(value:Boolean):void
		{
			if(value)
			{
				Connection.forget(onPacket, [PacketRoomRound.PACKET_ID, PacketBuy.PACKET_ID,
					PacketDiscountUse.PACKET_ID]);
				DiscountManager.removeEventListener(DiscountEvent.BONUS_START, onBonus);
				DiscountManager.removeEventListener(DiscountEvent.BONUS_END, onBonusEnd);
			}
			else
			{
				Connection.listen(onPacket, [PacketRoomRound.PACKET_ID, PacketBuy.PACKET_ID,
					PacketDiscountUse.PACKET_ID], 2);
				DiscountManager.addEventListener(DiscountEvent.BONUS_START, onBonus);
				DiscountManager.addEventListener(DiscountEvent.BONUS_END, onBonusEnd);
			}
		}

		public function dispose():void
		{
			if (this.statusCertificate)
				this.statusCertificate.remove();
			if (this.statusNewbie)
				this.statusNewbie.remove();

			standby(true);
		}

		public function update():void
		{
			this.shamanContainer.visible = this.shamanAvailable;
			this.hareContainer.visible = this.hareAvailable;
			this.dragonContainer.visible = this.dragonAvailable;

			this.bg.height = 172 + (this.hareAvailable ? this.hareContainer.height : 0) + (this.dragonAvailable ?
			this.dragonContainer.height : 0);

			placeButtons();
		}

		public function get hasAvailable():Boolean
		{
			return (this.shamanAvailable || this.hareAvailable || this.dragonAvailable);
		}

		public function set hare(value:Boolean):void
		{
			this.hareAcornButton.enabled = value;
			this.hareAcornButton.mouseEnabled = value;
			this.hareCoinsButton.enabled = value;
			this.hareCoinsButton.mouseEnabled = value;
			this.hareAcornButton.filters = this.hareCoinsButton.filters = value ? [] : FiltersUtil.GREY_FILTER;
			this.hareImage.filters = value ? [] : FiltersUtil.GREY_FILTER;
		}

		public function get hare():Boolean
		{
			return this.hareAcornButton.enabled;
		}

		public function set dragon(value:Boolean):void
		{
			this.dragonAcornButton.enabled = value && Experience.selfLevel >= Game.LEVEL_TO_OPEN_DRAGON;
			this.dragonAcornButton.mouseEnabled = value && Experience.selfLevel >= Game.LEVEL_TO_OPEN_DRAGON;
			this.dragonCoinsButton.enabled = value && Experience.selfLevel >= Game.LEVEL_TO_OPEN_DRAGON;
			this.dragonCoinsButton.mouseEnabled = value && Experience.selfLevel >= Game.LEVEL_TO_OPEN_DRAGON;
			this.dragonAcornButton.filters = this.dragonCoinsButton.filters = value ? [] : FiltersUtil.GREY_FILTER;
			this.dragonImage.filters = (value && Experience.selfLevel >= Game.LEVEL_TO_OPEN_DRAGON) ? [] : FiltersUtil.GREY_FILTER;
		}

		public function get dragon():Boolean
		{
			return this.dragonAcornButton.enabled;
		}

		public function set shaman(value:Boolean):void
		{
			this.shamanAcornButton.enabled = value;
			this.shamanAcornButton.mouseEnabled = value;
			this.shamanCoinsButton.enabled = value;
			this.shamanCoinsButton.mouseEnabled = value;
			this.shamanFreeButton.enabled = value;
			this.shamanFreeButton.mouseEnabled = value;
			this.shamanAcornButton.filters = this.shamanCoinsButton.filters = this.shamanFreeButton.filters = value ? [] : FiltersUtil.GREY_FILTER;
			this.shamanImage.filters = value ? [] : FiltersUtil.GREY_FILTER;
		}

		public function get shaman():Boolean
		{
			return this.shamanAcornButton.enabled;
		}

		private function toggleButtons(value:Boolean):void
		{
			toggleShamanButton(value && FlagsManager.has(Flag.SHAMAN_SCHOOL_FINISH) && Experience.selfLevel >= Game.LEVEL_TO_OPEN_SHAMAN);

			hare = value;
			dragon = value;

			if (this.statusDragon == null && Experience.selfLevel < Game.LEVEL_TO_OPEN_DRAGON)
				this.statusDragon = new Status(this.dragonImage, gls("<body><b>Недоступно</b><br/>Дракоша доступен с {0} уровня</body>", Game.LEVEL_TO_OPEN_DRAGON), false, true);
			if (this.statusDragon && Experience.selfLevel >= Game.LEVEL_TO_OPEN_DRAGON)
			{
				this.statusDragon.remove();
				this.statusDragon = null;
			}
		}

		private function placeButtons():void
		{
			var buttonsCount:int = 0;
			if (this.shamanAvailable)
				buttonsCount++;
			if (this.hareAvailable)
				buttonsCount++;
			if (this.dragonAvailable)
				buttonsCount++;

		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			this.shamanContainer = new Sprite();
			this.hareContainer = new Sprite();
			this.dragonContainer = new Sprite();

			this.dragonContainer.scaleX = this.dragonContainer.scaleY = 0.67;
			this.hareContainer.scaleX = this.hareContainer.scaleY = 0.67;
			this.shamanContainer.scaleX = this.shamanContainer.scaleY = 0.67;

			addChild(this.shamanContainer);
			addChild(this.hareContainer);
			addChild(this.dragonContainer);

			this.shamanContainer.y = SHAMAN_POSITION.y;
			this.shamanContainer.x = SHAMAN_POSITION.x;

			this.hareContainer.x = HARE_POSITION.x;
			this.hareContainer.y = HARE_POSITION.y;

			this.dragonContainer.x = DRAGON_POSITION.x;
			this.dragonContainer.y = DRAGON_POSITION.y;

			var nameChar:GameField = new GameField(gls("Шаман"), TEXT_CHAR_POSITION.x, TEXT_CHAR_POSITION.y, NAME_CHAR_FORMAT, 122);
			this.shamanContainer.addChild(nameChar);

			nameChar = new GameField(gls("Дракончик"), TEXT_CHAR_POSITION.x, TEXT_CHAR_POSITION.y, NAME_CHAR_FORMAT, 122);
			this.dragonContainer.addChild(nameChar);

			nameChar = new GameField(gls("Заяц Несудьбы"), TEXT_CHAR_POSITION.x, TEXT_CHAR_POSITION.y, NAME_CHAR_FORMAT, 122);
			this.hareContainer.addChild(nameChar);

			var priceFormat:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 16, 0xDEFFCD, null, null, null, null, null,
				TextFormatAlign.CENTER);

			this.shamanAcornButton = new ButtonEditableText(new ButtonBuySmall, priceFormat, -9, 1, 60);
			this.shamanAcornButton.textField.text = Game.SHAMAN_ACORNS_COST + "  #";
			this.shamanAcornButton.back.width = 60;
			this.shamanAcornButton.back.height = 30;
			this.shamanAcornButton.centerField();
			this.shamanAcornButton.x = BUTTON_POSITION_X;
			this.shamanAcornButton.y = BUTTON_POSITION_Y;
			this.shamanAcornButton.visible = DiscountManager.freeShaman == -1;
			this.shamanAcornButton.addEventListener(MouseEvent.CLICK, click);
			this.shamanContainer.addChild(this.shamanAcornButton);

			this.shamanImage = new ImageShamanCharacterIcon();
			this.shamanImage.x = ICON_POSITION.x;
			this.shamanImage.y = ICON_POSITION.y;
			this.shamanContainer.addChild(this.shamanImage);

			new Status(this.shamanAcornButton, gls("Стать Шаманом"));
			FieldUtils.replaceSign(this.shamanAcornButton.textField, "#", ImageIconNut, 0.7, 0.7, -this.shamanAcornButton.textField.x - 4,
				-this.shamanAcornButton.textField.y-1, false, true);

			this.shamanCoinsButton = new ButtonEditableText(new ButtonBuySmall, priceFormat, -9, 1, 50);
			this.shamanCoinsButton.textField.text = Game.SHAMAN_COINS_COST + "  #";
			this.shamanCoinsButton.back.width = 50;
			this.shamanCoinsButton.back.height = 30;
			this.shamanCoinsButton.centerField();
			this.shamanCoinsButton.x = BUTTON_POSITION_X2;
			this.shamanCoinsButton.y = BUTTON_POSITION_Y;
			this.shamanCoinsButton.visible = DiscountManager.freeShaman == -1;
			this.shamanCoinsButton.addEventListener(MouseEvent.CLICK, click);
			this.shamanContainer.addChild(this.shamanCoinsButton);
			new Status(this.shamanCoinsButton, gls("Стать Шаманом"));
			FieldUtils.replaceSign(this.shamanCoinsButton.textField, "#", ImageIconCoins, 0.8, 0.8, -this.shamanCoinsButton.textField.x-5,
				-this.shamanCoinsButton.textField.y, false, true);

			this.shamanFreeButton = new ButtonEditableText(new ButtonBuySmall, priceFormat, 0, 1);
			this.shamanFreeButton.textField.text = gls("Играть");
			this.shamanFreeButton.back.width = 60;
			this.shamanFreeButton.back.height = 30;
			this.shamanFreeButton.centerField();
			this.shamanFreeButton.x = 24;
			this.shamanFreeButton.y = BUTTON_POSITION_Y;
			this.shamanFreeButton.visible = DiscountManager.freeShaman != -1;
			this.shamanFreeButton.addEventListener(MouseEvent.CLICK, click);
			this.shamanContainer.addChild(this.shamanFreeButton);
			new Status(this.shamanFreeButton, gls("Стать Шаманом"));

			//--------------
			this.dragonAcornButton = new ButtonEditableText(new ButtonBuySmall, priceFormat, -9, 1, 60);
			this.dragonAcornButton.textField.text = Game.DRAGON_ACORNS_COST + "  #";
			this.dragonAcornButton.back.width = 60;
			this.dragonAcornButton.back.height = 30;
			this.dragonAcornButton.centerField();
			this.dragonAcornButton.x = BUTTON_POSITION_X;
			this.dragonAcornButton.y = BUTTON_POSITION_Y;
			this.dragonAcornButton.addEventListener(MouseEvent.CLICK, click);
			new Status(this.dragonAcornButton, gls("Стать Дракошей"));
			this.dragonContainer.addChild(this.dragonAcornButton);
			FieldUtils.replaceSign(this.dragonAcornButton.textField, "#", ImageIconNut, 0.7, 0.7, -this.dragonAcornButton.textField.x-4,
				-this.dragonAcornButton.textField.y-1, false, true);

			this.dragonCoinsButton = new ButtonEditableText(new ButtonBuySmall, priceFormat, -9, 1, 50);
			this.dragonCoinsButton.textField.text = Game.DRAGON_COINS_COST + "  #";
			this.dragonCoinsButton.back.width = 50;
			this.dragonCoinsButton.back.height = 30;
			this.dragonCoinsButton.centerField();
			this.dragonCoinsButton.x = BUTTON_POSITION_X2;
			this.dragonCoinsButton.y = BUTTON_POSITION_Y;
			this.dragonCoinsButton.addEventListener(MouseEvent.CLICK, click);
			new Status(this.dragonCoinsButton, gls("Стать Дракошей"));
			this.dragonContainer.addChild(this.dragonCoinsButton);
			FieldUtils.replaceSign(this.dragonCoinsButton.textField, "#", ImageIconCoins, 0.7, 0.7, -this.dragonCoinsButton.textField.x-5,
				-this.dragonCoinsButton.textField.y, false, true);

			this.dragonImage = new ImageDragonCharacterIcon();
			this.dragonImage.x = ICON_POSITION.x;
			this.dragonImage.y = ICON_POSITION.y;
			this.dragonContainer.addChild(this.dragonImage);

			//------------
			this.hareAcornButton = new ButtonEditableText(new ButtonBuySmall, priceFormat, -9, 1, 60);
			this.hareAcornButton.textField.text = Game.HARE_ACORNS_COST + "  #";
			this.hareAcornButton.back.width = 60;
			this.hareAcornButton.back.height = 30;
			this.hareAcornButton.centerField();
			this.hareAcornButton.x = BUTTON_POSITION_X;
			this.hareAcornButton.y = BUTTON_POSITION_Y;
			this.hareAcornButton.addEventListener(MouseEvent.CLICK, click);
			this.hareContainer.addChild(this.hareAcornButton);
			new Status(this.hareAcornButton, gls("Стать Зайцем НеСудьбы"));
			FieldUtils.replaceSign(this.hareAcornButton.textField, "#", ImageIconNut, 0.7, 0.7, -this.hareAcornButton.textField.x-4,
				-this.hareAcornButton.textField.y-1, false, true);

			this.hareCoinsButton = new ButtonEditableText(new ButtonBuySmall, priceFormat, -9, 1, 50);
			this.hareCoinsButton.textField.text = Game.HARE_COINS_COST + "  #";
			this.hareCoinsButton.back.width = 50;
			this.hareCoinsButton.back.height = 30;
			this.hareCoinsButton.centerField();
			this.hareCoinsButton.x = BUTTON_POSITION_X2;
			this.hareCoinsButton.y = BUTTON_POSITION_Y;
			this.hareCoinsButton.addEventListener(MouseEvent.CLICK, click);
			this.hareContainer.addChild(this.hareCoinsButton);
			new Status(this.hareCoinsButton, gls("Стать Зайцем НеСудьбы"));
			FieldUtils.replaceSign(this.hareCoinsButton.textField, "#", ImageIconCoins, 0.7, 0.7,
				-this.hareCoinsButton.textField.x-5, -this.hareCoinsButton.textField.y, false, true);

			this.hareImage = new ImageHareCharacterIcon();
			this.hareImage.x = ICON_POSITION.x;
			this.hareImage.y = ICON_POSITION.y;
			this.hareContainer.addChild(this.hareImage);
		}

		private function click(e:MouseEvent):void
		{
			switch (e.currentTarget)
			{
				case this.hareCoinsButton:
					if (Game.self.coins < Game.HARE_COINS_COST)
					{
						Services.bank.open();
						return;
					}
					this.hareCoinsButton.mouseEnabled = false;
					Connection.sendData(PacketClient.BUY, PacketClient.BUY_HARE, Game.HARE_COINS_COST, 0, Game.selfId);
					break;
				case this.hareAcornButton:
					this.hareAcornButton.mouseEnabled = false;
					Connection.sendData(PacketClient.BUY, PacketClient.BUY_HARE, 0, Game.HARE_ACORNS_COST, Game.selfId);
					break;
				case this.dragonCoinsButton:
					if (Game.self.coins < Game.DRAGON_COINS_COST)
					{
						Services.bank.open();
						return;
					}
					this.dragonCoinsButton.mouseEnabled = false;
					Connection.sendData(PacketClient.BUY, PacketClient.BUY_DRAGON, Game.DRAGON_COINS_COST, 0, Game.selfId);
					break;
				case this.dragonAcornButton:
					this.dragonAcornButton.mouseEnabled = false;
					Connection.sendData(PacketClient.BUY, PacketClient.BUY_DRAGON, 0, Game.DRAGON_ACORNS_COST, Game.selfId);
					break;
				case this.shamanCoinsButton:
					if (Game.self.coins < Game.SHAMAN_COINS_COST)
					{
						Services.bank.open();
						return;
					}
					this.shamanCoinsButton.mouseEnabled = false;
					Connection.sendData(PacketClient.BUY, PacketClient.BUY_SHAMAN, Game.SHAMAN_COINS_COST, 0, Game.selfId);
					break;
				case this.shamanAcornButton:
					this.shamanAcornButton.mouseEnabled = false;
					Connection.sendData(PacketClient.BUY, PacketClient.BUY_SHAMAN, 0, Game.SHAMAN_ACORNS_COST, Game.selfId);
					break;
				case this.shamanFreeButton:
					this.shamanFreeButton.mouseEnabled = false;
					Connection.sendData(PacketClient.DISCOUNT_USE, DiscountManager.freeShaman, 0);
					break;
			}
		}

		private function get shamanAvailable():Boolean
		{
			return (Experience.selfLevel >= Game.LEVEL_TO_OPEN_SHAMAN) && Boolean(Locations.MODES[this.modeId]['shamanButton']);
		}

		private function get hareAvailable():Boolean
		{
			return !Locations.currentLocation.nonHare && Boolean(Locations.MODES[this.modeId]['hareButton']);
		}

		private function get dragonAvailable():Boolean
		{
			return Boolean(Locations.MODES[this.modeId]['dragonButton']);
		}

		private function toggleShamanButton(value:Boolean):void
		{
			if (!FlagsManager.has(Flag.SHAMAN_SCHOOL_FINISH) && !this.statusCertificate)
				this.statusCertificate = new Status(this.shamanImage, gls("<body><b>Недоступно</b><br/>Сначала пройди «Школу Шаманов» - нельзя становиться Шаманом без должного обучения<br/>«Школа Шаманов» находится на экране Планеты</body>"), false, true);
			else if (FlagsManager.has(Flag.SHAMAN_SCHOOL_FINISH) && this.statusCertificate)
			{
				this.statusCertificate.remove();
				this.statusCertificate = null;
			}

			if (!this.statusCertificate && !this.statusNewbie && Experience.selfLevel < Game.LEVEL_TO_OPEN_SHAMAN)
				this.statusNewbie = new Status(this.shamanImage, gls("<body><b>Недоступно</b><br/>На Солнечной Долине белки ниже {0} уровня не могут купить место Шамана</body>", Game.LEVEL_TO_OPEN_SHAMAN), false, true);
			else if (this.statusNewbie)
			{
				this.statusNewbie.remove();
				this.statusNewbie = null;
			}

			shaman = value;
		}

		private function onBonus(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.SHAMAN_BRANCH)
				return;
			this.shamanAcornButton.visible = false;
			this.shamanCoinsButton.visible = false;
			this.shamanFreeButton.visible = true;
		}

		private function onBonusEnd(e:DiscountEvent):void
		{
			if (e.id != DiscountManager.SHAMAN_BRANCH)
				return;
			this.shamanAcornButton.visible = true;
			this.shamanCoinsButton.visible = true;
			this.shamanFreeButton.visible = false;
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoomRound.PACKET_ID:
					var round: PacketRoomRound = packet as PacketRoomRound;

					this.modeId = Locations.getGameMode(round.mode > 0 ? round.mode : this.modeId);

					switch (round.type)
					{
						case PacketServer.ROUND_STARTING:
							this.statusField = gls("Кем ты будешь играть?");
							toggleButtons(ScreenGame.cheaterId == 0);
							break;
						case PacketServer.ROUND_PLAYING:
						case PacketServer.ROUND_START:
						case PacketServer.ROUND_RESULTS:
							toggleButtons(false);
							break;
					}
					break;
				case PacketBuy.PACKET_ID:
					var buy: PacketBuy = packet as PacketBuy;

					if (buy.goodId != PacketClient.BUY_SHAMAN && buy.goodId != PacketClient.BUY_HARE && buy.goodId != PacketClient.BUY_DRAGON)
						return;
					if (!this.visible)
						return;
					switch (buy.status)
					{
						case PacketServer.BUY_FAIL:
							switch (buy.goodId)
							{
								case PacketClient.BUY_SHAMAN:
									this.statusField = gls("Место Шамана уже занято!");
									break;
								case PacketClient.BUY_HARE:
									this.statusField = gls("Место Зайца НеСудьбы уже занято!");
									break;
								case PacketClient.BUY_DRAGON:
									this.statusField = gls("Место Дракоши уже занято!");
									break;
							}
							break;
						case PacketServer.BUY_SUCCESS:
							switch (buy.goodId)
							{
								case PacketClient.BUY_SHAMAN:
									toggleButtons(false);
									this.shamanImage.filters = [];
									this.statusField = gls("Ты станешь Шаманом");
									break;
								case PacketClient.BUY_HARE:
									toggleButtons(false);
									this.hareImage.filters = [];
									this.statusField = gls("Ты станешь Зайцем НеСудьбы");
									break;
								case PacketClient.BUY_DRAGON:
									toggleButtons(false);
									this.dragonImage.filters = [];
									this.statusField = gls("Ты станешь Дракошей");
									break;
							}
							break;
					}
					break;
				case PacketDiscountUse.PACKET_ID:
					var discUse: PacketDiscountUse = packet as PacketDiscountUse;

					if (discUse.discount != DiscountManager.freeShaman)
						return;
					if (discUse.data == 0)
						this.statusField = gls("Ты станешь Шаманом");
					else
						this.statusField = gls("Место Шамана уже занято!");
					break;
			}
		}
	}
}