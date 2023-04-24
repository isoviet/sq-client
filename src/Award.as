package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import dialogs.DialogRepost;
	import game.gameData.AwardManager;
	import statuses.Status;
	import views.AwardImageLoader;

	import utils.Bar;
	import utils.FiltersUtil;
	import utils.WallTool;

	public class Award
	{
		static private var statId:int = 0;

		static private const BATTLE_ALIVE:int = statId++;
		static private const BATTLE_COLLECT_HEALS:int = statId++;
		static private const BATTLE_COLLECT_POISE:int = statId++;
		static private const BATTLE_DOUBLE_KILL:int = statId++;
		static private const BATTLE_TRIPLE_KILL:int = statId++;
		static private const BATTLE_MEGA_KILL:int = statId++;
		static private const BATTLE_KILL:int = statId++;
		static private const BATTLE_KILL_FRIEND:int = statId++;
		static private const BATTLE_REVENGE:int = statId++;
		static private const BATTLE_WINS:int = statId++;
		static private const BECOME_SUPER:int = statId++;
		static private const BUY_AUTORESQUE:int = statId++;
		static private const BUY_CLOTHES:int = statId++;
		static private const BUY_COINS:int = statId++;
		static private const BUY_ENERGY:int = statId++;
		static private const BUY_SUBSCRIBE_BIG:int = statId++;
		static private const BUY_SUBSCRIBE_MIDDLE:int = statId++;
		static private const CHEST:int = statId++;
		static private const CLAN_JOIN:int = statId++;
		static private const COLLECTION_ASSEMBLE:int = statId++;
		static private const COLLECT_ACORNS:int = statId++;
		static private const CONTINUES_ENTER:int = statId++;
		static private const DRAGON_FIRE:int = statId++;
		static private const FIRST_FLYING_ACORN:int = statId++;
		static private const FRIENDS_PLAY:int = statId++;
		static private const FRIENDS_PLAY_ON_FIVE:int = statId++;
		static private const GIFT:int = statId++;
		static private const GIFT_ACCEPT:int = statId++;
		static private const GIFT_ENERGY:int = statId++;
		static private const HOLLOW:int = statId++;
		static private const HOLLOW_ALL:int = statId++;
		static private const HOLLOW_FIRST:int = statId++;
		static private const MAGIC_ALL:int = statId++;
		static private const MAGIC_BARBARIAN:int = statId++;
		static private const MAGIC_BOLT:int = statId++;
		static private const MAGIC_CLOTHES:int = statId++;
		static private const MAGIC_DOUBLE_JUMP:int = statId++;
		static private const MAGIC_FLY:int = statId++;
		static private const MAGIC_HIGH_JUMP:int = statId++;
		static private const MAGIC_INVISIBLE:int = statId++;
		static private const MAGIC_LITTLE:int = statId++;
		static private const MAGIC_RESSURECT:int = statId++;
		static private const MAGIC_TELEPORT:int = statId++;
		static private const MAGIC_ROUGH:int = statId++;
		static private const MAP_SEND:int = statId++;
		static private const PLAY_CAST:int = statId++;
		static private const PLAY_CAST_REMOVE:int = statId++;
		static private const PLAY_DRAGON:int = statId++;
		static private const PLAY_GIVE_ACORN:int = statId++;
		static private const PLAY_RABBIT:int = statId++;
		static private const QUEST_COMPLETE:int = statId++;
		static private const RABBIT_GLUE:int = statId++;
		static private const REPOST_AWARD:int = statId++;
		static private const REPOST_NEWS:int = statId++;
		static private const REPOST_SCREEN:int = statId++;
		static private const SCRAT:int = statId++;
		static private const SCRATTY:int = statId++;
		static private const SCRATTY_ALL:int = statId++;
		static private const SCRATTY_DRAGON:int = statId++;
		static private const SCRATTY_IRON:int = statId++;
		static private const SCRATTY_MAGIC:int = statId++;
		static private const SCRAT_ALL:int = statId++;
		static private const SCRAT_DRAGON:int = statId++;
		static private const SCRAT_IRON:int = statId++;
		static private const SCRAT_MAGIC:int = statId++;
		static private const SHAMAN:int = statId++;
		static private const SHAMAN_CAST:int = statId++;
		static private const SHAMAN_CAST_REMOVE:int = statId++;
		static private const SHAMAN_CERT:int = statId++;
		static private const SHAMAN_COMPLEX:int = statId++;
		static private const SHAMAN_GIVE_ACORN:int = statId++;
		static private const SHAMAN_INVISIBLE_KILLS:int = statId++;
		static private const SHAMAN_ISLAND:int = statId++;
		static private const SHAMAN_MOUNTAINS:int = statId++;
		static private const SHAMAN_SPACESHIP:int = statId++;
		static private const SHAMAN_STORM:int = statId++;
		static private const SHAMAN_SWAMPS:int = statId++;
		static private const SPEND_ACORNS:int = statId++;
		static private const TWO_SHAMAN_SQUIRRELS:int = statId++;
		static private const WEREWOLF:int = statId++;
		static private const WIN_COMPLEX:int = statId++;
		static private const WIN_ISLAND:int = statId++;
		static private const WIN_MOUNTAINS:int = statId++;
		static private const WIN_RABBIT:int = statId++;
		static private const WIN_SPACESHIP:int = statId++;
		static private const WIN_STORM:int = statId++;
		static private const WIN_SURVIVAL:int = statId++;
		static private const WIN_SURVIVAL_SHAMAN:int = statId++;
		static private const WIN_SWAMPS:int = statId++;
		static private const WIN_TWO_SHAMANS:int = statId++;
		static private const WIN_DESERT:int = statId++;
		static private const DESERT_ALIVE:int = statId++;
		static private const DESERT_AURA:int = statId++;
		static private const SHAMAN_DESERT:int = statId++;
		static private const SHAMAN_DESERT_WIN:int = statId++;
		static private const DESERT_RABBIT:int = statId++;
		static private const DESERT_DRAGON:int = statId++;

		static private var awardId:int = 0;
		static public const DATA:Array =[
			{'id': awardId++, 'name': gls("Ответственный"),				'total': 5,	'stat': CONTINUES_ENTER,	'category': AwardManager.GENERAL,	'image': "AwardFan1",			'text': gls("Заходи в игру 5 дней подряд, не пропуская ни одного."),			"awardText": gls("У меня новое достижение «Ответственный» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Игроман"),				'total': 15,	'stat': CONTINUES_ENTER,	'category': AwardManager.GENERAL,	'image': "AwardFan2",			'text': gls("Заходи в игру 15 дней подряд, не пропуская ни одного."),			"awardText": gls("У меня новое достижение «Игроман» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Предприимчивый"),			'total': 5,	'stat': QUEST_COMPLETE,		'category': AwardManager.GENERAL,	'image': "AwardQuests1",		'text': gls("Выполни 5 заданий."),							"awardText": gls("У меня новое достижение «Предприимчивый» за выполнение пяти заданий в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Неудержимый"),				'total': 20,	'stat': QUEST_COMPLETE,		'category': AwardManager.GENERAL,	'image': "AwardQuests2",		'text': gls("Выполни 20 заданий."),							"awardText": gls("У меня новое достижение «Неудержимый» за выполнение двадцати заданий в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Неистовый"),				'total': 50,	'stat': QUEST_COMPLETE,		'category': AwardManager.GENERAL,	'image': "AwardQuests3",		'text': gls("Выполни 50 заданий."),							"awardText": gls("У меня новое достижения «Неистовый» за выполнение пятидесяти заданий в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Зазывала"),				'total': 2,	'stat': FRIENDS_PLAY_ON_FIVE,	'category': AwardManager.GENERAL,	'image': "AwardFriendsCall1",		'text': gls("2 приглашённых тобой друга достигли {0} уровня.", Game.LEVEL_TO_FRIEND_INVITE),	"awardText": gls("Получено новое достижение «Зазывала», двое приглашённых мною друга достигли {0} уровня в игре Трагедия Белок!", Game.LEVEL_TO_FRIEND_INVITE)},
			{'id': awardId++, 'name': gls("Знающий"),				'total': 5,	'stat': FRIENDS_PLAY_ON_FIVE,	'category': AwardManager.GENERAL,	'image': "AwardFriendsCall2",		'text': gls("5 приглашённых тобой друзей достигли {0} уровня.", Game.LEVEL_TO_FRIEND_INVITE),	"awardText": gls("Получено новое достижение «Знающий», пять приглашённых мною друзей достигли {0} уровня в игре Трагедия Белок!", Game.LEVEL_TO_FRIEND_INVITE)},
			{'id': awardId++, 'name': gls("Скромняга"),				'total': 5,	'stat': FRIENDS_PLAY,		'category': AwardManager.GENERAL,	'image': "AwardFriends1",		'text': gls("Подружись с 5 игроками в игре."),						"awardText": gls("У меня появилось пять друзей в игре Трагедия Белок! Достижение «Скромняга» получено!")},
			{'id': awardId++, 'name': gls("Общительный"),				'total': 10,	'stat': FRIENDS_PLAY,		'category': AwardManager.GENERAL,	'image': "AwardFriends2",		'text': gls("Подружись с 10 игроками в игре."),						"awardText": gls("У меня появилось десять друзей в игре Трагедия Белок! Достижение «Общительный» получено!")},
			{'id': awardId++, 'name': gls("Звезда"),				'total': 25,	'stat': FRIENDS_PLAY,		'category': AwardManager.GENERAL,	'image': "AwardFriends3",		'text': gls("Подружись с 25 игроками в игре."),						"awardText": gls("У меня появилось двадцать пять друзей в игре Трагедия Белок! Достижение «Звезда» получено!")},
			{'id': awardId++, 'name': gls("Модник"),				'total': 1,	'stat': BUY_CLOTHES,		'category': AwardManager.GENERAL,	'image': "AwardBuyClothes1",		'text': gls("Купи предмет одежды в магазине."),						"awardText": gls("У моей белки новая одежда и новое достижение «Модник»!")},
			{'id': awardId++, 'name': gls("Пижон"),					'total': 5,	'stat': BUY_CLOTHES,		'category': AwardManager.GENERAL,	'image': "AwardBuyClothes2",		'text': gls("Купи 5 предметов одежды в магазине."),					"awardText": gls("У моей белки пять новых вещей и новое достижение «Пижон» !")},
			{'id': awardId++, 'name': gls("Выпендрёжник"),				'total': 15,	'stat': BUY_CLOTHES,		'category': AwardManager.GENERAL,	'image': "AwardBuyClothes3",		'text': gls("Купи 15 предметов одежды в магазине."),					"awardText": gls("У моей белки пятнадцать новых вещей и новое достижение «Выпендрёжник»!")},
			{'id': awardId++, 'name': gls("Активный"),				'total': 1,	'stat': BUY_ENERGY,		'category': AwardManager.GENERAL,	'image': "AwardEnergy1",		'text': gls("Купи Энергетический напиток или Колдовской отвар."),			"awardText": gls("Использовано зелье и за это получено новое достижение «Активный»!")},
			{'id': awardId++, 'name': gls("Гиперактивный"),				'total': 5,	'stat': BUY_ENERGY,		'category': AwardManager.GENERAL,	'image': "AwardEnergy2",		'text': gls("Купи 5 Энергетических напитков или Колдовских отваров."),			"awardText": gls("Использованы ещё пять зелья и получено новое достижение «Гиперактивный»!")},
			{'id': awardId++, 'name': gls("Манчкин"),				'total': 12,	'stat': BUY_COINS,		'category': AwardManager.GENERAL,	'image': "AwardMoney1",			'text': gls("Получи 12 монеток."),							"awardText": gls("Достижение «Манчкин» получено! Теперь у меня есть двенадцать золотых монеток!")},
			{'id': awardId++, 'name': gls("Бизнесмен"),				'total': 30,	'stat': BUY_COINS,		'category': AwardManager.GENERAL,	'image': "AwardMoney2",			'text': gls("Получи 30 монеток."),							"awardText": gls("Достижение «Бизнесмен» получено! Теперь у меня есть тридцать золотых монеток!")},
			{'id': awardId++, 'name': gls("Предприниматель"),			'total': 50,	'stat': BUY_COINS,		'category': AwardManager.GENERAL,	'image': "AwardMoney3",			'text': gls("Получи 50 монеток."),							"awardText": gls("Достижение «Предприниматель» получено! Теперь у меня есть пятьдесят золотых монеток!")},
			{'id': awardId++, 'name': gls("Неистребимый"),				'total': 4,	'stat': BUY_AUTORESQUE,		'category': AwardManager.GENERAL,	'image': "AwardAutoRevive",		'text': gls("Используй комплект автовоскрешения 4 раза."),				"awardText": gls("Теперь меня не так-то просто убить! Мною был использован комплект автовоскрешения, и за это получено достижение «Неистребимый»!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Фотограф-новичок"),			'total': 5,	'stat': REPOST_SCREEN,		'category': AwardManager.GENERAL,	'image': "AwardSayPhotos1",		'text': gls("Опубликуй 5 снимков экрана."),						"awardText": gls("У меня новое достижение «Фотограф-новичок»! Опубликовано пять скриншотов игры Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Фотограф-любитель"),			'total': 15,	'stat': REPOST_SCREEN,		'category': AwardManager.GENERAL,	'image': "AwardSayPhotos2",		'text': gls("Опубликуй 15 снимков экрана."),						"awardText": gls("У меня новое достижение «Фотограф-любитель»! Опубликовано пятнадцать скринштов игры Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Фотограф-профессионал"),			'total': 50,	'stat': REPOST_SCREEN,		'category': AwardManager.GENERAL,	'image': "AwardSayPhotos3",		'text': gls("Опубликуй 50 снимков экрана."),						"awardText": gls("У меня новое достижение «Фотограф-профессионал»! Опубликовано пятьдесят скриншотов игры Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Оратор"),				'total': 1,	'stat': REPOST_NEWS,		'category': AwardManager.GENERAL,	'image': "AwardSayNews",		'text': gls("Опубликуй новость на стену."),						"awardText": gls("У меня новое достижение «Оратор» в игре Трагедия Белок!"),	'avaliable': "post"},
			{'id': awardId++, 'name': gls("Даритель"),				'total': 10,	'stat': GIFT_ENERGY,		'category': AwardManager.GENERAL,	'image': "AwardEnergyGift1",		'text': gls("Подари друзьям ежедневные эликсиры 10 раз."),				"awardText": gls("Я всегда дарю своим друзьям элексиры энергии и получаю за это новое достижение «Даритель»!")},
			{'id': awardId++, 'name': gls("Кофе в постель"),			'total': 30,	'stat': GIFT_ENERGY,		'category': AwardManager.GENERAL,	'image': "AwardEnergyGift2",		'text': gls("Подари друзьям ежедневные эликсиры 30 раз."),				"awardText": gls("Я всегда дарю своим друзьям элексиры энергии и получаю за это новое достижение «Кофе в постель»!")},
			{'id': awardId++, 'name': gls("Угощаю всех!"),				'total': 100,	'stat': GIFT_ENERGY,		'category': AwardManager.GENERAL,	'image': "AwardEnergyGift3",		'text': gls("Подари друзьям ежедневные эликсиры 100 раз."),				"awardText": gls("Я всегда дарю своим друзьям элексиры энергии и получаю за это новое достижение «Угощаю всех»!")},
			{'id': awardId++, 'name': gls("Хамелеон"),				'total': 15,	'stat': MAGIC_INVISIBLE,	'category': AwardManager.GENERAL,	'image': "AwardMagicInvisible1",	'text': gls("Используй магию «Невидимка» 15 раз."),					"awardText": gls("Я получил достижение «Хамелеон»! Магия «Невидимка» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Как Сэм Фишер"),				'total': 150,	'stat': MAGIC_INVISIBLE,	'category': AwardManager.GENERAL,	'image': "AwardMagicInvisible2",	'text': gls("Используй магию «Невидимка» 150 раз."),					"awardText": gls("Я получил достижение «Как Сэм Фишер»! Магия «Невидимка» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Кто съел мои орехи?!"),			'total': 350,	'stat': MAGIC_INVISIBLE,	'category': AwardManager.GENERAL,	'image': "AwardMagicInvisible3",	'text': gls("Используй магию «Невидимка» 350 раз."),					"awardText": gls("Я получил достижение «Кто съел мои орехи?!» Магия «Невидимка» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Молния"),				'total': 20,	'stat': MAGIC_BOLT,		'category': AwardManager.GENERAL,	'image': "AwardMagicBolt1",		'text': gls("Используй магию «Белка-молния» 20 раз."),					"awardText": gls("Я получил достижение «Молния»! Магия «Белка-молния» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Искры по шёрстке"),			'total': 200,	'stat': MAGIC_BOLT,		'category': AwardManager.GENERAL,	'image': "AwardMagicBolt2",		'text': gls("Используй магию «Белка-молния» 200 раз."),					"awardText": gls("Я получил достижение «Искры по шёрстке»! Магия «Белка-молния» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Батарейки в комплекте"),			'total': 400,	'stat': MAGIC_BOLT,		'category': AwardManager.GENERAL,	'image': "AwardMagicBolt3",		'text': gls("Используй магию «Белка-молния» 400 раз."),					"awardText": gls("Я получил достижение «Батарейки в комплекте»! Магия «Белка-молния» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Скалолаз"),				'total': 15,	'stat': MAGIC_ROUGH,		'category': AwardManager.GENERAL,	'image': "AwardMagicRough1",		'text': gls("Используй магию «Цепкие лапки» 15 раз."),					"awardText": gls("Я получил достижение «Скалолаз»! Магия «Цепкие лапки» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Я иду по потолку"),			'total': 50,	'stat': MAGIC_ROUGH,		'category': AwardManager.GENERAL,	'image': "AwardMagicRough2",		'text': gls("Используй магию «Цепкие лапки» 50 раз."),					"awardText": gls("Я получил достижение «Я иду по потолку»! Магия «Цепкие лапки» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Гравитация не для меня"),		'total': 150,	'stat': MAGIC_ROUGH,		'category': AwardManager.GENERAL,	'image': "AwardMagicRough3",		'text': gls("Используй магию «Цепкие лапки» 150 раз."),					"awardText": gls("Я получил достижение «Гравитация не для меня»! Магия «Цепкие лапки» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Малыш"),					'total': 15,	'stat': MAGIC_LITTLE,		'category': AwardManager.GENERAL,	'image': "AwardMagicSmall1",		'text': gls("Используй магию «Малыш» 15 раз."),						"awardText": gls("Я получил достижение «Малыш»! Магия «Малыш» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Букашка"),				'total': 150,	'stat': MAGIC_LITTLE,		'category': AwardManager.GENERAL,	'image': "AwardMagicSmall2",		'text': gls("Используй магию «Малыш» 150 раз."),					"awardText": gls("Я получил достижение «Букашка»! Магия «Малыш» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Прилип к подошве"),			'total': 400,	'stat': MAGIC_LITTLE,		'category': AwardManager.GENERAL,	'image': "AwardMagicSmall3",		'text': gls("Используй магию «Малыш» 400 раз."),					"awardText": gls("Я получил достижение «Прилип к подошве»! Магия «Малыш» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Варвар"),				'total': 20,	'stat': MAGIC_BARBARIAN,	'category': AwardManager.GENERAL,	'image': "AwardMagicBarbar1",		'text': gls("Используй магию «Белка-варвар» 20 раз."),					"awardText": gls("Я получил достижение «Варвар»! Магия «Белка-варвар» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Кочевник"),				'total': 200,	'stat': MAGIC_BARBARIAN,	'category': AwardManager.GENERAL,	'image': "AwardMagicBarbar2",		'text': gls("Используй магию «Белка-варвар» 200 раз."),					"awardText": gls("Я получил достижение «Кочевник»! Магия «Белка-варвар» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Король севера"),				'total': 400,	'stat': MAGIC_BARBARIAN,	'category': AwardManager.GENERAL,	'image': "AwardMagicBarbar3",		'text': gls("Используй магию «Белка-варвар» 400 раз."),					"awardText": gls("Я получил достижение «Король севера»! Магия «Белка-варвар» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Высокая планка"),			'total': 25,	'stat': MAGIC_HIGH_JUMP,	'category': AwardManager.GENERAL,	'image': "AwardMagicJump1",		'text': gls("Используй магию «Высокий прыжок» 25 раз."),				"awardText": gls("Я получил достижение «Высокая планка»! Магия «Высокий прыжок» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Печенье на верхней полке"),		'total': 250,	'stat': MAGIC_HIGH_JUMP,	'category': AwardManager.GENERAL,	'image': "AwardMagicJump2",		'text': gls("Используй магию «Высокий прыжок» 250 раз."),				"awardText": gls("Я получил достижение «Печенье на верхней полке»! Магия «Высокий прыжок» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Дыра в потолке"),			'total': 500,	'stat': MAGIC_HIGH_JUMP,	'category': AwardManager.GENERAL,	'image': "AwardMagicJump3",		'text': gls("Используй магию «Высокий прыжок» 500 раз."),				"awardText": gls("Я получил достижение «Дыра в потолке»! Магия «Высокий прыжок» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Пилот"),					'total': 15,	'stat': MAGIC_FLY,		'category': AwardManager.GENERAL,	'image': "AwardMagicFly1",		'text': gls("Используй магию «Белка-летяга» 15 раз."),					"awardText": gls("Я получил достижение «Пилот»! Магия «Белка-летяга» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Космонавт"),				'total': 150,	'stat': MAGIC_FLY,		'category': AwardManager.GENERAL,	'image': "AwardMagicFly2",		'text': gls("Используй магию «Белка-летяга» 150 раз."),					"awardText": gls("Я получил достижение «Космонавт»! Магия «Белка-летяга» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("В бесконечность и далее!"),		'total': 400,	'stat': MAGIC_FLY,		'category': AwardManager.GENERAL,	'image': "AwardMagicFly3",		'text': gls("Используй магию «Белка-летяга» 400 раз."),					"awardText": gls("Я получил достижение «В бесконечность и далее»! Магия «Белка-летяга» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Два раза сразу"),			'total': 50,	'stat': MAGIC_DOUBLE_JUMP,	'category': AwardManager.GENERAL,	'image': "AwardMagicDouble1",		'text': gls("Используй магию «Двойной прыжок» 50 раз."),				"awardText": gls("Я получил достижение «Два раза сразу»! Магия «Двойной прыжок» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Как кузнечик"),				'total': 400,	'stat': MAGIC_DOUBLE_JUMP,	'category': AwardManager.GENERAL,	'image': "AwardMagicDouble2",		'text': gls("Используй магию «Двойной прыжок» 400 раз."),				"awardText": gls("Я получил достижение «Как кузнечик»! Магия «Двойной прыжок» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Прогулки по воздуху"),			'total': 600,	'stat': MAGIC_DOUBLE_JUMP,	'category': AwardManager.GENERAL,	'image': "AwardMagicDouble3",		'text': gls("Используй магию «Двойной прыжок» 600 раз."),				"awardText": gls("Я получил достижение «Прогулки по воздуху»! Магия «Двойной прыжок» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Всегда вовремя"),			'total': 5,	'stat': MAGIC_TELEPORT,		'category': AwardManager.GENERAL,	'image': "AwardMagicTeleport1",		'text': gls("Используй магию «Телепортация» 5 раз."),					"awardText": gls("Я получил достижение «Всегда вовремя»! Магия «Телепортация» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Одна нога здесь..."),			'total': 30,	'stat': MAGIC_TELEPORT,		'category': AwardManager.GENERAL,	'image': "AwardMagicTeleport2",		'text': gls("Используй магию «Телепортация» 30 раз."),					"awardText": gls("Я получил достижение «Одна нога здесь...»! Магия «Телепортация» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Сезон хэдкрабов"),			'total': 100,	'stat': MAGIC_TELEPORT,		'category': AwardManager.GENERAL,	'image': "AwardMagicTeleport3",		'text': gls("Используй магию «Телепортация» 100 раз."),					"awardText": gls("Я получил достижение «Сезон хэдкрабов»! Магия «Телепортация» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Переселение душ"),			'total': 5,	'stat': MAGIC_RESSURECT,	'category': AwardManager.GENERAL,	'image': "AwardMagicRevive1",		'text': gls("Используй магию «Реинкарнация» 5 раз."),					"awardText": gls("Я получил достижение «Переселение душ»! Магия «Реинкарнация» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Зомби"),					'total': 30,	'stat': MAGIC_RESSURECT,	'category': AwardManager.GENERAL,	'image': "AwardMagicRevive2",		'text': gls("Используй магию «Реинкарнация» 30 раз."),					"awardText": gls("Я получил достижение «Зомби»! Магия «Реинкарнация» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Отрицающий смерть"),			'total': 100,	'stat': MAGIC_RESSURECT,	'category': AwardManager.GENERAL,	'image': "AwardMagicRevive3",		'text': gls("Используй магию «Реинкарнация» 100 раз."),					"awardText": gls("Я получил достижение «Отрицающий смерть»! Магия «Реинкарнация» не раз помогала мне в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Ученик чародея"),			'total': 25,	'stat': MAGIC_ALL,		'category': AwardManager.GENERAL,	'image': "AwardMagicAll1",		'text': gls("Используй любую магию 25 раз."),						"awardText": gls("Получено новое достижение «Ученик чародея», магия белок была использована двадцать пять раз!")},
			{'id': awardId++, 'name': gls("Волшебник"),				'total': 200,	'stat': MAGIC_ALL,		'category': AwardManager.GENERAL,	'image': "AwardMagicAll2",		'text': gls("Используй любую магию 200 раз."),						"awardText": gls("Получено новое достижение «Волшебник», магия белок была использована двести раз!")},
			{'id': awardId++, 'name': gls("Молодой Скрэт"),				'total': 10,	'stat': PLAY_GIVE_ACORN,		'category': AwardManager.GENERAL,	'image': "AwardScratLover1",		'text': gls("Раздай орех 10 белкам, играя за Скрэтти или Скрэта."),			"awardText": gls("Мой Скрэт раздает орехи и раздал уже десять штук! Достижение «Молодой Скрэт» получено!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Опытный Скрэт"),				'total': 100,	'stat': PLAY_GIVE_ACORN,		'category': AwardManager.GENERAL,	'image': "AwardScratLover2",		'text': gls("Раздай орех 100 белкам, играя за Скрэтти или Скрэта."),			"awardText": gls("Мой Скрэт раздает орехи и раздал уже сто штук! Достижение «Опытный Скрэт» получено!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Бывалый Скрэт"),				'total': 1000,	'stat': PLAY_GIVE_ACORN,		'category': AwardManager.GENERAL,	'image': "AwardScratLover3",		'text': gls("Раздай орех 1000 белкам, играя за Скрэтти или Скрэта."),			"awardText": gls("Мой Скрэт раздает орехи и раздал уже тысячу штук! Достижение «Бывалый Скрэт» получено!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Воин"),					'total': 10,	'stat': BATTLE_KILL,		'category': AwardManager.GENERAL,	'image': "AwardBattleKill1",		'text': gls("Убей 10 белок в режиме битвы."),						"awardText": gls("У меня новое достижение «Воин» в игре Трагедия Белок! Мной убито десять врагов!")},
			{'id': awardId++, 'name': gls("Ветеран"),				'total': 100,	'stat': BATTLE_KILL,		'category': AwardManager.GENERAL,	'image': "AwardBattleKill2",		'text': gls("Убей 100 белок в режиме битвы."),						"awardText": gls("У меня новое достижение «Ветеран» в игре Трагедия Белок! Мной убито сто врагов!")},
			{'id': awardId++, 'name': gls("Длань смерти"),				'total': 1000,	'stat': BATTLE_KILL,		'category': AwardManager.GENERAL,	'image': "AwardBattleKill3",		'text': gls("Убей 1000 белок в режиме битвы."),						"awardText": gls("У меня новое достижение «Длань смерти» в игре Трагедия Белок! Мной убито тысяча врагов!")},
			{'id': awardId++, 'name': gls("Медик"),					'total': 10,	'stat': BATTLE_COLLECT_HEALS,	'category': AwardManager.GENERAL,	'image': "AwardBattleMedic1",		'text': gls("Собери 10 аптечек в режиме битвы."),					"awardText": gls("Собрано уже более десяти аптечек в битвах и получено новое достижение «Медик»!")},
			{'id': awardId++, 'name': gls("Ценитель жизни"),			'total': 250,	'stat': BATTLE_COLLECT_HEALS,	'category': AwardManager.GENERAL,	'image': "AwardBattleMedic2",		'text': gls("Собери 250 аптечек в режиме битвы."),					"awardText": gls("Собрано уже более двухсот пятидесяти аптечек в битвах и получено новое достижение «Ценитель жизни»!")},
			{'id': awardId++, 'name': gls("А если порежу пальчик?"),		'total': 1000,	'stat': BATTLE_COLLECT_HEALS,	'category': AwardManager.GENERAL,	'image': "AwardBattleMedic3",		'text': gls("Собери 1000 аптечек в режиме битвы."),					"awardText": gls("Собрано уже более тысячи аптечек в битвах и получено новое достижение «А если порежу пальчик?»!")},
			{'id': awardId++, 'name': gls("Полный арсенал"),			'total': 100,	'stat': BATTLE_COLLECT_POISE,	'category': AwardManager.GENERAL,	'image': "AwardBattleGun1",		'text': gls("Собери 100 ядер в режиме битвы."),						"awardText": gls("Собрано уже более ста боевых ядер в битве Трагедии Белок! За это получено новое достижение «Полный арсенал»!")},
			{'id': awardId++, 'name': gls("Вооружён до зубов"),			'total': 750,	'stat': BATTLE_COLLECT_POISE,	'category': AwardManager.GENERAL,	'image': "AwardBattleGun2",		'text': gls("Собери 750 ядер в режиме битвы."),						"awardText": gls("Собрано уже более семисот пятидесяти боевых ядер в битве Трагедии Белок! За это получено новое достижение «Вооружён до зубов»!")},
			{'id': awardId++, 'name': gls("Терминатор"),				'total': 3000,	'stat': BATTLE_COLLECT_POISE,	'category': AwardManager.GENERAL,	'image': "AwardBattleGun3",		'text': gls("Собери 3000 ядер в режиме битвы."),					"awardText": gls("Собрано уже более трёх тысяч боевых ядер в битве Трагедии Белок! За это получено новое достижение «Терминатор»!")},
			{'id': awardId++, 'name': gls("Мститель"),				'total': 5,	'stat': BATTLE_REVENGE,		'category': AwardManager.GENERAL,	'image': "AwardBattleRevenge",		'text': gls("Отомсти за своё убийство в режиме битвы 5 раз."),				"awardText": gls("Месть сладка! Получено новое достижение «Мститель» в Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Убийца"),				'total': 5,	'stat': BATTLE_DOUBLE_KILL,	'category': AwardManager.GENERAL,	'image': "AwardKillDouble",		'text': gls("Соверши двойное убийство в режиме битвы."),				"awardText": gls("Получено новое достижение «Убийца» за совершение двойного убийства в битвах Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Ассасин"),				'total': 5,	'stat': BATTLE_TRIPLE_KILL,	'category': AwardManager.GENERAL,	'image': "AwardKillTriple",		'text': gls("Соверши тройное убийство в режиме битвы."),				"awardText": gls("Получено новое достижение «Ассасин» за совершение тройного убийства в битвах Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Снайпер"),				'total': 5,	'stat': BATTLE_MEGA_KILL,	'category': AwardManager.GENERAL,	'image': "AwardKillQuadro",		'text': gls("Соверши Мега-выстрел в режиме битвы."),					"awardText": gls("Получено новое достижение «Снайпер» за совершение мега-выстрела в битвах Трагедии Белок!")},
			{'id': awardId++, 'name': gls("Огонь по своим"),			'total': 5,	'stat': BATTLE_KILL_FRIEND,	'category': AwardManager.GENERAL,	'image': "AwardBattleFriend",		'text': "Убей белку — друга из соц.сети в битве 5 раз",					"awardText": gls("Я заработал новое достижение «Огонь по своим» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Большая зелёная белка"),			'total': 5,	'stat': PLAY_DRAGON,		'category': AwardManager.GENERAL,	'image': "AwardDragonPlay",		'text': gls("Сыграй Дракошей 5 раз."),							"awardText": gls("Играть Дракошей и поджигать белок весело! Получено новое достижение «Большая зелёная белка»!")},
			{'id': awardId++, 'name': gls("Поиграть? Не судьба"),			'total': 5,	'stat': PLAY_RABBIT,		'category': AwardManager.GENERAL,	'image': "AwardHarePlay",		'text': gls("Сыграй Зайцем НеСудьбы 5 раз."),						"awardText": gls("Играть Зайцем НеСудьбы весело! Получено новое достижение «Поиграть? Не судьба»!")},
			{'id': awardId++, 'name': gls("Добытчик"),				'total': 10,	'stat': REPOST_AWARD,		'category': AwardManager.GENERAL,	'image': "AwardSayAward1",		'text': gls("Опубликуй 10 достижений."),						"awardText": gls("Получено новое достижение «Добытчик» в игре Трагедия Белок! Теперь у меня уже десять полученных достижений!"),	'avaliable': "post"},
			{'id': awardId++, 'name': gls("Молодчик"),				'total': 50,	'stat': REPOST_AWARD,		'category': AwardManager.GENERAL,	'image': "AwardSayAward2",		'text': gls("Опубликуй 50 достижений."),						"awardText": gls("Получено новое достижение «Молодчик» в игре Трагедия Белок! Теперь у меня уже пятьдесят полученных достижений!"),	'avaliable': "post"},
			{'id': awardId++, 'name': gls("Хвастунишка"),				'total': 100,	'stat': REPOST_AWARD,		'category': AwardManager.GENERAL,	'image': "AwardSayAward3",		'text': gls("Опубликуй 100 достижений."),						"awardText": gls("Получено новое достижение «Хвастунишка» в игре Трагедия Белок! Теперь у меня уже сто полученных достижений!"),	'avaliable': "post"},
			{'id': awardId++, 'name': gls("Хорошая компания"),			'total': 1,	'stat': CLAN_JOIN,		'category': AwardManager.GENERAL,	'image': "AwardClan",			'text': gls("Вступи в Клан."),								"awardText": gls("У меня новое достижение «Хорошая компания» в игре Трагедия Белок! Теперь я в клане!")},
			{'id': awardId++, 'name': gls("Перспективный проектировщик"),		'total': 1,	'stat': MAP_SEND,		'category': AwardManager.GENERAL,	'image': "AwardMapCreate",		'text': gls("Создай карту и отправь на модерацию."),					"awardText": gls("Достижение «Перспективный проектировщик» получено за создание своей карты и отправки её на модерацию!")},

			{'id': awardId++, 'name': gls("Шустрый"),				'total': 10,	'stat': HOLLOW_FIRST,		'category': AwardManager.GAME,		'image': "AwardHollowFirst1",		'text': gls("Забеги в дупло первым 10 раз."),						"awardText": gls("У меня новое достижение «Шустрый» - Доберись до дупла первым десять раз!")},
			{'id': awardId++, 'name': gls("Проворный"),				'total': 25,	'stat': HOLLOW_FIRST,		'category': AwardManager.GAME,		'image': "AwardHollowFirst2",		'text': gls("Забеги в дупло первым 25 раз."),						"awardText": gls("У меня новое достижение «Проворный» - Доберись до дупла первым двадцать пять раз!")},
			{'id': awardId++, 'name': gls("Сверхзвуковой"),				'total': 50,	'stat': HOLLOW_FIRST,		'category': AwardManager.GAME,		'image': "AwardHollowFirst3",		'text': gls("Забеги в дупло первым 50 раз."),						"awardText": gls("У меня новое достижение «Сверхзвуковой» - Доберись до дупла первым пятьдесят раз!")},
			{'id': awardId++, 'name': gls("Оруженосец"),				'total': 10,	'stat': WIN_ISLAND,		'category': AwardManager.GAME,		'image': "AwardWinIsland1",		'text': gls("Забеги в дупло 10 раз на Солнечной долине."),				"awardText": gls("Мною получено новое достижение «Оруженосец» - Забежать в дупло десять раз на Солнечной долине!")},
			{'id': awardId++, 'name': gls("Рыцарь"),				'total': 25,	'stat': WIN_ISLAND,		'category': AwardManager.GAME,		'image': "AwardWinIsland2",		'text': gls("Забеги в дупло 25 раз на Солнечной долине."),				"awardText": gls("Мною получено новое достижение «Рыцарь» - Забежать в дупло двадцать пять раз на Солнечной долине!")},
			{'id': awardId++, 'name': gls("Джедай"),				'total': 150,	'stat': WIN_ISLAND,		'category': AwardManager.GAME,		'image': "AwardWinIsland3",		'text': gls("Забеги в дупло 150 раз на Солнечной долине."),				"awardText": gls("Мною получено новое достижение «Джедай» - Забежать в дупло сто пятьдесят раз на Солнечной долине!")},
			{'id': awardId++, 'name': gls("А здесь прохладно!"),			'total': 40,	'stat': WIN_MOUNTAINS,		'category': AwardManager.GAME,		'image': "AwardWinMountain1",		'text': gls("Забеги в дупло 40 раз на Снежных Хребтах."),				"awardText": gls("Мною получено новое достижение «А здесь прохладно» - Забежать в дупло сорок раз на Снежных Хребтах!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Бабушкины варежки"),			'total': 150,	'stat': WIN_MOUNTAINS,		'category': AwardManager.GAME,		'image': "AwardWinMountain2",		'text': gls("Забеги в дупло 150 раз на Снежных Хребтах."),				"awardText": gls("Мною получено новое достижение «Бабушкины варежки» - Забежать в дупло сто пятьдесят раз на Снежных Хребтах!"),	'avaliable': "false"},
			{'id': awardId++, 'name': gls("Отмороженный"),				'total': 300,	'stat': WIN_MOUNTAINS,		'category': AwardManager.GAME,		'image': "AwardWinMountain3",		'text': gls("Забеги в дупло 300 раз на Снежных Хребтах."),				"awardText": gls("Мною получено новое достижения «Отмороженный» - Забежать в дупло триста раз на Снежных Хребтах!"),			'avaliable': "false"},
			{'id': awardId++, 'name': gls("Мачете!"),				'total': 50,	'stat': WIN_SWAMPS,		'category': AwardManager.GAME,		'image': "AwardWinSwamp1",		'text': gls("Забеги в дупло 50 раз в Топях."),						"awardText": gls("Мною получено новое достижение «Мачете» - Забежать в дупло пятьдесят раз в Топях!")},
			{'id': awardId++, 'name': gls("Мачете два!"),				'total': 150,	'stat': WIN_SWAMPS,		'category': AwardManager.GAME,		'image': "AwardWinSwamp2",		'text': gls("Забеги в дупло 150 раз в Топях."),						"awardText": gls("Мною получено новое достижение «Мачете два» - Забежать в дупло сто пятьдесят раз в Топях!")},
			{'id': awardId++, 'name': gls("Мачете три!"),				'total': 300,	'stat': WIN_SWAMPS,		'category': AwardManager.GAME,		'image': "AwardWinSwamp3",		'text': gls("Забеги в дупло 300 раз в Топях."),						"awardText": gls("Мною получено новое достижения «Мачете три» - Забежать в дупло триста раз в Топях!")},
			{'id': awardId++, 'name': gls("Третий глаз"),				'total': 50,	'stat': WIN_SPACESHIP,		'category': AwardManager.GAME,		'image': "AwardWinAnomal1",		'text': gls("Забеги в дупло 50 раз в Аномальной зоне."),				"awardText": gls("Мною получено новое достижение «Третий глаз» - Забежать в дупло пятьдесят раз в Аномальной зоне!")},
			{'id': awardId++, 'name': gls("Шестилапый"),				'total': 150,	'stat': WIN_SPACESHIP,		'category': AwardManager.GAME,		'image': "AwardWinAnomal2",		'text': gls("Забеги в дупло 150 раз в Аномальной зоне."),				"awardText": gls("Мною получено новое достижение «Шестилапый» - Забежать в дупло сто пятьдесят раз в Аномальной зоне!")},
			{'id': awardId++, 'name': gls("Мутант"),				'total': 300,	'stat': WIN_SPACESHIP,		'category': AwardManager.GAME,		'image': "AwardWinAnomal3",		'text': gls("Забеги в дупло 300 раз в Аномальной зоне."),				"awardText": gls("Мною получено новое достижения «Мутант» - Забежать в дупло триста раз в Аномальной зоне!")},
			{'id': awardId++, 'name': gls("Осадки в виде орехов"),			'total': 50,	'stat': WIN_STORM,		'category': AwardManager.GAME,		'image': "AwardWinStorm1",		'text': gls("Забеги в дупло 50 раз в Шторме."),						"awardText": gls("Мною получено новое достижение «Осадки в виде орехов» - Забежать в дупло пятьдесят раз в Шторме!")},
			{'id': awardId++, 'name': gls("Гуляю под дождём"),			'total': 200,	'stat': WIN_STORM,		'category': AwardManager.GAME,		'image': "AwardWinStorm2",		'text': gls("Забеги в дупло 200 раз в Шторме."),					"awardText": gls("Мною получено новое достижение «Гуляю под дождём» - Забежать в дупло двести раз в Шторме!")},
			{'id': awardId++, 'name': gls("Повелитель бури"),			'total': 400,	'stat': WIN_STORM,		'category': AwardManager.GAME,		'image': "AwardWinStorm3",		'text': gls("Забеги в дупло 400 раз в Шторме."),					"awardText": gls("Мною получено новое достижения «Повелитель бури» - Забежать в дупло четыреста раз в Шторме!")},
			{'id': awardId++, 'name': gls("Испытанный"),				'total': 50,	'stat': WIN_COMPLEX,		'category': AwardManager.GAME,		'image': "AwardWinComplex1",		'text': gls("Забеги в дупло 50 раз на Испытаниях."),					"awardText": gls("Мною получено новое достижение «Испытанный» - Забежать в дупло пятьдесят раз на Испытаниях!")},
			{'id': awardId++, 'name': gls("Настоящая белка"),			'total': 200,	'stat': WIN_COMPLEX,		'category': AwardManager.GAME,		'image': "AwardWinComplex2",		'text': gls("Забеги в дупло 200 раз на Испытаниях."),					"awardText": gls("Мною получено новое достижение «Настоящая белка» - Забежать в дупло двести раз на Испытаниях!")},
			{'id': awardId++, 'name': gls("Знак качества"),				'total': 300,	'stat': WIN_COMPLEX,		'category': AwardManager.GAME,		'image': "AwardWinComplex3",		'text': gls("Забеги в дупло 300 раз на Испытаниях."),					"awardText": gls("Мною получено новое достижения «Знак качества» - Забежать в дупло триста раз на Испытаниях!")},
			{'id': awardId++, 'name': gls("Победитель"),				'total': 50,	'stat': BATTLE_WINS,		'category': AwardManager.GAME,		'image': "AwardBattleWin1",		'text': gls("Окажись в победившей команде 50 раз в режиме битвы."),			"awardText": gls("Моя команда победила в битве пятьдесят раз! Получено новое достижение «Победитель» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Полководец"),				'total': 200,	'stat': BATTLE_WINS,		'category': AwardManager.GAME,		'image': "AwardBattleWin2",		'text': gls("Окажись в победившей команде 200 раз в режиме битвы."),			"awardText": gls("Моя команда победила в битве двести раз! Получено новое достижение «Полководец» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Опытный Собиратель"),			'total': 250,	'stat': HOLLOW,			'category': AwardManager.GAME,		'image': "AwardHollow1",		'text': gls("Доберись до дупла 250 раз."),						"awardText": gls("Мною получено новое достижение «Опытный Собиратель» - Забежать в дупло двести пятьдесят раз!")},
			{'id': awardId++, 'name': gls("Усердный Собиратель"),			'total': 1000,	'stat': HOLLOW,			'category': AwardManager.GAME,		'image': "AwardHollow2",		'text': gls("Доберись до дупла 1000 раз."),						"awardText": gls("Мною получено новое достижение «Усердный Собиратель» - Забежать в дупло тысячу раз!")},
			{'id': awardId++, 'name': gls("Великий Собиратель"),			'total': 2000,	'stat': HOLLOW,			'category': AwardManager.GAME,		'image': "AwardHollow3",		'text': gls("Доберись до дупла 2000 раз."),						"awardText": gls("Мною получено новое достижение «Великий Собиратель» - Забежать в дупло две тысячи раз!")},
			{'id': awardId++, 'name': gls("Одетый"),				'total': 50,	'stat': MAGIC_CLOTHES,		'category': AwardManager.GAME,		'image': "AwardMagicClothes1",		'text': gls("Используй магию одежды 50 раз."),						"awardText": gls("Магия одежды дает мне новые возможности! Новое достижение «Одетый» получено!")},
			{'id': awardId++, 'name': gls("Шапка невидимка"),			'total': 250,	'stat': MAGIC_CLOTHES,		'category': AwardManager.GAME,		'image': "AwardMagicClothes2",		'text': gls("Используй магию одежды 250 раз."),						"awardText": gls("Магия одежды дает мне новые возможности! Новое достижение «Шапка невидимка» получено!")},
			{'id': awardId++, 'name': gls("Сапоги скороходы"),			'total': 1500,	'stat': MAGIC_CLOTHES,		'category': AwardManager.GAME,		'image': "AwardMagicClothes3",		'text': gls("Используй магию одежды 1500 раз."),					"awardText": gls("Магия одежды дает мне новые возможности! Новое достижение «Сапоги скороходы» получено!")},
			{'id': awardId++, 'name': gls("Турист"),				'total': 63,	'stat': HOLLOW_ALL,		'category': AwardManager.GAME,		'image': "AwardTourist",		'text': gls("Доберись до дупла в каждой локации."),					"awardText": gls("Получено новое достижение «Турист» за сбор орехов в каждой локации!"),			'values': ["Солнечная долина", "Топи", "Аномальная Зона", "Шторм", "Испытания"]},
			{'id': awardId++, 'name': gls("Добрый Зайка"),				'total': 5,	'stat': WIN_RABBIT,		'category': AwardManager.GAME,		'image': "AwardHareWin",		'text': gls("Не дай ни одной белке добраться до дупла Зайцем НеСудьбы 5 раз."),		"awardText": gls("Так здорово быть Зайцем НеСудьбы, ни одна белка не донесла свой орех!")},
			{'id': awardId++, 'name': gls("Поджигатель"),				'total': 10,	'stat': DRAGON_FIRE,		'category': AwardManager.GAME,		'image': "AwardDragonFire",		'text': gls("Подожги 10 белок, играя за Дракошу."),					"awardText": gls("Мой Дракоша поджарил кучу белок и заработал новое достижение!")},
			{'id': awardId++, 'name': gls("Сентиментальный"),			'total': 10,	'stat': GIFT,			'category': AwardManager.GAME,		'image': "AwardPresentsTake1",		'text': gls("Подари 10 подарков другим белкам на уровне."),				"awardText": gls("Мною сделаны уже десять подарков! Новое достижение «Сентиментальный» получено!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Романтик"),				'total': 100,	'stat': GIFT,			'category': AwardManager.GAME,		'image': "AwardPresentsTake2",		'text': gls("Подари 100 подарков другим белкам на уровне."),				"awardText": gls("Мною сделаны уже сто подарков! Новое достижение «Романтик» получено!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Обожатель"),				'total': 500,	'stat': GIFT,			'category': AwardManager.GAME,		'image': "AwardPresentsTake3",		'text': gls("Подари 500 подарков другим белкам на уровне."),				"awardText": gls("Мною сделаны уже пятьсот подарков! Новое достижение «Обожатель» получено!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Фаворит"),				'total': 10,	'stat': GIFT_ACCEPT,		'category': AwardManager.GAME,		'image': "AwardPresentsGive1",		'text': gls("Получи 10 подарков от других белок на уровне."),				"awardText": gls("У меня новое достижение «Фаворит» в игре Трагедия Белок! Мне подарили уже десять подарков!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Любимчик"),				'total': 50,	'stat': GIFT_ACCEPT,		'category': AwardManager.GAME,		'image': "AwardPresentsGive2",		'text': gls("Получи 50 подарков от других белок на уровне."),				"awardText": gls("У меня новое достижение «Любимчик» в игре Трагедия Белок! Мне подарили уже пятьдесят подарков!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Избранный"),				'total': 200,	'stat': GIFT_ACCEPT,		'category': AwardManager.GAME,		'image': "AwardPresentsGive3",		'text': gls("Получи 200 подарков от других белок на уровне."),				"awardText": gls("У меня новое достижение «Избранный» в игре Трагедия Белок! Мне подарили уже двести подарков!"),		'avaliable': "false"},
			{'id': awardId++, 'name': gls("Проказник"),				'total': 5,	'stat': RABBIT_GLUE,		'category': AwardManager.GAME,		'image': "AwardHareGum",		'text': gls("Скрепи жвачкой белок 5 раз, играя Зайцем НеСудьбы."),			"awardText": gls("У меня новое достижение «Проказник»! Так здорово скреплять жвачкой других белок!")},
			{'id': awardId++, 'name': gls("Зажиточный"),				'total': 500,	'stat': COLLECT_ACORNS,		'category': AwardManager.GAME,		'image': "AwardAcorn1",			'text': gls("Собери 500 орехов за все время."),						"awardText": gls("Собрано уже более пятисот орехов и заработано новое достижение «Зажиточный»!")},
			{'id': awardId++, 'name': gls("Богач"),					'total': 1500,	'stat': COLLECT_ACORNS,		'category': AwardManager.GAME,		'image': "AwardAcorn2",			'text': gls("Собери 1500 орехов за все время."),					"awardText": gls("Собрано уже более полторы тысячи орехов и заработано новое достижение «Богач»!")},
			{'id': awardId++, 'name': gls("Миллионер"),				'total': 5000,	'stat': COLLECT_ACORNS,		'category': AwardManager.GAME,		'image': "AwardAcorn3",			'text': gls("Собери 5000 орехов за все время."),					"awardText": gls("Собрано уже более пяти тысяч орехов и заработано новое достижение «Миллионер»!")},
			{'id': awardId++, 'name': gls("Первая сотня"),				'total': 500,	'stat': SPEND_ACORNS,		'category': AwardManager.GAME,		'image': "AwardAcornSpend1",		'text': gls("Потрать 500 орехов."),							"awardText": gls("Уже пятьсот орехов потрачено! Получено достижение «Первая сотня»!")},
			{'id': awardId++, 'name': gls("Щедрый"),				'total': 1000,	'stat': SPEND_ACORNS,		'category': AwardManager.GAME,		'image': "AwardAcornSpend2",		'text': gls("Потрать 1000 орехов."),							"awardText": gls("Уже тысяча орехов потрачено! Получено достижение «Щедрый»!")},
			{'id': awardId++, 'name': gls("Филантроп"),				'total': 2000,	'stat': SPEND_ACORNS,		'category': AwardManager.GAME,		'image': "AwardAcornSpend3",		'text': gls("Потрать 2000 орехов."),							"awardText": gls("Уже две тысячи орехов потрачено! Получено достижение «Филантроп»!")},
			{'id': awardId++, 'name': gls("Живунчик"),				'total': 5,	'stat': WIN_SURVIVAL,		'category': AwardManager.GAME,		'image': "AwardWinSurvival",		'text': gls("Спасись от черного шамана 5 раз."),					"awardText": gls("Безумный шаман пытался убить меня, но мне удалось уйти живым!")},

			{'id': awardId++, 'name': gls("Шаман с дипломом"),			'total': 1,	'stat': SHAMAN_CERT,		'category': AwardManager.SHAMAN,	'image': "AwardShamanCert",		'text': gls("Получи сертификат шамана."),						"awardText": gls("Теперь я сертифицированный шаман!")},
			{'id': awardId++, 'name': gls("Молодой шаман"),				'total': 50,	'stat': SHAMAN,			'category': AwardManager.SHAMAN,	'image': "AwardShamanPlay1",		'text': gls("Сыграй 50 игр шаманом."),							"awardText": gls("Новое достижение «Молодой Шаман»! Шаманом сыграно уже пятьдесят игр!")},
			{'id': awardId++, 'name': gls("Гуру"),					'total': 200,	'stat': SHAMAN,			'category': AwardManager.SHAMAN,	'image': "AwardShamanPlay2",		'text': gls("Сыграй 200 игр шаманом."),							"awardText": gls("Новое достижение «Гуру»! Шаманом сыграно уже двести игр!")},
			{'id': awardId++, 'name': gls("Магистр"),				'total': 400,	'stat': SHAMAN,			'category': AwardManager.SHAMAN,	'image': "AwardShamanPlay3",		'text': gls("Сыграй 400 игр шаманом."),							"awardText": gls("Новое достижение «Магистр»! Шаманом сыграно уже четыреста игр!")},
			{'id': awardId++, 'name': gls("Ведущий"),				'total': 100,	'stat': SHAMAN_GIVE_ACORN,	'category': AwardManager.SHAMAN,	'image': "AwardShamanHollow1",		'text': gls("Заведи 100 белок в дупло шаманом."),					"awardText": gls("Достижение «Ведущий» получено! Заведено уже более ста белок в дупло!")},
			{'id': awardId++, 'name': gls("Спаситель"),				'total': 350,	'stat': SHAMAN_GIVE_ACORN,	'category': AwardManager.SHAMAN,	'image': "AwardShamanHollow2",		'text': gls("Заведи 350 белок в дупло шаманом."),					"awardText": gls("Достижение «Спаситель» получено! Заведено уже триста пятьдесят белок в дупло!")},
			{'id': awardId++, 'name': gls("Незаменимый"),				'total': 1500,	'stat': SHAMAN_GIVE_ACORN,	'category': AwardManager.SHAMAN,	'image': "AwardShamanHollow3",		'text': gls("Заведи 1500 белок в дупло шаманом."),					"awardText": gls("Достижение «Незаменимый» получено! Заведено уже полторы тысячи белок в дупло!")},
			{'id': awardId++, 'name': gls("Трубка мира"),				'total': 100,	'stat': SHAMAN_ISLAND,		'category': AwardManager.SHAMAN,	'image': "AwardShamanIsland",		'text': gls("Сыграй шаманом на Солнечной Долине 100 раз."),				"awardText": gls("Я получил новое достижение «Трубка мира», сыграв шаманом на Солнечной Долине сто раз!")},
			{'id': awardId++, 'name': gls("Снежный волк"),				'total': 100,	'stat': SHAMAN_MOUNTAINS,	'category': AwardManager.SHAMAN,	'image': "AwardShamanMountain",		'text': gls("Сыграй шаманом на Снежных хребтах 100 раз."),				"awardText": gls("Я получил новое достижение «Снежный волк», сыграв шаманом на Снежных Хребтах сто раз!"),	'avaliable': "false"},
			{'id': awardId++, 'name': gls("Волшебная плесень"),			'total': 100,	'stat': SHAMAN_SWAMPS,		'category': AwardManager.SHAMAN,	'image': "AwardShamanSwamp",		'text': gls("Сыграй шаманом в Топях 100 раз."),						"awardText": gls("Я получил новое достижение «Волшебная плесень», сыграв шаманом в Топях сто раз!")},
			{'id': awardId++, 'name': gls("Болт на верёвочке"),			'total': 100,	'stat': SHAMAN_SPACESHIP,	'category': AwardManager.SHAMAN,	'image': "AwardShamanAnomal",		'text': gls("Сыграй шаманом в Аномальной зоне 100 раз."),				"awardText": gls("Я получил новое достижение «Болт на верёвочке», сыграв шаманом в Аномальной зоне сто раз!")},
			{'id': awardId++, 'name': gls("Бурерождённый"),				'total': 100,	'stat': SHAMAN_STORM,		'category': AwardManager.SHAMAN,	'image': "AwardShamanStorm",		'text': gls("Сыграй шаманом в Шторме 100 раз."),					"awardText": gls("Я получил новое достижение «Бурерождённый», сыграв шаманом в Шторме сто раз!")},
			{'id': awardId++, 'name': gls("Мастер боевых искусств"),		'total': 100,	'stat': SHAMAN_COMPLEX,		'category': AwardManager.SHAMAN,	'image': "AwardShamanComplex",		'text': gls("Сыграй шаманом в режиме Испытаний 100 раз."),				"awardText": gls("Я получил новое достижение «Мастер боевых искусств», сыграв шаманом в Испытаниях сто раз!")},
			{'id': awardId++, 'name': gls("Оракул"),				'total': 15,	'stat': TWO_SHAMAN_SQUIRRELS,	'category': AwardManager.SHAMAN,	'image': "AwardShamanTwo1",		'text': gls("Заведи 15 белок в дупло шаманом в режиме двух шаманов."),			"awardText": gls("У меня новое достижение «Оракул» в игре Трагедия Белок! Пятнадцать белок выбрали меня в режиме двух шаманов!")},
			{'id': awardId++, 'name': gls("Пророк"),				'total': 50,	'stat': TWO_SHAMAN_SQUIRRELS,	'category': AwardManager.SHAMAN,	'image': "AwardShamanTwo2",		'text': gls("Заведи 50 белок в дупло шаманом в режиме двух шаманов."),			"awardText": gls("У меня новое достижение «Пророк» в игре Трагедия Белок! Пятьдесят пять белок выбрали меня в режиме двух шаманов!")},
			{'id': awardId++, 'name': gls("Мессия"),				'total': 150,	'stat': TWO_SHAMAN_SQUIRRELS,	'category': AwardManager.SHAMAN,	'image': "AwardShamanTwo3",		'text': gls("Заведи 150 белок в дупло шаманом в режиме двух шаманов."),			"awardText": gls("У меня новое достижение «Мессия» в игре Трагедия Белок! Сто пятьдесят белок выбрали меня в режиме двух шаманов!")},
			{'id': awardId++, 'name': gls("Любимый шаман"),				'total': 5,	'stat': WIN_TWO_SHAMANS,	'category': AwardManager.SHAMAN,	'image': "AwardShamanTwoWin",		'text': gls("Доведи до дупла 7 белок за один раунд в режиме двух шаманов 5 раз."),	"awardText": gls("Новое достижение «Любимый шаман» получено! В режиме двух белок большинство выбрало меня!")},
			{'id': awardId++, 'name': gls("Учуял по запаху"),			'total': 5,	'stat': SHAMAN_INVISIBLE_KILLS,	'category': AwardManager.SHAMAN,	'image': "AwardKillInvisible1",		'text': gls("Убей 5 невидимых белок в режиме «Злой шаман»."),				"awardText": gls("Я заработал новое достижение «Учуял по запаху» в игре Трагедия Белок! Невидимые белки тоже смертны!")},
			{'id': awardId++, 'name': gls("Слепой монах"),				'total': 10,	'stat': SHAMAN_INVISIBLE_KILLS,	'category': AwardManager.SHAMAN,	'image': "AwardKillInvisible2",		'text': gls("Убей 10 невидимых белок в режиме «Злой шаман»."),				"awardText": gls("Я заработал новое достижение «Слепой монах» в игре Трагедия Белок! Невидимые белки тоже смертны!")},
			{'id': awardId++, 'name': gls("Ниндзя"),				'total': 15,	'stat': SHAMAN_INVISIBLE_KILLS,	'category': AwardManager.SHAMAN,	'image': "AwardKillInvisible3",		'text': gls("Убей 15 невидимых белок в режиме «Злой Шаман»."),				"awardText": gls("Я заработал новое достижение «Ниндзя» в игре Трагедия Белок! Невидимые белки тоже смертны!")},
			{'id': awardId++, 'name': gls("Злобный"),				'total': 5,	'stat': WIN_SURVIVAL_SHAMAN,	'category': AwardManager.SHAMAN,	'image': "AwardShamanBlack1",		'text': gls("Убей всех белок чёрным шаманом и останься в живых 5 раз."),		"awardText": gls("Весело быть черным шаманом! Получено новое достижение «Злобный»!")},
			{'id': awardId++, 'name': gls("Безумец"),				'total': 10,	'stat': WIN_SURVIVAL_SHAMAN,	'category': AwardManager.SHAMAN,	'image': "AwardShamanBlack2",		'text': gls("Убей всех белок чёрным шаманом и останься в живых 10 раз."),		"awardText": gls("Весело быть черным шаманом! Получено новое достижение «Безумец»!")},
			{'id': awardId++, 'name': gls("Помощник"),				'total': 5,	'stat': PLAY_CAST,		'category': AwardManager.SHAMAN,	'image': "AwardSquirrelCreate1",	'text': gls("Создай 5 предметов, играя за обычную белку."),				"awardText": gls("Пять предметов созданы мною за обычную белку! У меня новое достижение «Помощник» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("С блэкджеком и белочками"),		'total': 25,	'stat': PLAY_CAST,		'category': AwardManager.SHAMAN,	'image': "AwardSquirrelCreate2",	'text': gls("Создай 25 предметов, играя за обычную белку."),				"awardText": gls("Двадцать пять предметов созданы мною за обычную белку! У меня новое достижение «С блэкджеком и белочками» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Просто шаман объелся грибов"),		'total': 50,	'stat': PLAY_CAST,		'category': AwardManager.SHAMAN,	'image': "AwardSquirrelCreate3",	'text': gls("Создай 50 предметов, играя за обычную белку."),				"awardText": gls("Пятьдесят предметов созданы мною за обычную белку! У меня новое достижение «Просто шаман объелся грибов» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Инженер"),				'total': 10,	'stat': SHAMAN_CAST,		'category': AwardManager.SHAMAN,	'image': "AwardShamanCreate1",		'text': gls("Создай 10 предметов, играя шаманом."),					"awardText": gls("Достижение «Инженер» получено! Всего-то и стоило создать десять предметов шаманом!")},
			{'id': awardId++, 'name': gls("Конструктор"),				'total': 300,	'stat': SHAMAN_CAST,		'category': AwardManager.SHAMAN,	'image': "AwardShamanCreate2",		'text': gls("Создай 300 предметов, играя шаманом."),					"awardText": gls("Достижение «Конструктор» получено! Всего-то и стоило создать триста предметов шаманом!")},
			{'id': awardId++, 'name': gls("Творец"),				'total': 2000,	'stat': SHAMAN_CAST,		'category': AwardManager.SHAMAN,	'image': "AwardShamanCreate3",		'text': gls("Создай 2000 предметов, играя шаманом."),					"awardText": gls("Достижение «Творец» получено! Всего-то и стоило создать две тысячи предметов шаманом!")},
			{'id': awardId++, 'name': gls("Муки совести"),				'total': 5,	'stat': PLAY_CAST_REMOVE,	'category': AwardManager.SHAMAN,	'image': "AwardSquirrelDestroy1",	'text': gls("Уничтожь 5 предметов, играя за обычную белку."),				"awardText": gls("У меня новое достижение «Муки совести» в игре Трагедия Белок! Ставить и уничтожать предметы весело!")},
			{'id': awardId++, 'name': gls("Один раз отмерь"),			'total': 10,	'stat': PLAY_CAST_REMOVE,	'category': AwardManager.SHAMAN,	'image': "AwardSquirrelDestroy2",	'text': gls("Уничтожь 10 предметов, играя за обычную белку."),				"awardText": gls("У меня новое достижение «Один раз отмерь» в игре Трагедия Белок! Ставить и уничтожать предметы весело!")},
			{'id': awardId++, 'name': gls("Я художник"),				'total': 20,	'stat': PLAY_CAST_REMOVE,	'category': AwardManager.SHAMAN,	'image': "AwardSquirrelDestroy3",	'text': gls("Уничтожь 20 предметов, играя за обычную белку."),				"awardText": gls("У меня новое достижение «Я художник» в игре Трагедия Белок! Ставить и уничтожать предметы весело!")},
			{'id': awardId++, 'name': gls("Уничтожитель"),				'total': 10,	'stat': SHAMAN_CAST_REMOVE,	'category': AwardManager.SHAMAN,	'image': "AwardShamanDestroy1",		'text': gls("Уничтожь 10 предметов, играя шаманом."),					"awardText": gls("Получено новое достижение «Уничтожитель» в игре Трагедия Белок! Уничтожать предметы шамана весело!")},
			{'id': awardId++, 'name': gls("Вандал"),				'total': 200,	'stat': SHAMAN_CAST_REMOVE,	'category': AwardManager.SHAMAN,	'image': "AwardShamanDestroy2",		'text': gls("Уничтожь 200 предметов, играя шаманом."),					"awardText": gls("Получено новое достижение «Вандал» в игре Трагедия Белок! Уничтожать предметы шамана весело!")},
			{'id': awardId++, 'name': gls("Антиматерия в коробочке"),		'total': 500,	'stat': SHAMAN_CAST_REMOVE,	'category': AwardManager.SHAMAN,	'image': "AwardShamanDestroy3",		'text': gls("Уничтожь 500 предметов, играя шаманом."),					"awardText": gls("Получено новое достижение «Антиматерия в коробочке» в игре Трагедия Белок! Уничтожать предметы шамана весело!")},

			{'id': awardId++, 'name': gls("Превосходный"),				'total': 3,	'stat': BUY_SUBSCRIBE_MIDDLE,	'category': AwardManager.EPIC,		'image': "AwardBuySubscribe1",		'text': gls("Купи 3 зелья превосходства на 7 дней."),					"awardText": gls("Эпическое достижение «Превосходный» получено в игре Трагедия Белок! С зельем превосходства я чувствую себя всесильным!"),	'avaliable': "false"},
			{'id': awardId++, 'name': gls("Блистательный"),				'total': 1,	'stat': BUY_SUBSCRIBE_BIG,	'category': AwardManager.EPIC,		'image': "AwardBuySubscribe2",		'text': gls("Купи зелье превосходства на 30 дней."),					"awardText": gls("Эпическое достижение «Блистательный» получено в игре Трагедия Белок! С зельем превосходства я чувствую себя всесильным!"),	'avaliable': "false"},
			{'id': awardId++, 'name': gls("Энерджайзер"),				'total': 10,	'stat': BUY_ENERGY,		'category': AwardManager.EPIC,		'image': "AwardEnergy3",		'text': gls("Купи 10 Энергетических напитков или Колдовских отваров."),			"awardText": gls("Использованы ещё десять зелий и получено новое достижение «Энерджайзер»!")},
			{'id': awardId++, 'name': gls("Лучше всех"),				'total': 1,	'stat': BECOME_SUPER,		'category': AwardManager.EPIC,		'image': "AwardSuper",			'text': gls("Стань Супербелкой."),							"awardText": gls("Теперь я супербелка! Эпическое достижение «Лучше всех» получено!"),	'avaliable': "super"},
			{'id': awardId++, 'name': gls("Сундук"),				'total': 1,	'stat': CHEST,			'category': AwardManager.EPIC,		'image': "AwardChest",			'text': gls("Купи сундук."),								"awardText": gls("Эпическое достижение «Сундук» получено в игре Трагедия Белок!"),	'avaliable': "chest"},
			{'id': awardId++, 'name': gls("Осторожный"),				'total': 5,	'stat': BATTLE_ALIVE,		'category': AwardManager.EPIC,		'image': "AwardBattleAlive",		'text': gls("Не умри ни разу за раунд в режиме битвы 5 раз."),				"awardText": gls("Осторожность никогда не помешает. Не умереть ни разу в битве было не так просто!")},
			{'id': awardId++, 'name': gls("Изворотливый"),				'total': 10,	'stat': FIRST_FLYING_ACORN,	'category': AwardManager.EPIC,		'image': "AwardGetAcornFirst",		'text': gls("Поймай летающий орех раньше всех 10 раз."),				"awardText": gls("Эпическое достижение «Изворотливый» получено в игре Трагедия Белок! Летающий орех не так легко поймать!")},
			{'id': awardId++, 'name': gls("Фанат игры"),				'total': 50,	'stat': CONTINUES_ENTER,	'category': AwardManager.EPIC,		'image': "AwardFan3",			'text': gls("Заходи в игру 50 дней подряд, не пропуская ни одного."),			"awardText": gls("У меня новое достижение «Фанат игры» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Братюня"),				'total': 10,	'stat': FRIENDS_PLAY_ON_FIVE,	'category': AwardManager.EPIC,		'image': "AwardFriendsCall3",		'text': gls("10 приглашённых тобой друзей достигли {0} уровня.", Game.LEVEL_TO_FRIEND_INVITE),	"awardText": gls("Получено новое достижение «Братюня», десять приглашённых мною друзей достигли {0} уровня в игре Трагедия Белок!", Game.LEVEL_TO_FRIEND_INVITE)},
			{'id': awardId++, 'name': gls("Неугомонный"),				'total': 5000,	'stat': HOLLOW,			'category': AwardManager.EPIC,		'image': "AwardHollow4",		'text': gls("Забеги в дупло 5000 раз."),						"awardText": gls("Новое эпическое достижение «Неугомонный» получено! Добраться до дупла пять тысяч раз было не так просто!")},
			{'id': awardId++, 'name': gls("Со скоростью света"),			'total': 1000,	'stat': HOLLOW_FIRST,		'category': AwardManager.EPIC,		'image': "AwardHollowFirst4",		'text': gls("Забеги в дупло первым 1000 раз."),						"awardText": gls("Новое эпическое достижение «Со скоростью света» получено! Забежать в дупло тысячу раз было не так просто!")},
			{'id': awardId++, 'name': gls("Диктатор"),				'total': 400,	'stat': BATTLE_WINS,		'category': AwardManager.EPIC,		'image': "AwardBattleWin3",		'text': gls("Окажись в победившей команде 400 раз в режиме битвы."),			"awardText": gls("Моя команда победила в битве четыреста раз! Получено новое достижение «Диктатор» в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Старейшина"),				'total': 1000,	'stat': SHAMAN,			'category': AwardManager.EPIC,		'image': "AwardShamanPlay4",		'text': gls("Сыграй шаманом 1000 раз."),						"awardText": gls("Новое эпическое достижение «Старейшина» получено! Сыграть шаманом тысячу раз было не так просто!")},
			{'id': awardId++, 'name': gls("Псих"),					'total': 15,	'stat': WIN_SURVIVAL_SHAMAN,	'category': AwardManager.EPIC,		'image': "AwardShamanBlack3",		'text': gls("Убей всех белок чёрным шаманом и останься в живых 15 раз."),		"awardText": gls("Весело быть черным шаманом! Получено новое достижение «Псих»!")},
			{'id': awardId++, 'name': gls("Хомяк"),					'total': 30000,	'stat': COLLECT_ACORNS,		'category': AwardManager.EPIC,		'image': "AwardAcorn4",			'text': gls("Собери 30000 орехов за все время."),					"awardText": gls("Я получил эпическое достижение «Хомяк», собрав тридцать тысяч орехов за все время в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Транжира"),				'total': 20000,	'stat': SPEND_ACORNS,		'category': AwardManager.EPIC,		'image': "AwardAcornSpend4",		'text': gls("Потрать 20000 орехов."),							"awardText": gls("Новое эпическое достижение «Транжира» получено! Потрачено уже двадцать тысяч орехов в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Архимаг"),				'total': 1000,	'stat': MAGIC_ALL,		'category': AwardManager.EPIC,		'image': "AwardMagicAll3",		'text': gls("Используй любую магию 1000 раз."),						"awardText": gls("Получено новое достижение «Архимаг», магия белок была использована тысячу раз!")},
			{'id': awardId++, 'name': gls("Упорный"),				'total': 1,	'stat': COLLECTION_ASSEMBLE,	'category': AwardManager.EPIC,		'image': "AwardCollection1",		'text': gls("Собери одну коллекцию предметов."),					"awardText": gls("Я получил эпическое достижение «Упорный», собрав коллекцию в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Совершенный"),				'total': 6,	'stat': COLLECTION_ASSEMBLE,	'category': AwardManager.EPIC,		'image': "AwardCollection2",		'text': gls("Собери 6 коллекций предметов."),						"awardText": gls("Я получил эпическое достижение «Совершенный», собрав шесть коллекций в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Перфекционист"),				'total': 10,	'stat': COLLECTION_ASSEMBLE,	'category': AwardManager.EPIC,		'image': "AwardCollection3",		'text': gls("Собери 10 коллекций предметов."),						"awardText": gls("Я получил эпическое достижение «Перфекционист», собрав десять коллекций в игре Трагедия Белок!")},
			{'id': awardId++, 'name': gls("Скрэт"),					'total': 1,	'stat': SCRAT,			'category': AwardManager.EPIC,		'image': "AwardScrat",			'text': gls("Собери Скрэта."),								"awardText": gls("Получено эпическое достижение «Скрэт», за сбор всех коллекций для получения Скрэта!")},
			{'id': awardId++, 'name': gls("Скрэтти"),				'total': 1,	'stat': SCRATTY,		'category': AwardManager.EPIC,		'image': "AwardScratty",		'text': gls("Собери Скрэтти."),								"awardText": gls("Получено эпическое достижение «Скрэтти», за сбор всех коллекций для получения Скрэтти!")},
			{'id': awardId++, 'name': gls("Железный Скрэт"),			'total': 1,	'stat': SCRAT_IRON,		'category': AwardManager.EPIC,		'image': "AwardScratIron",		'text': gls("Собери костюм Железного Скрэта."),						"awardText": gls("Новое эпическое достижение «Железный Скрэт» получено! Теперь у меня есть костюм Железного Скрэта!")},
			{'id': awardId++, 'name': gls("Железная Скрэтти"),			'total': 1,	'stat': SCRATTY_IRON,		'category': AwardManager.EPIC,		'image': "AwardScrattyIron",		'text': gls("Собери костюм Железной Скрэтти."),						"awardText": gls("Новое эпическое достижение «Железная Скрэтти» получено! Теперь у меня есть костюм Железной Скрэтти!")},
			{'id': awardId++, 'name': gls("Скрэт-Гаргул"),				'total': 1,	'stat': SCRAT_DRAGON,		'category': AwardManager.EPIC,		'image': "AwardScratDragon",		'text': gls("Собери костюм Скрэта-Гаргула."),						"awardText": gls("Новое эпическое достижение «Скрэт-Гаргул» получено! Теперь у меня есть костюм Скрэта-Гаргула!")},
			{'id': awardId++, 'name': gls("Скрэтти-Гаргулья"),			'total': 1,	'stat': SCRATTY_DRAGON,		'category': AwardManager.EPIC,		'image': "AwardScrattyDragon",		'text': gls("Собери костюм Скрэтти-Гаргульи."),						"awardText": gls("Новое эпическое достижение «Скрэтти-Гаргулья» получено! Теперь у меня есть костюм Скрэтти-Гаргульи!")},
			{'id': awardId++, 'name': gls("Скрэт-Фокусник"),			'total': 1,	'stat': SCRAT_MAGIC,		'category': AwardManager.EPIC,		'image': "AwardScratMagic",		'text': gls("Собери костюм Скрэта-Фокусника."),						"awardText": gls("Новое эпическое достижение «Скрэт-Фокусник» получено! Теперь у меня есть костюм Скрэта-Фокусника!")},
			{'id': awardId++, 'name': gls("Скрэтти-Фокусница"),			'total': 1,	'stat': SCRATTY_MAGIC,		'category': AwardManager.EPIC,		'image': "AwardScrattyMagic",		'text': gls("Собери костюм Скрэтти-Фокусницы."),					"awardText": gls("Новое эпическое достижение «Скрэтти-Фокусница» получено! Теперь у меня есть костюм Скрэтти-Фокусницы!")},
			{'id': awardId++, 'name': gls("Поклонник Скрэта"),			'total': 15,	'stat': SCRAT_ALL,		'category': AwardManager.EPIC,		'image': "AwardScratAll",		'text': gls("Собери костюмы Скрэта."),							"awardText": gls("Эпическое достижение «Поклонник Скрэта» получено в игре Трагедия Белок! Теперь у меня есть костюмы Скрэта!"), 'values': [gls("Скрэт"), gls("Скрэт-Гаргул"), gls("Железный Скрэт"), gls("Скрэт-Фокусник")]},
			{'id': awardId++, 'name': gls("Поклонник Скрэтти"),			'total': 15,	'stat': SCRATTY_ALL,		'category': AwardManager.EPIC,		'image': "AwardScrattyAll",		'text': gls("Собери костюмы Скрэтти."),							"awardText": gls("Эпическое достижение «Поклонник Скрэтти» получено в игре Трагедия Белок! Теперь у меня есть костюмы Скрэтти!"), 'values': [gls("Скрэтти"), gls("Скрэтти-Гаргулья"), gls("Железная Скрэтти"), gls("Скрэтти-Фокусница")]},
			{'id': awardId++, 'name': gls("Оборотень"),				'total': 63,	'stat': WEREWOLF,		'category': AwardManager.EPIC,		'image': "AwardWerewolf",		'text': gls("Сыграй всеми персонажами Трагедии Белок."),				"awardText": gls("Эпическое достижение «Оборотень» получено! Собрать и сыграть всеми персонажами игры Трагедия Белок было не так просто!"), 'values': [gls("Шаман"), gls("Чёрный Шаман"), gls("Дракоша"), gls("Заяц НеСудьбы"), gls("Скрэт"), gls("Скрэтти")]},

			{'id': awardId++, 'name': gls("Кладоискатель"),				'total': 30,	'stat': WIN_DESERT,		'category': AwardManager.GAME,		'image': "AwardWinDesert1",		'text': gls("Забеги в дупло 30 раз в Пустыне."),					"awardText": gls("Я заработал достижение «Кладоискатель» - Забежать в дупло тридцать раз в Пустыне!")},
			{'id': awardId++, 'name': gls("Собиратель древностей"),			'total': 150,	'stat': WIN_DESERT,		'category': AwardManager.GAME,		'image': "AwardWinDesert2",		'text': gls("Забеги в дупло 150 раз в Пустыне."),					"awardText": gls("Я заработал достижение «Собиратель древностей» - Забежать в дупло сто пятьдесят раз в Пустыне!")},
			{'id': awardId++, 'name': gls("Расхититель гробниц"),			'total': 500,	'stat': WIN_DESERT,		'category': AwardManager.GAME,		'image': "AwardWinDesert3",		'text': gls("Забеги в дупло 500 раз в Пустыне."),					"awardText": gls("Я заработал достижение «Расхититель гробниц» - Забежать в дупло пятьсот раз в Пустыне!")},
			{'id': awardId++, 'name': gls("Обезвоженный"),				'total': 5,	'stat': DESERT_ALIVE,		'category': AwardManager.GAME,		'image': "AwardDesertThirst1",		'text': gls("Опусти шкалу воды до 50% и выживи 5 раз"),					"awardText": gls("Новое достижение «Обезвоженный»! Кажется, я научился мастерски выживать в Пустыне.")},
			{'id': awardId++, 'name': gls("Сушёные финики"),			'total': 25,	'stat': DESERT_ALIVE,		'category': AwardManager.GAME,		'image': "AwardDesertThirst2",		'text': gls("Опусти шкалу воды до 50% и выживи 25 раз"),				"awardText": gls("Новое достижение «Сушёные финики»! Кажется, я научился мастерски выживать в Пустыне.")},
			{'id': awardId++, 'name': gls("Сухая и не пахнет"),			'total': 100,	'stat': DESERT_ALIVE,		'category': AwardManager.GAME,		'image': "AwardDesertThirst3",		'text': gls("Опусти шкалу воды до 50% и выживи 100 раз"),				"awardText": gls("Новое достижение «Сухая и не пахнет»! Кажется, я научился мастерски выживать в Пустыне.")},
			{'id': awardId++, 'name': gls("Погонщик верблюдов"),			'total': 10,	'stat': DESERT_AURA,		'category': AwardManager.SHAMAN,	'image': "AwardDesertAura1",		'text': gls("Не выходи из ауры шамана ни разу в 10 раундах."),				"awardText": gls("Достижение «Погонщик Верблюдов». Когда Шаман несёт воду в пустыне — не стоит отходить слишком далеко.")},
			{'id': awardId++, 'name': gls("Охранник каравана"),			'total': 30,	'stat': DESERT_AURA,		'category': AwardManager.SHAMAN,	'image': "AwardDesertAura2",		'text': gls("Не выходи из ауры шамана ни разу в 30 раундах."),				"awardText": gls("Достижение «Охранник каравана». Когда Шаман несёт воду в пустыне — не стоит отходить слишком далеко.")},
			{'id': awardId++, 'name': gls("Странствующий торговец"),		'total': 100,	'stat': DESERT_AURA,		'category': AwardManager.SHAMAN,	'image': "AwardDesertAura3",		'text': gls("Не выходи из ауры шамана ни разу в 100 раундах."),				"awardText": gls("Достижение «Странствующий торговец». Когда Шаман несёт воду в пустыне — не стоит отходить слишком далеко.")},
			{'id': awardId++, 'name': gls("Наследник Трона"),			'total': 100,	'stat': SHAMAN_DESERT,		'category': AwardManager.SHAMAN,	'image': "AwardShamanDesert",		'text': gls("Сыграй шаманом в Пустыне 100 раз."),					"awardText": gls("Я получил новое достижение «Наследник Трона», сыграв шаманом в Пустыне сто раз!")},
			{'id': awardId++, 'name': gls("Жажда"),					'total': 10,	'stat': SHAMAN_DESERT_WIN,	'category': AwardManager.SHAMAN,	'image': "AwardDesertHelper1",		'text': gls("Не дай ни одной белке умереть от жажды в 10 играх."),			"awardText": gls("Новое достижение «Жажда». Когда я Шаман, ни одна белка не умрёт от обезвоживания в Пустыне.")},
			{'id': awardId++, 'name': gls("Глоток воды"),				'total': 100,	'stat': SHAMAN_DESERT_WIN,	'category': AwardManager.SHAMAN,	'image': "AwardDesertHelper2",		'text': gls("Не дай ни одной белке умереть от жажды в 100 играх."),			"awardText": gls("Новое достижение «Глоток воды». Целых сто игр я спас всех белочек от обезвоживания в Пустыне.")},
			{'id': awardId++, 'name': gls("Спасительный источник"),			'total': 500,	'stat': SHAMAN_DESERT_WIN,	'category': AwardManager.EPIC,		'image': "AwardDesertHelper3",		'text': gls("Не дай ни одной белке умереть от жажды в 500 играх."),			"awardText": gls("Новое достижение «Спасительный источник». Целых двести игр я спас всех белочек от обезвоживания в Пустыне.")},
			{'id': awardId++, 'name': gls("Как будто жары недостаточно?!"),		'total': 10,	'stat': DESERT_RABBIT,		'category': AwardManager.EPIC,		'image': "AwardDesertHare",		'text': gls("Сыграй Зайцем НеСудьбы в Пустыне 10 раз."),				"awardText": gls("НеСудьба белочкам выбраться из Пустыни. Я получил достижение «Как будто жары недостаточно?!» За игру Зайцем.")},
			{'id': awardId++, 'name': gls("Грабитель караванов"),			'total': 15,	'stat': DESERT_DRAGON,		'category': AwardManager.EPIC,		'image': "AwardDesertDragon",		'text': gls("Сыграй Дракошей в Пустыне 15 раз."),					"awardText": gls("Достижение «Грабитель кОрОванов» за игру Дракошей в Пустыне. Дракоша, определённо, выносливее белки!")}
			];

		static public const CAPTION:TextFormat = new TextFormat(null, 16, 0x663300, true);
		static public const TEXT:TextFormat = new TextFormat(null, 14, 0x663300, false);
		static public const BAR:TextFormat = new TextFormat(null, 16, 0xFFFFFF, true);

		static public var counterInAward:Object = {};

		public var id:int = -1;

		public var isLock:Boolean = false;
		public var current:uint = 0;

		private var _view:Sprite = null;
		private var mask:DisplayObject;
		private var bar:Bar;
		private var field:GameField;
		private var partImages:Vector.<DisplayObject> = new Vector.<DisplayObject>();

		private var imageLock:DisplayObject;
		private var imageComplete:DisplayObject;
		private var imageProgress:DisplayObject;
		private var status:Status;

		public function Award(id:int):void
		{
			this.id = id;
		}

		static public function init():void
		{
			var stats:Dictionary = new Dictionary();
			var prev:Dictionary = new Dictionary();
			for each (var data:Object in DATA)
			{
				if (!(data['stat'] in stats))
					stats[data['stat']] = 0;
				if (data['stat'] in prev)
				{
					prev[data['stat']]['last'] = false;
					data['unlock_name'] = prev[data['stat']]['name'];
				}
				data['unlock'] = stats[data['stat']];
				data['last'] = true;
				stats[data['stat']] += data['total'];
				prev[data['stat']] = data;

				if (data['stat'] in counterInAward)
					counterInAward[data['stat']].push(data['id']);
				else
					counterInAward[data['stat']] = [data['id']];
			}
		}

		static public function getProgress(counter:int, newValue:int, oldValue:int):Object
		{
			var awards:Array = counterInAward[counter];

			for (var i:int = 0; i < awards.length; i++)
			{
				var award:Object = DATA[awards[i]];
				if (award['unlock'] > newValue)
					continue;
				var oldPercent:int = 100 * (oldValue - award['unlock']) / award['total'];
				var newPercent:int = 100 * (newValue - award['unlock']) / award['total'];
				for (var j:int = 0; j <= 100; j += 20)
				{
					if (!(oldPercent < j && newPercent >= j))
						continue;
					return {'id': awards[i], 'value': j};
				}
			}
			return null;
		}

		static public function getImage(id:int):DisplayObject
		{
			return new AwardImageLoader(id);
		}

		static public function getImagePart(id:int, part:int):DisplayObject
		{
			var imageClass:Class = getDefinitionByName(DATA[id]['image'] + part.toString()) as Class;
			return new imageClass as DisplayObject;
		}

		public function get view():Sprite
		{
			if (this._view == null)
			{
				this._view = new Sprite();
				init();
			}
			return this._view;
		}

		public function get name():String
		{
			return DATA[this.id]['name'];
		}

		public function get text():String
		{
			return DATA[this.id]['text'];
		}

		public function get complete():Boolean
		{
			return this.current >= this.total;
		}

		public function get total():uint
		{
			return DATA[this.id]['total'];
		}

		public function get category():int
		{
			return DATA[this.id]['category'];
		}

		public function get avaliable():Boolean
		{
			if (!('avaliable' in DATA[this.id]))
				return true;
			if (DATA[this.id]['avaliable'] == "post")
				return (Game.self.type == Config.API_VK_ID || Game.self.type == Config.API_OK_ID || Game.self.type == Config.API_FB_ID || Game.self.type == Config.API_MM_ID);
			return false;
		}

		public function set stat(value:Object):void
		{
			if (DATA[this.id]['stat'] in value)
				this.value = value[DATA[this.id]['stat']];
			else
				this.value = 0;
		}

		public function get unlock():uint
		{
			return DATA[this.id]['unlock'];
		}

		public function get values():Array
		{
			if ("values" in DATA[this.id])
				return DATA[this.id]['values'];
			return null;
		}

		public function get unlockName():String
		{
			if ("unlock_name" in DATA[this.id])
				return DATA[this.id]['unlock_name'];
			return "";
		}

		public function get isLast():Boolean
		{
			//Не показывать и для последнего достижения максимальный прогресс
			return DATA[this.id]['last'] && false;
		}

		private function set value(value:int):void
		{
			var current:uint = value < 0 ? value + (1 << 16) : value;
			this.current = Math.max(current - this.unlock, 0);
			if (!this.isLast)
				this.current = Math.min(this.current, this.total);
			this.isLock = current < this.unlock;

			if (this._view == null)
				return;

			if (this.values == null)
			{
				this.bar.setValues(this.current, this.total);
				this.bar.buttonMode = this.complete;
				this.field.text = this.current + "/" + this.total;
				this.field.x = 110 - (this.field.textWidth * 0.5);
				this.status.setStatus(this.complete ? gls("<body>Рассказать друзьям</body>") : gls("<body>Выполняется...</body>"));
				if (this.isLock)
					this.status.setStatus(gls("<body>Получи достижение <b>«{0}»</b></body>", this.unlockName));

				this.imageLock.visible = this.isLock;
				this.imageComplete.visible = this.complete;
				this.imageProgress.visible = !this.complete && !this.isLock;

			}
			else for (var i:int = 0; i < this.partImages.length; i++)
				this.partImages[i].filters = ((this.current & (1 << i)) == 0) ? FiltersUtil.GREY_FILTER : [];

			this.mask.visible = !this.complete;
		}

		private function init():void
		{
			var button:DisplayObject = getImage(this.id);
			button.width = button.height = 100;
			button.addEventListener(MouseEvent.CLICK, onClick);
			this._view.addChild(button);
			this.mask = new ImageAwardMask();
			this.mask.width = this.mask.height = 100;
			this._view.addChild(this.mask);

			new Status(button, gls("Рассказать друзьям"));

			this._view.graphics.beginFill(0xF7F4EC);
			this._view.graphics.lineStyle(2, 0xF4E3CA);
			this._view.graphics.drawRoundRect(107, 0, 280, 100, 3, 3);

			var fieldCaption:GameField = new GameField(this.name, 112, 5, CAPTION);
			fieldCaption.mouseEnabled = false;
			this._view.addChild(fieldCaption);

			var fieldText:GameField = new GameField(this.text, 112, 30, TEXT);
			fieldText.mouseEnabled = false;
			fieldText.wordWrap = true;
			fieldText.width = 265;
			this._view.addChild(fieldText);

			if (this.values == null)
			{
				this.bar = new Bar([
						{'image': new AwardBack(), 'X': 0, 'Y': 0},
						{'image': new AwardActive(), 'X': 0, 'Y': 0.5},
						{'image': new AwardActive(), 'X': 0, 'Y': 0.5}
					], 220);
				this.bar.x = 115;
				this.bar.y = 70;
				this.bar.addEventListener(MouseEvent.CLICK, onClick);
				this._view.addChild(this.bar);

				this.imageComplete = new ImageAwardBarStar();
				this.imageComplete.x = 225;
				this.imageComplete.scaleX = this.imageComplete.scaleY = 1.25;
				this.bar.addChild(this.imageComplete);

				this.imageProgress = new ImageBarProgress();
				this.imageProgress.x = 225;
				this.imageProgress.scaleX = this.imageProgress.scaleY = 1.25;
				this.bar.addChild(this.imageProgress);

				this.imageLock = new ImageBarLock();
				this.imageLock.x = 225;
				this.imageLock.scaleX = this.imageLock.scaleY = 1.25;
				this.bar.addChild(this.imageLock);

				this.status = new Status(this.bar, "", false, true);

				this.field = new GameField("", 0, -1, BAR);
				this.field.mouseEnabled = false;
				this.bar.addChild(this.field);
			}
			else for (var i:int = 0; i < this.values.length; i++)
			{
				var image:DisplayObject = getImagePart(this.id, i);
				image.x = 115 + 40 * i;
				image.y = 70;
				this.partImages.push(image);
				this._view.addChild(this.partImages[i]);

				new Status(image, this.values[i]);
			}
		}

		private function onClick(e:MouseEvent):void
		{
			if (!this.complete)
				return;
			new DialogRepost(WallTool.WALL_AWARD, this.id).show();
		}
	}
}