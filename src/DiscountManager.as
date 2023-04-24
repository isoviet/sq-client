package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;

	import dialogs.DialogPackageTemp;
	import events.DiscountEvent;
	import footers.FooterGame;
	import game.gameData.GameConfig;
	import game.mainGame.entity.simple.Balk;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.Box;
	import game.mainGame.entity.simple.PoiseRight;
	import game.mainGame.entity.simple.PortalBlue;
	import game.mainGame.entity.simple.PortalRed;
	import game.mainGame.entity.simple.Trampoline;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBirthday;
	import protocol.packages.server.PacketBuy;
	import protocol.packages.server.PacketDiscountBonus;
	import protocol.packages.server.PacketDiscountClothes;
	import protocol.packages.server.PacketDiscountUse;
	import protocol.packages.server.structs.PacketLoginDiscounts;

	import utils.StringUtil;

	public class DiscountManager extends Sprite
	{
		static public const COLLECTIONS:int = 2;
		static public const DOUBLE_MANA:int = 3;
		static public const SMILES:int = 6;
		static public const SHAMAN_ITEMS_PACK:int = 7;
		static public const LOCATIONS:int = 9;
		static public const DOUBLE_COINS_SMALL:int = 10;
		static public const FREE_MANA:int = 18;
		static public const COLLECTIONS_NP:int = 21;
		static public const DOUBLE_COINS_ALL_NP:int = 22;
		static public const DOUBLE_MANA_NP:int = 23;
		static public const FREE_MANA_NP:int = 25;
		static public const FREE_SHAMAN_ITEMS_NP:int = 27;
		static public const LOCATIONS_NP:int = 28;
		static public const SHAMAN_ITEMS_PACK_NP:int = 29;
		static public const SMILES_NP:int = 40;
		static public const SHAMAN_BRANCH:int = 43;
		static public const SHAMAN_SKILL:int = 44;
		static public const DECORATION:int = 45;

		static public const DISCOUNT_COLLECTIONS:Number = 0.8;
		static public const DISCOUNT_COLLECTIONS_NP:Number = 0.5;
		static public const DISCOUNT_CLOTHES_ONE:Number = 0.8;
		static public const DISCOUNT_CLOTHES_ONE_NP:Number = 0.6;
		static public const DISCOUNT_CLOTHES_PACK:Number = 0.5;
		static public const DISCOUNT_CLOTHES_PACKAGE:Number = 0.85;
		static public const DISCOUNT_CLOTHES_PACKAGE_NP:Number = 0.7;
		static public const DISCOUNT_CLAN_AND_NAME:Number = 0.5;
		static public const DISCOUNT_SUBSCRIBE_SMALL:Number = 0.8;
		static public const DISCOUNT_SUBSCRIBE_BIG:Number = 0.8;
		static public const DISCOUNT_SUBSCRIBE_BIG_NP:Number = 0.25;
		static public const DISCOUNT_SMILES:Number = 0.7;
		static public const DISCOUNT_SMILES_NP:Number = 0.4;
		static public const DISCOUNT_VIP_DAY_NP:Number = 0.6;
		static public const DISCOUNT_VIP_WEEK_NP:Number = 0.5;
		static public const DISCOUNT_VIP_MONTH:Number = 0.5;
		static public const DISCOUNT_VIP_MONTH_NP:Number = 0.33;
		static public const DISCOUNT_VIP_MONTH_SUPER:Number = 0.8;
		static public const DISCOUNT_SHAMAN_SKILL:Number = 0.8;

		static public const CLOTHES_PACK_COUNT:int = 8;
		static public const DOUBLE_COINS_ALL_COUNT:int = 60;

		static public const COST_RESPAWN_PACK:int = 25;
		static public const COST_RESPAWN_PACK_NP:int = 1;
		static public const COST_SHAMAN_ITEMS_PACK:int = 28;
		static public const COST_SHAMAN_ITEMS_PACK_NP:int = 10;
		static public const COST_DOUBLE_MANA:int = 30;

		static public const PAYMENT_IDS:Array = [[FREE_MANA_NP, LOCATIONS_NP, FREE_SHAMAN_ITEMS_NP, DOUBLE_COINS_ALL_NP],
							[LOCATIONS, DOUBLE_COINS_SMALL],
							[FREE_MANA]];

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var discounts:Object = {};
		static private var discount_bonus:Object = {};

		static private var TEXTS:Object = null;

		static public var discount_clothes: Vector.<int> = null;
		static public var discount_package:int = -1;

		static public function init(data: Vector.<PacketLoginDiscounts>):void
		{
			for (var i:int = 0; i < data.length; i++)
			{
				discounts[data[i].type] = data[i].time;
				dispatcher.dispatchEvent(new DiscountEvent(data[i].type));
			}

			if (data.length > 0)
				EnterFrameManager.addPerSecondTimer(onTimer);

			Connection.listen(onPacket, [PacketBuy.PACKET_ID, PacketDiscountBonus.PACKET_ID,
				PacketDiscountClothes.PACKET_ID, PacketDiscountUse.PACKET_ID, PacketBirthday.PACKET_ID]);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function dispatchEvent(event:Event):void
		{
			dispatcher.dispatchEvent(event);
		}

		static public function get ids():Array
		{
			var answer:Array = [];

			for (var discount:String in discounts)
				answer.push(int(discount));
			return answer;
		}

		static public function getTime(id:int):int
		{
			if (id in discounts)
				return discounts[id];
			return 0;
		}

		static public function getButtonClass(id:int):Class
		{
			return getDefinitionByName("DiscountButton" + id) as Class;
		}

		static public function getImageClass(id:int):Class
		{
			return getDefinitionByName("DiscountImg" + (id + 1)) as Class;
		}

		static public function update():void
		{
			for (var discount:String in discounts)
			{
				if (discounts[discount] == 0)
					continue;
				dispatcher.dispatchEvent(new DiscountEvent(int(discount)));
			}
		}

		static public function get haveDiscounts():Boolean
		{
			for (var discount:String in discounts)
			{
				if (discount) {}
				return true;
			}
			return false;
		}

		static public function haveDiscount(id:int):Boolean
		{
			if (id in discounts)
				return discounts[id] != 0;
			return false;
		}

		static public function haveBonus(id:*, checkTime:Boolean = true):Boolean
		{
			if (id is int)
				return id in DiscountManager.discount_bonus && (!checkTime || (DiscountManager.discount_bonus[id] > 0));
			if (id is Array)
				for (var i:int = 0; i < (id as Array).length; i++)
					return id[i] in DiscountManager.discount_bonus && (!checkTime || (DiscountManager.discount_bonus[id[i]] > 0));
			return false;
		}

		static public function haveDouble(value:int = int.MAX_VALUE):Boolean
		{
			if (haveDiscount(DOUBLE_COINS_SMALL) || haveDiscount(DOUBLE_COINS_ALL_NP))
				return DOUBLE_COINS_ALL_COUNT >= value;
			return false;
		}

		static public function get freeContent():Boolean
		{
			return haveBonus([LOCATIONS, LOCATIONS_NP], false);
		}

		static public function get freeMana():Boolean
		{
			return haveBonus(FREE_MANA_NP);
		}

		static public function get freeShaman():int
		{
			if (haveBonus(SHAMAN_BRANCH))
				return SHAMAN_BRANCH;
			return -1;
		}

		static public function get freeShamanReset():Boolean
		{
			return haveBonus(SHAMAN_SKILL);
		}

		static public function get freePerkCast():Boolean
		{
			return haveBonus(DOUBLE_MANA);
		}

		static public function freeItems(value:Vector.<int>): Vector.<int>
		{
			var bonus:int = 0;
			if (haveBonus(FREE_SHAMAN_ITEMS_NP))
				bonus = 2;
			if (bonus == 0)
				return value;
			var items:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < value.length && i < CastItemsData.itemsCount; i++)
				items.push(GameConfig.getItemCoinsPrice(i) == 0 ? 0 : (value[i] + bonus));
			return items;
		}

		static public function get textBonuses():String
		{
			if (!TEXTS)
			{
				TEXTS = {};
				TEXTS[LOCATIONS] = 		gls("Доступ на все локации: ");
				TEXTS[LOCATIONS_NP] = 		gls("Доступ на все локации: ");
				TEXTS[FREE_SHAMAN_ITEMS_NP] = 	gls("Предметы шамана: ");
				TEXTS[FREE_MANA] = 		gls("Регенерация маны: ");
				TEXTS[FREE_MANA_NP] = 		gls("Бесконечная мана: ");
				TEXTS[DOUBLE_MANA] = 		gls("Бесплатная магия: ");
				TEXTS[SHAMAN_BRANCH] = 		gls("Бесплатный шаман: ");
				TEXTS[SHAMAN_SKILL] = 		gls("Бесплатный сброс навыков: ");
				TEXTS[SHAMAN_ITEMS_PACK] = 	gls("Мана за шаманские предметы: ");
			}

			var answer:String = "";
			for (var bonus:String in discount_bonus)
			{
				if (discount_bonus[bonus] == 0)
					continue;
				answer += (answer == "" ? "" : "\n") + TEXTS[bonus] + "<b>" + StringUtil.formatDate(discount_bonus[bonus], true) + "</b>";
			}
			return answer;
		}

		static public function onPayment():void
		{
			for (var i:int = 0; i < DiscountManager.PAYMENT_IDS.length; i++)
				for (var discount:int = 0; discount < DiscountManager.PAYMENT_IDS[i].length; discount++)
					removeDiscount(DiscountManager.PAYMENT_IDS[i][discount]);
		}

		static private function onTimer():void
		{
			var allStop:Boolean = true;
			for (var discount:String in discounts)
			{
				if (discounts[discount] == 0)
					continue;
				discounts[discount]--;
				allStop = false;
				if (discounts[discount] == 0)
					dispatcher.dispatchEvent(new DiscountEvent(int(discount), false));
			}

			for (var bonus:String in discount_bonus)
			{
				if (discount_bonus[bonus] == 0)
					continue;
				discount_bonus[bonus]--;
				allStop = false;
			}

			if (allStop)
				EnterFrameManager.removePerSecondTimer(onTimer);
			else
				dispatcher.dispatchEvent(new Event(Event.CHANGE));
		}

		static private function onPacket(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketDiscountUse.PACKET_ID:
					var discount: PacketDiscountUse = packet as PacketDiscountUse;

					switch (discount.discount)
					{
						case DECORATION:
							new DialogPackageTemp(discount.data).show();
							break;
					}
					break;
				case PacketDiscountClothes.PACKET_ID:
					discount_clothes = (packet as PacketDiscountClothes).clothes;

					//DialogShop.needToRefresh();
					break;
				case PacketDiscountBonus.PACKET_ID:
					var discountBonus: PacketDiscountBonus = packet as PacketDiscountBonus;

					if (discountBonus.resetPayment > 0)
						onPayment();

					if (discountBonus.bonuses.length == 0)
						return;

					for (var i:int = 0; i < discountBonus.bonuses.length; i++)
					{
						discount_bonus[discountBonus.bonuses[i].bonus] = discountBonus.bonuses[i].time;
						dispatcher.dispatchEvent(new DiscountEvent(discountBonus.bonuses[i].bonus, true, true));
					}
					EnterFrameManager.addPerSecondTimer(onTimer);
					break;
				case PacketBuy.PACKET_ID:
					var buy: PacketBuy = packet as PacketBuy;

					if (buy.targetId != Game.selfId || buy.status != PacketServer.BUY_SUCCESS)
						return;

					switch (buy.goodId)
					{
						case PacketClient.BUY_MANA_BIG:
							removeDiscount(DOUBLE_MANA_NP);
							break;
						case PacketClient.BUY_MISC:
							if (buy.data != 0)
								return;
							removeDiscount(SMILES);
							removeDiscount(SMILES_NP);
							break;
						case PacketClient.BUY_DISCOUNT:
							removeDiscount(buy.data);
							switch (buy.data)
							{
								case SHAMAN_ITEMS_PACK:
									var items:Array = [CastItemsData.getId(Balk), 10, CastItemsData.getId(Box), 10, CastItemsData.getId(BalloonBody), 5, CastItemsData.getId(PoiseRight), 5, CastItemsData.getId(Trampoline), 5, CastItemsData.getId(PortalRed), 5, CastItemsData.getId(PortalBlue), 5];
									break;
								case SHAMAN_ITEMS_PACK_NP:
									items = [CastItemsData.getId(BalloonBody), 5, CastItemsData.getId(Trampoline), 5, CastItemsData.getId(PortalRed), 5, CastItemsData.getId(PortalBlue), 5];
									break;
								default:
									return;
							}
							for (i = 0; i < items.length; i += 2)
							{
								Game.selfCastItems[items[i]] += items[i + 1];
								//DialogShop.onCastItemAdd(items[i]);
							}
							FooterGame.updateCastItems(items);
							break;
						case PacketClient.BUY_SHAMAN_BRANCH:
							removeDiscount(SHAMAN_BRANCH);
							break;
					}
					break;
			}
		}

		static private function removeDiscount(id:int):void
		{
			if (!(id in discounts))
				return;
			discounts[id] = 0;
			dispatcher.dispatchEvent(new DiscountEvent(id, false));
		}
	}
}