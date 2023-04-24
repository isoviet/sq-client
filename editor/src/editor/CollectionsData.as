package editor
{
	public class CollectionsData
	{
		static private var type:int = 0;

		static public const TYPE_REGULAR:int = type++;
		static public const TYPE_UNIQUE:int = type++;

		static public const FLY_ISLAND:int = 0;
		static public const SNOW_FOREST:int = 1;
		static public const MARSH:int = 2;
		static public const ANOMAL_ZONE:int = 3;
		static public const STORM:int = 4;
		static public const DESERT:int = 5;
		static public const BATTLE:int = 6;
		static public const HARD:int = 7;

		static public const MAX_COUNT:int = 65535;

		static public const LOCATIONS_TITLE:Array = [
			"Солнечные долины",
			"Снежные хребты",
			"Топи",
			"Аномальная зона",
			"Шторм",
			"Пустыня",
			"Битва",
			"Испытания"
		];

		static public const COLLECTIONS:Array = [
			[
				{'title': "Акватис", 'location': FLY_ISLAND, 'set': "Золотая бабочка"},
				{'title': "Эквитиа", 'location': FLY_ISLAND, 'set': "Золотая бабочка"},
				{'title': "Райская бабочка", 'location': FLY_ISLAND, 'set': "Золотая бабочка"},
				{'title': "Сакура портис", 'location': FLY_ISLAND, 'set': "Золотая бабочка"},
				{'title': "Солярис", 'location': FLY_ISLAND, 'set': "Золотая бабочка"},
//5
				{'title': "Перо Топазии", 'location': FLY_ISLAND, 'set': "Золотое перо"},
				{'title': "Перо Жизни", 'location': FLY_ISLAND, 'set': "Золотое перо"},
				{'title': "Перо Мимоса", 'location': FLY_ISLAND, 'set': "Золотое перо"},
				{'title': "Радужное Перо", 'location': FLY_ISLAND, 'set': "Золотое перо"},
				{'title': "Перо Феникса", 'location': FLY_ISLAND, 'set': "Золотое перо"},
//10
				{'title': "След льва", 'location': SNOW_FOREST, 'set': "Золотой след"},
				{'title': "След человека", 'location': SNOW_FOREST, 'set': "Золотой след"},
				{'title': "След енота", 'location': SNOW_FOREST, 'set': "Золотой след"},
				{'title': "След ворона", 'location': SNOW_FOREST, 'set': "Золотой след"},
				{'title': "След лося", 'location': SNOW_FOREST, 'set': "Золотой след"},
//15
				{'title': "Тазовая кость", 'location': SNOW_FOREST, 'set': "Золотой череп"},
				{'title': "Лопатка", 'location': SNOW_FOREST, 'set': "Золотой череп"},
				{'title': "Кисть", 'location': SNOW_FOREST, 'set': "Золотой череп"},
				{'title': "Ребра", 'location': SNOW_FOREST, 'set': "Золотой череп"},
				{'title': "Кость питекантропа", 'location': SNOW_FOREST, 'set': "Золотой череп"},
//20
				{'title': "Муравей", 'location': MARSH, 'set': "Золотой паук"},
				{'title': "Божья коровка", 'location': MARSH, 'set': "Золотой паук"},
				{'title': "Ископаемая блоха", 'location': MARSH, 'set': "Золотой паук"},
				{'title': "Таракан", 'location': MARSH, 'set': "Золотой паук"},
				{'title': "Комар", 'location': MARSH, 'set': "Золотой паук"},
//25
				{'title': "Белый гриб", 'location': MARSH, 'set': "Золотой гриб"},
				{'title': "Лисичка", 'location': MARSH, 'set': "Золотой гриб"},
				{'title': "Подосиновик", 'location': MARSH, 'set': "Золотой гриб"},
				{'title': "Поганка", 'location': MARSH, 'set': "Золотой гриб"},
				{'title': "Мухомор", 'location': MARSH, 'set': "Золотой гриб"},
//30
				{'title': "Морской гребешок", 'location': MARSH, 'set': "Золотая раковина"},
				{'title': "Мидия", 'location': MARSH, 'set': "Золотая раковина"},
				{'title': "Морской единорог", 'location': MARSH, 'set': "Золотая раковина"},
				{'title': "Речная улитка", 'location': MARSH, 'set': "Золотая раковина"},
				{'title': "Империус ползунус", 'location': MARSH, 'set': "Золотая раковина"},
//35
				{'title': "Ледяная рыба", 'location': MARSH, 'set': "Золотая рыба"},
				{'title': "Рыба-пижон", 'location': MARSH, 'set': "Золотая рыба"},
				{'title': "Анемоновая рыба", 'location': MARSH, 'set': "Золотая рыба"},
				{'title': "Рыба-хитер", 'location': MARSH, 'set': "Золотая рыба"},
				{'title': "Рыба-гурман", 'location': MARSH, 'set': "Золотая рыба"},
//40
				{'title': "Сущность огня", 'location': ANOMAL_ZONE, 'set': "Золотая сущность"},
				{'title': "Сущность льда", 'location': ANOMAL_ZONE, 'set': "Золотая сущность"},
				{'title': "Сущность жизни", 'location': ANOMAL_ZONE, 'set': "Золотая сущность"},
				{'title': "Сущность тьмы", 'location': ANOMAL_ZONE, 'set': "Золотая сущность"},
				{'title': "Сущность света", 'location': ANOMAL_ZONE, 'set': "Золотая сущность"},
//45
				{'title': "Злобус", 'location': ANOMAL_ZONE, 'set': "Золотая инфузория"},
				{'title': "Гринстар", 'location': ANOMAL_ZONE, 'set': "Золотая инфузория"},
				{'title': "Могильная бактерия", 'location': ANOMAL_ZONE, 'set': "Золотая инфузория"},
				{'title': "Амеба", 'location': ANOMAL_ZONE, 'set': "Золотая инфузория"},
				{'title': "Стики", 'location': ANOMAL_ZONE, 'set': "Золотая инфузория"},
//50
				null,	// nokia
				null,
				null,
				null,
				null,
//55
				{'title': "Пропеллер", 'location': STORM, 'set': "Золотой цеппелин"},
				{'title': "Крылья", 'location': STORM, 'set': "Золотой цеппелин"},
				{'title': "Дирижабль", 'location': STORM, 'set': "Золотой цеппелин"},
				{'title': "Реактивный двигатель", 'location': STORM, 'set': "Золотой цеппелин"},
				{'title': "Антигравитатор", 'location': STORM, 'set': "Золотой цеппелин"},
//60
				{'title': "Камень", 'location': STORM, 'set': "Золотой скафандр"},
				{'title': "Гиря", 'location': STORM, 'set': "Золотой скафандр"},
				{'title': "Якорь", 'location': STORM, 'set': "Золотой скафандр"},
				{'title': "Мешок с песком", 'location': STORM, 'set': "Золотой скафандр"},
				{'title': "Цепь", 'location': STORM, 'set': "Золотой скафандр"},
//65
				null,	// lego
				null,
				null,
				null,
				null,
//70
				{'title': "Скарабей", 'location': DESERT, 'set': "Золотой саркофаг"},
				{'title': "Анх", 'location': DESERT, 'set': "Золотой саркофаг"},
				{'title': "Пирамидка", 'location': DESERT, 'set': "Золотой саркофаг"},
				{'title': "Посох Фараона", 'location': DESERT, 'set': "Золотой саркофаг"},
				{'title': "Иероглиф Глаз", 'location': DESERT, 'set': "Золотой саркофаг"},
//75
				{'title': "Кинжал", 'location': DESERT, 'set': "Золотая лампа Джинна"},
				{'title': "Кальян", 'location': DESERT, 'set': "Золотая лампа Джинна"},
				{'title': "Ковёр-самолёт", 'location': DESERT, 'set': "Золотая лампа Джинна"},
				{'title': "Фигурка Змеи", 'location': DESERT, 'set': "Золотая лампа Джинна"},
				{'title': "Дудочка", 'location': DESERT, 'set': "Золотая лампа Джинна"},
//80
				{'title': "Шпага", 'location':BATTLE, 'set': "Золотой нож-бабочка"},
				{'title': "Экскалибур", 'location':BATTLE, 'set': "Золотой нож-бабочка"},
				{'title': "Секира", 'location':BATTLE, 'set': "Золотой нож-бабочка"},
				{'title': "Копьё", 'location':BATTLE, 'set': "Золотой нож-бабочка"},
				{'title': "Нунчаки", 'location':BATTLE, 'set': "Золотой нож-бабочка"},
//85
				{'title': "Обойма", 'location':BATTLE, 'set': "Золотая ядерная боеголовка"},
				{'title': "Пушка", 'location':BATTLE, 'set': "Золотая ядерная боеголовка"},
				{'title': "Огнемёт", 'location':BATTLE, 'set': "Золотая ядерная боеголовка"},
				{'title': "Маузер", 'location':BATTLE, 'set': "Золотая ядерная боеголовка"},
				{'title': "Базука", 'location':BATTLE, 'set': "Золотая ядерная боеголовка"},
//90
				{'title': "Шестерня", 'location':BATTLE, 'set': "Золотой робот"},
				{'title': "Аккумулятор", 'location':BATTLE, 'set': "Золотой робот"},
				{'title': "Процессор", 'location':BATTLE, 'set': "Золотой робот"},
				{'title': "Сервопривод", 'location':BATTLE, 'set': "Золотой робот"},
				{'title': "Электромотор", 'location':BATTLE, 'set': "Золотой робот"},
//95
				{'title': "Снаряд", 'location':BATTLE, 'set': "Золотой танк"},
				{'title': "Рация", 'location':BATTLE, 'set': "Золотой танк"},
				{'title': "Гусеница", 'location':BATTLE, 'set': "Золотой танк"},
				{'title': "Шлемофон", 'location':BATTLE, 'set': "Золотой танк"},
				{'title': "ДВС", 'location':BATTLE, 'set': "Золотой танк"},
//100
				{'title': "Рябина", 'location':HARD, 'set': "Золотая гроздь"},
				{'title': "Черника", 'location':HARD, 'set': "Золотая гроздь"},
				{'title': "Клубника", 'location':HARD, 'set': "Золотая гроздь"},
				{'title': "Вишня", 'location':HARD, 'set': "Золотая гроздь"},
				{'title': "Малина", 'location':HARD, 'set': "Золотая гроздь"},
//105
				{'title': "Рюкзак", 'location':HARD, 'set': "Золотая консервная банка"},
				{'title': "Аптечка", 'location':HARD, 'set': "Золотая консервная банка"},
				{'title': "Палатка", 'location':HARD, 'set': "Золотая консервная банка"},
				{'title': "Походный фонарь", 'location':HARD, 'set': "Золотая консервная банка"},
				{'title': "Столовые приборы", 'location':HARD, 'set': "Золотая консервная банка"},
//110
				{'title': "Парашют", 'location':HARD, 'set': "Золотой компас"},
				{'title': "Перчатки", 'location':HARD, 'set': "Золотой компас"},
				{'title': "Фляжка", 'location':HARD, 'set': "Золотой компас"},
				{'title': "Карабин", 'location':HARD, 'set': "Золотой компас"},
				{'title': "Кирка", 'location':HARD, 'set': "Золотой компас"},
//115
				{'title': "Камыши", 'location':HARD, 'set': "Золотой баллон кислорода"},
				{'title': "Бумажный кораблик", 'location':HARD, 'set': "Золотой баллон кислорода"},
				{'title': "Маска для дайвинга", 'location':HARD, 'set': "Золотой баллон кислорода"},
				{'title': "Лягушка", 'location':HARD, 'set': "Золотой баллон кислорода"},
				{'title': "Ласты", 'location':HARD, 'set': "Золотой баллон кислорода"},
//120
				{'title': "Змея", 'location':DESERT, 'set': "Золотой верблюд"},
				{'title': "Пустынная мышь", 'location':DESERT, 'set': "Золотой верблюд"},
				{'title': "Скорпион", 'location':DESERT, 'set': "Золотой верблюд"},
				{'title': "Ящерица", 'location':DESERT, 'set': "Золотой верблюд"},
				{'title': "Паук", 'location':DESERT, 'set': "Золотой верблюд"},
//125
				{'title': "Маммиллярия", 'location':DESERT, 'set': "Золотой кактус"},
				{'title': "Опунция", 'location':DESERT, 'set': "Золотой кактус"},
				{'title': "Пальма", 'location':DESERT, 'set': "Золотой кактус"},
				{'title': "Перекати-поле", 'location':DESERT, 'set': "Золотой кактус"},
				{'title': "Сухая акация", 'location':DESERT, 'set': "Золотой кактус"},
//130
				{'title': "Нептун", 'location':ANOMAL_ZONE, 'set': "Золотой звездолёт"},
				{'title': "Марс", 'location':ANOMAL_ZONE, 'set': "Золотой звездолёт"},
				{'title': "Венера", 'location':ANOMAL_ZONE, 'set': "Золотой звездолёт"},
				{'title': "Сатурн", 'location':ANOMAL_ZONE, 'set': "Золотой звездолёт"},
				{'title': "Плутон", 'location':ANOMAL_ZONE, 'set': "Золотой звездолёт"},
//135
				{'title': "Зелёникус", 'location':ANOMAL_ZONE, 'set': "Золотой инопланетянин"},
				{'title': "Сиреневикус", 'location':ANOMAL_ZONE, 'set': "Золотой инопланетянин"},
				{'title': "Синикус", 'location':ANOMAL_ZONE, 'set': "Золотой инопланетянин"},
				{'title': "Жёлтикус", 'location':ANOMAL_ZONE, 'set': "Золотой инопланетянин"},
				{'title': "Красникус", 'location':ANOMAL_ZONE, 'set': "Золотой инопланетянин"},
//140
				{'title': "Резиновые сапоги", 'location':STORM, 'set': "Золотой штурвал"},
				{'title': "Морской узел", 'location':STORM, 'set': "Золотой штурвал"},
				{'title': "Подзорная труба", 'location':STORM, 'set': "Золотой штурвал"},
				{'title': "Спасательный круг", 'location':STORM, 'set': "Золотой штурвал"},
				{'title': "Матросская шапка", 'location':STORM, 'set': "Золотой штурвал"},
//145
				{'title': "Морж", 'location':STORM, 'set': "Золотой морской котик"},
				{'title': "Пингвин", 'location':STORM, 'set': "Золотой морской котик"},
				{'title': "Белый медведь", 'location':STORM, 'set': "Золотой морской котик"},
				{'title': "Чайка", 'location':STORM, 'set': "Золотой морской котик"},
				{'title': "Кит", 'location':STORM, 'set': "Золотой морской котик"}
			],
			[
				{'title': "бабочка", 'location': FLY_ISLAND},
				{'title': "перо", 'location': FLY_ISLAND},
				{'title': "след", 'location': SNOW_FOREST},
				{'title': "череп", 'location': SNOW_FOREST},
				{'title': "паук", 'location': MARSH},
				{'title': "гриб", 'location': MARSH},
				{'title': "раковина", 'location': MARSH},
				{'title': "рыба", 'location': MARSH},
				{'title': "сущность", 'location': ANOMAL_ZONE},
				{'title': "инфузория", 'location': ANOMAL_ZONE},
				null,	//nokia
				{'title': "цеппелин", 'location': STORM},
				{'title': "скафандр", 'location': STORM},
				null,	//lego
				null,
				null,
				null,
				null,
				{'title': "саркофаг", 'location': DESERT},
				{'title': "лампа Джинна", 'location': DESERT},
				{'title': "нож-бабочка", 'location':BATTLE},
				{'title': "боеголовка", 'location':BATTLE},
				{'title': "робот", 'location':BATTLE},
				{'title': "танк", 'location':BATTLE},
				{'title': "гроздь", 'location':HARD},
				{'title': "консервная банка", 'location':HARD},
				{'title': "компас", 'location':HARD},
				{'title': "баллон кислорода", 'location':HARD},
				{'title': "верблюд", 'location':DESERT},
				{'title': "кактус", 'location':DESERT},
				{'title': "звездолёт", 'location':ANOMAL_ZONE},
				{'title': "инопланетянин", 'location':ANOMAL_ZONE},
				{'title': "штурвал", 'location':STORM},
				{'title': "морской котик", 'location':STORM}
			],
		];

		static public function get regularData():Array
		{
			return COLLECTIONS[TYPE_REGULAR];
		}

		static public function get uniqueData():Array
		{
			return COLLECTIONS[TYPE_UNIQUE];
		}
	}
}