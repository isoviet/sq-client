package game.mainGame.perks.clothes
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import game.mainGame.perks.PerkData;

	public class PerkClothesFactory
	{
		static public const EXTRA_PERK:int = 0;

		static public const IRONMAN:int = 11;
		static public const SUPERMAN_MAN:int = 12;
		static public const ALTRONE:int = 13;
		static public const ROBOCOP:int = 14;
		static public const PIRATE:int = 15;
		static public const BLACK_BEARD:int = 16;
		static public const AMELIA:int = 17;
		static public const FLASH:int = 18;
		static public const PIKACHU:int = 19;
		static public const THRONE:int = 20;
		static public const ZOOM:int = 21;
		static public const CHESHIRE_CAT:int = 22;
		static public const BLACK_CAT:int = 23;
		static public const FAIRY_CAT:int = 24;
		static public const CHESHIRE3:int = 25;
		static public const DORMAMMU:int = 26;
		static public const PHARAON_MAN:int = 27;
		static public const PHARAON_WOMAN:int = 28;
		static public const ANUBIS:int = 29;
		static public const TUTENSHTAIN:int = 30;
		static public const DEATH:int = 31;
		static public const SWEET_DEATH:int = 32;
		static public const AID:int = 33;
		static public const BANSHEE:int = 34;
		static public const SAILORMOON:int = 35;
		static public const FAIRY:int = 36;
		static public const ASSASSIN:int = 37;
		static public const TUXEDOMASK:int = 38;
		static public const SWEET_TOOTH:int = 39;
		static public const HONEY_LEMON_WOMAN:int = 40;
		static public const CHRONOS_MAN:int = 41;
		static public const PERSIA_MAN:int = 42;
		static public const LEPRECHAUN:int = 43;
		static public const HATTER:int = 44;
		static public const ELF:int = 45;
		static public const WIZARD_MAN:int = 46;
		static public const JUGGLER:int = 47;
		static public const SCRAT_JUGGLER:int = 48;
		static public const SCRATTY_JUGGLER:int = 49;
		static public const TOOTHLESS:int = 50;
		static public const ZOMBIE:int = 51;
		static public const SKELETON:int = 52;
		static public const VAMPIRE:int = 53;
		static public const CTHULHU_MAN:int = 54;
		static public const SONIC:int = 55;
		static public const AMYROSE:int = 56;
		static public const ARMADILLO:int = 57;
		static public const STORM:int = 58;
		static public const HATSUNE:int = 59;
		static public const LEN:int = 60;
		static public const BUMBLEBEE:int = 61;
		static public const ARCEE:int = 62;
		static public const HIPSTER_WOMAN:int = 63;
		static public const HIPPIE_MAN:int = 64;
		static public const MOD:int = 65;
		static public const PARTY:int = 66;
		static public const CHAMPION:int = 67;
		static public const WOLF_FREEZE_COLLECTION:int = 68;
		static public const WOLF_BLIZZARD:int = 69;
		static public const VIKING:int = 70;
		static public const NINJA:int = 71;
		static public const FOOTPAD:int = 72;
		static public const SAMURAI:int = 73;
		static public const RAMBO:int = 74;
		static public const RABBIT:int = 75;
		static public const WENDIGO:int = 76;
		static public const VADER:int = 77;
		static public const CAPITAN_AMERICA:int = 78;
		static public const SPIDER:int = 79;
		static public const LOGAN:int = 80;
		static public const FROST_2014:int = 81;
		static public const SNOW_MAIDEN_2014:int = 82;
		static public const DEER:int = 83;
		static public const PARROT_MAN:int = 84;
		static public const IRBIS:int = 85;
		static public const BATMAN:int = 86;
		static public const CATWOMAN_BATMAN:int = 87;
		static public const CATWOMAN:int = 88;
		static public const JOKER:int = 89;
		static public const HARLEY_QUINN:int = 90;
		static public const SPARTAN_MAN:int = 91;
		static public const LEGION_RED:int = 92;
		static public const NAPOLEON:int = 93;
		static public const COP_MAN:int = 94;
		static public const ALCHEMIST_SHEEP:int = 95;
		static public const ALCHEMIST_SHADOW:int = 96;
		static public const TOR:int = 97;
		static public const LOKI:int = 98;

		static public const CRYSTAL_MAIDEN_FREEZING:int = 99;
		static public const CRYSTAL_MAIDEN_SNOWMAN:int = 100;
		static public const CRYSTAL_MAIDEN_BIGFOOT:int = 101;
		static public const CRYSTAL_MAIDEN_DRAGON:int = 102;

		static public const KOWABUNGA:int = 103;
		static public const HURRY:int = 104;
		static public const LOVE_SHOT:int = 105;

		static public const DEADPOOL:int = 106;
		static public const BUBBLEGUM:int = 107;

		static public const RAPUNZEL:int = 108;
		static public const DRUID:int = 109;
		static public const BEAR:int = 110;

		static public const EVA:int = 111;
		static public const STITCH:int = 112;
		static public const FARMER:int = 113;
		static public const HARLOCK:int = 114;
		static public const MINION:int = 115;

		static public const ORC:int = 116;
		static public const CHAPLIN:int = 117;

		static public const MAX_TYPE:int = 116;

		static public var perkData:Object = {};
		static public var i:* = PerkClothesFactory.init();

		static public function init():void
		{
			//отступ это значит что ещё не реализовано
			perkData[EXTRA_PERK] = new PerkData(gls("Пустой слот"), gls("В пустой слот магии можно уставить любую магию из других костюмов, которые у тебя есть."), Sprite, null);
			perkData[FARMER] = new PerkData(gls("Знатный урожай"), gls("Фермер прямо на карте высаживает различные растения."), IconPerkFarmer, PerkClothesFarmer);

			perkData[IRONMAN] = new PerkData(gls("Шар Стали"), gls("Белка выпускает импульсный заряд, который сносит все на своем пути."), IconPerkIronMan, PerkClothesIronMan);
			perkData[ROBOCOP] = new PerkData(gls("Огонь на поражение"), gls("Белка ослепляет прочих, выпуская дымовую завесу, которая рассеивается через некоторое время."), IconPerkSmoke, PerkClothesRobocop);
			perkData[ALTRONE] = new PerkData(gls("Полет Альтрона"), gls("Белочка способна лететь в течение определённого времени в любом направлении."), IconPerkAltrone, PerkClothesAltrone);
			perkData[SUPERMAN_MAN] = new PerkData(gls("Знак качества"), gls("Над белкой появляется знак героя, вселяющий надежду в сердца сородичей."), IconPerkSuperMan, PerkClothesSuperman);

			perkData[PIRATE] = new PerkData(gls("Залп"), gls("Белочка ставит пушку, которая появляется около него и стреляет ядром через некоторое время."), IconPerkPirate, PerkClothesPirate);
			perkData[BLACK_BEARD] = new PerkData(gls("Дитя Моря"), gls("Позволяет белочке плавать быстрее в течение некоторого времени."), IconPerkAquaMan, PerkClothesPirateSwim);
			perkData[AMELIA] = new PerkData(gls("Йо-хо-хо"), gls("Белочка ставит препятствие, бочку с ромом, которая пропадает через некоторое время."), IconPerkObject, PerkClothesPirateBarrel);
			perkData[HARLOCK] = new PerkData(gls("Пиратский флаг"), gls("Ставит пиратский флаг, к которому автоматически перемещается через 10 секунд."), IconPerkHarlock, PerkClothesHarlock);

			perkData[FLASH] = new PerkData(gls("Вспышка"), gls("Позволяет белочке двигаться быстрее и отталкивать от себя предметы в течение определённого времени."), IconPerkFlash, PerkClothesFlash);
			perkData[PIKACHU] = new PerkData(gls("Удар грома"), gls("Позволяет белочке оглушать других белок электрическим разрядом на несколько секунд."), IconPerkPikachu, PerkClothesPikachu);
			perkData[THRONE] = new PerkData(gls("Цифровой сдвиг"), gls("Белочка создает свою астральную копию, которая стоит на месте и радует всех своим присутствием."), IconPerkThrone, PerkClothesThrone);
			perkData[ZOOM] = new PerkData(gls("Еще быстрее"), gls("Белочка перемещается вперед на некоторое расстояние, игнорируя пропасти и препятствия."), IconPerkZoom, PerkClothesZoom);

			perkData[CHESHIRE_CAT] = new PerkData(gls("Улыбка Чешира"), gls("Белочка телепортируется в пределах определенного расстояния, минуя препятствия, оставляя за собой исчезающую улыбку."), IconPerkCheshire, PerkClothesCheshire);
			perkData[BLACK_CAT] = new PerkData(gls("Назад во времени"), gls("Позволяет переместиться обратно в точку телепортации."), IconPerkRollBack, PerkClothesBlackCat);
			perkData[FAIRY_CAT] = new PerkData(gls("Аэрокот"), gls("Может летать на дальние расстояния. Во время полёта виднеется лишь его голова."), IconPerkCheshireFly, PerkClothesFairyCat);
				perkData[CHESHIRE3] = new PerkData(gls("Дымовая завеса"), gls(""), IconPerkSmoke, PerkClothesCheshire);
				perkData[DORMAMMU] = new PerkData(gls("Огненное дыхание"), gls(""), IconPerkFire, PerkClothesCheshire);

			perkData[PHARAON_MAN] = new PerkData(gls("Вихрь Судьбы"), gls("Позволяет превращаться на время в песчаный вихрь. Вихрь неуязвим, проходит сквозь препятствия и разбрасывает других белок."), IconPerkTornado, PerkClothesPharaon);
			perkData[PHARAON_WOMAN] = new PerkData(gls("Истинное зрение"), gls("Позволяет отличать настоящие элементы коллекций от иллюзий, а также самому создавать и перемешивать иллюзии на любых локациях, кроме Битвы и Летающих Островов. А в довесок позволяет в пустыне обходиться без воды и плавать в зыбучих песках."), IconPerkIllusion, PerkClothesCollectonCopy);
			perkData[ANUBIS] = new PerkData(gls("Обелиск смерти"), gls("Позволяет ставить непроходимый для других белок каменный обелиск, оставляя всех позади."), IconPerkAnubis, PerkClothesAnubis);
				perkData[TUTENSHTAIN] = new PerkData(gls("С приветом с того света"), gls(""), IconPerkAnkh, PerkClothesCollectonCopy);

			perkData[DEATH] = new PerkData(gls("Поцелуй смерти"), gls("Позволяет наложить проклятие на белку. Если проклятая белка умирает, Смерть получает ее душу и возможность бесплатно воскреснуть самой."), IconPerkDeath, PerkClothesDeath);
			perkData[SWEET_DEATH] = new PerkData(gls("Любовь до гроба"), gls("Может влюбиться в другую белку. Если эта белка умрет, она возродится один раз за раунд, а Сладкая смерть получит ее добро: орех или коллекцию."), IconPerkSweetDeath, PerkClothesSweetDeath);
			perkData[BANSHEE] = new PerkData(gls("Призрачная угроза"), gls("Позволяет летать и игнорировать любые препятствия на короткое время."), IconPerkAltrone, PerkClothesBanshee);
			perkData[AID] = new PerkData(gls("Загробный мост"), gls("Аид ставит мост, по которому может пройти только он. Белки не смогут вступить на мост из душ."), IconPerkAid, PerkClothesAid);

			perkData[SAILORMOON] = new PerkData(gls("Лунная призма"), gls("Позволяет призвать Луну, которая помогает преодолевать препятствия"), IconPerkSailorMoon, PerkClothesSailorMoon);
			perkData[FAIRY] = new PerkData(gls("Маленькое чудо"), gls("Позволяет запускать праздничный фейерверк"), IconPerkTrippleStar, PerkClothesSalutSnowgirl);

			perkData[ASSASSIN] = new PerkData(gls("Дымовая завеса"), gls("Выпускает дымовую завесу, которая не позволяет видеть белкам, где прячется ассассин."), IconPerkSmoke, PerkClothesAssassinSmoke);
			perkData[TUXEDOMASK] = new PerkData(gls("Осторожней, шипы"), gls("Выпускает розу, которая, воткнувшись в стену, позволяет преодолеть её."), IconPerkTuxedo, PerkClothesTuxedoMask);
			perkData[KOWABUNGA] = new PerkData(gls("Кавабанга"), gls("Крик юной черепашки воодушевляет всех вокруг. Моральная поддержка в трудную минуту."), IconPerkRafael, PerkClothesRafael);

			perkData[SWEET_TOOTH] = new PerkData(gls("Кекс"), gls("Позволяет ставить кекс, который помогает преодолевать препятствия."), IconPerkObject, PerkClothesMuffin);
			perkData[HONEY_LEMON_WOMAN] = new PerkData(gls("Бомба-Липучка"), gls("Позволяет кидать бомбу-липучку, которая после взрыва слепляет белок находящихся рядом вместе."), IconPerkGum, PerkClothesHoneySticky);
			perkData[BUBBLEGUM] = new PerkData(gls("Гарпун-жвачка"), gls("Позволяет прицепится к любому объекту с помощью гарпуна-жвачки и переместиться на большое расстояние."), IconPerkBubbleGum, PerkClothesBubblegum);
			perkData[RAPUNZEL] = new PerkData(gls("Небесные фонарики"), gls("Запускает яркий небесный фонарик."), IconPerkRapunzel, PerkClothesRapunzel);

			perkData[CHRONOS_MAN] = new PerkData(gls("Назад в прошлое"), gls("Позволяет возвращать других белок назад во времени на три секунды."), IconPerkTime, PerkClothesChronos);
			perkData[PERSIA_MAN] = new PerkData(gls("Ловкость акробата"), gls("Позволяет превратиться в Песчаного призрака и безопасно ходить по любым шипам, Странник дольше обходится в пустыне без воды"), IconPerkPersian, PerkClothesPersian);
			perkData[HURRY] = new PerkData(gls("Время спешить"), gls("Используя свои часы, МакТвист заставляет всех сбавить ход и пропустить его. Ведь он невероятно спешит."), IconPerkMcTwist, PerkClothesMcTwist);

			perkData[LEPRECHAUN] = new PerkData(gls("Щедрость Лепрекона"), gls("Позволяет ставить мешок с золотом, подобрав который, игрок получит один из бонусов: орехи, ману, энергию, монетку. Лепрекон получит ту же награду"), IconPerkLeprechaun, PerkClothesLeprechaun);
			perkData[HATTER] = new PerkData(gls("Безумное чаепитие"), gls("Позволяет использовать магию смены мест: Шляпник встаёт на место шамана, а остальные белки меняются местами друг с другом. Не может применятся сразу после применения этой магии другим шляпником."), IconPerkHatter, PerkClothesHatter);

			perkData[ELF] = new PerkData(gls("С ветки на ветку"), gls("Позволяет совершать много повторных, но невысоких прыжков."), IconPerkDoubleJump, PerkClothesElf);
			perkData[DRUID] = new PerkData(gls("Духи леса"), gls("Временная неуязвимость к кислоте и смоле."), IconPerkDruid, PerkClothesDruid);

			perkData[WIZARD_MAN] = new PerkData(gls("Магический воришка"), gls("Позволяет создавать ауру. Когда другие белочки используют магию, находясь в этой ауре, волшебник получает копию их магии."), IconPerkWizard, PerkClothesWizard);
			perkData[JUGGLER] = new PerkData(gls("Козырная карта"), gls("Позволяет ставить карту, подобрав которую игрок получит две бесплатные магии. При повтороном использовании этой магии старая карта разрушается."), IconPerkMagicCard, PerkClothesMagician);
			perkData[SCRAT_JUGGLER] = new PerkData(gls("Козырная карта"), gls("Позволяет ставить карту, подобрав которую игрок получит две бесплатные магии. При повтороном использовании этой магии старая карта разрушается."), IconPerkMagicCard, PerkClothesMagician);
			perkData[SCRATTY_JUGGLER] = new PerkData(gls("Козырная карта"), gls("Позволяет ставить карту, подобрав которую игрок получит две бесплатные магии. При повтороном использовании этой магии старая карта разрушается."), IconPerkMagicCard, PerkClothesMagician);

			perkData[TOOTHLESS] = new PerkData(gls("Полет фурии"), gls("Позволяет прыгать выше и парить."), IconPerkAltrone, PerkClothesToothlessJump);
			perkData[STITCH] = new PerkData(gls("Луч хаоса"), gls("При попадании мощный лазер раскидывает всех белок в округе."), IconPerkStitch, PerkClothesStitch);

			perkData[ZOMBIE] = new PerkData(gls("Из под земли достану"), gls("Ставит могилу, которая позволяет воскреситься после попадания на шипы или кислоту. Сама могила после этого ломается."), IconPerkZombie, PerkClothesZombie);
			perkData[SKELETON] = new PerkData(gls("Безшабашные друзья"), gls("Позволяет призывать веселые прыгающие черепа на некоторое время."), IconPerkFire, PerkClothesSkeleton);
			perkData[VAMPIRE] = new PerkData(gls("Крылья ночи"), gls("Позволяет призвать стаю летучих мышей, которые принесут игроку предмет коллекции на уровне"), IconPerkVampire, PerkClothesVampire);
			perkData[CTHULHU_MAN] = new PerkData(gls("Узы любви"), gls("Позволяет задержать белочек на несколько секунд"), IconPerkCthulhu, PerkClothesCthulhu);

			perkData[SONIC] = new PerkData(gls("Соник Бум"), gls("Позволяет ускоряться и отскакивать от любой поверхности"), IconPerkSonic, PerkClothesSonic);
			perkData[AMYROSE] = new PerkData(gls("Цена ошибки"), gls("Позволяет один раз за раунд получить временную неуязвимость при попадании на шипы или кислоту"), IconPerkImmune, PerkClothesSonicProtect);
			perkData[ARMADILLO] = new PerkData(gls("Броня броненосца"), gls("Дает неуязвимость к шипам и кислоте на время работы этой магии."), IconPerkArmadillo, PerkClothesArmadillo);

			perkData[STORM] = new PerkData(gls("Притяжение"), gls("Позволяет притягивать коллекции."), IconPerkCollectionPull, PerkClothesCollectionPull);
			perkData[HATSUNE] = new PerkData(gls("Не доставайся же ты никому"), gls("Позволяет отталкивать коллекции."), IconPerkCollectionPush, PerkClothesCollectionPush);
			perkData[LEN] = new PerkData(gls("Зажигай!"), gls("Белочка достает гитару и начинает на ней играть, создавая на уровне целое представление."), IconPerkMusic, PerkClothesLen);

			perkData[BUMBLEBEE] = new PerkData(gls("Автобот"), gls("Позволяет превращаться в спортивный АВТО и передвигаться с огромной скоростью"), IconPerkTransformCar, PerkClothesBumblebee);
			perkData[ARCEE] = new PerkData(gls("Подскок"), gls("Позволяет подпрыгнуть на небольшое расстояние, даже в форме авто."), IconPerkTransformFly, PerkClothesArcee);
			perkData[EVA] = new PerkData(gls("Послание"), gls(""), IconPerkEva, PerkClothesEva);

			perkData[HIPSTER_WOMAN] = new PerkData(gls("Заряд энергии"), gls("Ставить коктейль, который восстановит +1 выносливости поднявшей его белке, а хипстер получит +5 орехов."), IconPerkObjectEnergy, PerkClothesHipster);
				perkData[HIPPIE_MAN] = new PerkData(gls("Всем нужна любовь"), gls("Позволяет поставить переливающуюся радугу"), IconPerkPeaceful, PerkClothesHipster);
				perkData[MOD] = new PerkData(gls("Сними это!"), gls("С выбранной белочки снимается костюм и у нее отбирается магия на короткий промежуток времени."), IconPerkBlockDress, PerkClothesHipster);
				perkData[PARTY] = new PerkData(gls("Танцуй!"), gls("Ставит красивый и яркий диско-шар, который можно использовать как ящик, висящий в воздухе."), IconPerkDance, PerkClothesDisco);
			perkData[CHAMPION] = new PerkData(gls("Бэкфлип"), gls("Позволяет бытрее бегать и выше прыгать."), IconPerkDoubleJump, PerkClothesChampion);

			perkData[WOLF_FREEZE_COLLECTION] = new PerkData(gls("Руки прочь"), gls("Позволяет замораживать предметы коллекций и кроме игрока, заморозившего их, никто не может их собрать."), IconPerkFreezeCollection, PerkClothesFreezeCollection);
			perkData[WOLF_BLIZZARD] = new PerkData(gls("Метелица"), gls("Позволяет вызывать снежную бурю, которая замедляет других белок"), IconPerkBlizzard, PerkClothesBlizzard);

			perkData[VIKING] = new PerkData(gls("Планета для белок"), gls("Позволяет издавать воинствующий клич, набирается ярости и бежит на 20% быстрее."), IconPerkViking, PerkClothesViking);
			perkData[NINJA] = new PerkData(gls("Легкая поступь"), gls("Дает возмоность совершить 5 высоких двойных прыжков."), IconPerkDoubleJump, PerkClothesNinja);
			perkData[FOOTPAD] = new PerkData(gls("А если найду?"), gls("Позволяет пытаться отобрать орех у другой белки"), IconPerkStealNut, PerkClothesStealNuts);
			perkData[SAMURAI] = new PerkData(gls("Весеннее настроение"), gls("Позволяет ставить цветущую сакуру, великолепием своим услаждающую взоры"), IconPerkSamurai, PerkClothesSamurai);
			perkData[RAMBO] = new PerkData(gls("В укрытие!"), gls("Позволяет ставить мину, вызывающую дезориентацию у белок, попавших в зону взрыва, старое дестроится"), IconPerkStun, PerkClothesRembo);

			perkData[RABBIT] = new PerkData(gls("Хоп-хоп"), gls("Подпрыгивает высоко вверх, всякий раз, когда его лапы касаются земли."), IconPerkDoubleJump, PerkClothesRabbit);
			perkData[MINION] = new PerkData(gls("Бана-на!"), gls("Подбрасывает банан в воздух, который распадается на 5 маленьких бананов. Чем больше фруктов поймают другие белки, тем большее ускорение получит миньон."), IconPerkBanana, PerkClothesMinion);

			perkData[WENDIGO] = new PerkData(gls("Волчьи законы"), gls("Позволяет превратиться в быстрого Оборотня и забрать элемент коллекции у случайной белки"), IconPerkVendigo, PerkClothesVendigo);

			perkData[VADER] = new PerkData(gls("Тёмная сторона"), gls("Поднимает белочку вверх над землей и в течении некоторого времени та не может пошевелиться."), IconPerkVader, PerkClothesVader);

			perkData[CAPITAN_AMERICA] = new PerkData(gls("Удар патриота"), gls("Капитан Америка бросает свой могучий щит, который оглушает всех белок на своём пути. А отскочив от стены он летит обратно."), IconPerkAmerica, PerkClothesAmerica);
			perkData[SPIDER] = new PerkData(gls("Паутина"), gls("Пускает паутину, которая помогает преодолеть препятствия."), IconPerkSpider, PerkClothesSpider);
			perkData[LOGAN] = new PerkData(gls("Разрушитель"), gls("Росомаха ускоряется и отбрасывает всех белок на своём пути."), IconPerkLogan, PerkClothesLogan);
			perkData[DEADPOOL] = new PerkData(gls("Всё на показ"), gls("Дэдпул мешает другим игрокам, мелькая на экране в своем ярком обтягивающем костюме."), IconPerkDeadpool, PerkClothesDeadpool);

			perkData[FROST_2014] = new PerkData(gls("Лучший подарок"), gls("Ставит праздничную коробку, которая как ящик, позволяет преодолевать препятствия."), IconPerkObject, PerkClothesSanta);
			perkData[SNOW_MAIDEN_2014] = new PerkData(gls("С Новым Годом!"), gls("Позволяет оставлять новогоднее поздравление."), IconPerkNewYear, PerkClothesSnowMaiden);
			perkData[DEER] = new PerkData(gls("Полет"), gls("Позволяет некоторое время лететь вперед."), IconPerkAltrone, PerkClothesDeer);

			perkData[PARROT_MAN] = new PerkData(gls("Порхай как попугай"), gls("Высокий прыжок с медленным продвижением вперед"), IconPerkAltrone, PerkClothesRio);
			perkData[IRBIS] = new PerkData(gls("Звериный рык"), gls("Своим рычанием барс распугивает всех белок поблизости. От испуга белки теряют контроль и начинают бегать на месте"), IconPerkStun, PerkClothesLeopardRoar);
			perkData[BEAR] = new PerkData(gls("Медвежья услуга"), gls("Cтавит мешочек с угощением, в котором скрыта одна из пяти магий."), IconPerkBear, PerkClothesBear);

			perkData[BATMAN] = new PerkData(gls("Батаранг"), gls("Позволяет прицепиться к любому объекту с помощью гарпуна и переместиться на большое расстояние"), IconPerkBatman, PerkClothesHarpoonBat);
				//perkData[CATWOMAN_BATMAN] = new PerkData(gls("Кошачья грация"), gls("Кидает бэтаранг, который, как ядро, разбрасывает все вокруг и может вернуться обратно, отскочив от стены."), IconPerkHarpoon, PerkClothesHarpoonCat);
			perkData[CATWOMAN] = new PerkData(gls("Кошачья ловкость"), gls("После применения позволяет совершить один высокий прыжок."), IconPerkDoubleJump, PerkClothesCatWoman);
			perkData[JOKER] = new PerkData(gls("Шкатулка с сюрпризом"), gls("Позволяет ставить шкатулку с секретом внутри - от ускорения до отравления веселящим газом. Если эффект положительный, он также действует и на Джокера."), IconPerkJoker, PerkClothesJoker);
			perkData[HARLEY_QUINN] = new PerkData(gls("Сокрушительная сила"), gls("Удар молота по земле разбрасывает всех белок рядом."), IconPerkHammer, PerkClothesHarli);

			perkData[SPARTAN_MAN] = new PerkData(gls("Это Спарта!"), gls("Позволяет белке бегать быстрее. Чем больше других Спартанцев на поле игры, тем выше её скорость"), IconPerkSparta, PerkClothesSpartan);
			perkData[LEGION_RED] = new PerkData(gls("Под эгидой Воина"), gls("Позволяет ставить боевой штандарт"), IconPerkFlag, PerkClothesLegion);
			perkData[NAPOLEON] = new PerkData(gls("Боевой барабан"), gls("Ставит перед собой барабан, который позволяет прыгать на нем, как на батуте."), IconPerkBouncer, PerkClothesNapoleon);
			perkData[COP_MAN] = new PerkData(gls("Никому не двигаться!"), gls("Позволяет включать мигалку"), IconPerkCop, PerkClothesPolice);

			perkData[ALCHEMIST_SHEEP] = new PerkData(gls("Алхимическое зелье"), gls("Зелье, которое при попадании в другую белку, превращает ее в овцу."), IconPerkSheep, PerkClothesSheepBomb);
			perkData[ALCHEMIST_SHADOW] = new PerkData(gls("Эликсир тени"), gls("Зелье, которое при попадании в землю переносит алхимика в точку падения."), IconPerkShadowBomb, PerkClothesShadowBomb);

			perkData[TOR] = new PerkData(gls("Божественная сила"), gls("Удар молота по земле разбрасывает всех белок рядом."), IconPerkTor, PerkClothesTor);
			perkData[LOKI] = new PerkData(gls("Обманщик"), gls("Позволяет менять внешность во время игры."), IconPerkRedress, PerkClothesLoki);

			perkData[CRYSTAL_MAIDEN_FREEZING] = new PerkData(gls("Мороз"), gls("Зачарованный новогодний амулет позволяет рисовать морозные узоры и вызывать снегопад."), IconPerkMaidenFreezing, PerkClothesAmuletSnowfall);
			perkData[CRYSTAL_MAIDEN_SNOWMAN] = new PerkData(gls("Снеговик"), gls("Зачарованный новогодний амулет позволяет ставить снеговика."), IconPerkMaidenSnowman, PerkClothesAmuletSnowman);
			perkData[CRYSTAL_MAIDEN_BIGFOOT] = new PerkData(gls("Йети"), gls("Зачарованный новогодний амулет позволяет повелевать Йети."), IconPerkMaidenYeti, PerkClothesAmuletYeti);
			perkData[CRYSTAL_MAIDEN_DRAGON] = new PerkData(gls("Ледяной дракон"), gls("Зачарованный новогодний амулет позволяет призывать ледянного дракона. Чтобы управлять драконом, используй стрелки Влево-Вправо."), IconPerkMaidenDragon, PerkClothesAmuletDragon);

			perkData[LOVE_SHOT] = new PerkData(gls("Сила Любви"), gls("Посланник любви помогает двум одиноким белкам найти друг друга. И... Связать их. Выпустив стрелу, он предрешает чью-то судьбу. Порой без спроса."), IconPerkAmur, PerkClothesAmur);

			perkData[ORC] = new PerkData(gls("Берсерк"), gls("Позволяет устремиться вперёд с огромной скоростью. Белкой нельзя управлять, кроме как перепрыгивать через препятствия."), IconPerkOrc, PerkClothesOrc);
			perkData[CHAPLIN] = new PerkData(gls("Назад в прошлое"), gls("Позволяет сделать мир чёрно-белым и впасть в ностальгию по прошлым временам."), IconPerkCharli, PerkClothesCharli);
		}

		static public function getNewImage(id:int):DisplayObject
		{
			return new (perkData[id] as PerkData).image;
		}

		static public function getImageClass(id:int):Class
		{
			if(!(perkData[id] as PerkData) || !(perkData[id] as PerkData).image)
				return (perkData[EXTRA_PERK] as PerkData).image;
			else
				return (perkData[id] as PerkData).image;
		}

		static public function getName(id:int):String
		{
			return (perkData[id] as PerkData).name;
		}

		static public function getDescription(id:int):String
		{
			return (perkData[id] as PerkData).description;
		}

		static public function getPerkClass(id:int):Class
		{
			if (id in perkData)
				return (perkData[id] as PerkData).perk;
			return null;
		}
	}
}