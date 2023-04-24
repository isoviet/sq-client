package game.gameData
{
	import flash.events.EventDispatcher;

	import dialogs.DialogBundleOffer;
	import events.GameEvent;
	import footers.FooterGame;
	import game.mainGame.entity.simple.BalloonBody;
	import loaders.RuntimeLoader;
	import screens.Screens;
	import sounds.GameSounds;
	import views.issuance.BundleAnimation;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketBundles;

	public class BundleManager
	{
		static public const HOLIDAY_BOOSTER_TIME:int = 1462147200;

		static public const WOODEN:int = 16;
		static public const SILVER:int = 17;
		static public const GOLDEN:int = 18;
		static public const NEWBIE_RICH:int = 23;
		static public const NEWBIE_POOR:int = 24;
		static public const LEGENDARY:int = 5;
		static public const WIZARD:int = 6;
		static public const COLLECTION:int = 7;
		static public const VETERAN:int = 19;
		static public const CARRIER:int = 9;

		static public const HOLIDAY_100:int = 10;
		static public const HOLIDAY_500:int = 11;
		static public const HOLIDAY_1000:int = 12;
		static public const HOLIDAY_1500:int = 13;
		static public const HOLIDAY_2000:int = 14;

		static public const CLOSEOUT:int = 15;

		static public const AMUR:int = 20;
		static public const AMUR_PACK:int = 21;
		static public const HOLIDAY_BOOSTER:int = 22;

		static public const GOLDEN_CUP:int = int.MAX_VALUE;
		static public const HOT_WEEKEND:int = int.MAX_VALUE - 2;

		//---OFFER_ID
		static public const WOODEN_OFFER:int = 119;//100
		static public const SILVER_OFFER:int = 120;//101
		static public const GOLDEN_OFFER:int = 121;//102
		static public const NEWBIE_RICH_OFFER:int = 125;//103
		static public const NEWBIE_POOR_OFFER:int = 126;//104
		static public const LEGENDARY_OFFER:int = 105;
		static public const WIZARD_OFFER:int = 106;
		static public const COLLECTION_OFFER:int = 107;
		static public const VETERAN_OFFER:int = 122;//108
		static public const CARRIER_OFFER:int = 109;

		static public const GOLDEN_CUP_OFFER:int = 4;
		static public const HOT_WEEKEND_OFFER:int = 5;

		static public const HOLIDAY_BOOSTER_OFFER:int = 113;

		static public const HOLIDAY_100_OFFER:int = 114;
		static public const HOLIDAY_500_OFFER:int = 115;
		static public const HOLIDAY_1000_OFFER:int = 116;
		static public const HOLIDAY_1500_OFFER:int = 117;
		static public const HOLIDAY_2000_OFFER:int = 118;

		static public const AMUR_OFFER:int = 123;
		static public const AMUR_PACK_OFFER:int = 124;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var _ids:Array = [WOODEN, SILVER, GOLDEN, VETERAN];
		static private var _bundles:Object = {};
		static private var _prices:Object = null;
		static private var _discounts:Object = null;

		static private function initPrices():void
		{
			_prices = {};
			_prices[WOODEN] = Config.isRus ? 21 : 0.99;
			_prices[SILVER] = Config.isRus ? 98 : 2.99;
			_prices[GOLDEN] = Config.isRus ? 294 : 9.99;
			_prices[NEWBIE_RICH] = Config.isRus ? 98 : 2.99;
			_prices[NEWBIE_POOR] = Config.isRus ? 21 : 0.99;
			_prices[LEGENDARY] = Config.isRus ? 994 : 29.99;
			_prices[WIZARD] = Config.isRus ? 98 : 2.99;
			_prices[COLLECTION] = Config.isRus ? 126 : 3.99;
			_prices[VETERAN] = Config.isRus ? 98 : 2.99;
			_prices[CARRIER] = Config.isRus ? 294 : 8.99;

			_prices[HOLIDAY_100] = Config.isRus ? 49 : 0.99;
			_prices[HOLIDAY_500] = Config.isRus ? 196 : 2.99;
			_prices[HOLIDAY_1000] = Config.isRus ? 350 : 4.99;
			_prices[HOLIDAY_1500] = Config.isRus ? 497 : 6.99;
			_prices[HOLIDAY_2000] = Config.isRus ? 595 : 8.99;

			_prices[GOLDEN_CUP] = Config.isRus ? 168 : 5.99;
			_prices[HOLIDAY_BOOSTER] = Config.isRus ? 14 : 0.99;
			_prices[AMUR] = Config.isRus ? 7 : 0.49;
			_prices[AMUR_PACK] = Config.isRus ? 49 : 3.49;

			_prices[HOT_WEEKEND] = Config.isRus ? 28 : 0.99;
		}

		static private function initDiscounts():void
		{
			_discounts = {};
			_discounts[WOODEN] = 120;
			_discounts[SILVER] = 150;
			_discounts[GOLDEN] = 250;
			_discounts[NEWBIE_RICH] = 500;
			_discounts[NEWBIE_POOR] = 1000;
			_discounts[LEGENDARY] = 500;
			_discounts[WIZARD] = 300;
			_discounts[COLLECTION] = 300;
			_discounts[VETERAN] = 180;
			_discounts[CARRIER] = 250;

			_discounts[HOLIDAY_100] = 0;
			_discounts[HOLIDAY_500] = 0;
			_discounts[HOLIDAY_1000] = 0;
			_discounts[HOLIDAY_1500] = 0;
			_discounts[HOLIDAY_2000] = 0;

			_discounts[GOLDEN_CUP] = 300;
			_discounts[HOLIDAY_BOOSTER] = 500;
			_discounts[AMUR] = 0;
			_discounts[AMUR_PACK] = 0;
			_discounts[HOT_WEEKEND] = 0;
		}

		static private function initModels():void
		{
			//--------------WOODEN
			var listInsides: Vector.<BundleInsidesInfo> = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetCoins, gls("{0} монет", 20)));
			listInsides.push(new BundleInsidesInfo(ImageGetEnergy, gls("{0} энергии", 250)));
			_bundles[WOODEN] = new BundleModel(WOODEN, WOODEN_OFFER, gls("Деревянный сундук"), _prices[WOODEN],
				_discounts[WOODEN], "bundle_wooden_2016_01_12", "ImageBundleWooden", "MovieBundleWooden",
				listInsides);

			//--------------SILVER
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetCoins, gls("{0} монет", 80)));
			listInsides.push(new BundleInsidesInfo(ImageGetPowers, gls("{0} энергии\n{1} маны", 250, 250)));
			listInsides.push(new BundleInsidesInfo(ImageGetCollections, gls("{0} элементов коллекций", 5)));
			_bundles[SILVER] = new BundleModel(SILVER, SILVER_OFFER, gls("Серебряный сундук"), _prices[SILVER],
				_discounts[SILVER], "bundle_silver_2016_01_12", "ImageBundleSilver", "MovieBundleSilver",
				listInsides);

			//--------------GOLDEN
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetCoins, gls("{0} монет", 250)));
			listInsides.push(new BundleInsidesInfo(ImageGetPowers, gls("{0} энергии\n{1} маны", 1000, 1000)));
			listInsides.push(new BundleInsidesInfo(ImageGetCollections, gls("{0} элементов коллекций", 15)));
			listInsides.push(new BundleInsidesInfo(ImageGetManaRegenDrink, gls("Зелье Могущества\nна {0} дней", 7)));
			_bundles[GOLDEN] = new BundleModel(GOLDEN, GOLDEN_OFFER, gls("Золотой сундук"), _prices[GOLDEN],
				_discounts[GOLDEN], "bundle_golden_2016_01_12", "ImageBundleGolden", "MovieBundleGolden", listInsides);

			//--------------NEWBIE_RICH
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetCoins, gls("{0} монет", 75)));
			listInsides.push(new BundleInsidesInfo(ImageGetEnergy, gls("{0} энергии", 500)));
			listInsides.push(new BundleInsidesInfo(ImageGetMana, gls("{0} маны", 800)));
			listInsides.push(new BundleInsidesInfo(ImageGetPackage, gls("Случайный костюм")));
			_bundles[NEWBIE_RICH] = new BundleModel(NEWBIE_RICH, NEWBIE_RICH_OFFER, gls("Сундук Начинающего"),
				_prices[NEWBIE_RICH], _discounts[NEWBIE_RICH], "bundle_newbie_rich_2016_05_06",
				"ImageBundleNewbieRich", "MovieBundleNewbieRich", listInsides);

			//--------------NEWBIE_POOR
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetCoins, gls("{0} монет", 20)));
			listInsides.push(new BundleInsidesInfo(ImageGetEnergy, gls("{0} энергии", 250)));
			listInsides.push(new BundleInsidesInfo(ImageGetMana, gls("{0} маны", 400)));
			listInsides.push(new BundleInsidesInfo(ImageGetPackage, gls("Случайный костюм")));
			_bundles[NEWBIE_POOR] = new BundleModel(NEWBIE_POOR, NEWBIE_POOR_OFFER, gls("Сундук Новичка"),
				_prices[NEWBIE_POOR], _discounts[NEWBIE_POOR], "bundle_newbie_poor_2016_05_06",
				"ImageBundleNewbiePoor", "MovieBundleNewbiePoor", listInsides);

			//--------------LEGENDARY
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetPackageVendigo, gls("Костюм Вендиго\nна {0} дней", 30)));
			listInsides.push(new BundleInsidesInfo(ImageGetPackageVampire, gls("Костюм Вампира\nна {0} дней", 30)));
			listInsides.push(new BundleInsidesInfo(ImageGetPackageWolf, gls("Костюм Снежного Волка\nна {0} дней", 30)));
			_bundles[LEGENDARY] = new BundleModel(LEGENDARY, LEGENDARY_OFFER, gls("Легендарный Сундук"), _prices[LEGENDARY],
				_discounts[LEGENDARY], "bundle_legendary_2015_10_15", "ImageBundleLegendary",
				"MovieBundleLegendary", listInsides);

			//--------------WIZARD
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetMana, gls("{0} маны", 300)));
			listInsides.push(new BundleInsidesInfo(ImageGetManaRegenDrink, gls("Зелье Могущества\nна {0} дней", 7)));
			listInsides.push(new BundleInsidesInfo(ImageGetPackageWizard, gls("Костюмы волшебников\nна {0} дней", 7)));
			_bundles[WIZARD] = new BundleModel(WIZARD, WIZARD_OFFER, gls("Сундук Волшебника"), _prices[WIZARD],
				_discounts[WIZARD], "bundle_wizard_2015_10_15", "ImageBundleWizard", "MovieBundleWizard",
				listInsides);

			//-------------COLLECTION
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetCollectionsRare, gls("{0} редких элементов коллекций", 15)));
			_bundles[COLLECTION] = new BundleModel(COLLECTION, COLLECTION_OFFER, gls("Сундук Коллекций"), _prices[COLLECTION],
				_discounts[COLLECTION], "bundle_collection_2015_10_15", "ImageBundleCollection",
				"MovieBundleCollection", listInsides);

			//---------------------VETERAN
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetEnergy, gls("{0} энергии", 5000)));
			listInsides.push(new BundleInsidesInfo(ImageGetItemsPack, gls("{0} предметов шамана каждого типа", 15)));
			_bundles[VETERAN] = new BundleModel(VETERAN, VETERAN_OFFER, gls("Сундук Ветерана"), _prices[VETERAN],
				_discounts[VETERAN], "bundle_veteran_2016_01_12", "ImageBundleVeteran",
				"MovieBundleVeteran", listInsides);

			//--------------------CARRIER
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetVip, gls("VIP-статус\nна {0} дней", 7)));
			listInsides.push(new BundleInsidesInfo(ImageGetExp, gls("{0} опыта", "100.000")));
			listInsides.push(new BundleInsidesInfo(ImageGetBalloon, gls("{0} шариков", 50)));
			_bundles[CARRIER] = new BundleModel(CARRIER, CARRIER_OFFER, gls("Сундук Карьериста"), _prices[CARRIER],
				_discounts[CARRIER], "bundle_carrier_2015_10_15", "ImageBundleCarrier",
				"MovieBundleCarrier", listInsides);

			//----------HOLIDAY_100----
			_bundles[HOLIDAY_100] = new BundleModel(HOLIDAY_100, HOLIDAY_100_OFFER, HolidayManager.elementEventName,
				_prices[HOLIDAY_100], _discounts[HOLIDAY_100], "bundle_holiday_100_elements_2016_04_25",
				"ImageMovieBonus", "MovieBonus", null);

			//----------HOLIDAY_500----
			_bundles[HOLIDAY_500] = new BundleModel(HOLIDAY_500, HOLIDAY_500_OFFER, HolidayManager.elementEventName,
				_prices[HOLIDAY_500], _discounts[HOLIDAY_500], "bundle_holiday_500_elements_2016_04_25",
				"ImageMovieBonus", "MovieBonus", null);

			//----------HOLIDAY_1000----
			_bundles[HOLIDAY_1000] = new BundleModel(HOLIDAY_1000, HOLIDAY_1000_OFFER,  HolidayManager.elementEventName,
				_prices[HOLIDAY_1000], _discounts[HOLIDAY_1000], "bundle_holiday_1000_elements_2016_04_25",
				"ImageMovieBonus", "MovieBonus", null);

			//----------HOLIDAY_1500----
			_bundles[HOLIDAY_1500] = new BundleModel(HOLIDAY_1500, HOLIDAY_1500_OFFER,  HolidayManager.elementEventName,
				_prices[HOLIDAY_1500], _discounts[HOLIDAY_1500], "bundle_holiday_1500_elements_2016_04_25",
				"ImageMovieBonus", "MovieBonus", null);

			//----------HOLIDAY_2000----
			_bundles[HOLIDAY_2000] = new BundleModel(HOLIDAY_2000, HOLIDAY_2000_OFFER, HolidayManager.elementEventName,
				_prices[HOLIDAY_2000], _discounts[HOLIDAY_2000], "bundle_holiday_2000_elements_2016_04_25",
				"ImageMovieBonus", "MovieBonus", null);

			//----------GOLDEN_CUP----
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetCoins, gls("+{0} монет в день", ProduceManager.COUNT_GOLD_IN_TIME)));
			_bundles[GOLDEN_CUP] = new BundleModel(GOLDEN_CUP, GOLDEN_CUP_OFFER,  gls("Горшочек Лепрекона"),
				_prices[GOLDEN_CUP], _discounts[GOLDEN_CUP], "golden_cup_2015_11_03", "GoldenCupBundle",
				null, listInsides);

			//----------AMUR----
			_bundles[AMUR] = new BundleModel(AMUR, AMUR_OFFER,  gls("Валентинка"),
				_prices[AMUR], _discounts[AMUR], "amur_1_gift_2016_02_10", "",
				null, null);

			//----------AMUR----
			_bundles[AMUR_PACK] = new BundleModel(AMUR_PACK, AMUR_PACK_OFFER,  gls("10 Валентинок"),
				_prices[AMUR_PACK], _discounts[AMUR_PACK], "amur_10_gifts_2016_02_10", "",
				null, null);

			//----------BUNDLE_HOLIDAY_BOOSTER----
			listInsides = new Vector.<BundleInsidesInfo>();
			listInsides.push(new BundleInsidesInfo(ImageGetHolidayElements, gls("+{0} семян в день", ProduceManager.COUNT_HOLIDAY_IN_TIME)));
			_bundles[HOLIDAY_BOOSTER] = new BundleModel(HOLIDAY_BOOSTER, HOLIDAY_BOOSTER_OFFER,  gls("Горшочек плодородия"),
				_prices[HOLIDAY_BOOSTER], _discounts[HOLIDAY_BOOSTER], "bundle_holiday_booster_2016_04_25", "ImageHolidayBooster",
				null, listInsides);

			//----------HOT_WEEKEND----
			_bundles[HOT_WEEKEND] = new BundleModel(HOT_WEEKEND, HOT_WEEKEND_OFFER, HotWeekendManager.caption,
				_prices[HOT_WEEKEND], _discounts[HOT_WEEKEND], "hot_weekend_2016_04_02", "",
				null, null);
		}

		static public function init():void
		{
			initPrices();
			initDiscounts();
			initModels();

			Connection.listen(onPacket, [PacketBundles.PACKET_ID]);

			ExpirationsManager.addEventListener(GameEvent.EXPIRATIONS_CHANGE, onExpiration);
			Experience.addEventListener(GameEvent.LEVEL_CHANGED, onLevel);

			dispatcher.dispatchEvent(new GameEvent(GameEvent.BUNDLE_UPDATE));
		}

		public static function getBundleById(id:int): BundleModel
		{
			return _bundles[id];
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function onShow(id:int):void
		{
			if ((id == BundleManager.NEWBIE_POOR && ExpirationsManager.isNone(ExpirationsManager.BUNDLE_NEWBIE_POOR))
				|| (id == BundleManager.NEWBIE_RICH && ExpirationsManager.isNone(ExpirationsManager.BUNDLE_NEWBIE_RICH)))
				Connection.sendData(PacketClient.BUNDLE_NEWBIE_ACTIVATE);
		}

		static public function get ids():Array
		{
			return _ids;
		}

		static private function onLevel(e:GameEvent):void
		{
			if (e.data['value'] != Game.LEVEL_TO_NEWBIE_BUNDLE || (Experience.selfLevel >= Game.LEVEL_TO_NEWBIE_BUNDLE_END))
				return;
			add(NEWBIE_RICH);

			_ids.sort(sort);
			dispatcher.dispatchEvent(new GameEvent(GameEvent.BUNDLE_UPDATE));

			DialogBundleOffer.show(NEWBIE_RICH);
		}

		static private function onExpiration(e:GameEvent):void
		{
			var type:int = e.data['type'];
			var bundleType:int = -1;
			var available:Boolean = false;
			switch (type)
			{
				case ExpirationsManager.BUNDLE_NEWBIE_RICH:
					bundleType = NEWBIE_RICH;
					var level:Boolean = (Experience.selfLevel >= Game.LEVEL_TO_NEWBIE_BUNDLE) && (Experience.selfLevel <= Game.LEVEL_TO_NEWBIE_BUNDLE_END);
					available = level && (ExpirationsManager.haveExpiration(type) || ExpirationsManager.isNone(type));
					break;
				case ExpirationsManager.BUNDLE_NEWBIE_POOR:
					bundleType = NEWBIE_POOR;
					level = (Experience.selfLevel >= Game.LEVEL_TO_NEWBIE_BUNDLE) && (Experience.selfLevel <= Game.LEVEL_TO_NEWBIE_BUNDLE_END);
					available = level && (ExpirationsManager.haveExpiration(type) || ExpirationsManager.isNone(type)) && (_ids.indexOf(NEWBIE_RICH) == -1);
					break;
				case ExpirationsManager.BUNDLE_LEGENDARY:
					bundleType = LEGENDARY;
					available = false;//!ExpirationsManager.haveExpiration(type);
					break;
				default:
					return;
			}
			if (available)
				add(bundleType);
			if (!available)
				remove(bundleType);

			if (available && ExpirationsManager.isNone(type) && (bundleType == NEWBIE_RICH || bundleType == NEWBIE_POOR))
				DialogBundleOffer.show(bundleType);

			_ids.sort(sort);
			dispatcher.dispatchEvent(new GameEvent(GameEvent.BUNDLE_UPDATE));
		}

		static private function add(id:int):void
		{
			if (_ids.indexOf(id) != -1)
				return;
			_ids.push(id);
		}

		static private function remove(id:int):void
		{
			if (_ids.indexOf(id) == -1)
				return;
			_ids.splice(_ids.indexOf(id), 1);
		}

		static private function onPacket(packet:PacketBundles):void
		{
			GameSounds.play("buy", true);

			switch (packet.type)
			{
				case VETERAN:
					var array:Array = [];
					for (i = 0; i < CastItemsData.itemsCount; i++)
					{
						if (GameConfig.getItemCoinsPrice(i) == 0)
							continue;
						Game.selfCastItems[i] += 15;

						array.push(i, 15);
					}
					FooterGame.updateCastItems(array);
					break;
				case CARRIER:
					var id:int = CastItemsData.getId(BalloonBody);
					Game.selfCastItems[id] += 50;
					FooterGame.updateCastItems([id, 50]);
					break;
				case HOLIDAY_BOOSTER:
					ProduceManager.requestTime(ProduceManager.HOLIDAY);
					break;
			}

			var model:BundleModel = getBundleById(packet.type);
			if (!model || !model.haveAnimation)
				return;

			Screens.addCallback(function():void
			{
				RuntimeLoader.load(function():void
				{
					new BundleAnimation(packet.type, packet.collections, packet.packages);
				}, true);
			});

			var collections:Vector.<int> = packet.collections;
			for (var i:int = 0; i < collections.length; i++)
				CollectionManager.incItem(CollectionsData.TYPE_REGULAR, (collections[i] + 256) % 256, 1);
		}

		static private function sort(a:int, b:int):int
		{
			return a > b ? 1 : -1;
		}
	}
}