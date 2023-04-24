package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;

	import dialogs.Dialog;
	import dialogs.DialogHolidayLottery;
	import dialogs.DialogHolidayTicket;
	import events.GameEvent;
	import loaders.RuntimeLoader;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBonuses;
	import protocol.packages.server.PacketHolidayBalance;
	import protocol.packages.server.PacketHolidayLottery;
	import protocol.packages.server.structs.PacketDeferredBonusItems;

	import utils.DateUtil;

	public class HolidayManager
	{
		static private const HOLIDAY_END:int = 0;//1464652800;

		static public const SPIN_PRICE:int = 10;

		static public const TICKETS_TO_PACKAGE:int = 5;

		static public const MAX_TICKETS:int = 20;

		static public const CLOTHES:Array = [133, 134, 135, 13];

		static public const CLOTHES_NAME:Array = [gls("Фермера"), gls("Харлока"), gls("Миньона"), gls("Чешира")];

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var _tickets:int = -1;
		static private var _elements:int = -1;
		static private var _rating:int = -1;

		static private var current_bonus:PacketDeferredBonusItems = null;

		static private var _images:Array = null;
		static private var _currentClothes:int = NaN;

		static private var dialogLottery:Dialog = null;
		static private var dialogTicket:DialogHolidayTicket = null;

		static private var sended:Boolean = false;

		static public function init():void
		{
			Connection.listen(onPacket, [PacketHolidayBalance.PACKET_ID, PacketHolidayLottery.PACKET_ID, PacketBonuses.PACKET_ID]);
			DeferredBonusManager.addEventListener(GameEvent.DEFERRED_BONUS_UPDATE, onDeferredBonus);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function get boosterAllow():Boolean
		{
			return false;
			//return (Game.unix_time - Game.paymentTime) >= (30 * 24 * 60 * 60);
		}

		static public function get isHolidayEnd():Boolean
		{
			var timeLeft:int = HOLIDAY_END - Game.unix_time - int(getTimer() / 1000);
			return timeLeft <= 0;
		}

		static public function get isShowTimer():Boolean
		{
			var timeLeft:int = HOLIDAY_END - Game.unix_time - int(getTimer() / 1000);
			return timeLeft <= 24 * 60 * 60;
		}

		static public function get timeLeftString():String
		{
			//Не менять текст - иначе не влезает в дизайн окна
			var timeLeft:int = HOLIDAY_END - Game.unix_time - int(getTimer() / 1000);
			if (timeLeft <= 0)
				return gls("окончен");
			return DateUtil.durationDayTime(timeLeft);
		}

		static public function get holidayName():String
		{
			return gls("Озеленение");
		}

		static public function get ratingName():String
		{
			return gls("Рейтинг озеленения");
		}

		static public function get elementsBankName():String
		{
			return gls("семена");
		}

		static public function get bundleManager():String
		{
			return gls("семян");
		}

		static public function get description():String
		{
			return gls("Собирай семена и получай призы!");
		}

		static public function get ratingCaption():String
		{
			return gls("Очки рейтинга Весны");
		}

		static public function get faqDescription():String
		{
			return gls("Собирай семена на локациях, крути рулетку и получай призы! Если тебе не везёт в сборе семян - просто докупи их в банке");
		}

		static public function get balanceDescription():String
		{
			return gls("Семена для участия в Рейтинге Озеленения! Собирай их на локациях или приобретай в банке!");
		}

		static public function get elementEventName():String
		{
			return gls("Семена");
		}

		static public function get ratingText():String
		{
			return gls("Чтобы заработать очки рейтинга Весны, нужно собирать угощения на локации.\nА также можно выиграть очки рейтинга Весны в Весенней рулетке");
		}

		static public function get elementEventDescription():String
		{
			return gls("Тебе удалось добыть семена для озеленения!");
		}

		static public function get images():Array
		{
			if (_images == null)
				_images = [HolidayItemImage0, HolidayItemImage1, HolidayItemImage2, HolidayItemImage3, HolidayItemImage4];
			return _images;
		}

		static public function showLottery(e:MouseEvent = null):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK, true);

			RuntimeLoader.load(function():void
			{
				if (!dialogLottery)
					dialogLottery = new DialogHolidayLottery();
				dialogLottery.show();
			});
		}

		static public function spinLottery():void
		{
			if (sended)
				return;
			if (!haveElements)
				return;
			sended = true;
			Connection.sendData(PacketClient.HOLIDAY_LOTTERY);
		}

		static public function get haveElements():Boolean
		{
			return elements >= SPIN_PRICE;
		}

		static private function onDeferredBonus(e:GameEvent):void
		{
			DeferredBonusManager.removeEventListener(GameEvent.DEFERRED_BONUS_UPDATE, onDeferredBonus);
			receiveBonus();
		}

		static public function receiveBonus():void
		{
			var bonuses:Vector.<PacketDeferredBonusItems> = DeferredBonusManager.getByReason(PacketServer.REASON_HOLIDAY_LOTTERY);

			for (var i:int = 0; i < bonuses.length; i++)
				DeferredBonusManager.receiveBonus(bonuses[i].id);
		}

		static public function setSelfDelta(delta:int):void
		{
			dispatcher.dispatchEvent(new GameEvent(GameEvent.PLACE_CHANGED, {'value': delta}));
		}

		static public function get tickets():int
		{
			return Math.max(_tickets, 0);
		}

		static public function set tickets(value:int):void
		{
			if (tickets == value)
				return;

			if (_tickets != -1 && (value%TICKETS_TO_PACKAGE == 0))
				RuntimeLoader.load(function():void
				{
					if(!dialogTicket)
						dialogTicket = new DialogHolidayTicket();
					dialogTicket.show();
					dialogTicket.onClothesChange(currentClothes);
				}, true);

			_tickets = value;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.HOLIDAY_TICKETS));
		}

		static public function get elements():int
		{
			return Math.max(_elements, 0);
		}

		static public function set elements(value:int):void
		{
			if (elements == value)
				return;
			_elements = value;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.HOLIDAY_ELEMENTS));
		}

		static public function get rating():int
		{
			return Math.max(_rating, 0);
		}

		static public function set rating(value:int):void
		{
			if (rating == value)
				return;
			_rating = value;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.HOLIDAY_RATINGS, {'value': value}));
		}

		static public function get currentBonus():PacketDeferredBonusItems
		{
			return current_bonus;
		}

		static public function get currentClothesPackageID():int
		{
			return CLOTHES[currentClothes];
		}

		static public function get currentClothes():int
		{
			return _currentClothes;
		}

		static public function set currentClothes(value:int):void
		{
			if(_currentClothes == value)
				return;
			_currentClothes = value;
			dispatcher.dispatchEvent(new GameEvent(GameEvent.HOLIDAY_CLOTHES));
		}

		static private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketHolidayBalance.PACKET_ID:
					tickets = (packet as PacketHolidayBalance).tickets;
					elements = (packet as PacketHolidayBalance).elements;
					rating = (packet as PacketHolidayBalance).rating;
					currentClothes = tickets >= MAX_TICKETS ? 3 : int(tickets/TICKETS_TO_PACKAGE);
					break;
				case PacketHolidayLottery.PACKET_ID:
					sended = false;
					if ((packet as PacketHolidayLottery).deferredBonusId == 0)
						return;
					current_bonus = DeferredBonusManager.getById((packet as PacketHolidayLottery).deferredBonusId);
					if (current_bonus == null)
						return;
					dispatcher.dispatchEvent(new GameEvent(GameEvent.HOLIDAY_LOTTERY));
					break;
				case PacketBonuses.PACKET_ID:
					if ((packet as PacketBonuses).awardReason != PacketServer.REASON_HOLIDAY_TICKETS)
						return;
					var collections:Vector.<int> = (packet as PacketBonuses).collections;
					for (var i:int = 0; i < collections.length; i++)
						CollectionManager.incItem(CollectionsData.TYPE_REGULAR, (collections[i] + 256) % 256, 1);
					break;
			}
		}
	}
}