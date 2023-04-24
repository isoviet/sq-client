package game.mainGame.perks.shaman
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import utils.HtmlTool;

	public class PerkShamanFactory
	{
		static private var perkId:int = 0;

		static public const DEFAULT_DESCRIPTION:String = "default";
		static public const LEVEL_BONUS_DESCRIPTION:String = "level";
		static public const TOTAL_BONUS_DESCRIPTION:String = "total";
		static public const BUFF_DESCRIPTION:String = "buff";

		static public const PERK_BIG_ACORN:int = perkId++;
		static public const PERK_MADNESS:int = perkId++;
		static public const PERK_ADORATION:int = perkId++;
		static public const PERK_WALRUS:int = perkId++;
		static public const PERK_THIN_ICE:int = perkId++;
		static public const PERK_ICE_CUBE:int = perkId++;
		static public const PERK_RUNE:int = perkId++;
		static public const PERK_HIGH_FRICTION:int = perkId++;
		static public const PERK_SPEEDY_AURA:int = perkId++;
		static public const PERK_POINTER:int = perkId++;
		static public const PERK_LAGGING:int = perkId++;
		static public const PERK_INSPIRED:int = perkId++;
		static public const PERK_FRIEND:int = perkId++;
		static public const PERK_TELEPORT:int = perkId++;
		static public const PERK_SQUIRRELS_HAPPINESS:int = perkId++;
		static public const PERK_FAVORITE:int = perkId++;
		static public const PERK_MASS_IMMORTAL:int = perkId++;
		static public const PERK_BIG_HEAD:int = perkId++;
		static public const PERK_CLOUD:int = perkId++;
		static public const PERK_SATIETY:int = perkId++;
		static public const PERK_SURRENDER:int = perkId++;
		static public const PERK_SLOWFALL:int = perkId++;
		static public const PERK_TELEKINESIS:int = perkId++;
		static public const PERK_FORTH_TELEPORT:int = perkId++;
		static public const PERK_CAPTAIN_HOOK:int = perkId++;
		static public const PERK_SPEEDY:int = perkId++;
		static public const PERK_LAZY:int = perkId++;
		static public const PERK_TIME_MASTER:int = perkId++;
		static public const PERK_RUNNING_CAST:int = perkId++;
		static public const PERK_PATTER:int = perkId++;
		static public const PERK_POCKET_TELEPORT:int = perkId++;
		static public const PERK_HEAVENS_GATE:int = perkId++;
		static public const PERK_CONCENTRATION:int = perkId++;
		static public const PERK_IMMORTAL:int = perkId++;
		static public const PERK_DYNAMITE:int = perkId++;
		static public const PERK_HELIUM:int = perkId++;
		static public const PERK_WEIGHT:int = perkId++;
		static public const PERK_HELPER:int = perkId++;
		static public const PERK_LEAP:int = perkId++;
		static public const PERK_ONE_WAY_TICKET:int = perkId++;
		static public const PERK_TURN_BALK:int = perkId++;
		static public const PERK_TIMER:int = perkId++;
		static public const PERK_STRONGHOLD:int = perkId++;
		static public const PERK_SPIRITS:int = perkId++;
		static public const PERK_TIME_SLOWDOWN:int = perkId++;
		static public const PERK_STORM:int = perkId++;
		static public const PERK_GRAVITY:int = perkId++;
		static public const PERK_DESTROYER:int = perkId++;
		static public const PERK_DRAWING_MODE:int = perkId++;
		static public const PERK_PORTAL_MASTER:int = perkId++;
		static public const PERK_HOISTMAN:int = perkId++;
		static public const PERK_SAFE_WAY:int = perkId++;

		static public var perkData:Dictionary = new Dictionary(false);

		static public var perkCollection:Array = [
			PerkShamanBigAcorn,
			PerkShamanMadness,
			PerkShamanAdoration,
			PerkShamanWalrus,
			PerkShamanThinIce,
			PerkShamanIceCube,
			PerkShamanRune,
			PerkShamanHighFriction,
			PerkShamanSpeedyAura,
			PerkShamanPointer,
			PerkShamanLagging,
			PerkShamanInspired,
			PerkShamanFriend,
			PerkShamanTeleport,
			PerkShamanSquirrelHappiness,
			PerkShamanFavorite,
			PerkShamanMassImmortal,
			PerkShamanBigHead,
			PerkShamanCloud,
			PerkShamanSatiety,
			PerkShamanSurrender,
			PerkShamanSlowFall,
			PerkShamanTelekinesis,
			PerkShamanForthTeleport,
			PerkShamanCaptainHook,
			PerkShamanSpeedy,
			PerkShamanLazy,
			PerkShamanTimeMaster,
			PerkShamanRunningCast,
			PerkShamanPatter,
			PerkShamanPocketTeleport,
			PerkShamanHeavensGate,
			PerkShamanConcentration,
			PerkShamanImmortal,
			PerkShamanDynamite,
			PerkShamanHelium,
			PerkShamanWeight,
			PerkShamanHelper,
			PerkShamanLeap,
			PerkShamanOneWayTicket,	PerkShamanTurnBalk,
			PerkShamanTimer,
			PerkShamanStronghold,
			PerkShamanSpirits,
			PerkShamanTimeSlowdown,
			PerkShamanStorm,
			PerkShamanGravity,
			PerkShamanDestroyer,
			PerkShamanDrawingMode,
			PerkShamanPortalMaster,
			PerkShamanHoistman,
			PerkShamanSafeWay
		];

		static public function init():void
		{
			perkData[PerkShamanBigAcorn] =
			{
				'perkClass': PerkShamanBigAcorn,
				'name': gls("Большой орех"),
				'active': false,
				'description': {
					'default': gls("Увеличивает размер ореха на локации."),
					'level': {'free': [gls("Увеличивает размер ореха на {0}%.", "<bonus_level_free_1>"), gls("Увеличивает размер ореха на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает размер ореха на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает размер ореха на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает размер ореха на {0}%.", "<bonus_level_paid_2>"), gls("Размер ореха сохраняется после смерти шамана.")]},
					'total': {'free': [gls("Увеличивает размер ореха на {0}%.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton1,
				'bonuses': {'free': [5, 6, 7], 'paid': [9, 13, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanMadness] =
			{
				'perkClass': PerkShamanMadness,
				'name': gls("Массовое безумие"),
				'active': true,
				'description': {
					'default': gls("При активации накладывает на всех белок эффект магии «белка-варвар». Позволяет ходить по головам других белок."),
					'level': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_2>"), gls("Позволяет белкам отталкивать от себя других белок. Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Позволяет белкам отталкивать от себя других белок.", "<descr_total_level_free_1>")]},
					'buff': {'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", gls("{0} Позволяет белкам отталкивать от себя других белок.", "<descr_default>")]}
				},
				'buttonClass': PerkShamanButton2,
				'bonuses': {'free': [1, 2, 3], 'paid': [3, 5, 2]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanAdoration] =
			{
				'perkClass': PerkShamanAdoration,
				'name': gls("Обожание шамана"),
				'active': true,
				'description': {
					'default': gls("При активации навыка, белки вблизи шамана повторяют его эмоции, когда он плачет или смеётся. Требуется время на восстановление навыка."),
					'total': {'free': [gls("При активации навыка, белки вблизи шамана повторяют его эмоции, когда он плачет или смеётся. Время восстановления навыка — 30 сек. Количество белок, повторяющих за шаманом — {0}.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("При активации навыка, все белки на карте повторяют эмоции шамана. Навык восстанавливается мгновенно.")]},
					'level': {'free': [gls("При активации навыка, белки вблизи шамана повторяют его эмоции, когда он плачет или смеётся. Требуется время на восстановление навыка. Время восстановления навыка — 30 сек. Количество белок, повторяющих за шаманом — {0}.", "<bonus_level_free_1>"), gls("Увеличивает количество белок повторяющих за шаманом на {0}.", "<bonus_level_free_2>"), gls("Увеличивает количество белок повторяющих за шаманом на {0}.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает количество белок повторяющих за шаманом на {0}.", "<bonus_level_paid_1>"), gls("Увеличивает количество белок повторяющих за шаманом на {0}.", "<bonus_level_paid_2>"), gls("Все белки на карте повторяют эмоции шамана. Время восстановления навыка — 0 сек.")]}
				},
				'buttonClass': PerkShamanButton3,
				'bonuses': {'free': [1, 2, 3], 'paid': [3, 5, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanWalrus] =
			{
				'perkClass': PerkShamanWalrus,
				'name': gls("Дух моржа"),
				'active': false,
				'description': {
					'default': gls("Увеличивает скорость белок в воде вблизи шамана на {0}%.", PerkShamanWalrus.SWIM_BONUS_FACTOR),
					'level': {'free': [gls("{0} Навык действует в небольшом радиусе от шамана. Радиус увеличен на {1}%", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает радиус навыка действия на {0}%.", "<bonus_level_paid_2>"), gls("Навык действует на всех белок на локации.")]},
					'total': {'free': [gls("{0} Навык действует в небольшом радиусе от шамана. Радиус увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_default> <descr_level_level_paid_3>"]},
					'buff': {'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", "<descr_default>"]}
				},
				'buttonClass': PerkShamanButton4,
				'bonuses': {'free': [5, 10, 15], 'paid': [15, 20, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanThinIce] =
			{
				'perkClass': PerkShamanThinIce,
				'name': gls("Тонкий лёд"),
				'active': true,
				'description': {
					'default': gls("При активации позволяет выбранной белке провалиться сквозь препятствия. Требуется время на восстановление навыка."),
					'level': {'free': [gls("При активации позволяет выбранной белке провалиться сквозь препятствия. Время восстановления навыка — 1 минута. Количество применений навыка за раунд — {0}.", "<bonus_level_free_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_2>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_2>"), gls("Уменьшает время восстановления навыка на 30 сек.")]},
					'total': {'free': [gls("При активации позволяет выбранной белке провалиться сквозь препятствия. Время восстановления навыка — 1 минута. Количество применений навыка за раунд — {0}.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("При активации позволяет выбранной белке провалиться сквозь препятствия. Время восстановления навыка — 30 сек. Количество применений навыка за раунд — {0}.", "<bonus_total>")]}
				},
				'buttonClass': PerkShamanButton5,
				'bonuses': {'free': [1, 1, 1], 'paid': [1, 1, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanIceCube] =
			{
				'perkClass': PerkShamanIceCube,
				'name': gls("Ледяной куб"),
				'active': true,
				'description': {
					'default': gls("При активации выбранная белка заключается в ледяной куб на 2 секунды."),
					'level': {'free': [gls("{0} Количество применений навыка за раунд — {1}.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_2>"), gls("Увеличивает количество применений навыка на {0} и размер ледяного куба на {1}%.", "<bonus_level_free_3>", "<extraBonus_level_free_3>")], 'paid': [gls("Увеличивает количество применений навыка на {0} и размер ледяного куба на {1}%.", "<bonus_level_paid_1>", "<extraBonus_level_paid_1>"), gls("Увеличивает количество применений навыка на {0} и размер ледяного куба на {1}%.", "<bonus_level_paid_2>", "<extraBonus_level_paid_2>"), gls("Увеличивает количество применений навыка на {0} и размер ледяного куба на {1}%. Позволяет белкам вставать на ледяной куб.", "<bonus_level_paid_3>", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Количество применений навыка за раунд — {1}.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", gls("{0} Размер ледяного куба увеличен на {1}%.", "<descr_total_level_free_1>", "<extraBonus_total>")], 'paid': ["<descr_total_level_free_3>", "<descr_total_level_free_3>", gls("{0} Белки могут вставать на куб.", "<descr_total_level_free_3>")]}
				},
				'buttonClass': PerkShamanButton6,
				'bonuses': {'free': [1, 1, 1], 'paid': [1, 1, 2]},
				'extraBonuses': {'free': [0, 0, 5], 'paid': [7, 8, 10]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanRune] =
			{
				'perkClass': PerkShamanRune,
				'name': gls("Руна"),
				'active': true,
				'description': {
					'default': gls("При активации создаёт руну. Руна движется в заданном направлении и перемещает объекты. Время жизни руны — 30 сек."),
					'level': {'free': [gls("{0} Увеличивает силу воздействия на объекты на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает силу воздействия на объекты на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает силу воздействия на объекты на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает силу воздействия на объекты на {0}%.", '<bonus_level_paid_1>'), gls("Увеличивает силу воздействия на объекты на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает силу воздействия на объекты на {0}% и скорость перемещения руны на {1}%.", "<bonus_level_paid_3>", PerkShamanRune.SPEED_BONUS_FACTOR)]},
					'total': {'free': [gls("{0} Сила воздействия на объекты увеличена на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Скорость перемещения руны увеличена на {1}%.", "<descr_total_level_free_1>", PerkShamanRune.SPEED_BONUS_FACTOR)]}
				},
				'buttonClass': PerkShamanButton7,
				'bonuses': {'free': [5, 7, 9], 'paid': [15, 35, 29]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanHighFriction] =
			{
				'perkClass': PerkShamanHighFriction,
				'name': gls("Цепкие коготки"),
				'active': false,
				'description': {
					'default': gls("Увеличивает силу трения для белок на льду и на земле."),
					'level': {'free': [gls("{0} Сила трения для белок увеличена на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает силу трения для белок на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает силу трения для белок на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает силу трения для белок на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает силу трения для белок на {0}%.", "<bonus_level_paid_2>"), gls("Белки не скользят по земле и по льду.")]},
					'total': {'free': [gls("{0} Сила трения для белок увеличена на {1}%", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_level_level_paid_3>"]},
					'buff': {'free': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton8,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 1000]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanSpeedyAura] =
			{
				'perkClass': PerkShamanSpeedyAura,
				'name': gls("Аура шустрости"),
				'active': false,
				'description': {
					'default': gls("Увеличивает скорость перемещения белок рядом с шаманом"),
					'level': {'free': [gls("Вблизи шамана белки перемещаются быстрее на {0}%. Навык действует в небольшом радиусе от шамана. Радиус увеличен на {1}%.", PerkShamanSpeedyAura.SPEED_BONUS_FACTOR, "<bonus_level_free_1>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает радиус действия навыка на {0}% и скорость перемещения белок на {1}%.", "<bonus_level_paid_3>", PerkShamanSpeedyAura.MAX_LEVEL_SPEED_BONUS_FACTOR)]},
					'total': {'free': [gls("Вблизи шамана белки перемещаются быстрее на {0}%. Навык действует в небольшом радиусе от шамана. Радиус увеличен на {1}%.", PerkShamanSpeedyAura.SPEED_BONUS_FACTOR, "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Вблизи шамана белки перемещаются на {0}% быстрее. Навык действует в небольшом радиусе от шамана. Радиус увеличен на {1}%.", (PerkShamanSpeedyAura.SPEED_BONUS_FACTOR + PerkShamanSpeedyAura.MAX_LEVEL_SPEED_BONUS_FACTOR), "<bonus_total>")]},
					'buff':	{'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", gls("Вблизи шамана белки перемещаются на {0}% быстрее.", (PerkShamanSpeedyAura.SPEED_BONUS_FACTOR + PerkShamanSpeedyAura.MAX_LEVEL_SPEED_BONUS_FACTOR))]}
				},
				'buttonClass': PerkShamanButton9,
				'bonuses': {'free': [5, 10, 15], 'paid': [15, 20, 10]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanPointer] =
			{
				'perkClass': PerkShamanPointer,
				'name': gls("Указатель"),
				'active': true,
				'description': {
					'default': gls("При активации устанавливает указатель места сбора для белок. Время жизни указателя — 5 секунд."),
					'level': {'free': [gls("{0} Размер указателя увеличен на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает размер указателя на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает размер указателя на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает размер указателя на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает размер указателя на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает размер указателя на {0}%. Указатель анимирован.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Размер указателя увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Указатель анимирован.", "<descr_total_level_free_1>")]}
				},
				'buttonClass': PerkShamanButton10,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 20]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanLagging] =
			{
				'perkClass': PerkShamanLagging,
				'name': gls("Отстающий"),
				'active': false,
				'description': {
					'default': gls("Увеличивает скорость и высоту прыжка для последней белки. Навык действует, если в дупло зашла хотя бы одна белка."),
					'level': {'free': [gls("{0} Увеличивает скорость перемещения и высоту прыжка на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает скорость перемещения и высоту прыжка на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает скорость перемещения и высоту прыжка белки на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает скорость перемещения и высоту прыжка белки на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает скорость перемещения и высоту прыжка белки на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает скорость перемещения и высоту прыжка белки на {0}%.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Увеличивает скорость перемещения и высоту прыжка на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]},
					'buff':	{'free': [gls("Последняя белка, незабежавшая в дупло, бегает быстрее и прыгает выше. Увеличивает скорость перемещения и высоту прыжка на {0}%.", "<bonus_total>"), "<descr_buff_level_free_1>", "<descr_buff_level_free_1>"], 'paid': ["<descr_buff_level_free_1>", "<descr_buff_level_free_1>", "<descr_buff_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton11,
				'bonuses': {'free': [2, 3, 5], 'paid': [5, 5, 10]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanInspired] =
			{
				'perkClass': PerkShamanInspired,
				'name': gls("Воодушевление"),
				'active': false,
				'description': {
					'default': gls("Увеличивает высоту прыжка для белок рядом с шаманом на {0}%.", PerkShamanInspired.JUMP_BONUS_FACTOR),
					'level': {'free': [gls("{0} Навык действует в небольшом радиусе от шамана. Радиус увеличен на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает радиус действия навыка на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает радиус действия навыка на {0}% и высоту прыжка белок на {1}%.", "<bonus_level_paid_3>", PerkShamanInspired.MAX_LEVEL_JUMP_FACTOR)]},
					'total': {'free': [gls("{0} Навык действует в небольшом радиусе от шамана. Радиус увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "Вблизи шамана белки прыгают выше на " + (PerkShamanInspired.JUMP_BONUS_FACTOR + PerkShamanInspired.MAX_LEVEL_JUMP_FACTOR) + "%. Навык действует в небольшом радиусе от шамана. Радиус увеличен на <bonus_total>%."]},
					'buff':	{'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", gls("Вблизи шамана белки прыгают выше на {0}%.", (PerkShamanInspired.JUMP_BONUS_FACTOR + PerkShamanInspired.MAX_LEVEL_JUMP_FACTOR))]}
				},
				'buttonClass': PerkShamanButton12,
				'bonuses': {'free': [5, 10, 15], 'paid': [15, 20, 10]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanFriend] =
			{
				'perkClass': PerkShamanFriend,
				'name': gls("Друг шамана"),
				'active': true,
				'description': {
					'default': gls("При активации выбранная белка становится другом шамана. Друг шамана получает бонус к скорости передвижения и высоте прыжка. Время действия навыка — 10 сек. Время восстановления навыка — 5 сек."),
					'level': {'free': [gls("{0} Скорость перемещения и высота прыжка друга шамана увеличены на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает скорость перемещения и высоту прыжка друга шамана на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает скорость перемещения и высоту прыжка друга шамана на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает скорость перемещения и высоту прыжка друга шамана на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает скорость перемещения и высоту прыжка друга шамана на {0}%.", "<bonus_level_paid_2>"), gls("Шаман может выбрать двух друзей.")]},
					'total': {'free': [gls("{0} Скорость перемещения и высота прыжка друга шамана увеличены на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Назначает двух белок друзьями шамана. Теперь белки бегают быстрее и прыгают выше. Время действия навыка — 10 сек. Время восстановления навыка — 5 сек. Скорость перемещения и высота прыжка друга шамана увеличены на {0}%.", '<bonus_total>')]},
					'buff': {'free': [gls("Скорость перемещения и высота прыжка друга шамана увеличены на {0}%.", '<bonus_total>'), "<descr_buff_level_free_1>", "<descr_buff_level_free_1>"], 'paid': ["<descr_buff_level_free_1>", "<descr_buff_level_free_1>", "<descr_buff_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton13,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 0]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanTeleport] =
			{
				'perkClass': PerkShamanTeleport,
				'name': gls("Телепорт"),
				'active': true,
				'description': {
					'default':gls("При активации мгновенно перемещает белку к шаману. Навык имеет ограниченный радиус применения."),
					'level': {'free': [gls("{0} Радиус увеличен на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает радиус применения навыка на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает радиус применения навыка на {0}% и количество белок для перемещения на {1}.", "<bonus_level_free_3>", "<extraBonus_level_free_3>")], 'paid': [gls("Увеличивает радиус применения навыка на {0}% и количество белок для перемещения на {1}.", "<bonus_level_paid_1>", "<extraBonus_level_paid_1>"), gls("Увеличивает радиус применения навыка на {0}% и количество белок для перемещения на {1}.", "<bonus_level_paid_2>", "<extraBonus_level_paid_2>"), gls("Увеличивает радиус применения навыка на {0}% и количество белок для перемещения на {1}.", "<bonus_level_paid_3>", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Радиус увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", gls("{0} Количество белок, которых может телепортировать шаман — {1}.", "<descr_total_level_free_1>", "<extraBonus_total>")], 'paid': ["<descr_total_level_free_3>", "<descr_total_level_free_3>", "<descr_total_level_free_3>"]}
				},
				'buttonClass': PerkShamanButton14,
				'bonuses': {'free': [5, 5, 5], 'paid': [7, 8, 100]},
				'extraBonuses': {'free': [1, 0, 1], 'paid': [1, 1, 1]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanSquirrelHappiness] =
			{
				'perkClass': PerkShamanSquirrelHappiness,
				'name': gls("Беличье счастье"),
				'active': true,
				'description': {
					'default': gls("При активации мгновенно перемещает выбранную белку с орехом в дупло."),
					'level': {'free': [gls("<descr_default> Время восстановления навыка — {0}{1} сек.", PerkShamanSquirrelHappiness.DELAY_TIME_SEC, "<sub><bonus_level_free_1>"), gls("Время восстановления навыка меньше на {0} сек.", "<bonus_level_free_2>"), gls("Время восстановления навыка меньше на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Время восстановления навыка меньше на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает количество белок, которых можно телепортировать, на {0}.", "<extraBonus_level_paid_2>"), gls("Восстановление навыка меньше на {0} сек. Увеличивает количество белок для перемещения, на {1}.", "<bonus_level_paid_3>", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("<descr_default> Время восстановления навыка — {0}{1} сек.", PerkShamanSquirrelHappiness.DELAY_TIME_SEC, "<sub><bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", gls("{0} Количество белок, которых можно телепортировать — {1}.", "<descr_total_level_free_1>", "<extraBonus_total>"), "<descr_total_level_paid_2>"]}
				},
				'buttonClass': PerkShamanButton15,
				'bonuses': {'free': [5, 10, 10], 'paid': [15, 0, 20]},
				'extraBonuses': {'free': [1, 0, 0], 'paid': [0, 1, 1]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanFavorite] =
			{
				'perkClass': PerkShamanFavorite,
				'name': gls("Любимчик"),
				'active': true,
				'description': {
					'default': gls("При активации передаёт орех выбранной белке. Требуется время на восстановление навыка."),
					'level': {'free': [gls("Передаёт орех выбранной белке. Время восстановления навыка — 1 минута. Количество белок, которым можно передать орех — {0}.", "<bonus_level_free_1>"), gls("Увеличивает количество белок, которым можно передать орех, на {0}.", "<bonus_level_free_2>"), gls("Уменьшает время восстановления навыка на {0} сек.", "<extraBonus_level_free_3>")], 'paid': [gls("Увеличивает количество белок, которым можно передать орех, на {0}.", "<bonus_level_paid_1>"), gls("Увеличивает количество белок, которым можно передать орех, на {0}.", "<bonus_level_paid_2>"), gls("Уменьшает время восстановления навыка на {0} сек.", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("Передаёт орех выбранной белке. Время восстановления навыка — {0}{1} сек. Количество белок, которым можно передать орех — {2}.", PerkShamanFavorite.DELAY_TIME_SEC, "<sub><extraBonus_total>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton16,
				'bonuses': {'free': [2, 1, 0], 'paid': [1, 1, 0]},
				'extraBonuses': {'free': [0, 0, 20], 'paid': [0, 0, 30]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanMassImmortal] =
			{
				'perkClass': PerkShamanMassImmortal,
				'name': gls("Массовое бессмертие"),
				'active': true,
				'description': {
					'default': gls("При активации белки становятся бессмертными. Можно воспользоваться 1 раз за раунд. Не действует на шамана."),
					'level': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_2>"), gls("В течение 2 секунд, после окончания действия навыка, белки воскрешаются вблизи шамана.")]},
					'total': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]},
					'buff': {'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", "<descr_default> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton17,
				'bonuses': {'free': [1, 2, 2], 'paid': [3, 5, 0]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanBigHead] =
			{
				'perkClass': PerkShamanBigHead,
				'name': gls("Большая голова"),
				'active': false,
				'description': {
					'default': gls("Увеличивает голову шамана."),
					'level': {'free': [gls("{0} Размер головы увеличен на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает размер головы на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает размер головы на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает размер головы на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает размер головы на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает всего шамана.")]},
					'total': {'free': [gls("{0} Размер головы увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Увеличивает всего шамана.")]}
				},
				'buttonClass': PerkShamanButton18,
				'bonuses': {'free': [5, 6, 7], 'paid': [9, 13, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanCloud] =
			{
				'perkClass': PerkShamanCloud,
				'name': gls("Тучка"),
				'active': false,
				'description': {
					'default': gls("Создаёт тучку на месте гибели белки. Время жизни тучки ограничено."),
					'level': {'free': [gls("На месте гибели белки появляется тучка. Количество тучек, которые могут появится за раунд — {0}. Тучка активна — {1} сек.", "<bonus_level_free_1>", "<extraBonus_level_free_1>"), gls("Увеличивает количество тучек в каждом раунде на {0}. Увеличивает время жизни тучек на {1} сек.", "<bonus_level_free_2>", "<extraBonus_level_free_2>"), gls("Увеличивает количество тучек в каждом раунде на {0}. Увеличивает время жизни тучек на {1} сек.", "<bonus_level_free_3>", "<extraBonus_level_free_3>")], 'paid': [gls("Увеличивает количество тучек в каждом раунде на {0}. Увеличивает время жизни тучек на {1} сек. Тучкой можно воспользоваться для подъёма вверх.", "<bonus_level_paid_1>", "<extraBonus_level_paid_1>"), gls("Увеличивает количество тучек в каждом раунде на {0}. Увеличивает время жизни тучек на {1} сек. Тучка поднимается медленнее на 50%.", "<bonus_level_paid_1>", "<extraBonus_level_paid_1>"), gls("Увеличивает время жизни тучек на {0} сек.", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("На месте гибели белки появляется тучка. Количество тучек, которые могут появится за раунд — {0}. Тучка активна — {1} сек.", "<bonus_total>", "<extraBonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': [gls("{0} Тучкой можно воспользоваться для подъёма вверх.", "<descr_total_level_free_1>"), gls("{0} Тучка поднимается медленнее на 50%.", "<descr_total_level_paid_1>"), "<descr_total_level_paid_2>"]}
				},
				'buttonClass': PerkShamanButton19,
				'bonuses': {'free': [1, 2, 3], 'paid': [3, 3, 0]},
				'extraBonuses': {'free': [2, 2, 3], 'paid': [3, 3, 10]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanSatiety] =
			{
				'perkClass': PerkShamanSatiety,
				'name': gls("Тяжёлый шаман"),
				'active': true,
				'description': {
					'default': gls("При активации увеличивает вес шамана."),
					'level': {'free': [gls("Вес шамана увеличивается на {0}%.", "<bonus_level_free_1>"), gls("Увеличивает вес шамана на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает вес шамана на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает вес шамана на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает вес шамана на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает вес шамана на {0}%.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("Вес шамана увеличивается на {0}%.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton20,
				'bonuses': {'free': [20, 30, 40], 'paid': [50, 60, 90]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanSurrender] =
			{
				'perkClass': PerkShamanSurrender,
				'name': gls("Капитуляция"),
				'active': true,
				'description': {
					'default': gls("При активации другой игрок становится шаманом. Вы получаете дополнительные орешки и перемещаетесь к шаману. Навык можно применять один раз за раунд."),
					'level': {'free': [gls("{0} Количество орешков — {1}.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает количество орешков на {0}.", "<bonus_level_free_2>"), gls("Увеличивает количество орешков на {0}.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает количество орешков на {0}.", "<bonus_level_paid_1>"), gls("Увеличивает количество орешков на {0}.", "<bonus_level_paid_2>"), gls("Если вы не подобрали орех, а до конца раунда меньше 30 секунд, то будете перемещены к ореху.")]},
					'total': {'free': [gls("{0} Количество орешков — {1}.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Другой игрок становится шаманом. Вы получаете дополнительные орешки. Если до конца раунда меньше 30 сек. и нет ореха — перемещаетесь к ореху, если орех уже у вас — к новому шаману. Количество орешков — {0}. Навык можно применять один раз за раунд.", "<bonus_total>")]}
			},
			'buttonClass': PerkShamanButton21,
			'bonuses': {'free': [3, 5, 7], 'paid': [10, 15, 0]},
			'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanSlowFall] =
			{
				'perkClass': PerkShamanSlowFall,
				'name': gls("Летун"),
				'active': false,
				'description': {
					'default': gls("Уменьшает скорость падения."),
					'level': {'free': [gls("{0} Скорость падения уменьшается на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Уменьшает скорость падения на {0}%.", "<bonus_level_free_2>"), gls("Уменьшает скорость падения на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Уменьшает скорость падения на {0}%.", "<bonus_level_paid_1>"), gls("Уменьшает скорость падения на {0}%.", "<bonus_level_paid_2>"), gls("Позволяет подпрыгнуть в падении.")]},
					'total': {'free': [gls("{0} Скорость падения уменьшается на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton22,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanTelekinesis] =
			{
				'perkClass': PerkShamanTelekinesis,
				'name': gls("Улучшенный телекинез"),
				'active': false,
				'description': {
					'default': gls("Увеличивает радиус применения телекинеза."),
					'level': {'free': [gls("{0} Радиус увеличен на {1}%.", "<descr_default>", '<bonus_level_free_1>'), gls("Увеличивает радиус телекинеза на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает радиус телекинеза на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает радиус телекинеза на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает радиус телекинеза на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает радиус телекинеза на {0}%. Меняет цвет луча на красный.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Радиус увеличен на {1}%.", "<descr_default>", '<bonus_total>'), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Красный луч телекинеза.", "<descr_total_level_free_1>")]}
				},
				'buttonClass': PerkShamanButton23,
				'bonuses': {'free': [1, 2, 2], 'paid': [3, 5, 7]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanForthTeleport] =
			{
				'perkClass': PerkShamanForthTeleport,
				'name': gls("Фронтальный телепорт"),
				'active': true,
				'description': {
					'default': gls("При активации телепортирует шамана вперёд."),
					'level': {'free': ["<descr_default>", gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_2>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_2>"), gls("Навык может быть применён на бегу и в прыжке.")]},
					'total': {'free': [gls("{0} Количество применений навыка за раунд — {1}.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton24,
				'bonuses': {'free': [1, 1, 1], 'paid': [1, 1, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanCaptainHook] =
			{
				'perkClass': PerkShamanCaptainHook,
				'name': gls("Капитан крюк"),
				'active': true,
				'description': {
					'default': gls("При активации позволяет бросить крюк, который цепляется к стенам и потолку."),
					'level': {'free': [gls("{0} Сила броска увеличена на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает силу броска на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает силу броска на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает силу броска на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает силу броска на {0}%.", "<bonus_level_paid_2>"), gls("Скорость подтягивания верёвки больше на {0}%.", PerkShamanCaptainHook.ROPE_SHRINK_FACTOR)]},
					'total': {'free': [gls("{0} Сила броска увеличена на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton25,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanSpeedy] =
			{
				'perkClass': PerkShamanSpeedy,
				'name': gls("Шустряк"),
				'active': true,
				'description': {
					'default': gls("При активации увеличивает скорость передвижения шамана. Время действия навыка — 10 секунд."),
					'level': {'free': [gls("{0} Скорость передвижения шамана увеличена на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает скорость передвижения шамана на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает скорость передвижения шамана на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает скорость передвижения шамана на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает скорость передвижения шамана на {0}%.", "<bonus_level_paid_2>"), gls("Вблизи шамана белки получают бонус к скорости.")]},
					'total': {'free': [gls("{0} Скорость передвижения шамана увеличена на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Увеличивает скорость передвижения шамана и белок рядом с ним на {0}%. Время действия навыка — 10 секунд.", "<bonus_total>")]},
					'buff': {'free': ["", "", ""], 'paid': ["", "", gls("Увеличивает скорость передвижения шамана и белок рядом с ним на {0}%.", "<bonus_total>")]}
				},
				'buttonClass': PerkShamanButton26,
				'bonuses': {'free': [1, 2, 3], 'paid': [3, 5, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanLazy] =
				{
				'perkClass': PerkShamanLazy,
				'name': gls("Ленивый шаман"),
				'active': false,
				'description': {
					'default': gls("Шаману больше не требуется заходить в дупло. Применить навык можно, если в дупло зашло не менее 3 белок. Навык нельзя применить в начале раунда."),
					'level': {'free': [gls("Шаману больше не требуется заходить в дупло. Применить навык можно, если в дупло зашла хотя бы одна белка. Навык может быть применён через — {0}{1} сек.", PerkShamanLazy.DELAY_TIME_SEC, "<sub><bonus_level_free_1>"), gls("Воспользоваться навыком можно раньше на {0} сек.", "<bonus_level_free_2>"), gls("Воспользоваться навыком можно раньше на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Воспользоваться навыком можно раньше на {0} сек.", "<bonus_level_paid_1>"), gls("Воспользоваться навыком можно раньше на {0} сек.", "<bonus_level_paid_2>"), gls("Чтобы зайти в дупло, шаману не требуется орех.")]},
					'total': {'free': [gls("Шаману больше не требуется заходить в дупло. Применить навык можно, если в дупло зашло не менее 3 белок. Навык может быть применён через — {0}{1} сек.", PerkShamanLazy.DELAY_TIME_SEC, "<sub><bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton27,
				'bonuses': {'free': [20, 20, 20], 'paid': [30, 30, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanTimeMaster] =
			{
				'perkClass': PerkShamanTimeMaster,
				'name': gls("Повелитель времени"),
				'active': true,
				'description': {
					'default': gls("При активации возвращает шамана на место, где он был несколько секунд назад. Время восстановления навыка — 1 мин."),
					'level': {'free': [gls("{0} Возвращает время на {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время возвращения назад на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время возвращения назад на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время возвращения назад на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время возвращения назад на {0} сек.", "<bonus_level_paid_2>"), gls("Белки вблизи шамана возвращаются во времени.")]},
					'total': {'free': [gls("{0} Возвращает время на {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Возвращает шамана и стоящих рядом с ним белок на место, где они были несколько секунд назад. Возвращает время на <bonus_total> сек. Время восстановления навыка — 1 мин.")]}
				},
				'buttonClass': PerkShamanButton28,
				'bonuses': {'free': [1, 2, 3], 'paid': [3, 5, 0]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanRunningCast] =
			{
				'perkClass': PerkShamanRunningCast,
				'name': gls("Концентрация"),
				'active': false,
				'description': {
					'default': gls("Позволяет устанавливать предметы во время передвижения. Радиус области для создания предметов на бегу вдвое меньше обычного."),
					'level': {'free': [gls("{0} Радиус области создания предметов на бегу увеличен на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает радиус области создания предметов на бегу на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает радиус области создания предметов на бегу на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает радиус области создания предметов на бегу на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает радиус области создания предметов на бегу на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает радиус области создания предметов на бегу на {0}%.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Радиус области создания предметов на бегу увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton29,
				'bonuses': {'free': [5, 5, 10], 'paid': [10, 20, 20]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanPatter] =
			{
				'perkClass': PerkShamanPatter,
				'name': gls("Умелец"),
				'active': false,
				'description': {
					'default': gls("Снижает время на создание предметов."),
					'level': {'free': [gls("Время создания предметов снижено на {0}%.", "<bonus_level_free_1>"), gls("Уменьшает время создания предметов на {0}%.", "<bonus_level_free_2>"), gls("Уменьшает время создания предметов на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Уменьшает время создания предметов на {0}%.", "<bonus_level_paid_1>"), gls("Уменьшает время создания предметов на {0}%.", "<bonus_level_paid_2>"), gls("Предметы создаются мгновенно.")]},
					'total': {'free': [gls("Время создания предметов снижено на {0}%.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton30,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 65]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanPocketTeleport] =
			{
				'perkClass': PerkShamanPocketTeleport,
				'name': gls("Карманный телепорт"),
				'active': true,
				'description': {
					'default': gls("При активации перемещает шамана в указанную точку. Восстановление навыка — 45 сек. Навык нельзя применить сразу после того, как игрок стал шаманом."),
					'level': {'free': [gls("{0} Область перемещения увеличена на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает область перемещения на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает область перемещения на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает область перемещения на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает область перемещения на {0}%.", "<bonus_level_paid_2>"), gls("Радиус применения навыка неограничен.")]},
					'total': {'free': [gls("{0} Область перемещения увеличена на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Перемещает шамана на выбранную позицию. Восстановление навыка — 45 сек. Навык нельзя применить сразу после того, как игрок стал шаманом. {0}", "<descr_level_level_paid_3>")]}
				},
				'buttonClass': PerkShamanButton31,
				'bonuses': {'free': [40, 60, 80], 'paid': [100, 150, 0]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanHeavensGate] =
			{
				'perkClass': PerkShamanHeavensGate,
				'name': gls("Райские врата"),
				'active': true,
				'description': {
					'default': gls("При активации устанавливает райские врата для воскрешения погибших белок. Навык можно применять дважды за раунд."),
					'level': {'free': [gls("{0} Время жизни ворот — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время жизни ворот на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время жизни ворот на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время жизни ворот на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время жизни ворот на {0} сек.", "<bonus_level_paid_2>"), gls("Увеличивает время жизни ворот на {0} сек. Ворота следуют за шаманом.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Время жизни ворот — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Ворота следуют за шаманом.", "<descr_total_level_free_1>")]}
				},
				'buttonClass': PerkShamanButton32,
				'bonuses': {'free': [1, 2, 3], 'paid': [3, 5, 5]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanConcentration] =
			{
				'perkClass': PerkShamanConcentration,
				'name': gls("Сосредоточение"),
				'active': false,
				'description': {
					'default': gls("Увеличивает радиус создания предметов."),
					'level': {'free': [gls("{0} Радиус создания предметов увеличен на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает радиус создания предметов на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает радиус создания предметов на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает радиус создания предметов на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает радиус создания предметов на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает радиус создания предметов на {0}%. Радиус создания предметов виден всегда.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Радиус создания предметов увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Радиус создания предметов виден всегда.", "<descr_total_level_free_1>")]}
				},
				'buttonClass': PerkShamanButton33,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 15]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanImmortal] =
			{
				'perkClass': PerkShamanImmortal,
				'name': gls("Бессмертный шаман"),
				'active': true,
				'description': {
					'default': gls("При активации шаман становится бессмертным. Время восстановления навыка — 60 секунд."),
					'level': {'free': [gls("{0} Длительность навыка — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает длительность навыка на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает длительность навыка на {0} сек. Увеличивает количество применений на {1}.", "<bonus_level_free_3>", "<extraBonus_level_free_3>")], 'paid': [gls("Увеличивает длительность навыка на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает длительность навыка на {0} сек.", "<bonus_level_paid_2>"), gls("Увеличивает длительность навыка на {0} сек. Увеличивает количество применений на {1}.", "<bonus_level_paid_3>", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Длительность навыка — {1} сек. Количество применений навыка за раунд — {2}.", "<descr_default>", "<bonus_total>", "<extraBonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton34,
				'bonuses': {'free': [1, 2, 3], 'paid': [3, 5, 2]},
				'extraBonuses': {'free': [1, 0, 1], 'paid': [1, 0, 1]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanDynamite] =
			{
				'perkClass': PerkShamanDynamite,
				'name': gls("Динамит"),
				'active': true,
				'description': {
					'default': gls("При активации взрывает динамит в указанной точке и отбрасывает белок. Требуется время на восстановление навыка."),
					'level': {'free': [gls("При активации взрывает динамит в указанной точке и отбрасывает белок. Время восстановления навыка — {0}{1} сек.", PerkShamanDynamite.DELAY_TIME_SEC, "<sub><bonus_level_free_1>"), gls("Снижает время восстановления навыка на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает мощность динамита на {0}%.", PerkShamanDynamite.POWER_FACTOR)], 'paid': [gls("Снижает время восстановления навыка на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает радиус действия динамита на {0}%.", PerkShamanDynamite.RADIUS_FACTOR), gls("Динамит не действует на шамана.")]},
					'total': {'free': [gls("При активации взрывает динамит в указанной точке и отбрасывает белок. Время восстановления навыка — {0}{1} сек.", PerkShamanDynamite.DELAY_TIME_SEC, "<sub><bonus_total>"), "<descr_total_level_free_1>", gls("{0} Мощность динамита увеличена на {1}%.", "<descr_total_level_free_1>", PerkShamanDynamite.POWER_FACTOR)], 'paid': ["<descr_total_level_free_1>", gls("{0} Радиус действия динамита увеличен на {1}%.", "<descr_total_level_free_1>", PerkShamanDynamite.RADIUS_FACTOR), "<descr_total_level_free_3> <descr_total_level_paid_2> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton35,
				'bonuses': {'free': [2, 3, 0], 'paid': [5, 0, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanHelium] =
			{
				'perkClass': PerkShamanHelium,
				'name': gls("Гелий"),
				'active': false,
				'description': {
					'default': gls("Увеличивает подъёмную силу шаров."),
					'level': {'free': [gls("Подъёмная сила шаров увеличена на {0}%.", "<bonus_level_free_1>"), gls("Увеличивает подъёмную силу шаров на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает подъёмную силу шаров на {0}%", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает подъёмную силу шаров на {0}%", "<bonus_level_paid_1>"), gls("Увеличивает подъёмную силу шаров на {0}%.", "<bonus_level_paid_2>"), gls("Шары создаются по 2 штуки и крепятся к одной точке.")]},
					'total': {'free': [gls("Подъёмная сила шаров увеличена на {0}%.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton36,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanWeight] =
			{
				'perkClass': PerkShamanWeight,
				'name': gls("Тяжёлая гиря"),
				'active': false,
				'description': {
					'default': gls("Увеличивает вес гири."),
					'level': {'free': [gls("Вес гири увеличен на {0}%.", "<bonus_level_free_1>"), gls("Увеличивает вес гири на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает вес гири на {0}>%", "<bonus_level_free_3")], 'paid': [gls("Увеличивает вес гири на {0}>%", "<bonus_level_paid_1"), gls("Увеличивает вес гири на {0}%.", "<bonus_level_paid_2>"), gls("Гиря исчезает через 30 секунд.")]},
					'total': {'free': [gls("Вес гири увеличен на {0}%.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton37,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanHelper] =
			{
				'perkClass': PerkShamanHelper,
				'name': gls("Помощник"),
				'active': true,
				'description': {
					'default': gls("При активации перемещает выбранную белку из любого места карты в указанную точку вблизи шамана. Время восстановления навыка — 1 мин."),
					'level': {'free': [gls("{0} Область для перемещения увеличена на  {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает область для перемещения на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает область для перемещения на {0}%", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает область для перемещения на {0}%", "<bonus_level_paid_1>"), gls("Увеличивает область для перемещения на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает область для перемещения на {0}%.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Область для перемещения увеличена на  {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton38,
				'bonuses': {'free': [10, 20, 30], 'paid': [20, 30, 100]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanLeap] =
			{
				'perkClass': PerkShamanLeap,
				'name': gls("Скачок"),
				'active': true,
				'description': {
					'default': gls("При активации увеличивает дальность прыжка."),
					'level': {'free': [gls("При активации увеличивает дальность прыжка. Время действия навыка — 10 секунд. Дальность прыжка увеличена на {0}%.", "<bonus_level_free_1>"), gls("Увеличивает дальность прыжка на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает дальность прыжка на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает дальность прыжка на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает дальность прыжка на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает время действия навыка на 5 секунд.")]},
					'total': {'free': [gls("При активации увеличивает дальность прыжка. Время действия навыка — 10 секунд. Дальность прыжка увеличена на {0}%.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "При активации увеличивает дальность прыжка. Время действия навыка — 15 секунд. Дальность прыжка увеличена на <bonus_total>%."]}
				},
				'buttonClass': PerkShamanButton39,
				'bonuses': {'free': [10, 20, 20], 'paid': [30, 50, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanOneWayTicket] =
			{
				'perkClass': PerkShamanOneWayTicket,
				'name': gls("Билет в одну сторону"),
				'active': true,
				'description': {
					'default': gls("При активации создаёт балку, сквозь которую можно пройти только в одну сторону. Время жизни балки ограничено."),
					'level': {'free': [gls("При активации создаёт балку, сквозь которую можно пройти только в одну сторону. Время жизни балки — 15 сек. Количество применений навыка за раунд — {0}.", "<bonus_level_free_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_2>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_2>"), gls("Время жизни балки неограничено. Можно развернуть все балки наоборот.")]},
					'total': {'free': [gls("При активации создаёт балку, сквозь которую можно пройти только в одну сторону. Время жизни балки — 15 сек. Количество применений навыка за раунд — {0}.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("При активации создаёт балку, сквозь которую можно пройти только в одну сторону. {0} Количество применений навыка за раунд — {1}.", "<descr_level_level_paid_3>", "<bonus_total>")]}
				},
				'buttonClass': PerkShamanButton40,
				'bonuses': {'free': [1, 1, 2], 'paid': [2, 3, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanTurnBalk] =
			{
				'perkClass': PerkShamanTurnBalk,
				'name': gls("Перевернуть балку"),
				'active': true,
				'description': {
					'default': gls("При активации разворачивает все односторонние балки на локации."),
					'total': {'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", "<descr_default>"]}
				},
				'buttonClass': PerkShamanButton40
			};

			perkData[PerkShamanTimer] =
			{
				'perkClass': PerkShamanTimer,
				'name': gls("Таймер"),
				'active': true,
				'description': {
					'default': gls("При активации создаёт короткую балку с ограниченным временем жизни."),
					'level': {'free': [gls("{0} Время жизни балки — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время жизни балки на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время жизни балки на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время жизни балки на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время жизни балки на {0} сек.", "<bonus_level_paid_2>"), gls("Увеличивает время жизни балки на {0} сек. Увеличивает длину балки.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Время жизни балки — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Увеличивает длину балки.", "<descr_total_level_free_1>")]}
				},
				'buttonClass': PerkShamanButton41,
				'bonuses': {'free': [1, 2, 2], 'paid': [3, 5, 2]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanStronghold] =
			{
				'perkClass': PerkShamanStronghold,
				'name': gls("Оплот"),
				'active': true,
				'description': {
					'default': gls("При активации устанавливает тотем. Вокруг тотема можно создавать предметы. Время жизни тотема — 1 минута. Время восстановления навыка — 1 минута."),
					'level': {'free': [gls("{0} Размер области создания тотема увеличен на {1}%.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает размер области создания тотема на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает размер области создания тотема на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает размер области создания тотема на {0}%.", "<bonus_level_paid_1>"), gls("Увеличивает размер области создания тотема на {0}%.", "<bonus_level_paid_2>"), gls("Увеличивает размер области создания тотема на {0}%. Позволяет установить два тотема.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Размер области создания тотема увеличен на {1}%.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Позволяет установить два тотема. Вокруг тотемов можно создавать предметы. Время жизни каждого тотема — 1 минута. Время восстановления навыка — 1 минута. Размер области создания тотема увеличен на {0}%.", "<bonus_total>")]}
				},
				'buttonClass': PerkShamanButton47,
				'bonuses': {'free': [2, 3, 5], 'paid': [10, 15, 10]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanSpirits] =
			{
				'perkClass': PerkShamanSpirits,
				'name': gls("Духи предков"),
				'active': true,
				'description': {
					'default': gls("При активации позволяет белкам наступать на прозрачные предметы."),
					'level': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_2>"), gls("Все прозрачные объекты становятся видимыми на время действия навыка.")]},
					'total': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]},
					'buff': {'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", "<descr_default>"]}
				},
				'buttonClass': PerkShamanButton43,
				'bonuses': {'free': [1, 2, 2], 'paid': [3, 5, 0]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanTimeSlowdown] =
			{
				'perkClass': PerkShamanTimeSlowdown,
				'name': gls("Замедление времени"),
				'active': true,
				'description': {
					'default': gls("При активации временно замедляет все движущиеся механизмы."),
					'level': {'free': [gls("{0} Время действия навыка — {1} сек. Механизмы замедляются на {2}%.", "<descr_default>", "<bonus_level_free_1>", "<extraBonus_level_free_1>"), gls("Увеличивает время действия навыка на {0} сек. Увеличивает замедление механизмов на {1}%.", "<bonus_level_free_2>", "<extraBonus_level_free_2>"), gls("Увеличивает время действия навыка на {0} сек. Увеличивает замедление механизмов на {1}%.", "<bonus_level_free_3>", "<extraBonus_level_free_3>")], 'paid': [gls("Увеличивает время действия навыка на {0} сек. Увеличивает замедление механизмов на {1}%.", "<bonus_level_paid_1>", "<extraBonus_level_paid_1>"), gls("Увеличивает время действия навыка на {0} сек. Увеличивает замедление механизмов на {1}%.", "<bonus_level_paid_2>", "<extraBonus_level_paid_2>"), gls("Увеличивает время действия навыка на {0} сек. Увеличивает замедление механизмов на {1}%.", "<bonus_level_paid_3>", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Время действия навыка — {1} сек. Механизмы замедляются на {2}%.", "<descr_default>", "<bonus_total>", "<extraBonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton44,
				'bonuses': {'free': [1, 2, 2], 'paid': [3, 5, 2]},
				'extraBonuses': {'free': [10, 15, 20], 'paid': [20, 25, 10]},
				'gold_cost': [35, 35, 5]
			};

			perkData[PerkShamanStorm] =
			{
				'perkClass': PerkShamanStorm,
				'name': gls("Гроза"),
				'active': true,
				'description': {
					'default': gls("Позволяет вызывать грозовое облако. Вблизи облака белки получают бонус к скорости передвижения 15%. Время восстановления навыка — 50 секунд."),
					'level': {'free': [gls("{0} Бонус к скорости действует в течение {1} сек. Время жизни грозового облака — {2} сек.", "<descr_default>", "<bonus_level_free_1>", "<extraBonus_level_free_1>"), gls("Увеличивает время действия бонуса скорости на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время действия бонуса скорости на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время действия бонуса скорости на {0} сек. и время жизни грозового облака на {1} сек.", "<bonus_level_paid_1>", "<extraBonus_level_paid_1>"), gls("Увеличивает время действия бонуса скорости на {0} сек. и время жизни грозового облака на {1} сек.", "<bonus_level_paid_2>", "<extraBonus_level_paid_2>"), gls("Увеличивает время действия бонуса скорости на {0} сек. и время жизни грозового облака на {1} сек.", "<bonus_level_paid_3>", "<extraBonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Бонус к скорости действует в течение {1} сек. Время жизни грозового облака — {2} сек.", "<descr_default>", "<bonus_total>", "<extraBonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1>"]}
				},
				'buttonClass': PerkShamanButton50,
				'bonuses': {'free': [5, 2, 3], 'paid': [3, 3, 4]},
				'extraBonuses': {'free': [10, 0, 0], 'paid': [4, 5, 6]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanGravity] =
			{
				'perkClass': PerkShamanGravity,
				'name': gls("Грави-блок"),
				'active': true,
				'description': {
					'default': gls("При активации создаёт грави-блок. В зоне действия грави-блока повышена сила гравитации. Время существования блока ограничено. Требуется время на восстановление навыка."),
					'level': {'free': [gls("При активации создаёт грави-блок. В зоне действия грави-блока повышена сила гравитации. Время жизни грави-блока — 20 сек. Время восстановления навыка — 20 сек. Размер грави-блока увеличен на {0}%.", "<bonus_level_free_1>"), gls("Увеличивает размер грави-блока на {0}%.", "<bonus_level_free_2>"), gls("Увеличивает размер грави-блока на {0}%.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает размер грави-блока на <bonus_level_paid_1>%."), gls("Увеличивает размер грави-блока на <bonus_level_paid_2>%."), gls("Позволяет создать два грави-блока. Время жизни каждого грави-блока увеличено на 10 сек.")]},
					'total': {'free': [gls("При активации создаёт грави-блок. В зоне действия грави-блока повышена сила гравитации. Время жизни грави-блока — 20 сек. Время восстановления навыка — 20 сек. Размер грави-блока увеличен на {0}%.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Позволяет создать два грави-блока. Время жизни каждого грави-блока — 30 сек. Время восстановления навыка — 15 сек. Размер грави-блока увеличен на {0}%.", "<bonus_total>")]}
				},
				'buttonClass': PerkShamanButton46,
				'bonuses': {'free': [10, 20, 30], 'paid': [20, 30, 0]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanDestroyer] =
			{
				'perkClass': PerkShamanDestroyer,
				'name': gls("Уничтожитель"),
				'active': true,
				'description': {
					'default': gls("При активации позволяет шаману удалить любой созданный им предмет в любой точке карты. Требуется время на восстановление навыка."),
					'level': {'free': [gls("При активации позволяет шаману удалить любой построенный им предмет, независимо от радиуса области создания предметов. Время восстановления навыка — 10 сек. Количество применений навыка за раунд — {0}.", "<bonus_level_free_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_2>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_1>"), gls("Увеличивает количество применений навыка на {0}.", "<bonus_level_paid_2>"), gls("Время восстановления навыка — 0 сек.")]},
					'total': {'free': [gls("При активации позволяет шаману удалить любой построенный им предмет, независимо от радиуса области создания предметов. Время восстановления навыка — 10 сек. Количество применений навыка за раунд — {0}.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("Позволяет шаману удалить любой созданный им предмет на всей карте. {0} Количество применений навыка за раунд — {1}.", "<descr_level_level_paid_3>", "<bonus_total>")]}
				},
				'buttonClass': PerkShamanButton42,
				'bonuses': {'free': [1, 1, 1], 'paid': [2, 2, 0]},
				'gold_cost': [50, 50, 5]
			};

			perkData[PerkShamanDrawingMode] =
			{
				'perkClass': PerkShamanDrawingMode,
				'name': gls("Режим рисования"),
				'active': true,
				'description': {
					'default': gls("При активации позволяет создавать маленькие блоки, следующие один за другим. По блокам можно передвигаться."),
					'level': {'free': [gls("{0} Время жизни блоков — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время жизни блоков на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время жизни блоков на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время жизни блоков на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время жизни блоков на {0} сек.", "<bonus_level_paid_2>"), gls("Увеличивает время жизни блоков на {0} сек. Можно рисовать во время движения.", "<bonus_level_paid_3>")]},
					'total': {'free': [gls("{0} Время жизни блоков — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("{0} Можно рисовать во время движения.", "<descr_total_level_free_1>")]}
				},
				'buttonClass': PerkShamanButton48,
				'bonuses': {'free': [1, 2, 2], 'paid': [3, 5, 2]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanPortalMaster] =
			{
				'perkClass': PerkShamanPortalMaster,
				'name': gls("Мастер порталов"),
				'active': true,
				'description': {
					'default': gls("При активации создаёт «мастер-портал» зелёного цвета, к которому телепортируются белки из красного и синего порталов. Из зелёного портала телепортироваться можно, если установлен только синий, либо только красный портал."),
					'level': {'free': [gls("{0} Время жизни портала — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время жизни портала на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время жизни портала на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время жизни портала на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время жизни портала на {0} сек.", "<bonus_level_paid_2>"), gls("Время жизни зелёного портала неограничено.")]},
					'total': {'free': [gls("{0} Время жизни портала — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_default> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton49,
				'bonuses': {'free': [5, 5, 10], 'paid': [10, 15, 0]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanHoistman] =
			{
				'perkClass': PerkShamanHoistman,
				'name': gls("Крановщик"),
				'active': true,
				'description': {
					'default': gls("При активации позволяет шаману создать предмет в любой точке карты. Требуется время на восстановление навыка."),
					'level': {'free': [gls("При активации позволяет шаману создать предмет в любой точке карты. Время восстановления навыка — 20 сек. Время действия навыка — {0} сек.", "<bonus_level_free_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_2>"), gls("Навык активен постоянно.")]},
					'total': {'free': [gls("При активации позволяет шаману создать предмет в любой точке карты. Время восстановления навыка — 20 сек. Время действия навыка — {0} сек.", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", gls("При активации позволяет создать предмет в любой части карты, независимо от радиуса области создания предметов. {0}", "<descr_level_level_paid_3>")]}
				},
				'buttonClass': PerkShamanButton45,
				'bonuses': {'free': [2, 2, 2], 'paid': [4, 5, 0]},
				'gold_cost': [70, 70, 5]
			};

			perkData[PerkShamanSafeWay] =
			{
				'perkClass': PerkShamanSafeWay,
				'name': gls("Безопасный путь"),
				'active': true,
				'description': {
					'default': gls("При активации белки временно становятся бессмертными."),
					'level': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_level_free_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_2>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_free_3>")], 'paid': [gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_1>"), gls("Увеличивает время действия навыка на {0} сек.", "<bonus_level_paid_2>"), gls("В течение 2 секунд, после окончания действия навыка, белки воскрешаются вблизи шамана.")]},
					'total': {'free': [gls("{0} Время действия навыка — {1} сек.", "<descr_default>", "<bonus_total>"), "<descr_total_level_free_1>", "<descr_total_level_free_1>"], 'paid': ["<descr_total_level_free_1>", "<descr_total_level_free_1>", "<descr_total_level_free_1> <descr_level_level_paid_3>"]},
					'buff': {'free': ["<descr_default>", "<descr_default>", "<descr_default>"], 'paid': ["<descr_default>", "<descr_default>", "<descr_default> <descr_level_level_paid_3>"]}
				},
				'buttonClass': PerkShamanButton51,
				'bonuses': {'free': [1, 2, 2], 'paid': [3, 5, 0]},
				'gold_cost': [70, 70, 5]
			};
		}

		static public function getId(object:*):int
		{
			for (var id:int = 0, length:int = perkCollection.length; id < length; id++)
			{
				if (object is Class && object == perkCollection[id])
					return id;

				if (getQualifiedClassName(object) == getQualifiedClassName(perkCollection[id]))
					return id;
			}

			return -1;
		}

		static public function getClassById(id:int):Class
		{
			return (id in perkCollection) ? perkCollection[id] : null;
		}

		static public function getDescriptionById(id:int, type:String, levels:Array):String
		{
			if (!(id in perkCollection))
				return "";

			var perkClass:Class = getClassById(id);

			if (!(type in perkData[perkClass]['description']))
				return "";

			var levelFree:int = (levels ? levels[0] : 0);
			var levelPaid:int = (levels ? levels[1] : 0);

			switch (type)
			{
				case DEFAULT_DESCRIPTION:
					return perkData[perkClass]['description'][DEFAULT_DESCRIPTION];
				case LEVEL_BONUS_DESCRIPTION:
				{
					if (levelFree == 0)
						return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][LEVEL_BONUS_DESCRIPTION]['paid'][levelPaid - 1]);
					return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][LEVEL_BONUS_DESCRIPTION]['free'][levelFree - 1]);
				}
				case TOTAL_BONUS_DESCRIPTION:
				{
					if (levelFree == 0 && levelPaid == 0)
						return perkData[perkClass]['description'][DEFAULT_DESCRIPTION];
					else if (levelPaid == 3)
						return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][TOTAL_BONUS_DESCRIPTION]['paid'][levelPaid - 1]);
					return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][TOTAL_BONUS_DESCRIPTION]['free'][levelFree - 1] + ((levelPaid != 0) ? (" " + perkData[perkClass]['description'][TOTAL_BONUS_DESCRIPTION]['paid'][levelPaid - 1]) : ""));
				}
				case BUFF_DESCRIPTION:
				{
					if (levelFree == 0 && levelPaid == 0)
						return perkData[perkClass]['description'][DEFAULT_DESCRIPTION];
					else if (levelPaid == 3)
						return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][BUFF_DESCRIPTION]['paid'][levelPaid - 1]);
					return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][BUFF_DESCRIPTION]['free'][levelFree - 1] + ((levelPaid != 0) ? (" " + perkData[perkClass]['description'][BUFF_DESCRIPTION]['paid'][levelPaid - 1]) : ""));
				}
			}

			return "";
		}

		static public function getTotalDescription(id:int, levels:Array):String
		{
			if (!(id in perkCollection))
				return "";

			var perkClass:Class = getClassById(id);

			if (!(TOTAL_BONUS_DESCRIPTION in perkData[perkClass]['description']))
				return "";

			var levelFree:int = (levels ? levels[0] : 0);
			var levelPaid:int = (levels ? levels[1] : 0);

			if (levelFree == 0 && levelPaid == 0)
				return perkData[perkClass]['description'][DEFAULT_DESCRIPTION];
			else if (levelPaid == 3)
				return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][TOTAL_BONUS_DESCRIPTION]['paid'][levelPaid - 1], true);
			return parseDescription(perkClass, levelFree, levelPaid, perkData[perkClass]['description'][TOTAL_BONUS_DESCRIPTION]['free'][levelFree - 1] + ((levelPaid != 0) ? (" " + perkData[perkClass]['description'][TOTAL_BONUS_DESCRIPTION]['paid'][levelPaid - 1]) : ""), true);
		}

		static private function parseDescription(perkClass:Class, levelFree:int, levelPaid:int, description:String, isHtml:Boolean = false):String
		{
			var result:String = description.concat();

			var tags:Array, tag:String, data:Array;

			while (true)
			{
				tags = result.match(/<descr_total[a-zA-Z_0-9]*>/g);
				tags = tags.concat(result.match(/<descr_level[a-zA-Z_0-9]*>/g));
				tags = tags.concat(result.match(/<descr_buff[a-zA-Z_0-9]*>/g));

				if (tags.length == 0)
					break;

				for (var i:int = tags.length - 1; i >= 0; i--)
				{
					tag = (tags[i] as String);
					data = tag.slice(1, tags[i].length - 1).split("_");

					var replaceString:String = perkData[perkClass]['description'][data[1]][data[3]][data[4] - 1];
					result = result.replace(tag, result.match(replaceString) == null ? replaceString : "");
				}
			}

			tags = result.match(/<[a-zA-Z_0-9]*>/g);

			var replaceNumber:String;

			for (i = 0; i < tags.length; i++)
			{
				tag = tags[i];
				data = tag.slice(1, tags[i].length - 1).split("_");

				replaceNumber = "";

				if (tag.match("extraBonus_level"))
					replaceNumber = String(perkData[perkClass]['extraBonuses'][data[2]][data[3] - 1]);
				else if (tag.match("bonus_level"))
					replaceNumber = String(perkData[perkClass]['bonuses'][data[2]][data[3] - 1]);
				else if (tag.match("extraBonus_total"))
					replaceNumber = String(PerkShaman.getBonus(levelFree, levelPaid, perkData[perkClass]['extraBonuses']));
				else if (tag.match("bonus_total"))
					replaceNumber = String(PerkShaman.getBonus(levelFree, levelPaid, perkData[perkClass]['bonuses']));
				else if (tag.match("descr_default"))
				{
					result = result.replace(tag, String(perkData[perkClass]['description'][DEFAULT_DESCRIPTION]));
					continue;
				}

				if (replaceNumber == "")
					continue;

				if (isHtml)
				{
					var isExpr:Boolean = false;

					if (i != 0 && tags[i - 1] == "<sub>")
						isExpr = true;
					else if (i != tags.length - 1 && tags[i + 1] == "<sub>")
						isExpr = true;

					if (!isExpr)
						replaceNumber = HtmlTool.span(replaceNumber, "number");
				}

				result = result.replace(tag, replaceNumber);
			}

			var mathOp:Array = result.match(/[0-9]+<su[mb]>[0-9]+/g);

			for (i = 0; i < mathOp.length; i++)
			{
				tag = mathOp[i];

				var operator:String = tag.match(/<su[mb]>/).pop();
				data = tag.split(operator);

				switch (operator)
				{
					case "<sub>":
						var sub:String = String(int(data[0]) - int(data[1]));

						if (isHtml)
							sub = HtmlTool.span(sub, "number");

						result = result.replace(tag, sub);
						break;
				}
			}

			result = result.replace("  ", " ");

			return result;
		}
	}
}