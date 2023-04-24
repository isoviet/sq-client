package
{
	public class InteriorData
	{
		static public const WALLPAPER:int = 0;
		static public const FLOOR:int = 1;
		static public const PICTURE:int = 2;
		static public const WINDOW:int = 3;
		static public const CURTAINS:int = 4;
		static public const RACK:int = 5;
		static public const CLOCKS:int = 6;
		static public const CHAIR:int = 7;
		static public const TABLE:int = 8;
		static public const VASE:int = 9;
		static public const PLANT:int = 10;
		static public const SCULPTURE:int = 11;
		static public const CHANDELIER:int = 12;

		static public const DATA:Array = [
			{'name': gls("Выцветшие обои"),		'class': WallpaperDefault,								'type': WALLPAPER,														'tapeClass': WallpaperDefaultImage},
			{'name': gls("Зелёные обои"),		'class': WallpaperByAcorns,	'gold_cost': 32,	'acorn_cost': 5000,		'type': WALLPAPER,	'description': gls("<body>В любую непогоду напомнят о тёплом лете, густой траве и спелых орехах.</body>"),	'tapeClass': WallpaperByAcornsImage},
			{'name': gls("Обои со звёздами"),		'class': WallpaperByCoins,	'gold_cost': 35,					'type': WALLPAPER,	'description': gls("<body>Звёздное небо в домике настоящего мечтателя.</body>"),				'tapeClass': WallpaperByCoinsImage},

			{'name': gls("Старые полы"),			'class': FloorDefault,									'type': FLOOR,															'tapeClass': FloorDefaultImage},
			{'name': gls("Сиреневый пол"),		'class': FloorByAcorns,		'gold_cost': 23,	'acorn_cost': 3000,		'type': FLOOR,		'description': gls("<body>Если хочется чего-то необычного, то этот цвет пола для тебя.</body>"),		'tapeClass': FloorByAcornsImage},
			{'name': gls("Тёмно-синий пол"),		'class': FloorByCoins,		'gold_cost': 25,					'type': FLOOR,		'description': gls("<body>Практичный тёмный цвет, на его фоне вся мебель заиграет новыми красками.</body>"),	'tapeClass': FloorByCoinsImage},

			{'name': gls("Рисунок акварелью"),		'class': PictureDefault,	'gold_cost': 9,		'acorn_cost': 1000,		'type': PICTURE,		'description': gls("<body>Кто знает, возможно обычный рисунок на бумаге станет через несколько лет шедевром искусства.</body>")},
			{'name': gls("Картина с деревом"),		'class': PictureByAcorns,	'gold_cost': 15,	'acorn_cost': 2000,		'type': PICTURE,	'description': gls("<body>Чудесная картина с ореховым деревом дополнит обстановку домика.</body>")},
			{'name': gls("Портрет в золотой раме"),	'class': PictureByCoins,	'gold_cost': 19,					'type': PICTURE,	'description': gls("<body>Лучший художник нарисовал этот портрет специально для тебя. Некоторые белки считают, что это не твоё изображение, а их. Они ошибаются.</body>")},

			{'name': gls("Круглое окошко"),		'class': WindowDefault,									'type': WINDOW},
			{'name': gls("Большое окно"),		'class': WindowByAcorns,	'gold_cost': 35,	'acorn_cost': 5000,		'type': WINDOW,		'description': gls("<body>Распахнутое большое окно даст больше солнечного света и свежего воздуха. В Трагедии Белок всегда тепло и солнечно.</body>")},
			{'name': gls("Окно с цветами"),		'class': WindowByCoins,		'gold_cost': 39,					'type': WINDOW,		'description': gls("<body>Цветы на окне не только украшение, но и лёгкий аромат фиалок в твоём домике.</body>")},

			{'name': gls("Оранжевая занавеска"),		'class': CurtainsDefault,	'gold_cost': 29,	'acorn_cost': 4000,		'type': CURTAINS,	'description': gls("<body>Скроют от жаркого летнего солнца и любопытных глаз.</body>")},
			{'name': gls("Зелёные занавески"),		'class': CurtainsByAcorns,	'gold_cost': 32,	'acorn_cost': 5000,		'type': CURTAINS,	'description': gls("<body>Яркие занавески создадут весеннее настроение в твоём доме.</body>")},
			{'name': gls("Голубая бархатная штора"),	'class': CurtainsByCoins,	'gold_cost': 35,					'type': CURTAINS,	'description': gls("<body>Продавец утверждает, что сшита она из отреза королевской бархатной мантии. На прилавке их довольно много, видимо, мантия была поистине королевских размеров.</body>")},

			{'name': gls("Деревянная полка"),		'class': RackDefault,									'type': RACK},
			{'name': gls("Полка с крючками"),		'class': RackByAcorns,		'gold_cost': 15,	'acorn_cost': 2000,		'type': RACK,		'description': gls("<body>Полезное и практичное приобретение. Повесить на неё ничего нельзя, но показывать и рекомендовать гостям — можно.</body>")},
			{'name': gls("Позолоченная полка"),		'class': RackByCoins,		'gold_cost': 15,					'type': RACK,		'description': gls("<body>Поговаривают, что некоторые полки из чистого золота! Даже если это не так — никто не рискнёт проверять.</body>")},

			{'name': gls("Настенные часы"),		'class': ClocksDefault,		'gold_cost': 9,		'acorn_cost': 1000,		'type': CLOCKS,		'description': gls("<body>Белки целый день в делах и хлопотах, но иногда стоит обратить внимание на время и передохнуть.</body>")},
			{'name': gls("Часы «Модерн»"),		'class': ClocksByAcorns,	'gold_cost': 15,	'acorn_cost': 2000,		'type': CLOCKS,		'description': gls("<body>Хорошо смотрятся на стене. Или на столе. Или на полу. С такими крупными цифрами они везде смотрятся хорошо.</body>")},
			{'name': gls("Антикварные часы"),		'class': ClocksByCoins,		'gold_cost': 19,					'type': CLOCKS,		'description': gls("<body>Эти напольные часы становятся с каждым годом только дороже. Место им в музее, но лучше оставь их у себя.</body>")},

			{'name': gls("Обычное красное кресло"),	'class': ChairDefault,									'type': CHAIR},
			{'name': gls("Мягкое кресло"),		'class': ChairByAcorns,		'gold_cost': 46,	'acorn_cost': 6000,		'type': CHAIR,		'description': gls("<body>Мягкое и уютное кресло, настолько большое, что можно разместить целую компанию друзей.</body>")},
			{'name': gls("Кресло Лорда"),		'class': ChairByCoins,		'gold_cost': 49,					'type': CHAIR,		'description': gls("<body>Невероятно удобное кресло, чем-то напоминает настоящий трон. Обязательно станет центром внимания всех гостей.</body>")},

			{'name': gls("Стандартный стол"),		'class': TableDefault,		'gold_cost': 8,		'acorn_cost': 1000,		'type': TABLE,		'description': gls("<body>Простой стол, но со своей основной задачей справляется превосходно.</body>")},
			{'name': gls("Журнальный столик"),		'class': TableByAcorns,		'gold_cost': 15,	'acorn_cost': 2000,		'type': TABLE,		'description': gls("<body>Небольшой столик, будет хорошо смотреться в любом домике.</body>")},
			{'name': gls("Роскошный стол"),		'class': TableByCoins,		'gold_cost': 19,					'type': TABLE,		'description': gls("<body>Изысканный стол из лучших пород дерева. Хотя в округе всего пару видов деревьев. Наверное привезён издалека.</body>")},

			{'name': gls("Зелёная ваза"),		'class': VaseDefault,		'gold_cost': 7,		'acorn_cost': 1000,		'type': VASE,		'description': gls("<body>Яркая ваза привлечёт внимание гостей.</body>")},
			{'name': gls("Стеклянная ваза"),		'class': VaseByAcorns,		'gold_cost': 7,		'acorn_cost': 1000,		'type': VASE,		'description': gls("<body>Оригинальная форма вазы удивляет гостей, а ещё не даёт ей упасть, когда они пытаются её потрогать.</body>")},
			{'name': gls("Старинный кубок"),		'class': VaseByCoins,		'gold_cost': 9,						'type': VASE,		'description': gls("<body>Древняя реликвия, предмет зависти для гостей и гордости владельца. Роскошный и изысканный кубок вполне подойдёт в качестве вазы.</body>")},

			{'name': gls("Горшок с тюльпанами"),		'class': PlantDefault,		'gold_cost': 15,	'acorn_cost': 2000,		'type': PLANT,		'description': gls("<body>Живые тюльпаны в твоём домике. Иногда получается вырастить тюльпаны особых форм и цветов.</body>")},
			{'name': gls("Винтовое деревце"),		'class': PlantByAcorns,		'gold_cost': 23,	'acorn_cost': 3000,		'type': PLANT,		'description': gls("<body>Садовник приложил немало усилий, пока выращивал это дерево по особой методике.</body>")},
			{'name': gls("Декоративный самшит"),		'class': PlantByCoins,		'gold_cost': 25,					'type': PLANT,		'description': gls("<body>Это деревце проделало долгий путь из экзотической страны, чтобы оказаться в твоём домике.</body>")},

			{'name': gls("Статуэтка «Созвездие»"),	'class': SculptureDefault,	'gold_cost': 23,	'acorn_cost': 3000,		'type': SCULPTURE,	'description': gls("<body>Сияние этой статуэтки не оставит гостей равнодушными.</body>")},
			{'name': gls("Бюст Белкистотеля"),		'class': SculptureByAcorns,	'gold_cost': 29,	'acorn_cost': 4000,		'type': SCULPTURE,	'description': gls("<body>Величайший философ Грецкой Орехции прославился своей ловкостью и силой. Странный был философ — не мог связать и двух слов, но в спорах почему-то побеждал.</body>")},
			{'name': gls("Крылатый лев"),		'class': SculptureByCoins,	'gold_cost': 29,					'type': SCULPTURE,	'description': gls("<body>Статуэтка крылатого льва из чистого золота. Символ отваги, смелости и благородства. Обычно её владельцы обладают этими качествами.</body>")},

			{'name': gls("Обычный светильник"),		'class': ChandelierDefault,	'gold_cost': 29,	'acorn_cost': 4000,		'type': CHANDELIER,	'description': gls("<body>Простая форма абажура и светлые тона, отличное решение для домика белки.</body>")},
			{'name': gls("Бронзовая люстра"),		'class': ChandelierByAcorns,	'gold_cost': 39,	'acorn_cost': 5000,		'type': CHANDELIER,	'description': gls("<body>Лампы из этой люстры когда-то стояли на маяке и освещали путь кораблям. Теперь у них новое предназначение — освещать твой домик.</body>")},
			{'name': gls("Королевская люстра"),		'class': ChandelierByCoins,	'gold_cost': 39,					'type': CHANDELIER,	'description': gls("<body>Интересно, как люстра из дворца будет смотреться в домике у белки. Есть только один способ это проверить!</body>")}
		];

		static public function getType(id:int):int
		{
			return DATA[id]['type'];
		}

		static public function getClass(id:int):Class
		{
			return DATA[id]['class'];
		}

		static public function getItem(id:int):Object
		{
			return DATA[id];
		}

		static public function getTapeClass(id:int):Class
		{
			return ("tapeClass" in DATA[id] ? DATA[id]['tapeClass'] : DATA[id]['class']);
		}

		static public function getTitle(id:int):String
		{
			return DATA[id]['name'];
		}
	}
}