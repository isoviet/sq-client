package
{
	import screens.ScreenGame;

	import utils.StringUtil;

	public class Locations
	{
		static public const OLYMPIC_SUBS:Array = [
			{'name': gls("Кручёные белки"), 'modes': [0]},
			{'name': gls("Грави-белки"), 'modes': [0]},
			{'name': gls("Прыгай"), 'modes': [0]},
			{'name': gls("Турбобелки"), 'modes': [0]},
			{'name': gls("Альпинизм"), 'modes': [0]},
			{'name': gls("Самолётики"), 'modes': [0]},
			{'name': gls("Ниндзи"), 'modes': [0]},
			{'name': gls("Прыжок с парашютом"), 'modes': [0]},
			{'name': gls("Равновесие"), 'modes': [0]},
			{'name': gls("Пузыри"), 'modes': [0]}
		];

		static public const LIST:Array = [
			{'value': OLYMPIC_ID,		'name': gls("Стадион"),			'game': false,	'level': 0,	'cost': 10,			'nonHare': true,	'subs': OLYMPIC_SUBS,	'nonPerk': true,	'nonClothes': true,	'nonItems': true,	'respawn': true},
			{'value': SANDBOX_ID,		'name': gls("Песочница"),		'game': false,	'level': 0,	'cost': 10,			'nonHare': true},
			{'value': ISLAND_ID,		'name': gls("Солнечная долина"),	'game': true,	'level': 0,	'cost': 10,	'award': 2500,	'nonHare': true,	'mapModes': [0, 17, 18], 'mapModesFull': [11]},
			{'value': BATTLE_ID,		'name': gls("Битва"),			'game': true,	'level': 7,	'cost': 10,	'award': 10000,	'nonHare': false,	'teamMode': true,	'nonPerk': true,	'nonClothes': true,	'nonItems': true,	'respawn': true},
			{'value': SWAMP_ID,		'name': gls("Топи"),			'game': true,	'level': 12,	'cost': 10,	'award': 5000,	'nonHare': false},
			{'value': WILD_ID,		'name': gls("Дикие земли"),		'game': false,	'level': 15,	'cost': 10, 			'nonHare': true,	'modes': [15, 16],	'mapModes': [15, 16],	'nonItems': true},
			{'value': STORM_ID,		'name': gls("Шторм"),			'game': true,	'level': 18,	'cost': 10,	'award': 6500,	'nonHare': false,	'modes': [2, 4, 5, 6, 7, 8, 9],	'mapModes': [2, 4, 5, 6, 7, 9]},
			{'value': HARD_ID,		'name': gls("Испытания"),		'game': true,	'level': 20,	'cost': 15,	'award': 10000,	'nonHare': false},
			{'value': DESERT_ID,		'name': gls("Пустыня"),			'game': true,	'level': 25,	'cost': 10,	'award': 7500,	'nonHare': false},
			{'value': ANOMAL_ID,		'name': gls("Аномальная зона"),		'game': true,	'level': 32,	'cost': 10, 	'award': 6500,	'nonHare': false},
			{'value': SCHOOL_ID,		'name': gls("Школа")},
			{'value': TENDER,		'name': gls("Конкурс карт")},
			{'value': NONAME_ID,		'name': gls("На модерации"),		'game': false,	'mapModes': [0, 1, 2, 4, 5, 6, 7, 9, 12, 13, 14]},
			{'value': APPROVED_ID,		'name': gls("Одобренные"),		'game': false,	'mapModes': [0, 1, 2, 4, 5, 6, 7, 9, 12, 13, 14]},
			{'value': BAD_ID,		'name': gls("Плохие карты"),		'game': false,	'mapModes': [0, 1, 2, 4, 5, 6, 7, 9, 12, 13, 14]},
			{'value': PRE_RELEASE_ID,	'name': gls("Релиз"),			'game': false,	'mapModes': [0, 1, 2, 4, 5, 6, 7, 9, 12, 13, 14]}
		];

		static public const MODES:Array = [
			{'name': gls("Классический"),	'shamanButton': true,	'hareButton': true,	'dragonButton': true,	'caption': gls("Классический"), 'text': gls("Возьми орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Испытания"),	'shamanButton': true,	'hareButton': false,	'dragonButton': false,	'caption': gls("Классический"), 'text': gls("Возьми орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Все дракоши"),	'shamanButton': false,	'hareButton': true,	'dragonButton': false,	'caption': gls("Все дракоши"), 'text': gls("Возьми орех, беги в дупло!")},
			{'name': null},
			{'name': gls("Безумный шаман"),	'shamanButton': true,	'hareButton': false,	'dragonButton': true,	'caption': gls("Безумный шаман"), 'text': gls("Спасайся! Шаман хочет тебя убить!\nШаман, убей белок!")},
			{'name': gls("Два шамана"),	'shamanButton': true,	'hareButton': false,	'dragonButton': true,	'caption': gls("Два шамана"), 'text': gls("Возьми орех, беги в дупло!\nШаман, помоги белкам первым!")},
			{'name': gls("Связанные"),	'shamanButton': true,	'hareButton': false,	'dragonButton': false,	'caption': gls("Связанные"), 'text': gls("Белки связаны! Возьми орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Летающий орех"),	'shamanButton': true,	'hareButton': true,	'dragonButton': true,	'caption': gls("Летающий орех"), 'text': gls("Поймай орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Змейка"),		'shamanButton': true,	'hareButton': false,	'dragonButton': false,	'caption': gls("Связанные"), 'text': gls("Белки связаны! Возьми орех, беги в дупло! \nШаман, помоги белкам!")},
			{'name': gls("Колодец"),	'shamanButton': true,	'hareButton': false,	'dragonButton': true,	'caption': gls("Колодец"), 'text': gls("Уровень кислоты поднимается! Скорее поднимайся вверх!")},
			{'name': gls("Интерактивный")},
			{'name': gls("Снеговик"),	'shamanButton': false,	'hareButton': false,	'dragonButton': false,	'caption': gls("Снеговик"), 'text': gls("Бери снег, тащи к Снеговику!\nБери блоки, строй путь!")},
			{'name': gls("Механизмы"),	'shamanButton': true,	'hareButton': true,	'dragonButton': true,	'caption': gls("Классический"), 'text': gls("Возьми орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Логические"),	'shamanButton': true,	'hareButton': true,	'dragonButton': true,	'caption': gls("Классический"), 'text': gls("Возьми орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Ловушки"),	'shamanButton': true,	'hareButton': true,	'dragonButton': true,	'caption': gls("Классический"), 'text': gls("Возьми орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Зомби"),		'shamanButton': false,	'hareButton': false,	'dragonButton': false,	'caption': gls("Зомби"), 'text': gls("Белка, не дай зомби себя поймать!\nЗомби, зарази белок!")},
			{'name': gls("Гейзеры"),	'shamanButton': false,	'hareButton': false,	'dragonButton': false,	'caption': gls("Гейзеры"), 'text': gls("Опасайся гейзеров!\nУвидел пар - беги!")},
			{'name': gls("Снежные хребты"),	'shamanButton': true,	'hareButton': true,	'dragonButton': true,	'caption': gls("Классический"), 'text': gls("Возьми орех, беги в дупло!\nШаман, помоги белкам!")},
			{'name': gls("Безумие"), 	'shamanButton': true, 	'hareButton': true, 	'dragonButton': true, 	'caption': gls("Безумие"), 'text': gls("Нет времени объяснять!\nДумай быстро и действуй!")}
		];

		static public const RELEASE_FOLDER_ID:int = 0;
		static public const PRE_RELEASE_FOLDER_ID:int = 1;

		static public const ISLAND_ID:int = 0;
		static public const MOUNTAIN_ID:int = 1;
		static public const SWAMP_ID:int = 2;
		static public const DESERT_ID:int = 3;
		static public const ANOMAL_ID:int = 4;
		static public const WILD_ID:int = 5;
		static public const NONAME_ID:int = 6;
		static public const SCHOOL_ID:int = 7;
		static public const APPROVED_ID:int = 8;
		static public const HARD_ID:int = 9;
		static public const BATTLE_ID:int = 10;
		static public const TENDER:int = 11;
		static public const BAD_ID:int = 12;
		static public const STORM_ID:int = 13;
		static public const OLYMPIC_ID:int = 15;
		static public const PRE_RELEASE_ID:int = 16;
		static public const SANDBOX_ID:int = 18;

		static public const CLASSIC_MODE:int = 0;
		static public const HARD_MODE:int = 1;
		static public const DRAGON_MODE:int = 2;
		static public const NIGHT_MODE:int = 3;
		static public const BLACK_SHAMAN_MODE:int = 4;
		static public const TWO_SHAMANS_MODE:int = 5;
		static public const ROPED_MODE:int = 6;
		static public const FLY_NUT_MODE:int = 7;
		static public const SNAKE_MODE:int = 8;
		static public const WELL_MODE:int = 9;
		static public const INTERACTIVE_MODE:int = 10;
		static public const SNOWMAN_MODE:int = 11;
		static public const ZOMBIE_MODE:int = 15;
		static public const VOLCANO_MODE:int = 16;
		static public const MOUNTAINS_MODE: int = 17;
		static public const FUN_MODE: int = 18;
		static public const BATTLE_MIN_PLAYERS:int = 4;

		static private var data:Object = {};

		static private var eng_modify:Object = {};

		public function Locations():void
		{
			eng_modify[DESERT_ID] = 999;
			eng_modify[ANOMAL_ID] = 999;

			for each(var item:Object in Locations.LIST)
			{
				Locations.data[item['value']] = new Location(item);
				if (Config.isEng && (item['value'] in eng_modify))
					(Locations.data[item['value']] as Location).level = eng_modify[item['value']];
			}
		}

		static public function getLocations(level:int):Array
		{
			var unlockArray:Array = [];
			for each(var location:Location in list)
			{
				if (Config.isEng && (location.id == DESERT_ID || location.id == ANOMAL_ID))
					continue;
				if (level < location.level)
					continue;
				unlockArray.push(location.id);
			}
			unlockArray.sort();
			return unlockArray;
		}

		static public function getLocation(value:int):Location
		{
			if (value in Locations.data)
				return Locations.data[value];
			return new Location();
		}

		static public function get currentLocation():Location
		{
			return getLocation(ScreenGame.location);
		}

		static public function getLocationsName(level:int):String
		{
			var names:Array = [];
			for each (var location:Location in Locations.list)
			{
				if (location.level != level)
					continue;
				names.push(location.name);
			}
			return StringUtil.jointArray(names);
		}

		static public function get list():Object
		{
			return Locations.data;
		}

		static public function getGameMode(mapMode:int):int
		{
			if (mapMode == Locations.INTERACTIVE_MODE)
				return 0;

			return mapMode;
		}
	}
}