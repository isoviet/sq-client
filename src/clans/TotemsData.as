package clans
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;

	public class TotemsData
	{
		static private const DATA:Array = [
			{'id': EXP,						'name': gls("Тотем искусности"),		'level': [1, 1, 1, 3, 6, 10, 15, 21, 27, 33],		'image': "TotemExp",		'icon': "TotemExpIcon",		'tip': gls("Играй в трагедию белок,\nзабегай в дупло"),						'description': gls("Увеличивает количество опыта, получаемого на локациях, на #%"),				'common_description': gls("Увеличивает количетсво опыта, получаемого на локациях")},
			{'id': RESPAWN, 	'perkClass': PerkTotemRespawn,	'name': gls("Тотем жизненной силы"),		'level': [2, 2, 4, 7, 11, 16, 22, 28, 34, 39],		'image': "TotemRespawn",	'icon': "TotemRespawnIcon",	'tip': gls("Возрождайся, используя\nмагию «реинкарнация»,\nвоскрешение от VIP-статуса\nи одежду Зомби."),	'description': gls("Позволяет использовать магию «реинкарнация» без затрат маны раз в # минут"),	'common_description': gls("Позволяет использовать магию «реинкарнация» без затрат маны")},
			{'id': SPEED, 		'perkClass': PerkTotemSpeed,	'name': gls("Тотем быстрых лапок"),		'level': [5, 5, 8, 12, 17, 23, 29, 35, 40, 44],		'image': "TotemSpeed",		'icon': "TotemSpeedIcon",	'tip': gls("Используй магию «Белка-молния»"),							'description': gls("Усиливает магию «Белка-молния» на #%"),							'common_description': gls("Усиливает магию «Белка-молния»")},
			{'id': MAGIC, 						'name': gls("Тотем магической силы"),		'level': [9, 9, 13, 18, 24, 30, 36, 41, 45, 48],	'image': "TotemMagic",		'icon': "TotemMagicIcon",	'tip': gls("Восстанавливай ману с помощью\nКолдовских Отваров"),				'description': gls("Генерирует дополнительную единицу маны за каждые # маны, потраченных на локациях"),		'common_description': gls("Возвращает часть потраченной маны")},
			{'id': HIGH_JUMP, 	'perkClass': PerkTotemHighJump,	'name': gls("Тотем невесомости"),		'level': [14, 14, 19, 25, 31, 37, 42, 46, 49, 49],	'image': "TotemHighJump",	'icon': "TotemHighJumpIcon",	'tip': gls("Используй магию «Высокий прыжок»"),							'description': gls("Усиливает магию «Высокий прыжок» на #%"),							'common_description': gls("Усиливает магию «Высокий прыжок»")},
			{'id': ACORNS,						'name': gls("Тотем роста орехов"),		'level': [20, 20, 26, 32, 38, 43, 47, 50, 50, 50],	'image': "TotemNuts",		'icon': "TotemNutsIcon",	'tip': gls("Забегай в дупло раньше всех"),							'description': gls("Увеличивает количество орехов, полученных на локации, на #%"),				'common_description': gls("Увеличивает количество орехов, получаемых на локациях")}
		];

		static public const SLOT_DATA:Array = [
			{'id': 0,	'level': 1},
			{'id': 1,	'level': 10},
			{'id': 2,	'level': 20}
		];

		static public const NONE:int = -1;
		static public const EXP:int = 0;
		static public const RESPAWN:int = 1;
		static public const SPEED:int = 2;
		static public const MAGIC:int = 3;
		static public const HIGH_JUMP:int = 4;
		static public const ACORNS:int = 5;

		static public const SLOT_COUNT:int = 3;

		static public const MAX_TOTEM_LEVEL:int = 10;

		public function TotemsData():void
		{
			super();
		}

		static private function get(id:int):Object
		{
			for (var i:int = 0; i < TotemsData.DATA.length; i++)
			{
				if (TotemsData.DATA[i]['id'] != id)
					continue;
				return TotemsData.DATA[i];
			}
			return null;
		}

		static public function getSlotData(id:int):Object
		{
			for (var i:int = 0; i < TotemsData.SLOT_DATA.length; i++)
			{
				if (TotemsData.SLOT_DATA[i]['id'] != id)
					continue;
				return TotemsData.SLOT_DATA[i];
			}
			return null;
		}

		static public function getPerkClass(id:int):Class
		{
			if (id < 0)
				return null;
			var totem:Object = get(id);
			if (!('perkClass' in totem))
				return null;
			return totem['perkClass'];
		}

		static public function getImage(id:int):DisplayObject
		{
			if (id < 0)
				return null;
			var totem:Object = get(id);
			return new (getDefinitionByName(totem['image']) as Class)();
		}

		static public function getIcon(id:int):DisplayObject
		{
			if (id < 0)
				return null;
			var totem:Object = get(id);
			return new (getDefinitionByName(totem['icon']) as Class)();
		}

		static public function getName(id:int):String
		{
			if (id < 0)
				return null;
			var totem:Object = get(id);
			return totem['name'];
		}

		static public function getDescription(id:int, bonus:int = 0):String
		{
			if (id < 0)
				return null;
			var totem:Object = get(id);
			if (bonus == 0)
				return totem['common_description'];
			if (id == EXP || id == ACORNS)
				bonus = int(100 / bonus);
			return (totem['description'] as String).replace("#", bonus);
		}

		static public function getTip(id:int):String
		{
			if (id < 0)
				return null;
			var totem:Object = get(id);
			return totem['tip'];
		}

		static public function getLevel(id:int, totemLevel:int = 0):int
		{
			if (id < 0)
				return 0;
			var totem:Object = get(id);
			if (totemLevel > totem['level'].length)
				return 0;
			if (totemLevel < 1 )
				return totem['level'][0];
			return totem['level'][totemLevel - 1];
		}

		static public function getNextLevel(id:int, totemLevel:int = 0):int
		{
			if (id < 0)
				return 0;
			var totem:Object = get(id);
			if (totemLevel > totem['level'].length)
				return 0;
			if (totemLevel < 1 )
				return totem['level'][0];
			return totem['level'][totemLevel];
		}

		static public function getMaxId():int
		{
			return DATA.length;
		}

		static public function getSlotLevel(id:int):int
		{
			if (id < 0)
				return 0;
			var slot:Object = getSlotData(id);
			return slot['level'];
		}

		static public function isSlotAvailable(id:int, level:int):Boolean
		{
			if (id < 0 || id >= SLOT_COUNT)
				return false;
			var slot:Object = getSlotData(id);
			return level >= slot['level'];
		}
	}
}