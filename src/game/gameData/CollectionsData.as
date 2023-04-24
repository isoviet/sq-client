package game.gameData
{
	import flash.utils.getDefinitionByName;

	public class CollectionsData
	{
		//счетчики - должны инициализироваться раньше данных
		static private var type:int = 0;
		static private var collectionType:int = 0;

		static public const TYPE_REGULAR:int = type++;
		static public const TYPE_UNIQUE:int = type++;
		static public const TYPE_TROPHY:int = type++;

		static public const COLLECTION_BUTTERFLY:int = collectionType++;
		static public const COLLECTION_FEATHER:int = collectionType++;
		static public const COLLECTION_MARK:int = collectionType++;
		static public const COLLECTION_BONE:int = collectionType++;
		static public const COLLECTION_BEETLE:int = collectionType++;
		static public const COLLECTION_FUNGUS:int = collectionType++;
		static public const COLLECTION_SHELL:int = collectionType++;
		static public const COLLECTION_FISH:int = collectionType++;
		static public const COLLECTION_CRYSTAL:int = collectionType++;
		static public const COLLECTION_BACTERIUM:int = collectionType++;
		static public const REMOVED_1:int = collectionType++;
		static public const COLLECTION_AIRCRAFT:int = collectionType++;
		static public const COLLECTION_ANCHOR:int = collectionType++;
		static public const REMOVED_2:int = collectionType++;
		static public const REMOVED_3:int = collectionType++;
		static public const REMOVED_4:int = collectionType++;
		static public const REMOVED_5:int = collectionType++;
		static public const REMOVED_6:int = collectionType++;
		static public const COLLECTION_EGYPTIAN:int = collectionType++;
		static public const COLLECTION_ARABIC:int = collectionType++;
		static public const COLLECTION_COLD_WEAPON:int = collectionType++;
		static public const COLLECTION_FIREARM:int = collectionType++;
		static public const COLLECTION_ROBOTS:int = collectionType++;
		static public const COLLECTION_AFV:int = collectionType++;
		static public const COLLECTION_BERRIES:int = collectionType++;
		static public const COLLECTION_HIKE:int = collectionType++;
		static public const COLLECTION_EXTREME:int = collectionType++;
		static public const COLLECTION_LAKE:int = collectionType++;
		static public const COLLECTION_DESERT_ANIMAL:int = collectionType++;
		static public const COLLECTION_DESERT_PLANT:int = collectionType++;
		static public const COLLECTION_SPACESHIP:int = collectionType++;
		static public const COLLECTION_ALIEN:int = collectionType++;
		static public const COLLECTION_SEA:int = collectionType++;
		static public const COLLECTION_ICE_ANIMAL:int = collectionType++;

		static public const COLLECTION_ITEM_END:int = 150;

		static public const DATA:Array = [
			[
				{'icon': "ButterflyImage1",	'tittle': gls("Акватис"),		'collection': COLLECTION_BUTTERFLY,	'description': gls("Вестница дождя, желанный гость в жарких краях, несущий свежесть и прохладу.")},
				{'icon': "ButterflyImage2",	'tittle': gls("Эквитиа"),		'collection': COLLECTION_BUTTERFLY,	'description': gls("Символ равновесия. Жаркие цвета идеально сочетаются с прохладными, а форма крыльев преисполнена гармонии.")},
				{'icon': "ButterflyImage3",	'tittle': gls("Райская бабочка"),	'collection': COLLECTION_BUTTERFLY,	'description': gls("Всего несколько взмахов ее крыльев помогут вновь обрести потерянную надежду.")},
				{'icon': "ButterflyImage4",	'tittle': gls("Сакура портис"),		'collection': COLLECTION_BUTTERFLY,	'description': gls("Ее вид завораживает взгляд, а полет легок, как лепестки сакуры.")},
				{'icon': "ButterflyImage5",	'tittle': gls("Солярис"),		'collection': COLLECTION_BUTTERFLY,	'description': gls("Солнечная бабочка приносит свет даже в самые темные сердца.")},
//5
				{'icon': "FeatherImage1",	'tittle': gls("Перо Топазии"),		'collection': COLLECTION_FEATHER,	'description': gls("Птица Топазия редко живет в неволе и долго привыкает к хозяину, но привыкнув, защищает его от неудач.")},
				{'icon': "FeatherImage2",	'tittle': gls("Перо Жизни"),		'collection': COLLECTION_FEATHER,	'description': gls("Говорят, все живые существа — дети птицы Жизнь — появлялись там, где падали ее перья.")},
				{'icon': "FeatherImage3",	'tittle': gls("Перо Мимоса"),		'collection': COLLECTION_FEATHER,	'description': gls("Мимосы, подобно хамелеонам, способны менять цвет своих перьев. Иногда, чтобы их не было видно, а иногда наоборот.")},
				{'icon': "FeatherImage4",	'tittle': gls("Радужное Перо"),		'collection': COLLECTION_FEATHER,	'description': gls("Раз в год, в конце сезона дождей, миллионы ручейков и водопадов в Солнечных Долинах украшаются радугами. После этого, белки часто находят радужные перья.")},
				{'icon': "FeatherImage5",	'tittle': gls("Перо Феникса"),		'collection': COLLECTION_FEATHER,	'description': gls("С его помощью можно легко развести костер или согреть лапки.")},
//10
				{'icon': "MarkImage1",		'tittle': gls("След льва"),		'collection': COLLECTION_MARK,		'description': gls("Когда-то львы считались царями зверей. Конечно, это было до того, как белки освоили магию.")},
				{'icon': "MarkImage2",		'tittle': gls("След человека"),		'collection': COLLECTION_MARK,		'description': gls("Этот след сохранился с древних времен, когда люди и белки разговаривали на разных языках и не понимали друг друга.")},
				{'icon': "MarkImage3",		'tittle': gls("След енота"),		'collection': COLLECTION_MARK,		'description': gls("Еноты хитры, как лисы. У них очень ловкие и сильные лапки и красивая шкурка.")},
				{'icon': "MarkImage4",		'tittle': gls("След ворона"),		'collection': COLLECTION_MARK,		'description': gls("Вороны издревле ассоциируются с несчастьями, горем и смертью. Последнее время белочки все чаще видят их следы...")},
				{'icon': "MarkImage5",		'tittle': gls("След лося"),		'collection': COLLECTION_MARK,		'description': gls("Обычно лоси живут в северных болотистых лесах, а их широкие копыта позволяют ходить по трясине. Копыта этого лося слишком узки: скорее всего до ледникового периода он обитал в тропиках.")},
//15
				{'icon': "BoneImage1",		'tittle': gls("Тазовая кость"),		'collection': COLLECTION_BONE,		'description': gls("Формой напоминает ухо, Африку и младенца инопланетянина. Но на самом деле это всего лишь тазовая кость.")},
				{'icon': "BoneImage2",		'tittle': gls("Лопатка"),		'collection': COLLECTION_BONE,		'description': gls("Начинающие палеонтологи издалека могут перепутать эту кость с выпавшим клыком. Не повторяйте их ошибку!")},
				{'icon': "BoneImage3",		'tittle': gls("Кисть"),			'collection': COLLECTION_BONE,		'description': gls("Нам, белкам, кисти людей кажутся таким неудобными — совершенно невозможно цепляться за стволы деревьев.")},
				{'icon': "BoneImage4",		'tittle': gls("Ребра"),			'collection': COLLECTION_BONE,		'description': gls("Это не палеонтологическая находка; кто-то жарил свиные ребрышки и не убрал за собой.")},
				{'icon': "BoneImage5",		'tittle': gls("Кость питекантропа"),	'collection': COLLECTION_BONE,		'description': gls("Люди считают, что питекантропы — их давние предки. Какая разница? Все равно белки — вершина эволюции.")},
//20
				{'icon': "BeetleImage1",	'tittle': gls("Муравей"),		'collection': COLLECTION_BEETLE,	'description': gls("Способен поднимать грузы, в десятки раз превышающие его вес. Невероятно трудолюбив. В эти тяжелые времена многие берут с него пример.")},
				{'icon': "BeetleImage2",	'tittle': gls("Божья коровка"),		'collection': COLLECTION_BEETLE,	'description': gls("Неспроста считается талисманом и символом удачи. За свою жизнь может уничтожить несколько тысяч вредителей.")},
				{'icon': "BeetleImage3",	'tittle': gls("Ископаемая блоха"),	'collection': COLLECTION_BEETLE,	'description': gls("Древние блохи были  намного крупнее современных, но и они  переносили болезни и сосали кровь.")},
				{'icon': "BeetleImage4",	'tittle': gls("Таракан"),		'collection': COLLECTION_BEETLE,	'description': gls("Может пережить ядерную войну, ледниковый период и падение метеорита, но бессилен против янтаря.")},
				{'icon': "BeetleImage5",	'tittle': gls("Комар"),			'collection': COLLECTION_BEETLE,	'description': gls("Эти насекомые безумно докучают людям, но не белкам. Мягкая шерсть надежно защищает от комариных укусов.")},
//25
				{'icon': "FungusImage1",	'tittle': gls("Белый гриб"),		'collection': COLLECTION_FUNGUS,	'description': gls("В старину, когда люди говорили «гриб», чаще всего имелся ввиду именно этот вид.")},
				{'icon': "FungusImage2",	'tittle': gls("Лисичка"),		'collection': COLLECTION_FUNGUS,	'description': gls("Очень ценный съедобный гриб. Иногда применяется в медицинских целях.")},
				{'icon': "FungusImage3",	'tittle': gls("Подосиновик"),		'collection': COLLECTION_FUNGUS,	'description': gls("Этим названием объединяется целый род грибов. Но поскольку они все съедобны, мало кто их различает.")},
				{'icon': "FungusImage4",	'tittle': gls("Поганка"),		'collection': COLLECTION_FUNGUS,	'description': gls("Один из самых опасных и ядовитых грибов.")},
				{'icon': "FungusImage5",	'tittle': gls("Мухомор"),		'collection': COLLECTION_FUNGUS,	'description': gls("Не все мухоморы ядовиты. Но лучше не рисковать и оставить их для коллекции.")},
//30
				{'icon': "ShellImage1",		'tittle': gls("Морской гребешок"),	'collection': COLLECTION_SHELL,		'description': gls("Раковина морского гребешка — символ женского начала, источника жизни на земле.")},
				{'icon': "ShellImage2",		'tittle': gls("Мидия"),			'collection': COLLECTION_SHELL,		'description': gls("Мидии широко распространены — применяются в пищу практически во всем мире.")},
				{'icon': "ShellImage3",		'tittle': gls("Морской единорог"),	'collection': COLLECTION_SHELL,		'description': gls("Сказочный персонаж, очень популярен у мальков морских рыб и маленьких черепашат.")},
				{'icon': "ShellImage4",		'tittle': gls("Речная улитка"),		'collection': COLLECTION_SHELL,		'description': gls("Водится практически во всех пресных водоемах. Каким образом она очутилась на берегу Синего Моря — непонятно.")},
				{'icon': "ShellImage5",		'tittle': gls("Империус ползунус"),	'collection': COLLECTION_SHELL,		'description': gls("Королевская улитка встречается только на морских просторах Трагедии белок. Очень редкий экземпляр.")},
//35
				{'icon': "FishImage1",		'tittle': gls("Ледяная рыба"),		'collection': COLLECTION_FISH,		'description': gls("Обитает в очень холодных северных водах. Те, кому удавалось поймать такую рыбу, рассказывают, что в тепле она превращается в воду.")},
				{'icon': "FishImage2",		'tittle': gls("Рыба-пижон"),		'collection': COLLECTION_FISH,		'description': gls("У некоторых рыб дурной вкус — зеленые и оранжевые плавники, синее тело, черные полосы — все это просто ужасно сочетается друг с другом.")},
				{'icon': "FishImage3",		'tittle': gls("Анемоновая рыба"),	'collection': COLLECTION_FISH,		'description': gls("Морская рыбка, принадлежит семейству рыб-клоунов.")},
				{'icon': "FishImage4",		'tittle': gls("Рыба-хитер"),		'collection': COLLECTION_FISH,		'description': gls("Когда эта рыба злится или чувствует опасность, на ее теле появляются раскаленные красные полосы.")},
				{'icon': "FishImage5",		'tittle': gls("Рыба-гурман"),		'collection': COLLECTION_FISH,		'description': gls("Название получила благодаря окрасу, который напоминает лимон в салате.")},
//40
				{'icon': "CrystalImage1",	'tittle': gls("Сущность огня"),		'collection': COLLECTION_CRYSTAL,	'description': gls("Огонь может уничтожить целые города и леса. Но при этом без огня нет тепла, а без тепла нет жизни.")},
				{'icon': "CrystalImage2",	'tittle': gls("Сущность льда"),		'collection': COLLECTION_CRYSTAL,	'description': gls("Нельзя хранить лед на сердце — оно от этого черствеет. Лучше поставить сущность льда на полочку.")},
				{'icon': "CrystalImage3",	'tittle': gls("Сущность жизни"),	'collection': COLLECTION_CRYSTAL,	'description': gls("В Аномальной Зоне воля белок к победе материализовалась и превратилась в осязаемый предмет — сущность жизни.")},
				{'icon': "CrystalImage4",	'tittle': gls("Сущность тьмы"),		'collection': COLLECTION_CRYSTAL,	'description': gls("Не познав печали, нельзя почувствовать истинную радость. Без тьмы, невозможен свет.")},
				{'icon': "CrystalImage5",	'tittle': gls("Сущность света"),	'collection': COLLECTION_CRYSTAL,	'description': gls("Свет дарит надежду, даже в казалось бы безвыходных ситуациях. Вокруг белок еще много света!")},
//45
				{'icon': "BacteriumImage1",	'tittle': gls("Злобус"),		'collection': COLLECTION_BACTERIUM,	'description': gls("Одноклеточный сгусток злобы, готов ужалить любого, кто окажется рядом. Есть теория, что морские ежи произошли именно от Злобусов.")},
				{'icon': "BacteriumImage2",	'tittle': gls("Гринстар"),		'collection': COLLECTION_BACTERIUM,	'description': gls("Бассейн, пруд или фонтан, заполненный ими, ночью озаряется мягким и загадочным желто-зеленым светом.")},
				{'icon': "BacteriumImage3",	'tittle': gls("Могильная бактерия"),	'collection': COLLECTION_BACTERIUM,	'description': gls("Совершенно безопасна для большинства организмов, просто она очень похожа на могильный камень.")},
				{'icon': "BacteriumImage4",	'tittle': gls("Амеба"),			'collection': COLLECTION_BACTERIUM,	'description': gls("Один из самых распространенных одноклеточных организмов в Аномальной Зоне увеличился до размеров голубя.")},
				{'icon': "BacteriumImage5",	'tittle': gls("Стики"),			'collection': COLLECTION_BACTERIUM,	'description': gls("В естественных условиях этот вирус переносился ветром. В Аномальной Зоне сильно вырос и научился прыгать и цепляться за поверхности своими присосками.")},
//50
				{},	// nokia
				{},
				{},
				{},
				{},
//55
				{'icon': "AircraftImage1",	'tittle': gls("Пропеллер"),		'collection': COLLECTION_AIRCRAFT,	'description': gls("Поднимает в воздух самолёты и вертолёты, разгоняет катера и создает прохладу в жаркий день.")},
				{'icon': "AircraftImage2",	'tittle': gls("Крылья"),		'collection': COLLECTION_AIRCRAFT,	'description': gls("Нельзя просто взять крылья и взлететь. Но контролировать падение с их помощью — вполне возможно.")},
				{'icon': "AircraftImage3",	'tittle': gls("Дирижабль"),		'collection': COLLECTION_AIRCRAFT,	'description': gls("Самый величественный летательный аппарат. И как только 100-метровая махина помещается в кладовке?")},
				{'icon': "AircraftImage4",	'tittle': gls("Реактивный двигатель"),	'collection': COLLECTION_AIRCRAFT,	'description': gls("Позволяет развивать очень высокие скорости, если, конечно, получится найти авиационное топливо.")},
				{'icon': "AircraftImage5",	'tittle': gls("Антигравитатор"),	'collection': COLLECTION_AIRCRAFT,	'description': gls("Самый современный инструмент преодоления гравитации. Люди его еще не изобрели, а белочки уже им пользуются!")},
//60
				{'icon': "AnchorImage1",	'tittle': gls("Камень"),		'collection': COLLECTION_ANCHOR,	'description': gls("Штормовые ветра могут унести лёгких белочек в далекие земли. Этого можно избежать, если носить в карманах самые обычные камни.")},
				{'icon': "AnchorImage2",	'tittle': gls("Гиря"),			'collection': COLLECTION_ANCHOR,	'description': gls("Подобные гири стали редкостью, хотя совсем недавно их легко можно было найти в любом магазине.")},
				{'icon': "AnchorImage3",	'tittle': gls("Якорь"),			'collection': COLLECTION_ANCHOR,	'description': gls("Да, тяжелый якорь мешает прыгать по веткам, но можно не бояться быть унесённым сильным ветром.")},
				{'icon': "AnchorImage4",	'tittle': gls("Мешок с песком"),	'collection': COLLECTION_ANCHOR,	'description': gls("Очень сложно что-то разглядеть, когда сильный ветер поднимает стены песка. Гораздо лучше, если песок лежит в мешках и не слепит белочек.")},
				{'icon': "AnchorImage5",	'tittle': gls("Цепь"),			'collection': COLLECTION_ANCHOR,	'description': gls("Когда надвигается торнадо, лучше всего прятаться в погреб. Или приковать себя к большому дереву толстой цепью.")},
//65
				{},	// lego
				{},
				{},
				{},
				{},
//70
				{'icon': "EgyptImage1",		'tittle': gls("Скарабей"),		'collection': COLLECTION_EGYPTIAN,	'description': gls("Маленькое насекомое, которое повторяет путь Солнца с востока на запад. ")},
				{'icon': "EgyptImage2",		'tittle': gls("Анх"),			'collection': COLLECTION_EGYPTIAN,	'description': gls("Древний знак, ключ жизни. Символизирует жизнь, бессмертие, вечность, мудрость.")},
				{'icon': "EgyptImage3",		'tittle': gls("Пирамидка"),		'collection': COLLECTION_EGYPTIAN,	'description': gls("Маленькая фигурка в виде пирамиды. Хороший сувенир, напоминающий о путешествии в Пустыню.")},
				{'icon': "EgyptImage4",		'tittle': gls("Посох Фараона"),		'collection': COLLECTION_EGYPTIAN,	'description': gls("Символ власти. Всесильная рука, ведущая и оберегающая каждую душу через время и пространство.")},
				{'icon': "EgyptImage5",		'tittle': gls("Иероглиф Глаз"),		'collection': COLLECTION_EGYPTIAN,	'description': gls("Всевидящее око. Указывает путь, приносит удачу и спасает от неприятностей.")},
//75
				{'icon': "ArabicImage1",	'tittle': gls("Кинжал"),		'collection': COLLECTION_ARABIC,	'description': gls("Острейшее лезвие кинжала — верный помощник в любых делах.")},
				{'icon': "ArabicImage2",	'tittle': gls("Кальян"),		'collection': COLLECTION_ARABIC,	'description': gls("Тонкий и хрупкий инструмент для точного указания пути любому герою. Применять только в присутствии шамана.")},
				{'icon': "ArabicImage3",	'tittle': gls("Ковёр-самолёт"),		'collection': COLLECTION_ARABIC,	'description': gls("Самый надёжный транспорт в Пустыне.")},
				{'icon': "ArabicImage4",	'tittle': gls("Фигурка Змеи"),		'collection': COLLECTION_ARABIC,	'description': gls("Навершие посоха злодея — отличный трофей для сказочного героя.")},
				{'icon': "ArabicImage5",	'tittle': gls("Дудочка"),		'collection': COLLECTION_ARABIC,	'description': gls("Сказочный музыкальный инструмент. Поднимет настроение и спасёт от змей.")},
//80
				{'icon': "WeaponImage1",	'tittle': gls("Шпага"),			'collection': COLLECTION_COLD_WEAPON,	'description': gls("Своим точным колющим ударом шпага попадёт в любое незащищённое место противника. Лучшие фехтовальщики побеждают во всех сражениях.")},
				{'icon': "WeaponImage2",	'tittle': gls("Экскалибур"),		'collection': COLLECTION_COLD_WEAPON,	'description': gls("Меч короля Артура, обладающий магическими свойствами, выручит своего хозяина в любой ситуации. Твори волшебство вместе с легендой.")},
				{'icon': "WeaponImage3",	'tittle': gls("Секира"),		'collection': COLLECTION_COLD_WEAPON,	'description': gls("Уничтожить противника одним ударом легко. Воспользуйтесь секирой и победите.")},
				{'icon': "WeaponImage4",	'tittle': gls("Копьё"),			'collection': COLLECTION_COLD_WEAPON,	'description': gls("В скандинавской мифологии копьё — символ воинственности. Выберите противника, прицельтесь, бросайте.")},
				{'icon': "WeaponImage5",	'tittle': gls("Нунчаки"),		'collection': COLLECTION_COLD_WEAPON,	'description': gls("Данное восточное оружие наводит ужас на всех, кто хотя бы однажды сталкивался с ним. С Нунчаки вам нет равных.")},
//85
				{'icon': "ArmsImage1",		'tittle': gls("Обойма"),		'collection': COLLECTION_FIREARM,	'description': gls("Обойма объединяет несколько патронов. Перезаряжать оружие с её помощью легко и быстро.")},
				{'icon': "ArmsImage2",		'tittle': gls("Пушка"),			'collection': COLLECTION_FIREARM,	'description': gls("Пушкой можно смело стрелять по абсолютно любой цели: войскам, кораблям, танкам и т.д.")},
				{'icon': "ArmsImage3",		'tittle': gls("Огнемёт"),		'collection': COLLECTION_FIREARM,	'description': gls("Огнемёт — оружие, поражающее цель огнесмесью. Страшно попасться у него на пути.")},
				{'icon': "ArmsImage4",		'tittle': gls("Маузер"),		'collection': COLLECTION_FIREARM,	'description': gls("Маузер — самозарядный пистолет, неотъемлемая часть образа чекиста или комиссара.")},
				{'icon': "ArmsImage5",		'tittle': gls("Базука"),		'collection': COLLECTION_FIREARM,	'description': gls("Базука — ручной противотанковый гранатомёт, переносная ракетная установка.")},
//90
				{'icon': "RobotImage1",		'tittle': gls("Шестерня"),		'collection': COLLECTION_ROBOTS,	'description': gls("Шестерня — основная деталь в виде диска с зубьями, необходимая каждому роботу.")},
				{'icon': "RobotImage2",		'tittle': gls("Аккумулятор"),		'collection': COLLECTION_ROBOTS,	'description': gls("Ни один робот не сможет функционировать без источника энергии. Аккумулятор роботу просто необходим.")},
				{'icon': "RobotImage3",		'tittle': gls("Процессор"),		'collection': COLLECTION_ROBOTS,	'description': gls("Процессор — это «сердце» и «мозг» робота. Без этой детали робот — обычная груда железа.")},
				{'icon': "RobotImage4",		'tittle': gls("Сервопривод"),		'collection': COLLECTION_ROBOTS,	'description': gls("Сервопривод позволяет точно управлять параметрами движения робота. Задайте роботу программу, и он отправится, куда скажете.")},
				{'icon': "RobotImage5",		'tittle': gls("Электромотор"),		'collection': COLLECTION_ROBOTS,	'description': gls("Электромотор — это, конечно, не вечный двигатель, но тоже необходимая роботу деталь.")},
//95
				{'icon': "AfvImage1",		'tittle': gls("Снаряд"),		'collection': COLLECTION_AFV,		'description': gls("Снаряд — средство поражения, выстреливаемое из артиллерийского орудия. Удар снаряда может быть как мгновенным, так и замедленным.")},
				{'icon': "AfvImage2",		'tittle': gls("Рация"),			'collection': COLLECTION_AFV,		'description': gls("Связаться с товарищами и обсудить план действий легко и просто, когда у вас в кармане рация - переносное приёмопередающее устройство.")},
				{'icon': "AfvImage3",		'tittle': gls("Гусеница"),		'collection': COLLECTION_AFV,		'description': gls("Быстрое и эффективное средство передвижения в Битвах? Конечно, танк. Но никакой танк не сдвинется с места без гусеничной ленты.")},
				{'icon': "AfvImage4",		'tittle': gls("Шлемофон"),		'collection': COLLECTION_AFV,		'description': gls("Шлемофон - важный атрибут формы танкистов. Защита и тепло - его главные свойства.")},
				{'icon': "AfvImage5",		'tittle': gls("ДВС"),			'collection': COLLECTION_AFV,		'description': gls("Двигатель внутреннего сгорания — тепловой двигатель, использовать который можно практически в любом устройстве.")},
//100
				{'icon': "BerriesImage1",	'tittle': gls("Рябина"),		'collection': COLLECTION_BERRIES,	'description': gls("Ягоды рябины обладают массой полезных свойств. В отличие от большинства других ягод, плоды рябины собирают осенью, а не летом.")},
				{'icon': "BerriesImage2",	'tittle': gls("Черника"),		'collection': COLLECTION_BERRIES,	'description': gls("Нет ничего вкуснее черничного варенья и киселя. Ягоды черники легко найти в лесах и на болотах.")},
				{'icon': "BerriesImage3",	'tittle': gls("Клубника"),		'collection': COLLECTION_BERRIES,	'description': gls("Яркие ягоды клубники не только радуют глаз, но и очень приятны на вкус. Всегда смотрите под ноги, идя по лесу, возможно, вы вот-вот наступите на клубничку.")},
				{'icon': "BerriesImage4",	'tittle': gls("Вишня"),			'collection': COLLECTION_BERRIES,	'description': gls("Дикая вишня — самая вкусная, красивая и распространённая ягода, которую вы можете найти.")},
				{'icon': "BerriesImage5",	'tittle': gls("Малина"),		'collection': COLLECTION_BERRIES,	'description': gls("Вырваться из кустарников малины без царапин непросто, но риск того стоит. Малина не только приятна на вкус, но и легко вылечит простуду.")},
//105
				{'icon': "HikeImage1",		'tittle': gls("Рюкзак"),		'collection': COLLECTION_HIKE,		'description': gls("Сложить всё самое необходимое лучше всего в рюкзак. Тащить тяжести на спине проще, чем в руках.")},
				{'icon': "HikeImage2",		'tittle': gls("Аптечка"),		'collection': COLLECTION_HIKE,		'description': gls("В поход без аптечки никак нельзя. В лесах и горах путников поджидает множество опасностей.")},
				{'icon': "HikeImage3",		'tittle': gls("Палатка"),		'collection': COLLECTION_HIKE,		'description': gls("Для тех, кто не любит смотреть в ночное небо, палатка просто необходима: тепло и уют ждут путников внутри.")},
				{'icon': "HikeImage4",		'tittle': gls("Походный фонарь"),	'collection': COLLECTION_HIKE,		'description': gls("Двигаться в лесу на ощупь — занятие не из приятных. Фонарь в пути приведёт вас к успеху.")},
				{'icon': "HikeImage5",		'tittle': gls("Столовые приборы"),	'collection': COLLECTION_HIKE,		'description': gls("Даже в дикой местности нужно соблюдать приличия. Столовые приборы помогут вам не забыть правила этикета.")},
//110
				{'icon': "ExtremeImage1",	'tittle': gls("Парашют"),		'collection': COLLECTION_EXTREME,	'description': gls("Для любителей острых ощущений прыжки с парашютом — лучшее, что можно придумать.")},
				{'icon': "ExtremeImage2",	'tittle': gls("Перчатки"),		'collection': COLLECTION_EXTREME,	'description': gls("Стёртые руки — не самое лучшее, что может произойти в пути. В специальных перчатках руки защищены и от холода, и от внешних раздражителей.")},
				{'icon': "ExtremeImage3",	'tittle': gls("Фляжка"),		'collection': COLLECTION_EXTREME,	'description': gls("Без воды заниматься экстремальным спортом просто невозможно. Фляжка обязательна должна быть прикреплена к вашему снаряжению.")},
				{'icon': "ExtremeImage4",	'tittle': gls("Карабин"),		'collection': COLLECTION_EXTREME,	'description': gls("Карабины выдерживают значительные нагрузки и абсолютно необходимы при скалолазании. Обязательно проверьте защёлку перед использованием.")},
				{'icon': "ExtremeImage5",	'tittle': gls("Кирка"),			'collection': COLLECTION_EXTREME,	'description': gls("Взобраться на обледенелую гору — задача непростая. Цепляться киркой — единственная возможность добраться до вершины.")},
//115
				{'icon': "LakeImage1",		'tittle': gls("Камыши"),		'collection': COLLECTION_LAKE,		'description': gls("Камыш — растение, из которого можно сплести множество полезных вещей. Коврики, сумки, корзины — всё, что может пригодиться в испытаниях.")},
				{'icon': "LakeImage2",		'tittle': gls("Бумажный кораблик"),	'collection': COLLECTION_LAKE,		'description': gls("В пути всегда можно сделать перерыв и, смастерив бумажный кораблик, запустить его в воду.")},
				{'icon': "LakeImage3",		'tittle': gls("Маска для дайвинга"),	'collection': COLLECTION_LAKE,		'description': gls("Зрение — один из самых важных органов чувств. И даже под водой необходимо видеть, что происходит вокруг. В этом вам поможет маска.")},
				{'icon': "LakeImage4",		'tittle': gls("Лягушка"),		'collection': COLLECTION_LAKE,		'description': gls("Многие лягушки выделяют ядовитые вещества. С этими, на первый взгляд безобидными, животными стоит быть острожными.")},
				{'icon': "LakeImage5",		'tittle': gls("Ласты"),			'collection': COLLECTION_LAKE,		'description': gls("Быстро уплыть от опасности вам помогут ласты. Прежде чем нырять, обязательно наденьте их на ноги.")},
//120
				{'icon': "DesertAnimal1",	'tittle': gls("Змея"),			'collection': COLLECTION_DESERT_ANIMAL,	'description': gls("Определить, ядовитая перед вами змея или нет, не так-то просто. Главное, не выяснять это опытным путём.")},
				{'icon': "DesertAnimal2",	'tittle': gls("Пустынная мышь"),	'collection': COLLECTION_DESERT_ANIMAL,	'description': gls("Милое маленькое серое существо, необъяснимо пугающие миллионы. Приглядитесь, возможно, пустынная мышка понравится вам.")},
				{'icon': "DesertAnimal3",	'tittle': gls("Скорпион"),		'collection': COLLECTION_DESERT_ANIMAL,	'description': gls("Скорпионы — древнейший и самый опасный отряд членистоногих. Некоторые скорпионы убивают своим ядовитым жалом мгновенно.")},
				{'icon': "DesertAnimal4",	'tittle': gls("Ящерица"),		'collection': COLLECTION_DESERT_ANIMAL,	'description': gls("Ловить ящерицу за хвост — бессмысленная трата времени. Она оставит вам его в подарок, а себе отрастит новый.")},
				{'icon': "DesertAnimal5",	'tittle': gls("Паук"),			'collection': COLLECTION_DESERT_ANIMAL,	'description': gls("Пауки в пустыне значительно отличаются от своих домашних собратьев. В первую очередь, размером. Встретив такого паука на своём пути, вы совершенно точно захотите его обойти.")},
//125
				{'icon': "PlantsImage1",	'tittle': gls("Маммиллярия"),		'collection': COLLECTION_DESERT_PLANT,	'description': gls("Маммиллярия — кактус, способный адаптироваться к самому жаркому и засушливому климату.")},
				{'icon': "PlantsImage2",	'tittle': gls("Опунция"),		'collection': COLLECTION_DESERT_PLANT,	'description': gls("У ацтеков Опунция — символ силы и выносливости. Самый популярный кактус, отождествляющийся с божеством.")},
				{'icon': "PlantsImage3",	'tittle': gls("Пальма"),		'collection': COLLECTION_DESERT_PLANT,	'description': gls("В пустыне трудно найти место, где можно укрыться от палящего солнца. Пальма откидывает тень, чем может спасти жизнь бедному путнику.")},
				{'icon': "PlantsImage4",	'tittle': gls("Перекати-поле"),		'collection': COLLECTION_DESERT_PLANT,	'description': gls("Перекати-поле — травянистые растения, произрастающие в степных или пустынных районах. Вы можете встретить их в заброшенных, засушливых и безлюдных местах.")},
				{'icon': "PlantsImage5",	'tittle': gls("Сухая акация"),		'collection': COLLECTION_DESERT_PLANT,	'description': gls("В пустыне погибает множество деревьев, засохшие коряги встречаются здесь на каждом шагу.")},
//130
				{'icon': "SpaceshipImage1",	'tittle': gls("Нептун"),		'collection': COLLECTION_SPACESHIP,	'description': gls("Звездолёт «Нептун» назван в честь самой дальней планеты Солнечной системы, потому что способен развивать самую большую скорость среди других кораблей.")},
				{'icon': "SpaceshipImage2",	'tittle': gls("Марс"),			'collection': COLLECTION_SPACESHIP,	'description': gls("Римский бог войны благоволит к Звездолёту, названному в его честь. В межгалактических боях «Марс» непобедим.")},
				{'icon': "SpaceshipImage3",	'tittle': gls("Венера"),		'collection': COLLECTION_SPACESHIP,	'description': gls("Единственный и неповторимый звездолёт, названный в честь женского божества.")},
				{'icon': "SpaceshipImage4",	'tittle': gls("Сатурн"),		'collection': COLLECTION_SPACESHIP,	'description': gls("Самый большой звездолёт во всей галактике. В длину и ширину достигает 1,5 километров.")},
				{'icon': "SpaceshipImage5",	'tittle': gls("Плутон"),		'collection': COLLECTION_SPACESHIP,	'description': gls("Самый последний и самый маленький построенный звездолёт за последние 10 лет.")},
//135
				{'icon': "AlienImage1",		'tittle': gls("Зелёникус"),		'collection': COLLECTION_ALIEN,		'description': gls("Несмотря на свою схожесть с Циклопами, Зелёникусы видят лучше всех живых существ в мире.")},
				{'icon': "AlienImage2",		'tittle': gls("Сиреневикус"),		'collection': COLLECTION_ALIEN,		'description': gls("Существ умнее Сиреневикусов ещё надо поискать. И скорее всего не найдёте, их интеллект приравнивается к гениям.")},
				{'icon': "AlienImage3",		'tittle': gls("Синикус"),		'collection': COLLECTION_ALIEN,		'description': gls("Синикусы ведут себя как маленькие дети. Подарив Синикусу игрушку, вы займёте его на целый день.")},
				{'icon': "AlienImage4",		'tittle': gls("Жёлтикус"),		'collection': COLLECTION_ALIEN,		'description': gls("Долговязые и неуклюжие Жёлтикусы — миролюбивый народ. Если завтра начнётся межгалактическая война, они точно останутся в стороне.")},
				{'icon': "AlienImage5",		'tittle': gls("Красникус"),		'collection': COLLECTION_ALIEN,		'description': gls("Самые позитивные существа в галактике. Могут рассмешить любого и посмеяться над всем, что им говорят.")},
//140
				{'icon': "SeaImage1",		'tittle': gls("Резиновые сапоги"),	'collection': COLLECTION_SEA,		'description': gls("Промокшие ноги приводят к простуде. Резиновые сапоги — незаменимая вещь в морском путешествии.")},
				{'icon': "SeaImage2",		'tittle': gls("Морской узел"),		'collection': COLLECTION_SEA,		'description': gls("Любой моряк знает как минимум пятнадцать способов завязать морской узел. Но самый крепкий только один.")},
				{'icon': "SeaImage3",		'tittle': gls("Подзорная труба"),	'collection': COLLECTION_SEA,		'description': gls("Способностью увидеть землю издалека обладает только капитан кораблю. Помочь ему в этом может только подзорная труба.")},
				{'icon': "SeaImage4",		'tittle': gls("Спасательный круг"),	'collection': COLLECTION_SEA,		'description': gls("Спасение утопающих — дело рук самих утопающих. Ну, конечно, не без помощи спасательного круга.")},
				{'icon': "SeaImage5",		'tittle': gls("Матросская шапка"),	'collection': COLLECTION_SEA,		'description': gls("У каждого матроса должен быть свой отличительный знак. Матросская шапка идеально вписывается в образ моряка.")},
//145
				{'icon': "AnimalImage1",	'tittle': gls("Морж"),			'collection': COLLECTION_ICE_ANIMAL,	'description': gls("Пробить лёд для моржа не проблема. В этом ему помогают его огромные бивни, также при помощи них он вылезает из воды.")},
				{'icon': "AnimalImage2",	'tittle': gls("Пингвин"),		'collection': COLLECTION_ICE_ANIMAL,	'description': gls("В воде пингвины способны развивать рекордно высокую скорость. В холодных водах им нет равных.")},
				{'icon': "AnimalImage3",	'tittle': gls("Белый медведь"),		'collection': COLLECTION_ICE_ANIMAL,	'description': gls("Самый большой сухопутный хищник, белый медведь для эскимосов воплощает грозную силу природы.")},
				{'icon': "AnimalImage4",	'tittle': gls("Чайка"),			'collection': COLLECTION_ICE_ANIMAL,	'description': gls("Чайки — обитающие на морских просторах птицы, с лёгкостью скрывающиеся от крупных хищников при помощи своей неяркой, но всё же очень красивой окраски.")},
				{'icon': "AnimalImage5",	'tittle': gls("Кит"),			'collection': COLLECTION_ICE_ANIMAL,	'description': gls("Киты — самые большие животные в мире. Даже находясь под водой, киты дышат воздухом при помощи лёгких.")}
			],
			[
				{'icon': "ButterflyImageGold",	'tittle': gls("Золотая бабочка"),	'exp': 200,	'collectionName': gls("Бабочки"), 		'set': [0, 1, 2, 3, 4],		'collectorDescription': gls("Собери полный набор <b>бабочек</b> в <b>Солнечных Долинах</b>."),		'description': gls("Слишком тяжела, чтобы летать, но идеальна в качестве брошки.")},
				{'icon': "FeatherImageGold",	'tittle': gls("Золотое перо"),		'exp': 200,	'collectionName': gls("Пёрышки"),		'set': [5, 6, 7, 8, 9],		'collectorDescription': gls("Собери полный набор <b>перышек</b> в <b>Солнечных Долинах</b>."),		'description': gls("Золотой птицы, к сожалению, не существует. Тем почетнее иметь золотое перо.")},
				{'icon': "MarkImageGold",	'tittle': gls("Золотой след"),		'exp': 200,	'collectionName': gls("Следы на снегу"),	'set': [10, 11, 12, 13, 14],	'collectorDescription': gls("Собери полный набор <b>следов на снегу</b> в <b>Солнечных Долинах</b>."),	'description': gls("Подобные следы можно найти на Аллее Славы. Или в Трагедии Белок.")},
				{'icon': "BoneImageGold",	'tittle': gls("Золотой череп"),		'exp': 200,	'collectionName': gls("Кости"),			'set': [15, 16, 17, 18, 19],	'collectorDescription': gls("Собери полный набор <b>костей</b> в <b>Солнечных Долинах</b>."),		'description': gls("Череп, выполнен из мягкого золота 958 пробы. Поэтому обращаться с этим артефактом необходимо с крайней осторожностью.")},
				{'icon': "BeetleImageGold",	'tittle': gls("Золотой паук"),		'exp': 400,	'collectionName': gls("Насекомые в янтаре"),	'set': [20, 21, 22, 23, 24],	'collectorDescription': gls("Собери полный набор <b>насекомых в янтаре</b> в <b>Топях</b>."),		'description': gls("Не каждый день в природе встречаются слитки полупрозрачного золота. Еще реже можно найти останки древних насекомых в них.")},
				{'icon': "FungusImageGold",	'tittle': gls("Золотой гриб"),		'exp': 400,	'collectionName': gls("Грибы"),			'set': [25, 26, 27, 28, 29],	'collectorDescription': gls("Собери полный набор <b>грибов</b> в <b>Топях</b>."),			'description': gls("На нижней поверхности шляпки полустертыми буквами написано: «Вручить победителю XVII ежегодной летней олимпиады грибников».")},
				{'icon': "ShellImageGold",	'tittle': gls("Золотая раковина"),	'exp': 400,	'collectionName': gls("Ракушки"),		'set': [30, 31, 32, 33, 34],	'collectorDescription': gls("Собери полный набор <b>раковин</b> в <b>Топях</b>."),			'description': gls("Ходят слухи о том, что существует Золотая Лагуна с Бриллиантовыми кораллами, Изумрудными черепахами, птицей Топазией и Золотыми моллюсками. Но до сих пор ее никто не смог найти.")},
				{'icon': "FishImageGold",	'tittle': gls("Золотая рыба"),		'exp': 400,	'collectionName': gls("Рыбы"),			'set': [35, 36, 37, 38, 39],	'collectorDescription': gls("Собери полный набор <b>рыбок</b> в <b>Топях</b>."),			'description': gls("Не умеет исполнять желаний. Хотя... Чего может желать тот, у кого есть рыба из золота?")},
				{'icon': "CrystalImageGold",	'tittle': gls("Золотая сущность"),	'exp': 800,	'collectionName': gls("Сущности"),		'set': [40, 41, 42, 43, 44],	'collectorDescription': gls("Собери полный набор <b>сущностей</b> в <b>Аномальной Зоне</b>."),		'description': gls("В одних людях золото пробуждает жадность, а в других — щедрость. Золотая сущность, как зеркало души, покажет истинное лицо своего обладателя.")},
				{'icon': "BacteriumImageGold",	'tittle': gls("Золотая инфузория"),	'exp': 800,	'collectionName': gls("Микроорганизмы"),	'set': [45, 46, 47, 48, 49],	'collectorDescription': gls("Собери полный набор <b>микроорганизмов</b> в <b>Аномальной Зоне</b>."),	'description': gls("Обитает исключительно в гламурно-розовой среде. Рефлекторно тянется к блестяшкам в надежде симбиоза. Сильно развит клубный рефлекс.")},
				{},	//nokia
				{'icon': "AircraftImageGold",	'tittle': gls("Золотой цеппелин"),	'exp': 600,	'collectionName': gls("Летательные аппараты"),	'set': [55, 56, 57, 58, 59],	'collectorDescription': gls("Собери полный набор <b>летательных аппаратов</b> в <b>Шторме</b>."),	'description': gls("Золотой цеппелин сможет взлететь на воздух только если его начинить динамитом. С другой стороны, на земле намного безопаснее, чем в небе.")},
				{'icon': "AnchorImageGold",	'tittle': gls("Золотой скафандр"),	'exp': 600,	'collectionName': gls("Грузы"), 		'set': [60, 61, 62, 63, 64],	'collectorDescription': gls("Собери полный набор <b>грузов</b> в <b>Шторме</b>."),			'description': gls("Золотой скафандр — вещь полезная. Его можно надевать во время песчаных бурь, для защиты. А можно переплавить на кольца и серёжки, для красоты.")},
				{},	//lego
				{},
				{},
				{},
				{},
				{'icon': "EgyptImageGold",	'tittle': gls("Золотой саркофаг"),		'exp': 700,	'collectionName': gls("Набор Странника"),	'set': [70, 71, 72, 73, 74],		'collectorDescription': gls("Собери полный <b>набор Странника</b> в <b>Пустыне</b>."),			'description': gls("Транспорт для последнего путешествия. Лодка, в которой можно проплыть по реке Жизни, чтобы попасть в другие миры.")},
				{'icon': "ArabicImageGold",	'tittle': gls("Золотая лампа Джинна"),		'exp': 700,	'collectionName': gls("Сказочный набор"),	'set': [75, 76, 77, 78, 79],		'collectorDescription': gls("Собери полный <b>Сказочный набор</b> в <b>Пустыне</b>."),			'description': gls("Именно в таких лампах заточали древних Джиннов. Не побоишься проверить, есть ли Джинн здесь?")},
				{'icon': "WeaponImageGold",	'tittle': gls("Золотой нож-бабочка"),		'exp': 200,	'collectionName': gls("Холодное оружие"),	'set': [80, 81, 82, 83, 84],		'collectorDescription': gls("Собери полный набор <b>Холодного оружия</b> в <b>Битве</b>."),		'description': gls("В отличие от другого оружия, нож-бабочку легко спрятать, главное, чтобы он не блеснул своим золотом в самый неподходящий момент.")},
				{'icon': "ArmsImageGold",	'tittle': gls("Золотая ядерная боеголовка"),	'exp': 200,	'collectionName': gls("Огнестрельное оружие"),	'set': [85, 86, 87, 88, 89],		'collectorDescription': gls("Собери полный набор <b>Огнестрельного оружия</b> в <b>Битве</b>."),	'description': gls("Конечно, золотая боеголовка, пускай и ядерная, в битве поможет вряд ли, но как трофей её использовать можно.")},
				{'icon': "RobotImageGold",	'tittle': gls("Золотой робот"),			'exp': 200,	'collectionName': gls("Робототехника"),		'set': [90, 91, 92, 93, 94],		'collectorDescription': gls("Собери полный набор <b>Робототехники</b> в <b>Битве</b>."),		'description': gls("Золотой робот не только красивый элемент вашей коллекции, но и очень полезная вещь.")},
				{'icon': "AfvImageGold",	'tittle': gls("Золотой танк"),			'exp': 200,	'collectionName': gls("Бронетехника"),		'set': [95, 96, 97, 98, 99],		'collectorDescription': gls("Собери полный набор <b>Бронетехники</b> в <b>Битве</b>."),			'description': gls("На золотом танке далеко не уедешь, но зато всех победить его обладатель сможет с легкостью.")},
				{'icon': "BerriesImageGold",	'tittle': gls("Золотая гроздь"),		'exp': 700,	'collectionName': gls("Ягоды"),			'set': [100, 101, 102, 103, 104],	'collectorDescription': gls("Собери полный набор <b>Ягод</b> в <b>Испытаниях</b>."),			'description': gls("Золотая гроздь винограда — лучшая награда в испытаниях. Украсит вашу полку трофеев, выгодно выделяясь на фоне остальных.")},
				{'icon': "HikeImageGold",	'tittle': gls("Золотая консервная банка"),	'exp': 700,	'collectionName': gls("Походная экипировка"),	'set': [105, 106, 107, 108, 109],	'collectorDescription': gls("Собери полный набор <b>Походной Экипировки</b> в <b>Испытаниях</b>."),	'description': gls("Консервная банка — не самый распространённый золотой предмет. Тем ценнее его свойства.")},
				{'icon': "ExtremeImageGold",	'tittle': gls("Золотой компас"),		'exp': 700,	'collectionName': gls("Набор для экстрима"),	'set': [110, 111, 112, 113, 114],	'collectorDescription': gls("Собери полный набор <b>для экстрима</b> в <b>Испытаниях</b>."),		'description': gls("Золотой компас обладает магическими свойствами. Возможно, он укажет вам не только на север, но и на сокровища.")},
				{'icon': "LakeImageGold",	'tittle': gls("Золотой баллон кислорода"),	'exp': 700,	'collectionName': gls("Водная коллекция"),	'set': [115, 116, 117, 118, 119],	'collectorDescription': gls("Собери полный набор <b>Водной коллекции</b> в <b>Испытаниях</b>."),	'description': gls("Без кислорода выжить невозможно. Пусть золотой баллон и тяжелее обычного, зато не менее эффективный.")},
				{'icon': "DesertAnimalGold",	'tittle': gls("Золотой верблюд"),		'exp': 700,	'collectionName': gls("Животные пустыни"),	'set': [120, 121, 122, 123, 124],	'collectorDescription': gls("Собери полный набор <b>Животных</b> в <b>Пустыне</b>."),			'description': gls("Верблюд из золота может обходиться без воды ещё дольше, чем обычный. Полезная вещь в пустыне.")},
				{'icon': "PlantsImageGold",	'tittle': gls("Золотой кактус"),		'exp': 700,	'collectionName': gls("Растения пустыни"),	'set': [125, 126, 127, 128, 129],	'collectorDescription': gls("Собери полный набор <b>Растений </b> в <b>Пустыне</b>."),			'description': gls("Золотой кактус совершенно не опасен, в отличие от своих зелёных колючих собратьев, более того, стоя на окне, он будет наглядно демонстрировать успешность своего хозяина.")},
				{'icon': "SpaceshipImageGold",	'tittle': gls("Золотой звездолёт"),		'exp': 800,	'collectionName': gls("Звездолёты"),		'set': [130, 131, 132, 133, 134],	'collectorDescription': gls("Собери полный набор <b>Звездолётов</b> в <b>Аномальной зоне</b>."),	'description': gls("Золотой звездолёт выдаётся только почётным капитанам кораблей. Заслужить его крайне сложно.")},
				{'icon': "AlienImageGold",	'tittle': gls("Золотой инопланетянин"),		'exp': 800,	'collectionName': gls("Инопланетяне"),		'set': [135, 136, 137, 138, 139],	'collectorDescription': gls("Собери полный набор <b>Инопланетян</b> в <b>Аномальной зоне</b>."),	'description': gls("Золотой инопланетянин — глава всех инопланетных рас. Его слово — закон. Стать им может только наимудрейший из мудрейших.")},
				{'icon': "SeaImageGold",	'tittle': gls("Золотой штурвал"),		'exp': 600,	'collectionName': gls("Морская коллекция"),	'set': [140, 141, 142, 143, 144],	'collectorDescription': gls("Собери полный набор <b>Морской коллекции</b> в <b>Шторме</b>."),		'description': gls("Судно с золотым штурвалом автоматически попадает на первое место в рейтинге кораблей. Золотой штурвал ведёт к успеху и богатству.")},
				{'icon': "AnimalImageGold",	'tittle': gls("Золотой морской котик"),		'exp': 600,	'collectionName': gls("Обитатели льдов"),	'set': [145, 146, 147, 148, 149],	'collectorDescription': gls("Собери полный набор <b>Обитателей льдов</b> в <b>Шторме</b>."),		'description': gls("На лежбище золотой морской котик заметен сразу. Он выгодно выделяется на фоне своих собратьев с тёмной шёрсткой.")}
			],
			[
				{'icon': "CollectionScratPrizeImage",			'tittle': gls("Скрэт"),			'clothesId': OutfitData.SCRAT,			'awardText': gls("Теперь ты можешь играть за нового персонажа!"),	'description': gls("Чтобы получить нового персонажа, собери указанную коллекцию. Скрэт умеет переносить орех и излучает любовь с помощью магии.")},
				{},	//lego
				{'icon': "CollectionScrattyPrizeImage",			'tittle': gls("Скрэтти"),		'clothesId': OutfitData.SCRATTY,		'awardText': gls("Теперь ты можешь играть за нового персонажа!"),	'description': gls("Чтобы получить нового персонажа, собери указанную коллекцию. Скрэтти умеет переносить орех и излучает любовь с помощью магии.")},

				{'icon': "CollectionIronScratPrizeImage",		'tittle': gls("Железный Скрэт"),	'clothesId': OutfitData.SCRAT_METAL,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Железный экзоскелет — полезная в хозяйстве вещь. Ведь если ты Скрэт, то ты готов на всё ради орешка. Прочная красно-золотая броня надёжно защитит тебя от падений, непогоды, сглазов и плохого настроения!")},
				{'icon': "CollectionIronScrattyPrizeImage",		'tittle': gls("Железная Скрэтти"),	'clothesId': OutfitData.SCRATTY_METAL,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Железный экзоскелет — полезная в хозяйстве вещь. Ведь если ты Скрэтти, то ты готов на всё ради орешка. Прочная красно-золотая броня надёжно защитит тебя от падений, непогоды, сглазов и плохого настроения!")},

				{'icon': "CollectionDragonScratPrizeImage",		'tittle': gls("Скрэт-Гаргул"),		'clothesId': OutfitData.SCRAT_DRAGON,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Гаргульи, как дети, - шаловливые и непоседливые. К сожалению их забавы частенько приводят к сломанным стульям и рассыпанным орехам. Поэтому многие взрослые белки их недолюбливают.")},
				{'icon': "CollectionDragonScrattyPrizeImage",		'tittle': gls("Скрэтти-Гаргулья"),	'clothesId': OutfitData.SCRATTY_DRAGON,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Гаргульи, как дети, - шаловливые и непоседливые. К сожалению их забавы частенько приводят к сломанным стульям и рассыпанным орехам. Поэтому многие взрослые белки их недолюбливают.")},

				{'icon': "CollectionMagicianScratPrizeImage",		'tittle': gls("Скрэт-Фокусник"),	'clothesId': OutfitData.SCRAT_JUGGLER,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Белочки тоже хотят верить в чудеса! И в этом им помогает иллюзионист, мастер трюков - Фокусник. Подходите ближе и смотрите внимательней! Возможно, ты разгадаешь секрет фокуса... А может, это и есть самая настоящая магия.")},
				{'icon': "CollectionMagicianScrattyPrizeImage",		'tittle': gls("Скрэтти-Фокусница"),	'clothesId': OutfitData.SCRATTY_JUGGLER,	'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Белочки тоже хотят верить в чудеса! И в этом им помогает иллюзионист, мастер трюков - Фокусник. Подходите ближе и смотрите внимательней! Возможно, ты разгадаешь секрет фокуса... А может, это и есть самая настоящая магия.")},

				{'icon': "CollectionVampireScratPrizeImage",		'tittle': gls("Скрэт-Вампир"),		'clothesId': OutfitData.SCRAT_VAMPYRE,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Держитесь подальше от тех, кто облачён во мрак! Скрэты-Вампиры - древние и опасные существа. Этот костюм мгновенно наводит ужас на смертных белок!")},
				{'icon': "CollectionVampireScrattyPrizeImage",		'tittle': gls("Скрэтти-Вампир"),	'clothesId': OutfitData.SCRATTY_VAMPYRE,	'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Держитесь подальше от тех, кто облачён во мрак! Скрэтти-Вампиры - древние и опасные существа. Этот костюм мгновенно наводит ужас на смертных белок!")},

				{'icon': "CollectionHatterScratPrizeImage",		'tittle': gls("Скрэт-Шляпник"),		'clothesId': OutfitData.SCRAT_HATTER,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Безумный Скрэт? Такого вы ещё не видели! Никто в столь ярком и примечательном костюме не останется незаметным. Сила Шляпника не в магии, а в его непредсказуемости!")},
				{'icon': "CollectionHatterScrattyPrizeImage",		'tittle': gls("Скрэтти-Шляпница"),	'clothesId': OutfitData.SCRATTY_HATTER,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Безумная Скрэтти? Такого вы ещё не видели! Никто в столь ярком и примечательном костюме не останется незаметным. Сила Шляпницы не в магии, а в её непредсказуемости!")},

				{'icon': "CollectionSkeletonScratPrizeImage",		'tittle': gls("Скрэт-Скелет"),		'clothesId': OutfitData.SCRAT_SKELETON,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Не всем белкам удаётся чудесно выглядеть, только что встав из могилы. Скрэт-Скелет - счастливое исключение. Но всё же иногда у него вполне получается напугать других белок.")},
				{'icon': "CollectionSkeletonScrattyPrizeImage",		'tittle': gls("Скрэтти-Скелет"),	'clothesId': OutfitData.SCRATTY_SKELETON,	'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Не всем белкам удаётся чудесно выглядеть, только что встав из могилы. Скрэтти-Скелет - счастливое исключение. Но всё же иногда у нее вполне получается напугать других белок.")},

				{'icon': "CollectionPersianScratPrizeImage",		'tittle': gls("Скрэт-Странник"),	'clothesId': OutfitData.SCRAT_PERSIA,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Путешествия и опасности укрепили дух Скрэта-Странника и закалили его тело. В образе Странника Скрэт легко приспосабливается к выживанию в Пустыне и на других локациях!")},
				{'icon': "CollectionPersianScrattyPrizeImage",		'tittle': gls("Скрэтти-Странница"),	'clothesId': OutfitData.SCRATTY_PERSIA,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Путешествия и опасности укрепили дух Скрэтти-Странницы и закалили её тело. В образе Странницы Скрэтти легко приспосабливается к выживанию в Пустыне и на других локациях!")},

				{'icon': "CollectionRobocopScratPrizeImage",		'tittle': gls("Скрэт-Робокоп"),		'clothesId': OutfitData.SCRAT_ROBOCOP,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэта"),		'description': gls("Наполовину Скрэт, наполовину машина. На сто процентов коп. У зла нет шансов! Скрэт-робокоп арестует всех преступников и первым доберётся до ореха.")},
				{'icon': "CollectionFairyScrattyPrizeImage",		'tittle': gls("Скрэтти-Фея"),		'clothesId': OutfitData.SCRATTY_FAIRY,		'awardText': gls("Теперь у тебя есть новый костюм для Скрэтти"),	'description': gls("Отправляйся навстречу приключениям и разгадай загадку Солнечной Долины вместе с самым прекрасным и сказочным созданием на свете - Скрэтти-феей.")}
			]
		];

		static private var locations_sets:Array = null;

		static public function get regularData():Array
		{
			return DATA[TYPE_REGULAR];
		}

		static public function get uniqueData():Array
		{
			return DATA[TYPE_UNIQUE];
		}

		static public function get trophyData():Array
		{
			return DATA[TYPE_TROPHY];
		}

		static public function get locationsSets():Array
		{
			if (!locations_sets)
			{
				locations_sets = [
					{'location': Locations.ISLAND_ID,	'set': [COLLECTION_BONE, COLLECTION_MARK, COLLECTION_BUTTERFLY, COLLECTION_FEATHER]},
					{'location': Locations.BATTLE_ID,	'set': [COLLECTION_COLD_WEAPON, COLLECTION_FIREARM, COLLECTION_ROBOTS, COLLECTION_AFV]},
					{'location': Locations.SWAMP_ID,	'set': [COLLECTION_BEETLE, COLLECTION_FUNGUS, COLLECTION_SHELL, COLLECTION_FISH]},
					{'location': Locations.STORM_ID,	'set': [COLLECTION_AIRCRAFT, COLLECTION_ANCHOR, COLLECTION_SEA, COLLECTION_ICE_ANIMAL]},
					{'location': Locations.HARD_ID,		'set': [COLLECTION_BERRIES, COLLECTION_HIKE, COLLECTION_EXTREME, COLLECTION_LAKE]},
					{'location': Locations.DESERT_ID,	'set': [COLLECTION_EGYPTIAN, COLLECTION_ARABIC, COLLECTION_DESERT_ANIMAL, COLLECTION_DESERT_PLANT]},
					{'location': Locations.ANOMAL_ID,	'set': [COLLECTION_CRYSTAL, COLLECTION_BACTERIUM, COLLECTION_SPACESHIP, COLLECTION_ALIEN]}
				];
			}
			return locations_sets;
		}

		static public function getIconClass(id:int):Class
		{
			return getDefinitionByName(regularData[id]['icon']) as Class;
		}

		static public function getUniqueClass(id:int):Class
		{
			return getDefinitionByName(uniqueData[id]['icon']) as Class;
		}

		static public function getLocation(id:int):int
		{
			for (var i:int = 0; i < CollectionsData.locationsSets.length; i++)
			{
				if (CollectionsData.locationsSets[i]['set'].indexOf(id) == -1)
					continue;
				return CollectionsData.locationsSets[i]['location'];
			}
			return 0;
		}
	}
}