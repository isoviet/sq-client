package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import dialogs.DialogDailyQuests;
	import dialogs.education.DialogEducationFinish;
	import dialogs.education.DialogEducationQuest;
	import dialogs.education.DialogEducationQuestComplete;
	import events.GameEvent;
	import screens.ScreenLocation;
	import screens.Screens;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;
	import protocol.packages.server.PacketTraining;

	public class EducationQuestManager
	{
		static private const MAX_COUNT:int = 3;

		static private const NONE:int = 0;
		static private const DONE:int = 1;
		static private const COMPLETE:int = 2;

		static public const TRAINING_COMPLETE:int = 0;//MASTER-FLAG
		static public const FIRST_GAME:int = 1;
		static public const LEVEL_UP:int = 2;
		static public const MAGIC:int = 3;
		static public const SHOP:int = 4;
		static public const NEWS:int = 5;
		static public const RATING:int = 6;
		static public const WARDROBE:int = 7;
		static public const MAIL:int = 8;
		static public const COLLECTIONS:int = 9;
		static public const ACHIEVE:int = 10;

		static public const SWAMP:int = 11;
		static public const SCHOOL:int = 12;
		static public const SHAMAN:int = 13;
		static public const BATTLE:int = 14;

		static public const HOME:int = 15;
		static public const SHAMAN_TREE:int = 16;

		static private const QUESTS:Array = [
			{'id': FIRST_GAME,	 'name': gls("Первые шаги"),			'level': 0,	'short': gls("Отправляйся в Солнечные долины"),		'award': "#Ex   10",		'icon': EducationQuestIconFirstGame,	'image': EducationQuestImageFirstGame,	'text': gls("Собирать орехи и хранить их в дупле - вот беличий путь. Настанет зима и запасы тебе пригодятся. На <b>Солнечных долинах</b> как раз ореховый сезон, туда мы и отправимся. Ты готов к курсу молодой белки? Вперёд!")},
			{'id': HOME,		 'name': gls("Дом, милый дом"),			'level': 1,	'short': gls("Ознакомься с домиком"),			'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconHome,		'image': EducationQuestImageHome,	'text': gls("У каждого должен быть <b>дом</b>, где можно отдохнуть и расслабиться, куда приходят друзья и заглядывают знакомые. Поэтому там всегда должно быть красиво и празднично. Загляни к себе домой, рассмотри там всё и возвращайся!")},
			{'id': WARDROBE,	 'name': gls("Приоденься!"),			'level': 1,	'short': gls("Примерь костюм"),				'award': "#Co   1",		'icon': EducationQuestIconWardrobe,	'image': EducationQuestImageWardrobe,	'text': gls("Главное, чтобы костюмчик сидел! Пушистым белкам тоже хочется выглядеть красиво и круто. В твоём <b>гардеробе</b> будут храниться вещи, которые подчеркнут твою уникальность. Зайди туда и примерь новую одежду!")},
			{'id': LEVEL_UP,	 'name': gls("Белки-Летяги"),			'level': 1,	'short': gls("Получи 4 уровень"),			'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconLevelUp,	'image': EducationQuestImageLevelUp,	'text': gls("Основы ты изучил, пора проверить свои силы. Когда ты приносишь орех в дупло, ты получаешь опыт. А чем больше у тебя опыта - тем выше уровень. Вернись в <b>Солнечные долины</b> и заработай там <b>4 уровень</b>!")},

			{'id': MAGIC,		 'name': gls("Магия нас связала"),		'level': 4,	'short': gls("Пройди обучение магии"),			'award': "#Co   1",		'icon': EducationQuestIconMagic,	'image': EducationQuestImageMagic,	'text': gls("Ты - не простая белочка! <b>Ты - волшебник</b>, Гарр.. упс, Бельчонок! Белочки нашего мира ещё в древности научились творить магию, расходуя ману. Пройди <b>обучение в Школе</b> и ты тоже постигнешь это искусство.")},
			{'id': SHOP,		 'name': gls("По магазинам!"),			'level': 4,	'short': gls("Ознакомься с магазином"),			'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconShop,		'image': EducationQuestImageShop,	'text': gls("Как-то пусто у тебя в гардеробе. Время заглянуть в <b>магазин</b>. Аренда костюмов позволит тебе использовать удивительную магию и выделиться среди других белок. Сходи в магазин и посмотри, какие костюмы там есть!")},
			{'id': NEWS,		 'name': gls("Всегда в курсе"),			'level': 4,	'short': gls("Просмотри текущие новости"),		'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconNews,		'image': EducationQuestImageNews,	'text': gls("Ты знаешь последние новости? Ещё нет? Скорее читай в беличьей <b>газете</b>! Незаменимая штука: если что забудешь, она поможет тебе вспомнить всё. Там пишут обо всех событиях в мире белок, точно ничего не пропустишь.")},
			{'id': MAIL,		 'name': gls("Вам письмо, танцуйте!"),		'level': 4,	'short': gls("Ознакомься с почтой"),			'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconMail,		'image': EducationQuestImageMail,	'text': gls("Какой же домик без почтового ящика? Найди его, там тебя дожидается моё письмо. По <b>почте</b> ты будешь получать письма с подарками, приглашения и самые важные новости. Очень удобно, попробуй!")},
			{'id': COLLECTIONS,	 'name': gls("Пятый элемент"),			'level': 4,	'short': gls("Ознакомься с коллекциями"),		'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconCollection,	'image': EducationQuestImageCollection,	'text': gls("Кто-то собирает марки или крышки от люков. А белочки копят <b>элементы коллекций</b> и превращают их в <b>золотые элементы</b>. Обменивайся с друзьями и не зевай - ещё много желающих! Сходи в домик, проверь свою коллекцию.")},
			{'id': ACHIEVE,		 'name': gls("Только ачивки, только хардкор!"),	'level': 4,	'short': gls("Ознакомься с достижениями"),		'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconAchieve,	'image': EducationQuestImageAchieve,	'text': gls("Приятно знать, когда о твоих подвигах помнят. Все <b>твои достижения</b> внимательно отслеживаются - ты всегда можешь посмотреть, чего достиг и какие вершины ещё нужно покорить. Загляни в домик и посмотри сам!")},

			{'id': SWAMP,		 'name': gls("Таинственные топи"),		'level': 7,	'short': gls("Доберись до дупла на локации Топи"),	'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconRainbow,	'image': EducationQuestImageSwamp,	'text': gls("Мир белок велик и разнообразен! Пора тебе отправляться дальше - в таинственные <b>Топи</b> . Чем выше будет твой уровень, тем больше новых и интересных мест сможешь посетить. Принеси орех с труднопроходимых топей и я тебя награжу!")},
			{'id': BATTLE,		 'name': gls("Реши свою судьбу!"),		'level': 7,	'short': gls("Пройди обучение в Битве"),		'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconBattle,	'image': EducationQuestImageBattle,	'text': gls("В мире белок есть несколько разных планет. На одной из них проводятся соревнования закалённых бойцов - <b>Битва</b>. Тебе тоже стоит попробовать! Для начала, пройди обучение в Битве и возвращайся за наградой.")},
			{'id': SCHOOL,		 'name': gls("Быть шаманом"),			'level': 7,	'short': gls("Пройди обучение шамана"),			'award': "#Co   1",		'icon': EducationQuestIconSchool,	'image': EducationQuestImageSchool,	'text': gls("Взгляни вокруг, оглянись назад. Духи с тобой связаться хотят! Но тебе сперва надо пройти обучение <b>шаманству в Школе</b>. Отправляйся туда и познай это мастерство. Каждая белочка может стать шаманом! Надо только научиться!")},
			{'id': SHAMAN,		 'name': gls("Духи прошлого"),			'level': 7,	'short': gls("Стань шаманом"),				'award': "#Co   1",		'icon': EducationQuestIconShaman,	'image': EducationQuestImageShaman,	'text': gls("Ты уже знаешь, кто такие шаманы. Теперь твоя очередь вести за собой бельчат. Зайди на любую локацию и <b>стань шаманом</b>. Немножко орехов или монет помогут тебе. Покажи всё, чему ты научился за время тренировок.")},
			{'id': SHAMAN_TREE,	 'name': gls("С ветки на ветку"),		'level': 7,	'short': gls("Ознакомься с навыками шамана"),		'award': "#Ac   10 #Mn   10",	'icon': EducationQuestIconShamanTree,	'image': EducationQuestImageShamanTree,	'text': gls("Быть шаманом - не только важно и почётно. За помощь другим белкам ты получаешь шаманский опыт и особые <b>Перья</b> для изучения новых навыков. Посмотри какие <b>шаманские навыки</b> ты сможешь со временем освоить.")},
			{'id': RATING,		 'name': gls("Быстрее, выше, сильнее!"),	'level': 7,	'short': gls("Ознакомься с рейтингом"),			'award': "#Co   1",		'icon': EducationQuestIconRating,	'image': EducationQuestImageRating,	'text': gls("Среди белок есть свои спортсмены и чемпионы. С помощью <b>рейтинга</b> удаётся определить, кто из белочек самый лучший. Загляни в рейтинг и посмотри, к чему стоит стремиться. Как только разберёшься, возвращайся!")}
		];

		static private var dispatcher:EventDispatcher = new EventDispatcher();
		static private var quests:Object = {};

		static private var haveCompleted:Boolean = false;
		static private var haveDone:Boolean = false;
		static private var fieldStep:int = 0;

		static private var loaded:Boolean = false;

		static public var activeQuests:Array = [];
		static public var fieldState:GameField = null;
		static public var arrowMovie:ImageArrowRespawn = null;

		static public function init():void
		{
			arrowMovie = new ImageArrowRespawn();
			arrowMovie.visible = false;
			arrowMovie.rotation = 90;

			fieldState = new GameField("", 0, 0, new TextFormat(GameField.PLAKAT_FONT, 14, 0xFFFFFF, null, null, null, null, null, "center"));
			fieldState.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				if (EducationQuestManager.educationQuest)
					DialogEducationQuest.show();
				else
					DialogDailyQuests.show();
			});
			EnterFrameManager.addPerSecondTimer(onStep);

			Connection.listen(onPacket, PacketTraining.PACKET_ID);

			FlagsManager.find(Flag.MAGIC_SCHOOL_FINISH).listen(onMagic);
			FlagsManager.find(Flag.SHAMAN_SCHOOL_FINISH).listen(onShaman);
			FlagsManager.find(Flag.BATTLE_SCHOOL_FINISH).listen(onBattle);
		}

		static private function onMagic(flag:Flag):void
		{
			if (flag.value == 0)
				return;
			if (isDone(MAGIC) || isComplete(MAGIC) || !isAllow(MAGIC))
				return;
			if (!educationQuest)
				return;
			done(MAGIC, true);
		}

		static private function onShaman(flag:Flag):void
		{
			if (flag.value == 0)
				return;
			if (isDone(SCHOOL) || isComplete(SCHOOL) || !isAllow(SCHOOL))
				return;
			if (!educationQuest)
				return;
			done(SCHOOL, true);
		}

		static private function onBattle(flag:Flag):void
		{
			if (flag.value == 0)
				return;
			if (isDone(BATTLE) || isComplete(BATTLE) || !isAllow(BATTLE))
				return;
			if (!educationQuest)
				return;
			done(BATTLE, true);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function get firstGame():Boolean
		{
			return !isDone(TRAINING_COMPLETE) && !isDone(FIRST_GAME) && !isComplete(FIRST_GAME);
		}

		static public function get educationQuest():Boolean
		{
			return !isDone(TRAINING_COMPLETE);
		}

		static public function get allowDailyBonus():Boolean
		{
			return !educationQuest || haveCompleted;
		}

		static public function get notAllowGame():Boolean
		{
			return educationQuest && isDone(FIRST_GAME) && !isComplete(FIRST_GAME);
		}

		static public function get allowMagic():Boolean
		{
			return !educationQuest || (isAllow(MAGIC) && (activeQuests.indexOf(MAGIC) != -1));
		}

		static public function get allowSchool():Boolean
		{
			return !educationQuest || (isAllow(SCHOOL) && (activeQuests.indexOf(SCHOOL) != -1));
		}

		static public function getQuest(id:int):Object
		{
			for (var i:int = 0; i < QUESTS.length; i++)
			{
				if (QUESTS[i]['id'] != id)
					continue;
				return QUESTS[i];
			}
			return null;
		}

		static public function isComplete(id:int):Boolean
		{
			if (id in quests)
				return quests[id] == COMPLETE;
			return false;
		}

		static public function isDone(id:int):Boolean
		{
			if (id in quests)
				return quests[id] == DONE;
			return false;
		}

		static public function isAllow(id:int):Boolean
		{
			return getQuest(id)['level'] <= Experience.selfLevel;
		}

		static public function complete(id:int):void
		{
			if (activeQuests.indexOf(id) == -1)
				return;
			quests[id] = COMPLETE;

			Connection.sendData(PacketClient.TRAINING_SET, id, COMPLETE);

			haveCompleted = true;
			updateActiveQuests(true);
		}

		static public function done(id:int, force:Boolean = false):Boolean
		{
			if (!educationQuest)
				return false;
			if (quests[id] == DONE)
				return false;
			if (activeQuests.indexOf(id) == -1 && !force)
				return false;
			if (!isAllow(id) && !force)
				return false;
			quests[id] = DONE;

			Connection.sendData(PacketClient.TRAINING_SET, id, DONE);

			if (loaded)
			{
				if (id == SHAMAN)
					DialogEducationQuestComplete.show(id);
				else
				{
					Screens.addCallback(function():void
					{
						DialogEducationQuestComplete.show(id);
					});
				}
			}

			dispatcher.dispatchEvent(new GameEvent(GameEvent.EDUCATION_QUEST_PROGRESS));

			haveDone = true;
			updateText();

			return true;
		}

		static public function updateText():void
		{
			if (!educationQuest)
			{
				EducationQuestManager.fieldState.text = "";
				arrowMovie.visible = false;
				return;
			}
			if (haveDone)
			{
				EducationQuestManager.fieldState.text = gls("Задание\nвыполнено");
				return;
			}
			if (DialogEducationQuest.showed || activeQuests.length == 0)
			{
				EducationQuestManager.fieldState.text = "";
				arrowMovie.visible = false;
				return;
			}
			EducationQuestManager.fieldState.text = gls("Новое\nзадание");
		}

		static private function updateActiveQuests(onComplete:Boolean = false):void
		{
			arrowMovie.visible = educationQuest && (quests[LEVEL_UP] != COMPLETE);

			activeQuests = [];

			haveDone = false;
			for (var i:int = 0; i < QUESTS.length; i++)
			{
				if (isComplete(QUESTS[i]['id']))
					continue;
				activeQuests.push(QUESTS[i]['id']);
				haveDone = haveDone || isDone(QUESTS[i]['id']);

				if (activeQuests.length >= MAX_COUNT)
					break;
			}
			dispatcher.dispatchEvent(new GameEvent(GameEvent.EDUCATION_QUEST_CHANGED, {'onComplete': onComplete}));

			if (activeQuests.length == 0)
			{
				quests[TRAINING_COMPLETE] = DONE;
				new DialogEducationFinish().show();

				dispatcher.dispatchEvent(new GameEvent(GameEvent.EDUCATION_QUEST_FINISH));
			}
			updateText();

			if (Experience.selfLevel >= Game.LEVEL_TO_LEAVE_SANDBOX && (activeQuests.indexOf(LEVEL_UP) != -1))
				done(LEVEL_UP);
			ScreenLocation.sortMenu();
		}

		static private function onPacket(packet: PacketTraining):void
		{
			Connection.forget(onPacket, PacketTraining.PACKET_ID);

			loaded = true;

			for (var i:int = 0; i < packet.items.length; i++)
				quests[packet.items[i].type] = packet.items[i].value;
			updateActiveQuests();
		}

		static private function onStep():void
		{
			fieldStep++;

			fieldState.textColor = fieldStep % 2 ? 0xFF9900 : 0xFFFFFF;
			fieldStep = fieldStep % 2;
		}
	}
}