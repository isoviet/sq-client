package
{
	public class wClothesData
	{
		static public const TYPE_HAT:int = 1;
		static public const TYPE_HEAD:int = 2;
		static public const TYPE_EYES:int = 3;
		static public const TYPE_NECK:int = 4;
		static public const TYPE_FULL:int = 5;
		static public const TYPE_UPPER_BODY:int = 6;
		static public const TYPE_BOTTOM_BODY:int = 7;
		static public const TYPE_TAIL:int = 8;

		static public const CATEGORY_CLOTHES:int = 0;
		static public const CATEGORY_ENERGY:int = 1;

		static private var clothesId:int = 0;
		static private var energyId:int = 0;

		static public const DATA:Array = [
			{'id': -1, 		'name': "Шаман",				'class': "Shaman",		'type': TYPE_FULL,		'acorn_cost': 1,				'level': 1,							'description': "Шаман"},
			{'id': clothesId++,	'name': "Уши",					'class': "wRabbitEars", 	'type': TYPE_HAT,		'acorn_cost': 700,	'gold_cost': 7,		'level': 1,			'purchase_type': "clothes",	'description': "<body>Алоха! Рубашка цвета яркой тропической зелени изготовлена из высококачественной натуральной ткани и сшита нежными руками загорелых красавиц с далеких Гавайских островов.</body>", 'category': CATEGORY_CLOTHES},
			{'id': clothesId++,	'name': "Рубашка",				'class': "ShirtMod", 		'type': TYPE_UPPER_BODY,	'acorn_cost': 700,	'gold_cost': 7,		'level': 1,			'purchase_type': "clothes",	'description': "<body>Главное достояние каждой белки – шикарный хвост, и чем длиннее, ухоженнее и красивее хвост, тем больше уважают белку в племени. Увидев украшенный зелеными бомбошками хвост, другие белки могут запросто помереть от зависти.</body>"},
			{'id': clothesId++,	'name': "Очки",					'class': "wSunglass", 		'type': TYPE_EYES,		'acorn_cost': 1500,	'gold_cost': 15,	'level': 3,	'friends': 5,	'purchase_type': "clothes",	'description': "<body>Вот она, настоящая жесть! Привязанные к хвосту консервные банки – украшение настоящего анархиста. Грохот и скрежет будут сопровождать тебя повсюду, вводя в ступор других белок. Экстремальные консервные банки отлично сочетаются с ирокезом.</body>"},
			];

		static private var categoriesOffset:Object = new Object();

		static public function get clothesCount():int
		{
			return clothesId;
		}

		static public function getItem(id:int, category:int):Object
		{
			if (!(category in categoriesOffset))
				categoriesOffset[category] = getOffsetCategory(category);

			var offset:int = categoriesOffset[category];

			if (offset == -1)
				return null;

			return DATA[id + offset];
		}

		static public function getIndexById(id:int, category:int):int
		{
			if (!(category in categoriesOffset))
				categoriesOffset[category] = getOffsetCategory(category);

			var offset:int = categoriesOffset[category];

			if (offset == -1)
				return -1;

			return id + offset;
		}

		static public function getIdByIndex(index:int, category:int):int
		{
			if (!(category in categoriesOffset))
				categoriesOffset[category] = getOffsetCategory(category);

			var offset:int = categoriesOffset[category];

			if (offset == -1)
				return -1;

			return index - offset;
		}

		static private function getOffsetCategory(category:int):int
		{
			for (var i:int = 0; i < DATA.length; i++)
			{
				if (("category" in DATA[i]) && DATA[i]['category'] == category)
					return i;
			}

			return -1;
		}

		static public function get(id:int):Object
		{
			return DATA[id];
		}

		static public function getTitleByIndex(index:int):String
		{
			return DATA[index]['name'];
		}

		static public function getTitleById(id:int, category:int):String
		{
			var item:Object = getItem(id, category);
			return item['name'];
		}

		static public function getLevel(index:int):String
		{
			return DATA[index]['level'];
		}

		static public function getDescription(index:int):String
		{
			return DATA[index]['description'];
		}

		static public function getCostByIndex(index:int):int
		{
			return ("gold_cost" in DATA[index] ? DATA[index]['gold_cost'] : DATA[index]['acorn_cost']);
		}

		static public function getImageClassByIndex(index:int):String
		{
			return DATA[index]['class'] + "Image";
		}

		static public function getImageClassById(id:int, category:int):String
		{
			var item:Object = getItem(id, category);

			return item['class'] + "Image";
		}

		static public function getType(id:int):int
		{
			var item:Object = getItem(id, CATEGORY_CLOTHES);

			if (!("type" in item))
				return -1;

			return item['type'];
		}

		static public function getUpperCategoryIndex(category:int):int
		{
			return getOffsetCategory(category);
		}

		static public function getBottomCategoryIndex(category:int):int
		{
			for (var i:int = getUpperCategoryIndex(category); i < DATA.length; i++)
				if (("category" in DATA[i]) && DATA[i]['category'] != category)
					return i;

			return	DATA.length;
		}
	}
}