package
{
	import game.gameData.GameConfig;
	import game.gameData.OutfitData;

	public class ClothesData
	{
		static public var inited:Boolean = false;

		static public const DREAMCATCHERS_MALE_ID:int = 411;
		static public const DREAMCATCHERS_FEMALE_ID:int = 412;
		static public const FLOWER_ID:int = 448;

		static public const ACCESSORY_DATA:Object = {};
		static public const PACKAGES_DATA:Object = {};

		static public const IMAGES_CACHE_PACKAGES:Object = {
			13: "_1",
			65: "_1",
			73: "_1",
			77: "_2",
			78: "_2"
		};

		static public const IMAGES_CACHE:Object = {
			60: "_1"
		};

		static public const IMAGES_CACHE_SMALL:Object = {
			105: "_1",
			106: "_1"
		};

		static public function init():void
		{
			if (inited)
				return;
			inited = true;

			PACKAGES_DATA[OutfitData.AID] = {'name': gls("Аид"), 'description': gls("<body>Бог подземного царства. Повелитель душ.</body>")};
			PACKAGES_DATA[OutfitData.AIRBENDER_BLUE] = {'name': gls("Шаман стихий"), 'description': gls("<body>Костюм Шамана Стихий позволит стать ярче своих сородичей и насладиться уникальной анимацией, которая соответствует выбранной стихии костюма.\nСтоит только взглянуть на него, чтобы понять: каждый элемент несёт в себе могущество древних стихий!</body>")};
			PACKAGES_DATA[OutfitData.AIRBENDER_GREEN] = {'name': gls("Шаман стихий"), 'description': gls("<body>Костюм Шамана Стихий позволит стать ярче своих сородичей и насладиться уникальной анимацией, которая соответствует выбранной стихии костюма.\nСтоит только взглянуть на него, чтобы понять: каждый элемент несёт в себе могущество древних стихий!</body>")};
			PACKAGES_DATA[OutfitData.AIRBENDER_RED] = {'name': gls("Шаман стихий"), 'description': gls("<body>Костюм Шамана Стихий позволит стать ярче своих сородичей и насладиться уникальной анимацией, которая соответствует выбранной стихии костюма.\nСтоит только взглянуть на него, чтобы понять: каждый элемент несёт в себе могущество древних стихий!</body>")};
			PACKAGES_DATA[OutfitData.AIRBENDER_VIOLET] = {'name': gls("Шаман стихий"), 'description': gls("<body>Костюм Шамана Стихий позволит стать ярче своих сородичей и насладиться уникальной анимацией, которая соответствует выбранной стихии костюма.\nСтоит только взглянуть на него, чтобы понять: каждый элемент несёт в себе могущество древних стихий!</body>")};
			PACKAGES_DATA[OutfitData.ALCHEMIST] = {'name': gls("Алхимик"), 'description': gls("<body>Освоив магию, некоторые белки решили изучить алхимию. Алхимик искал способ опережать всех и первым добираться до дупла с драгоценным орехом. Ему удалось сотворить зелья, которые обладают поистине удивительной силой.</body>")};
			PACKAGES_DATA[OutfitData.AMYROSE] = {'name': gls("Эми Роуз"), 'description': gls("<body>Озорной характер этой ежихи сразу заметен по её весёлому розовому наряду.</body>")};
			PACKAGES_DATA[OutfitData.ANUBIS] = {'name': gls("Анубис"), 'description': gls("<body>Покровитель загробного мира. Древнее божество, наделённое невероятной силой.</body>")};
			PACKAGES_DATA[OutfitData.ARCEE] = {'name': gls("Арси"), 'description': gls("<body>По легенде, в далекие-далекие времена на планету белок уже падал метеорит. На месте падения были найдены могущественные костюмы древних героев.</body>")};
			PACKAGES_DATA[OutfitData.ARMADILLO] = {'name': gls("Броненосец"), 'description': gls("<body>Тело броненосца защищено твердым костяным панцирем, напоминающем доспехи. При необходимости он превращается в округлый шар, который защищает его от кислоты и шипов.</body>")};
			PACKAGES_DATA[OutfitData.ASSASSIN] = {'name': gls("Ассасин"), 'description': gls("<body>Ассасин – древний воин, существование которого окутано тайнами и легендами. Его навыки позволяют преодолеть любые препятствия на пути к своей цели. После чего он просто испаряется, оставляя после себя облако густого дыма.</body>")};
			PACKAGES_DATA[OutfitData.BANSHEE] = {'name': gls("Летучий голландец"), 'description': gls("<body>Костюм «Летучего голландца» позволит любой белке стать настоящим призраком, который не знает преград и наводит ужас на всё живое.</body>")};
			PACKAGES_DATA[OutfitData.BATMAN] = {'name': gls("Бэтмен"), 'description': gls("<body>Добро пожаловать в мир хаоса, где выжить смогут только супергерои. Движение по борьбе с самыми опасными белками в игре возглавит Бэтмен.</body>")};
			PACKAGES_DATA[OutfitData.BLUE_SHAMAN_MAN] = {'name': gls("Жрец"), 'description': gls("<body>Падение метеорита вызвало огромный всплеск волшебной энергии, которая пробудила древних жрецов. Предки современных шаманов были призваны в помощь белочкам в борьбе с ужасными последствиями трагедии.</body>")};
			PACKAGES_DATA[OutfitData.BUMBLEBEE] = {'name': gls("Бамблби"), 'description': gls("<body>По легенде, в далекие-далекие времена на планету белок уже падал метеорит. На месте падения были найдены могущественные костюмы древних героев.</body>")};
			PACKAGES_DATA[OutfitData.CAPITAN_AMERICA] = {'name': gls("Капитан Америка"), 'description': gls("<body>Капитан Америка, как щит, надежно защищает идеалы беличьего народа: честь, равенство и справедливость. Он вселяет веру в сердца белок.</body>")};
			PACKAGES_DATA[OutfitData.CATWOMAN] = {'name': gls("Кошка"), 'description': gls("<body>Полностью собранный костюм Кошки позволяет превращаться в поющего Манэки-нэко за один щелчок хлыста. В комплект входит: маска, леггинсы, водолазка, хлыст и Нэко-тян.</body>")};
			PACKAGES_DATA[OutfitData.CATWOMAN_BATMAN] = {'name': gls("Белочка-Кошка"), 'description': gls("<body>Добро пожаловать в мир хаоса, где выжить смогут только супергерои. Каждая белка мечтает стать великолепной и невероятно ловкой Женщиной-Кошкой.</body>")};
			PACKAGES_DATA[OutfitData.CHAMPION] = {'name': gls("Сноубордист"), 'description': gls("<body>«Быстрее! Выше! Сильнее!» - девиз всех настоящих чемпионов! У каждого чемпиона должна быть подобающая форма.</body>")};
			PACKAGES_DATA[OutfitData.CHESHIRE_CAT] = {'name': gls("Чеширский кот"), 'description': gls("<body>Костюм Чешира позволяет телепортироваться в любое место на карте, оставляя после себя постепенно исчезающую ухмылку.</body>")};
			PACKAGES_DATA[OutfitData.CHRONOS_MAN] = {'name': gls("Хранитель времени"), 'description': gls("<body>Костюм Хранителя времени - это один из самых могущественных костюмов, принадлежащих богам Олимпа. В его владении находится само Время, и он может управлять им по своему усмотрению.</body>")};
			PACKAGES_DATA[OutfitData.COP_MAN] = {'name': gls("Офицер полиции M."), 'description': gls("<body>Служить и защищать! Дуть в свисток и пугать зайцев мигалкой! Разве существует более интересная профессия?</body>")};
			PACKAGES_DATA[OutfitData.CTHULHU_MAN] = {'name': gls("Малыш Ктулху"), 'description': gls("<body>Милые глазки и проворные щупальца — что ещё нужно, чтобы выиграть любое состязание? Никто не сможет устоять перед обаянием этих сорванцов.</body>")};
			PACKAGES_DATA[OutfitData.DEATH] = {'name': gls("Смерть"), 'description': gls("<body>Рано или поздно Смерть приходит в гости к каждой белке, чтобы выпить чай с печеньками, или чтобы забрать еще одну душу...</body>")};
			PACKAGES_DATA[OutfitData.DEER] = {'name': gls("Рудольф"), 'description': gls("<body>Звонкий колокольчик и разноцветная гирлянда - символы новогоднего настроения. Сказочный облик оленёнка Рудольфа, хорошего проводника и незаменимого друга, добавит тепла в холодную зимнюю пору.</body>")};
			PACKAGES_DATA[OutfitData.ELF] = {'name': gls("Эльф"), 'description': gls("<body>Эльфы — очень древний и мудрый народ с богатой историей. Однако до недавних пор белочки считали, что они существуют только в сказках.</body>")};
			PACKAGES_DATA[OutfitData.FAIRY] = {'name': gls("Снежная Фея"), 'description': gls("<body>По взмаху волшебной палочки исполняются любые желания! Костюм Снежной Феи, гостьи ледяных чертогов, таит в себе красоту и обаяние самой хрупкой снежинки.</body>")};
			PACKAGES_DATA[OutfitData.FLASH] = {'name': gls("Флэш"), 'description': gls("<body>Флэш значительно выносливее обычной белки.  Он не только развивает сверхзвуковую скорость, но и отталкивает от себя предметы, пробивая себе путь.</body>")};
			PACKAGES_DATA[OutfitData.FLOWER_SHAMAN] = {'name': gls("Шаманка цветок"), 'description': gls("<body>Некоторые шаманы настолько сильно прониклись природой, что решил пойти по пути прославления жизни и цветов. Белки долгие годы ждали появления этих шаманов. Посмотрим, как они к ним отнесутся.</body>")};
			PACKAGES_DATA[OutfitData.FOOTPAD] = {'name': gls("Гопник"), 'description': gls("<body>Чёткий прикид, для чётких белок. Заряжен чёткой уличной магией!</body>")};
			PACKAGES_DATA[OutfitData.FROST_2014] = {'name': gls("Дедушка Мороз"), 'description': gls("<body>Повелитель зимы и трескучих морозов. Дед Мороз воплощает дух Нового года и распоряжается сказочным волшебством!</body>")};
			PACKAGES_DATA[OutfitData.GREEN_SHAMAN_MAN] = {'name': gls("Жрец"), 'description': gls("<body>Падение метеорита вызвало огромный всплеск волшебной энергии, которая пробудила древних жрецов. Предки современных шаманов были призваны в помощь белочкам в борьбе с ужасными последствиями трагедии.</body>")};
			PACKAGES_DATA[OutfitData.HARLEY_QUINN] = {'name': gls("Харли Квинн"), 'description': gls("<body>Харли Квинн - преданная помощница, напарница и просто хитрая суперзлодейка. Тайно влюблена в Джокера и ненавидит Бэтмена!</body>")};
			PACKAGES_DATA[OutfitData.HATSUNE] = {'name': gls("Мику"), 'description': gls("<body>Весеннее настроение? Душа поёт? Почувствуй себя виртуальной певицей Мику Хацуне! Возведи свою белку на вершину популярности!</body>")};
			PACKAGES_DATA[OutfitData.HATTER] = {'name': gls("Шляпник"), 'description': gls("<body>В таком костюме ты точно не останешься незамеченным! Его яркие и сочные цвета радуют глаз даже самого искушённого ценителя.</body>")};
			PACKAGES_DATA[OutfitData.HIPPIE_MAN] = {'name': gls("Хиппи-мальчик"), 'description': gls("<body>«Всё, что тебе нужно - это любовь!» - заявляют свободолюбивые белочки, называющие себя хиппи. Они ни с кем не воюют, носят бусики и разноцветную одежду и поют песни под гитару.</body>")};
			PACKAGES_DATA[OutfitData.HIPSTER_WOMAN] = {'name': gls("Хипстер-девочка"), 'description': gls("<body>Находя необычное в обыденном, хипстер может превратить самые скучные вещи в неповторимые наряды.</body>")};
			PACKAGES_DATA[OutfitData.HONEY_LEMON_WOMAN] = {'name': gls("Хани Лемон"), 'description': gls("<body>За внешностью модницы стоит целеустремлённая особа, девиз которой: «Невозможное возможно». Похоже, её ничто не остановит на пути к намеченной цели. Хани демонстрирует глубокие знания химии и может сделать любую химическую бомбу.</body>")};
			PACKAGES_DATA[OutfitData.IRBIS] = {'name': gls("Снежный Барс"), 'description': gls("<body>Снежный барс – невероятно красивый и загадочный зверь. Он долгое время скрывался в ущельях снежных хребтов. Но пришло время показать своё могущество и силу.</body>")};
			PACKAGES_DATA[OutfitData.IRONMAN] = {'name': gls("Железная Белка"), 'description': gls("<body>Полностью собранный бронекостюм позволяет превращаться в металлический шар.</body>")};
			PACKAGES_DATA[OutfitData.JOKER] = {'name': gls("Джокер"), 'description': gls("<body>Джокер – суперзлодей, заклятый враг Бэтмена. Его постоянные атрибуты - фиолетовый костюм и хитрая ухмылка на лице.</body>")};
			PACKAGES_DATA[OutfitData.JUGGLER_MAN] = {'name': gls("Фокусник"), 'description': gls("<body>Белочки тоже хотят верить в чудеса! И в этом им помогает иллюзионист, мастер трюков - Фокусник. Подходи ближе и смотри внимательней! Возможно, ты разгадаешь секрет фокуса... А может, это и есть самая настоящая магия.</body>")};
			PACKAGES_DATA[OutfitData.LEGION_RED] = {'name': gls("Легионер"), 'description': gls("<body>Легионер — символ беличьей надежности, непобедимости и дисциплины. Белки знают, что в трудную минуту легионер защитит их. А его самого может защитить только крепкая броня.</body>")};
			PACKAGES_DATA[OutfitData.LEN] = {'name': gls("Лен"), 'description': gls("<body>Весеннее настроение? Душа поёт? Почувствуй себя виртуальным певцом Леном Кагаминэ! Возведи свою белку на вершину популярности!</body>")};
			PACKAGES_DATA[OutfitData.LEPRECHAUN] = {'name': gls("Лепрекон"), 'description': gls("<body>Костюм Лепрекона приносит удачу любому, кто его наденет. Чудесные зелёные оттенки и цветки волшебного клевера, определённо, сделают вас самой привлекательной белкой в игре.</body>")};
			PACKAGES_DATA[OutfitData.LOGAN] = {'name': gls("Росомаха"), 'description': gls("<body>Росомаха (прозвище Логан, настоящее имя Джеймс Хоулетт) - супергерой из команды Людей Х. Его отличительные особенности - высокая способность к регенерации, адамантовый скелет и 6 когтей, острых как бритва.</body>")};
			PACKAGES_DATA[OutfitData.LOKI] = {'name': gls("Локи"), 'description': gls("<body>Локи — сводный брат Тора, бог иллюзий, хитрости и обмана. Он невероятно силён, но предпочитает использовать не физическую силу, а ложь, интриги и магию.</body>")};
			PACKAGES_DATA[OutfitData.MC_TWIST] = {'name': gls("МакТвист"), 'description': gls("<body>Весьма деловой персонаж. Всегда куда-то спешит, хотя его нигде не ждут. Если спросит о некой Алисе, просто делайте вид, что ничего не знаете.</body>")};
			PACKAGES_DATA[OutfitData.MOD] = {'name': gls("Стиляга"), 'description': gls("<body>Черный костюм с небесно-голубыми вставками - высший пилотаж беличьего стиля. Нет лучшего способа выглядеть элегантным, уверенным и независимым Бельчонком.</body>")};
			PACKAGES_DATA[OutfitData.NAPOLEON] = {'name': gls("Наполеон"), 'description': gls("<body>Наполеон — великий полководец и император, кавалер Большого Креста ордена Почётного Легиона.</body>")};
			PACKAGES_DATA[OutfitData.NINJA] = {'name': gls("Ниндзя"), 'description': gls("<body>Говорят, что ниндзя - самые лучшие шпионы - дети тени. Если люди нашли новый способ спастись от астероида, ниндзя обязательно узнают о нем.</body>")};
			PACKAGES_DATA[OutfitData.PARROT_MAN] = {'name': gls("Голубчик"), 'description': gls("<body>Экзотический костюм голубого попугайчика перенесёт вас в атмосферу тропических лесов Бразилии.</body>")};
			PACKAGES_DATA[OutfitData.PARTY] = {'name': gls("Тусовщик"), 'description': gls("<body>Самый стильный костюм сезона! В нём ты будешь в центре внимания в любой компании. Веселье и вечеринки будут следовать за тобой, где бы ты не оказался.</body>")};
			PACKAGES_DATA[OutfitData.PERSIA_MAN] = {'name': gls("Странник Пустыни"), 'description': gls("<body>В сердце Пустыни Странник нашёл ужасное сокровище! Древний Обелиск, забравший частичку беличьей души и засыпавший на её место горячий песок.</body>")};
			PACKAGES_DATA[OutfitData.PHARAON_MAN] = {'name': gls("Белхотеп I"), 'description': gls("<body>Костюм египетского бога, повелителя пустыни и величайшего мудреца Белхотепа I.</body>")};
			PACKAGES_DATA[OutfitData.PHARAON_WOMAN] = {'name': gls("Клеобелла"), 'description': gls("<body>Мечтаешь быть царицей? Воплощение идеальной красоты, невероятного шарма и гордости пустыни в костюме Клеобеллы!</body>")};
			PACKAGES_DATA[OutfitData.PIKACHU] = {'name': gls("Белкачу"), 'description': gls("<body>Белкачу - спокойный и добрый зверёк. Но, если ему будет грозить опасность он немедленно ринется в бой, используя электрические разряды!</body>")};
			PACKAGES_DATA[OutfitData.PIRATE] = {'name': gls("Пират"), 'description': gls("<body>Продавший душу морскому дьяволу, навсегда связан с морем крепкими узами. Под командованием опасного пирата целая армия скелетов. Никому не спастись!</body>")};
			PACKAGES_DATA[OutfitData.PUPIL] = {'name': gls("Школьник"), 'description': gls("<body>Самым умным белкам везёт всегда и во всём! Школьная форма — лучшее доказательство непревзойдённости ваших умений и навыков. В таком наряде успех вам гарантирован.</body>")};
			PACKAGES_DATA[OutfitData.PURPLE_SHAMAN_MAN] = {'name': gls("Жрец"), 'description': gls("<body>Падение метеорита вызвало огромный всплеск волшебной энергии, которая пробудила древних жрецов. Предки современных шаманов были призваны в помощь белочкам в борьбе с ужасными последствиями трагедии.</body>")};
			PACKAGES_DATA[OutfitData.RABBIT] = {'name': gls("Заяц НеСудьбы"), 'description': gls("<body>Заяц НеСудьбы уже давно докучает белкам, каждый день придумывает новые уловки. Пришло время нанести по нему ответный удар: в духе партизан, спецназа и косплея одновременно. Переоденься в зайца, притворись его сородичем, и, возможно, он не будет мешать тебе собирать драгоценные орехи!</body>")};
			PACKAGES_DATA[OutfitData.RAMBO] = {'name': gls("Рэмбо"), 'description': gls("<body>Рэмбо - эксперт по оружию, непобедимый воин. Он мастерски устраивает диверсии и взрывает всё, что может взорваться. Не становись у него на пути!</body>")};
			PACKAGES_DATA[OutfitData.RAFAEL] = {'name': gls("Рафаэль"), 'description': gls("<body>Давным давно маленькая черепашка, воспитанная белкой, испытала на себе действие мутагена и стала юной белкой ниндзей черепашкой. Любит пиццу с орехами. Пиццу. С орехами.</body>")};
			PACKAGES_DATA[OutfitData.SAILORMOON] = {'name': gls("Сейлор Мун"), 'description': gls("<body>Стань Лунной принцессой Сейлор Мун и совершай героические поступки. Этот великолепный костюм не оставит твоих поклонников равнодушными.</body>")};
			PACKAGES_DATA[OutfitData.SAMURAI] = {'name': gls("Самурай"), 'description': gls("<body>Веками Самураи сохраняли традиции доблестных воинов, воплощения силы и красоты.</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_DRAGON] = {'name': gls("Скрэт-Гаргул"), 'description': gls("<body>Гаргульи, как дети, - шаловливые и непоседливые. К сожалению их забавы частенько приводят к сломанным стульям и рассыпанным орехам. Поэтому многие взрослые белки их недолюбливают.</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_HATTER] = {'name': gls("Скрэт-Шляпник"), 'description': gls("<body>Безумный Скрэт? Такого вы ещё не видели! Никто в столь ярком и примечательном костюме не останется незаметным. Сила Шляпника не в магии, а в его непредсказуемости!</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_JUGGLER] = {'name': gls("Скрэт-Фокусник"), 'description': gls("<body>Белочки тоже хотят верить в чудеса! И в этом им помогает иллюзионист, мастер трюков - Фокусник. Подходите ближе и смотрите внимательней! Возможно, ты разгадаешь секрет фокуса... А может, это и есть самая настоящая магия.</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_METAL] = {'name': gls("Железный Скрэт"), 'description': gls("<body>Железный экзоскелет — полезная в хозяйстве вещь. Ведь если ты Скрэт, то ты готов на всё ради орешка. Прочная красно-золотая броня надёжно защитит тебя от падений, непогоды, сглазов и плохого настроения!</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_PERSIA] = {'name': gls("Скрэт-Странник"), 'description': gls("<body>Путешествия и опасности укрепили дух Скрэта-Странника и закалили его тело. В образе Странника Скрэт легко приспосабливается к выживанию в Пустыне и на других локациях!</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_ROBOCOP] = {'name': gls("Скрэт-Робокоп"), 'description': gls("<body>Наполовину Скрэт, наполовину машина. На сто процентов коп. У зла нет шансов! Скрэт-робокоп арестует всех преступников и первым доберётся до ореха.</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_SKELETON] = {'name': gls("Скрэт-Скелет"), 'description': gls("<body>Не всем белкам удаётся чудесно выглядеть, только что встав из могилы. Скрэт-Скелет - счастливое исключение. Но всё же иногда у него вполне получается напугать других белок.</body>")};
			PACKAGES_DATA[OutfitData.SCRAT_VAMPYRE] = {'name': gls("Скрэт-Вампир"), 'description': gls("<body>Держитесь подальше от тех, кто облачён во мрак! Скрэты-Вампиры - древние и опасные существа. Этот костюм мгновенно наводит ужас на смертных белок!</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_DRAGON] = {'name': gls("Скрэтти-Гаргулья"), 'description': gls("<body>Гаргульи, как дети, - шаловливые и непоседливые. К сожалению их забавы частенько приводят к сломанным стульям и рассыпанным орехам. Поэтому многие взрослые белки их недолюбливают.</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_FAIRY] = {'name': gls("Скрэтти-Фея"), 'description': gls("<body>Отправляйся навстречу приключениям и разгадай загадку Солнечной Долины вместе с самым прекрасным и сказочным созданием на свете - Скрэтти-феей.</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_HATTER] = {'name': gls("Скрэтти-Шляпница"), 'description': gls("<body>Безумная Скрэтти? Такого вы ещё не видели! Никто в столь ярком и примечательном костюме не останется незаметным. Сила Шляпницы не в магии, а в её непредсказуемости!</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_JUGGLER] = {'name': gls("Скрэтти-Фокусница"), 'description': gls("<body>Белочки тоже хотят верить в чудеса! И в этом им помогает иллюзионист, мастер трюков - Фокусник. Подходите ближе и смотрите внимательней! Возможно, ты разгадаешь секрет фокуса... А может, это и есть самая настоящая магия.</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_METAL] = {'name': gls("Железная Скрэтти"), 'description': gls("<body>Железный экзоскелет — полезная в хозяйстве вещь. Ведь если ты Скрэтти, то ты готов на всё ради орешка. Прочная красно-золотая броня надёжно защитит тебя от падений, непогоды, сглазов и плохого настроения!</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_PERSIA] = {'name': gls("Скрэтти-Странница"), 'description': gls("<body>Путешествия и опасности укрепили дух Скрэтти-Странницы и закалили её тело. В образе Странницы Скрэтти легко приспосабливается к выживанию в Пустыне и на других локациях!</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_SKELETON] = {'name': gls("Скрэтти-Скелет"), 'description': gls("<body>Не всем белкам удаётся чудесно выглядеть, только что встав из могилы. Скрэтти-Скелет - счастливое исключение. Но всё же иногда у нее вполне получается напугать других белок.</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY_VAMPYRE] = {'name': gls("Скрэтти-Вампир"), 'description': gls("<body>Держитесь подальше от тех, кто облачён во мрак! Скрэтти-Вампиры - древние и опасные существа. Этот костюм мгновенно наводит ужас на смертных белок!</body>")};
			PACKAGES_DATA[OutfitData.SHAMAN_DARK_PINK] = {'name': gls("Повелительница грёз"), 'description': gls("<body>Древнейшие мудрецы видели в грёзах не только мечты, но и истинный путь, который предназначен каждой белке.\nКостюм Повелительницы грёз позволит твоему шаману обратиться к древним духам и украсить карту сказочной анимацией.</body>")};
			PACKAGES_DATA[OutfitData.SHAMAN_DARK_RED] = {'name': gls("Ловец снов"), 'description': gls("<body>Сознание древних духов не знает границ. Ловцы снов способны разгадывать странные видения и открывать новые горизонты.\nКостюм Ловца снов позволит твоему шаману обратиться к древним духам и украсить карту сказочной анимацией.</body>")};
			PACKAGES_DATA[OutfitData.SKELETON] = {'name': gls("Скелет"), 'description': gls("<body>Да, у скелетов нет пушистой шубки. Зато все по достоинству могут оценить их богатый внутренний мир.</body>")};
			PACKAGES_DATA[OutfitData.SNOW_MAIDEN_2014] = {'name': gls("Снегурочка"), 'description': gls("<body>Костюм белокурой красавицы, внучки Деда Мороза, станет отличным нарядом в столь волшебное время года. Роскошный кокошник и волшебный аксессуар сделают белочку самой очаровательной Снегурочкой на планете.</body>")};
			PACKAGES_DATA[OutfitData.SONIC] = {'name': gls("Соник"), 'description': gls("<body>Синий – цвет решительности! Поэтому нет сомнений, что он к лицу этому проворному ёжику.</body>")};
			PACKAGES_DATA[OutfitData.SPARTAN_MAN] = {'name': gls("Спартанец"), 'description': gls("<body>Один в поле не воин. Это знают все истинные Спартанцы. Объединяйтесь и становитесь самыми быстрыми жителями планеты Белок!</body>")};
			PACKAGES_DATA[OutfitData.SPIDER] = {'name': gls("Белка-паук"), 'description': gls("<body>Человек-паук бесстрашно прыгает по крышам небоскребов, всегда готов дать отпор злу и не унывает даже в безвыходных ситуациях. Эти качества и его костюм сделало его таким известным.</body>")};
			PACKAGES_DATA[OutfitData.STORM] = {'name': gls("Импульс"), 'description': gls("<body>Возможности магнетизма не знают границ. Разрушительные и непредсказуемые, они не перестают быть самыми могущественными на планете!</body>")};
			PACKAGES_DATA[OutfitData.SUPERMAN_MAN] = {'name': gls("Белка из стали"), 'description': gls("<body>Пропитанный криптонитом, этот костюм дарует сверхбеличьи способности тому, кто его на себя наденет.</body>")};
			PACKAGES_DATA[OutfitData.SWEET_DEATH] = {'name': gls("Сладкая Смерть"), 'description': gls("<body>Белки с начала времён верят в то, что любовь сильнее Смерти. Интересно, каково это - знать, что она в тебя влюбилась?</body>")};
			PACKAGES_DATA[OutfitData.SWEET_TOOTH] = {'name': gls("Сладкоежка"), 'description': gls("<body>Самая сладкая и экстравагантная - встречайте, гостья с Карамельной Планеты, неподражаемая Сладкоежка. У неё всегда с собой вкусный кекс!</body>")};
			PACKAGES_DATA[OutfitData.TOOTHLESS] = {'name': gls("Беззубик"), 'description': gls("<body>Беззубик — верный друг и самый добрый представитель ночных фурий!</body>")};
			PACKAGES_DATA[OutfitData.TOR] = {'name': gls("Тор"), 'description': gls("<body>Тор — сын бога Одина, самый сильный воин Асгарда. Его реакция такова, что он может следить за объектами летящими быстрее света. Его практически невозможно убить — броня ему нужна, чтобы круто выглядеть.</body>")};
			PACKAGES_DATA[OutfitData.TUXEDOMASK] = {'name': gls("Такседо Маск"), 'description': gls("<body>Костюм таинственного Такседо Маска сделает из любой белочки настоящего джентльмена и борца с несправедливостью.</body>")};
			PACKAGES_DATA[OutfitData.VADER] = {'name': gls("Дарт Сквейдер"), 'description': gls("<body>Дарт Вейдер — в прошлом  жестокий руководитель армии Галактической Империи. В настоящем - верный спутник о добродетель.</body>")};
			PACKAGES_DATA[OutfitData.VAMPIRE] = {'name': gls("Вампир"), 'description': gls("<body>Вампир одет старомодно, но изысканно. Плащ, сотканный из черноты ночи, белоснежная сорочка, красная жилетка из дорогого шёлка, строгие брюки и изящные туфли. Вампир искусно очаровывает белочек, так что его сверкающие клыки почти никто не замечает.</body>")};
			PACKAGES_DATA[OutfitData.VIKING] = {'name': gls("Викинг"), 'description': gls("<body>Викинги – воины особой категории. Могучая сила и помощь Великого Одина снискала им вековую славу.</body>")};
			PACKAGES_DATA[OutfitData.WENDIGO] = {'name': gls("Вендиго"), 'description': gls("<body>Вендиго – прирождённый охотник с удивительными способностями — быстрый и сильный. Если Вендиго начал охоту за вашей коллекцией – вам не скрыться</body>")};
			PACKAGES_DATA[OutfitData.WIZARD_MAN] = {'name': gls("Волшебник"), 'description': gls("<body>Шаманы с помощью древних духов могут материализовать вещи прямо из воздуха, белки могут телепортироваться с помощью волшебства. Но впервые в белках появился мастер тайной магии!</body>")};
			PACKAGES_DATA[OutfitData.WOLF] = {'name': gls("Снежный Волк"), 'description': gls("<body>Снежный Волк из Северного Племени пришёл на помощь белкам.</body>")};
			PACKAGES_DATA[OutfitData.ZOMBIE] = {'name': gls("Зомби"), 'description': gls("<body>«...те, кто однажды уснул вечным сном, вернутся в наш мир и возвестят о [неразборчиво]...» - гласит рукопись святейшего Фундучелли. Большинство современных ученых полагают, что речь идет о крутой тематической вечеринке.</body>")};

			PACKAGES_DATA[OutfitData.ROBOCOP] = {'name': gls("Робокоп"), 'description': gls("<body>Бельчонок встал на путь борьбы за правосудие. Но, как известно, борьба эта - дело опасное. Броня ну просто необходима и ничто не мешает ей быть при этом еще и невероятно стильной. Те из врагов, кто не ослепнет от ее крутости, ничего не увидит из-за дымовой завесы.</body>")};
			PACKAGES_DATA[OutfitData.ALTRONE] = {'name': gls("Альтрон"), 'description': gls("<body>Созданный Тони Сквиком, он же Железная Белка, искусственный разум может летать некоторое время и производить впечатление крайне опасной особы. Но на деле он всего лишь хочет быть полезным.</body>")};
			PACKAGES_DATA[OutfitData.BLACK_BEARD] = {'name': gls("Черная борода"), 'description': gls("<body>Во времена флибустьеров и корсаров ходила легенда об одном пирате, настолько искусном, что казалось, будто само море его породило. И еще у него разряд по плаванию. Брассом. Плавает быстрее любой обычной белки.</body>")};
			PACKAGES_DATA[OutfitData.AMELIA] = {'name': gls("Амелия"), 'description': gls("<body>Привыкшая рассекать на солнечных парусах решительная Амелия никогда не перестает волноваться о своей команде. Даже если речь идет не о корабле, а о раунде в топях, к примеру. Всегда припасенау нее бочка рома, которую юные бельчата, как ни странно, используют, как ящик.</body>")};
			PACKAGES_DATA[OutfitData.THRONE] = {'name': gls("Трон"), 'description': gls("<body>Разорвав цифровое пространство, эта белочка научилась нарушать законы нашего мира. Появившаяся, как программный глюк, она может создавать свою копию, перемещающуюся невероятно быстро, способную забрать орех или коллекцию, а после оказаться там, где и была. Даже наши программисты, не знают, что с ней делать.</body>")};
			PACKAGES_DATA[OutfitData.ZOOM] = {'name': gls("Зум"), 'description': gls("<body>Один из врагов Флэша, Зум способен перемещаться так быстро, что это выглядит будто телепортация вперед. Но, чтобы не упасть за пределы раунда, Зум делает это долю секунды. И это бег. Не телепортация, а бег. Точно-точно.</body>")};
			PACKAGES_DATA[OutfitData.BLACK_CAT] = {'name': gls("Черный кот"), 'description': gls("<body>Жутковатый, но отзывчивый и бесконечно мудрый собрат чеширского кота. Способен выбраться из любой передряги. После телепортации он в течение некоторого времени может вернуться обратно через кроличью нору. Вот только обрадуется ли кролик таким гостям.</body>")};
			PACKAGES_DATA[OutfitData.FAIRY_CAT] = {'name': gls("Сказочный кот"), 'description': gls("<body>Еще один дальний родственник знаменитого кота из Чешира. Чуть какая беда - теряет голову. Точнее остается лишь голова и он может улететь от любой невзгоды, даже если это маленькие дети, норовящие затискать его до одури.</body>")};
			PACKAGES_DATA[OutfitData.MYSTERIO] = {'name': gls("Мистерио"), 'description': gls("<body>Мастер иллюзий, неудавшийся актер, но преуспевающий преступник. Белка-Паук обязательно с ним разберется, но это не к спеху. Ведь максимум, что сделает Мистерио - пустит пыль в глаза. Или дым. Не разглядеть.</body>")};
			PACKAGES_DATA[OutfitData.DORMAMMU] = {'name': gls("Дормамму"), 'description': gls("<body>Загадочный и таинственный гость. Могущественный маг, вселяющий страх в сердца мирных белок. Плюется огнем без стыда и совести, а может чихает. Ну что?! У него вся голова в огне, попробуй, разбери.</body>")};
			PACKAGES_DATA[OutfitData.SCRAT] = {'name': gls("Скрэт"), 'description': gls("<body>Чтобы получить нового персонажа, собери указанную коллекцию. Скрэт умеет переносить орех и излучает любовь с помощью магии.</body>")};
			PACKAGES_DATA[OutfitData.SCRATTY] = {'name': gls("Скрэтти"), 'description': gls("<body>Чтобы получить нового персонажа, собери указанную коллекцию. Скрэтти умеет переносить орех и излучает любовь с помощью магии.</body>")};

			// new year
			PACKAGES_DATA[OutfitData.FAN] = {'name': gls("Фанат игры"), 'description': ""};
			PACKAGES_DATA[OutfitData.CRYSTAL_MAIDEN] = {'name': gls("Повелительница Льда"), 'description': ""};
			PACKAGES_DATA[OutfitData.SANTA_ELF] = {'name': gls("Рождественский Эльф"), 'description': gls("<body>Самый преданный помощник Деда Мороза. Его яркий наряд узнаваем во всех уголках беличьего мира. В таком образе ты точно не останешься без внимания!</body>")};
			PACKAGES_DATA[OutfitData.DOVAHKIIN] = {'name': gls("Довакин"), 'description': gls("<body>Белка с душой дракона. Всем своим внешним видом эта белка показывает мужество и отвагу. Если в твоём сердце нет места для храбрости-этот образ не для тебя.</body>")};
			PACKAGES_DATA[OutfitData.DRAGON_ICE] = {'name': gls("Лазурный дракон"), 'description': gls("<body>Искрящиеся грани этого таинственного образа ослепляют своей красотой и могуществом.</body>")};
			PACKAGES_DATA[OutfitData.LICH_KING] = {'name': gls("Король Лич"), 'description': gls("<body>Единственный обладатель ледяной короны. Этот образ подчеркнёт твоё могущество и покажет всем, кто тут главный!</body>")};

			//st. Valentine
			PACKAGES_DATA[OutfitData.AMUR_MAN] = {'name': gls("Купидон"), 'description': ""};
			PACKAGES_DATA[OutfitData.AMUR_WOMAN] = {'name': gls("Лямури"), 'description': ""};
			PACKAGES_DATA[OutfitData.AMUR_GOLDEN_MAN] = {'name': gls("Золотой Купидон"), 'description': ""};
			PACKAGES_DATA[OutfitData.AMUR_GOLDEN_WOMAN] = {'name': gls("Золотая Лямури"), 'description': ""};

			PACKAGES_DATA[OutfitData.SHAMAN_SPRING] = {'name': gls("Сильван"), 'description': gls("<body>Покровитель лесов. Один из древнейших шаманов планеты белок!</body>")};
			PACKAGES_DATA[OutfitData.DRUID] = {'name': gls("Друид"), 'description': gls("<body>Друид подчиняет себе силы природы, чтобы сберечь себя от опасностей.</body>")};
			PACKAGES_DATA[OutfitData.BEAR] ={'name': gls("Медведь"), 'description': gls("<body>Добрый мишка пробудился после долгой спячки. Он уготовил много подарков для всех бельчат.</body>")};
			PACKAGES_DATA[OutfitData.RAPUNZEL] = {'name': gls("Рапунцель"), 'description': gls("<body>Длинноволосая красавица, которая очаровывает всех своей доброй магией.</body>")};

			PACKAGES_DATA[OutfitData.DEADPOOL] = {'name': gls("Дэдпул"), 'description': gls("Дэдпул — оснащённый по последнему слову техники боец, широко известный среди фанатов своими остротами, «крутостью» и чёрным юмором.")};
			PACKAGES_DATA[OutfitData.BUBBLEGUM] = {'name': gls("Принцесса Бубльгум"), 'description': gls("Принцесса Бубльгум — правительница Империи Сласти. У неё исследовательский характер, и свободное от правления время она посвящает науке. Одно из её лучших изобретений — гарпун-жвачка.")};

			PACKAGES_DATA[OutfitData.SHAMAN_SPRING] = {'name': gls("Сильван"), 'description': gls("Сильван - покровитель лесов. Один из древнейших шаманов планеты белок.")};
			PACKAGES_DATA[OutfitData.RAPUNZEL] = {'name': gls("Рапунцель"), 'description': gls("Рапунцель - длинноволосая красавица, которая очаровывает всех своей доброй магией. ")};
			PACKAGES_DATA[OutfitData.DRUID] = {'name': gls("Друид"), 'description': gls("Друид подчиняет себе силы природы, чтобы сберечь себя от опасностей. ")};
			PACKAGES_DATA[OutfitData.BEAR] = {'name': gls("Медведь"), 'description': gls("Медведь - добрый мишка пробудился после долгой спячки. Он уготовил много подарков для всех бельчат.")};

			PACKAGES_DATA[OutfitData.BLACK_CAT] = {'name': gls("Чёрный кот"), 'description': gls("Тёмная сторона Чеширского кота. Порождение кошмаров и ужасов.")};
			PACKAGES_DATA[OutfitData.FAIRY_CAT] = {'name': gls("Мартовский кот"), 'description': gls("Мартовский кот — самый модный пушистик на планете бельчат. Его роскошная шляпа и превосходная бабочка лишь подтверждают этот факт!")};
			PACKAGES_DATA[OutfitData.EVA] = {'name': gls("Ева"), 'description': gls("")};
			PACKAGES_DATA[OutfitData.STITCH] = {'name': gls("Синий демон"), 'description': gls("Синий демон прибыл на планету белок, чтобы создать хаос! Его мощный лазер беспощадно раскидывает всех белок в округе.")};
			PACKAGES_DATA[OutfitData.FARMER] = {'name': gls("Фермер Боб"), 'description': gls("Белочки решили разнообразить свой рацион и засеять поля разной вкуснятинкой. У фермера есть весь необходимый инструмент, чтобы выполнить эту задачу!")};
			PACKAGES_DATA[OutfitData.HARLOCK] = {'name': gls("Харлок"), 'description': gls("Космический пират Харлок, капитан призрачного корабля. Беглец, готовый сражаться за планету белок.")};
			PACKAGES_DATA[OutfitData.MINION] = {'name': gls("Миньон"), 'description': gls("Любимчик всех белок и любитель бананов!")};

			PACKAGES_DATA[OutfitData.ORC] = {'name': gls("Орк"), 'description': gls("Безжалостный монстр, одержимыми идеей захвата мира.")};
			PACKAGES_DATA[OutfitData.CHAPLIN] = {'name': gls("Чаплин"), 'description': gls("Бродяга и джентльмен, мечтающий о приключениях")};

			ACCESSORY_DATA[OutfitData.ALCHEMIST_HAND] = {'name': gls("Котелок Алхимика")};
			ACCESSORY_DATA[OutfitData.ALCHEMIST_TAIL] = {'name': gls("Склянки Алхимика")};
			ACCESSORY_DATA[OutfitData.BATMAN_CLOAK] = {'name': gls("Плащ Бэтмена")};
			ACCESSORY_DATA[OutfitData.BATMAN_TAIL] = {'name': gls("Знак Бэтмена")};
			ACCESSORY_DATA[OutfitData.CAPTAIN_AMERICA_SHIELD] = {'name': gls("Щит из вибрания")};
			ACCESSORY_DATA[OutfitData.CAT_HANDS] = {'name': gls("Гарпун")};
			ACCESSORY_DATA[OutfitData.CAT_WOMEN_TAIL] = {'name': gls("Нэко-тян")};
			ACCESSORY_DATA[OutfitData.CAT_WOMEN_WHIP] = {'name': gls("Хлыст")};
			ACCESSORY_DATA[OutfitData.CHAMPION_NECK] = {'name': gls("Шарф Сноубордиста")};
			ACCESSORY_DATA[OutfitData.CHAMPION_TAIL] = {'name': gls("Сноуборд")};
			ACCESSORY_DATA[OutfitData.CHRONOS_TAIL] = {'name': gls("Сфера Времени")};
			ACCESSORY_DATA[OutfitData.CUBE] = {'name': gls("Трансформ-куб")};
			ACCESSORY_DATA[OutfitData.CUTE_RABBIT_CARROT] = {'name': gls("Морковка")};
			ACCESSORY_DATA[OutfitData.DEER_NECK] = {'name': gls("Новогодний колокольчик")};

			ACCESSORY_DATA[OutfitData.DISC] = {'name': gls("Аксессуар для тусовок")};
			ACCESSORY_DATA[OutfitData.ELF_SWORD] = {'name': gls("Эльфийский Талисман")};
			ACCESSORY_DATA[OutfitData.FAIRY_STUFF] = {'name': gls("Волшебная палочка")};
			ACCESSORY_DATA[OutfitData.FAIRY_TAIL] = {'name': gls("Снежинка")};
			ACCESSORY_DATA[OutfitData.FAIRY_WINGS] = {'name': gls("Крылья Снежной Феи")};
			ACCESSORY_DATA[OutfitData.HIPSTER_WOMAN_GLASSES] = {'name': gls("Очки хипстера")};
			ACCESSORY_DATA[OutfitData.ILLUSIONIST_MAN_TAIL] = {'name': gls("Карта Фокусника")};
			ACCESSORY_DATA[OutfitData.IRON_MAN_TAIL] = {'name': gls("Энергоячейка")};
			ACCESSORY_DATA[OutfitData.LEGION_KNIFE] = {'name': gls("Копье легионера")};
			ACCESSORY_DATA[OutfitData.LEPRECHAUN_HAND] = {'name': gls("Мешок с золотом")};
			ACCESSORY_DATA[OutfitData.LEPRECHAUN_TAIL] = {'name': gls("Монетка на хвост")};
			ACCESSORY_DATA[OutfitData.LOKI_HAND] = {'name': gls("Посох Локи")};
			ACCESSORY_DATA[OutfitData.NAPOLEON_SWORD] = {'name': gls("Рапира Наполеона")};
			ACCESSORY_DATA[OutfitData.NAPOLEON_TAIL] = {'name': gls("Медаль Наполеона")};
			ACCESSORY_DATA[OutfitData.NEW_YEAR_STUFF] = {'name': gls("Волшебный посох")};
			ACCESSORY_DATA[OutfitData.NEW_YEAR_TAIL] = {'name': gls("Мешочек с подарками")};
			ACCESSORY_DATA[OutfitData.NINJA_SWORD] = {'name': gls("Меч Ниндзя")};
			ACCESSORY_DATA[OutfitData.NINJA_TAIL] = {'name': gls("Сюрикен на хвост")};
			ACCESSORY_DATA[OutfitData.PENDANT_HIPPIE] = {'name': gls("Подвеска Хиппи")};
			ACCESSORY_DATA[OutfitData.PERSIAN_SWORD] = {'name': gls("Меч Джинна")};
			ACCESSORY_DATA[OutfitData.PERSIAN_TAIL] = {'name': gls("Амулет из песка")};
			ACCESSORY_DATA[OutfitData.PHARAON_MAN_HANDS] = {'name': gls("Жезл Белхотепа I")};
			ACCESSORY_DATA[OutfitData.PHARAON_MAN_TAIL] = {'name': gls("Ключ жизни")};
			ACCESSORY_DATA[OutfitData.PHARAON_WOMAN_HANDS] = {'name': gls("Веер Клеобеллы")};
			ACCESSORY_DATA[OutfitData.PHARAON_WOMAN_TAIL] = {'name': gls("Око Ра")};
			ACCESSORY_DATA[OutfitData.PIRATE_TAIL] = {'name': gls("Амулет Пирата")};
			ACCESSORY_DATA[OutfitData.POLICE_TAIL] = {'name': gls("Наручники на хвост")};
			ACCESSORY_DATA[OutfitData.RAMBO_GRENADE] = {'name': gls("Граната Рэмбо")};
			ACCESSORY_DATA[OutfitData.RAMBO_GUN] = {'name': gls("Пулемёт Рэмбо")};
			ACCESSORY_DATA[OutfitData.RIO_MAN_NECK] = {'name': gls("Шарф Голубчика")};
			ACCESSORY_DATA[OutfitData.RIO_MAN_TAIL] = {'name': gls("Подвеска Рио")};
			ACCESSORY_DATA[OutfitData.SAILOR_MOON_TAIL] = {'name': gls("Талисман Сейлор Мун")};
			ACCESSORY_DATA[OutfitData.SAILOR_MOON_WAND] = {'name': gls("Лунный Жезл")};
			ACCESSORY_DATA[OutfitData.SAILOR_MOON_WINGS] = {'name': gls("Крылья Сейлор Мун")};
			ACCESSORY_DATA[OutfitData.SAMURAI_TAIL] = {'name': gls("Нунчаки Самурая")};
			ACCESSORY_DATA[OutfitData.SNOW_MAIDEN_TAIL] = {'name': gls("Ледяное сердце")};
			ACCESSORY_DATA[OutfitData.SPIDER_TAIL] = {'name': gls("Паук на хвост")};
			ACCESSORY_DATA[OutfitData.STICK] = {'name': gls("Трость для тусовок")};
			ACCESSORY_DATA[OutfitData.STORM_GLASSES] = {'name': gls("Очки Импульса")};
			ACCESSORY_DATA[OutfitData.TOR_HAMMER] = {'name': gls("Мьёльнир")};
			ACCESSORY_DATA[OutfitData.TUXEDO_MASK_HAND] = {'name': gls("Трость Такседо Маска")};
			ACCESSORY_DATA[OutfitData.VADER_COAT] = {'name': gls("Плащ Дарта Вейдера")};
			ACCESSORY_DATA[OutfitData.VADER_SWORD] = {'name': gls("Световой меч")};
			ACCESSORY_DATA[OutfitData.VAMPIRE_TAIL] = {'name': gls("Вампирский знак")};
			ACCESSORY_DATA[OutfitData.VAMPIRE_CLOAK] = {'name': gls("Плащ Вампира")};
			ACCESSORY_DATA[OutfitData.VENDIGO_TAIL] = {'name': gls("Клык Вендиго")};
			ACCESSORY_DATA[OutfitData.VIKING_HANDS] = {'name': gls("Оружие Викинга")};
			ACCESSORY_DATA[OutfitData.VIKING_TAIL] = {'name': gls("Щит Викинга")};
			ACCESSORY_DATA[OutfitData.WAND] = {'name': gls("Волшебная палочка")};
			ACCESSORY_DATA[OutfitData.WIZARD_TAIL] = {'name': gls("Чехол для палочки")};
			ACCESSORY_DATA[OutfitData.WOLF_STAFF] = {'name': gls("Посох Волка")};
			ACCESSORY_DATA[OutfitData.WOLF_TAIL] = {'name': gls("Ловец снов")};

			ACCESSORY_DATA[OutfitData.TIN] = {'name': gls("Жестяные банки")};
			ACCESSORY_DATA[OutfitData.LEGO_SMALL] = {'name': gls("Красный блок")};
			ACCESSORY_DATA[OutfitData.BIG_LEGO] = {'name': gls("Мегаблок")};
			ACCESSORY_DATA[OutfitData.PUPIL_NECK] = {'name': gls("Школьный галстук")};
			ACCESSORY_DATA[OutfitData.PUPIL_TAIL] = {'name': gls("Школьный портфель")};
			ACCESSORY_DATA[OutfitData.PUPIL_GLASS] = {'name': gls("Очки для занятий")};
			ACCESSORY_DATA[OutfitData.ICE_SHARD] = {'name': gls("Осколок Льда")};
			ACCESSORY_DATA[OutfitData.OLYMPUS_TORCH] = {'name': gls("Олимпийский факел")};
			ACCESSORY_DATA[OutfitData.EASTER_BASKET] = {'name': gls("Пасхальная корзинка")};
			ACCESSORY_DATA[OutfitData.MEDAL_GOLD] = {'name': gls("Олимпийская медаль")};
			ACCESSORY_DATA[OutfitData.EASTER_STAR] = {'name': gls("Пасхальная звезда")};
			ACCESSORY_DATA[OutfitData.MAY_RIBBON] = {'name': gls("Георгиевская ленточка")};
			ACCESSORY_DATA[OutfitData.HARD_SWEET] = {'name': gls("Чупа-Чупс")};
			ACCESSORY_DATA[OutfitData.MAD_GLASSES] = {'name': gls("Очки учёного")};
			ACCESSORY_DATA[OutfitData.PUMPKIN_HAND] = {'name': gls("Зловещая тыква")};
			ACCESSORY_DATA[OutfitData.SHADOW_CLOAK] = {'name': gls("Загадочный плащ")};
			ACCESSORY_DATA[OutfitData.SKULL_NECK] = {'name': gls("Амулет «Череп»")};
			ACCESSORY_DATA[OutfitData.SPIDER_HALLOWEEN_TAIL] = {'name': gls("Паук")};
			ACCESSORY_DATA[OutfitData.OLYMPIC_MEDAL] = {'name': gls("Медаль чемпиона")};

			ACCESSORY_DATA[OutfitData.HIPSTER_MAN_GLASSES] = {'name': gls("Очки хипстера")};
			ACCESSORY_DATA[OutfitData.THUNDER_GLASSES] = {'name': gls("Очки Импульса")};
			ACCESSORY_DATA[OutfitData.ASSASSIN_DAGGER] = {'name': gls("Кинжал Ассассина")};
			ACCESSORY_DATA[OutfitData.SPARTAN_SWORD] = {'name': gls("Оружие спартанца")};
			ACCESSORY_DATA[OutfitData.XMAS_MAN_STAFF] = {'name': gls("Новогодний посох")};
			ACCESSORY_DATA[OutfitData.ASSASSIN_TAIL] = {'name': gls("Сфера Ассассина")};
			ACCESSORY_DATA[OutfitData.ILLUSIONIST_WOMAN_TAIL] = {'name': gls("Карта Фокусника")};
			ACCESSORY_DATA[OutfitData.OLYMPUS_TAIL] = {'name': gls("Олимпийская медаль")};
			ACCESSORY_DATA[OutfitData.SUPERMAN_TAIL] = {'name': gls("Знак Супер-Белки")};
			ACCESSORY_DATA[OutfitData.SWEET_TEETH_TAIL] = {'name': gls("Леденец")};
			ACCESSORY_DATA[OutfitData.XMAS_GIRL_TAIL] = {'name': gls("Сказочная снежинка")};
			ACCESSORY_DATA[OutfitData.RIO_GIRL_NECK] = {'name': gls("Цветок")};

			ACCESSORY_DATA[OutfitData.CRYSTAL_MAIDEN_HANDS] = {'name': gls("Морозный посох ")};
			ACCESSORY_DATA[OutfitData.CRYSTAL_MAIDEN_CLOAK] = {'name': gls("Морозный плащ")};
			ACCESSORY_DATA[OutfitData.SANTA_ELF_TAIL] = {'name': gls("Носок на хвост")};
			ACCESSORY_DATA[OutfitData.LICH_KING_CLOAK] = {'name': gls("Мантия смерти")};
			ACCESSORY_DATA[OutfitData.LICH_KING_NECK] = {'name': gls("Наплечи смерти")};
			ACCESSORY_DATA[OutfitData.LICH_KING_HANDS] = {'name': gls("Ледяная скорбь")};
			ACCESSORY_DATA[OutfitData.DOVAHKIIN_HANDS] = {'name': gls("Булава дракона")};

			ACCESSORY_DATA[OutfitData.OLYMPIC_TORCH] = {'name': gls("Олимпийский факел")};
			ACCESSORY_DATA[OutfitData.NEW_YEAR_ACCESSORY] = {'name': gls("Новогодний амулет")};

			ACCESSORY_DATA[OutfitData.RAFAEL_HANDS] = {'name': gls("Сай")};
			ACCESSORY_DATA[OutfitData.MC_TWIST_TAIL] = {'name': gls("Хвостовые часы")};

			ACCESSORY_DATA[OutfitData.AMUR_TAIL] = {'name': gls("Фенечка Любви")};
			ACCESSORY_DATA[OutfitData.AMUR_HANDS] = {'name': gls("Лук Судьбы")};
			ACCESSORY_DATA[OutfitData.AMUR_MAN_CLOAK] = {'name': gls("Крылья Счастья")};
			ACCESSORY_DATA[OutfitData.AMUR_WOMAN_CLOAK] = {'name': gls("Крылья Радости")};
			ACCESSORY_DATA[OutfitData.AMUR_GOLDEN_CLOAK] = {'name': gls("Крылья Вдохновения")};
			ACCESSORY_DATA[OutfitData.AMUR_HAIRBAND] = {'name': gls("Шапочка Посланника")};

			ACCESSORY_DATA[OutfitData.DEADPOOL_CLOAK] = {'name': gls("Меч Дедпула")};
			ACCESSORY_DATA[OutfitData.DEADPOOL_HANDS] = {'name': gls("Оружие Дедпула")};

			ACCESSORY_DATA[OutfitData.RAPUNZEL_HANDS] = {'name': gls("Сковорода")};
			ACCESSORY_DATA[OutfitData.RAPUNZEL_HAIRBAND] = {'name': gls("Диадема Рапунцель")};
			ACCESSORY_DATA[OutfitData.RAPUNZEL_TAIL] = {'name': gls("Хамелеон Паскаль")};

			ACCESSORY_DATA[OutfitData.DRUID_HANDS] = {'name': gls("Посох Друида")};
			ACCESSORY_DATA[OutfitData.DRUID_CLOAK] = {'name': gls("Знамя Друида")};
			ACCESSORY_DATA[OutfitData.DRUID_TAIL] = {'name': gls("Лиана Друида")};

			ACCESSORY_DATA[OutfitData.BEAR_HANDS] = {'name': gls("Мишкина ложка")};
			ACCESSORY_DATA[OutfitData.BEAR_NECK] = {'name': gls("Бандана")};
			ACCESSORY_DATA[OutfitData.BEAR_CLOAK] = {'name': gls("Мишкин мешочек")};

			ACCESSORY_DATA[OutfitData.SPRING_HAIRBAND] = {'name': gls("Цветочный венок")};
			ACCESSORY_DATA[OutfitData.SPRING_MAN_GLASSES] = {'name': gls("Турбо-очки")};
			ACCESSORY_DATA[OutfitData.SPRING_WOMAN_GLASSES] = {'name': gls("Пчёлкины очки")};

			ACCESSORY_DATA[OutfitData.ROCK_WINGS] = {'name': gls("Крылья Рока")};
			ACCESSORY_DATA[OutfitData.ROCK_GLASSES] = {'name': gls("Очки Рока")};
			ACCESSORY_DATA[OutfitData.ROCK_GUITAR] = {'name': gls("Гитара Рока")};
			ACCESSORY_DATA[OutfitData.ROCK_TAIL] = {'name': gls("Талисман Рока")};
			ACCESSORY_DATA[OutfitData.ROCK_HAIRBAND] = {'name': gls("Бандана Рока")};

			ACCESSORY_DATA[OutfitData.FARMER_HANDS] = {'name': gls("Вилы")};
			ACCESSORY_DATA[OutfitData.FARMER_TAIL] = {'name': gls("Ведро")};
			ACCESSORY_DATA[OutfitData.FARMER_HAIR] = {'name': gls("Борода")};
			ACCESSORY_DATA[OutfitData.HARLOCK_CLOAK] = {'name': gls("Плащ пирата")};
			ACCESSORY_DATA[OutfitData.HARLOCK_HANDS] = {'name': gls("Бластер")};
			ACCESSORY_DATA[OutfitData.HARLOCK_TAIL] = {'name': gls("Цепь")};
			ACCESSORY_DATA[OutfitData.MINION_GLASSES] = {'name': gls("Очки Миньона")};
			ACCESSORY_DATA[OutfitData.MINION_HANDS] = {'name': gls("Укулеле")};
			ACCESSORY_DATA[OutfitData.MINION_TAIL] = {'name': gls("Банана!")};
			ACCESSORY_DATA[OutfitData.FAIRY_CAT_NECK] = {'name': gls("Бант")};
			ACCESSORY_DATA[OutfitData.FAIRY_CAT_HAIRBAND] = {'name': gls("Шляпка")};
			ACCESSORY_DATA[OutfitData.FAIRY_CAT_TAIL] = {'name': gls("Чашка на хвост")};

			ACCESSORY_DATA[OutfitData.ELECTRO_CLOAK] = {'name': gls("Плащ Теслы")};
			ACCESSORY_DATA[OutfitData.ELECTRO_GLASSES] = {'name': gls("Защитные очки Теслы")};
			ACCESSORY_DATA[OutfitData.ELECTRO_TAIL] = {'name': gls("Магнитное кольцо")};
			ACCESSORY_DATA[OutfitData.ELECTRO_HAIRBAND] = {'name': gls("Наушники Теслы")};

			ACCESSORY_DATA[OutfitData.SOLDIER_HAIRBAND] = {'name': gls("Каска Ветерана")};

			ACCESSORY_DATA[OutfitData.FAIRY_CAT_TAIL] = {'name': gls("Чашка на хвост")};

			ACCESSORY_DATA[OutfitData.ORC_HANDS] = {'name': gls("Топор орка")};
			ACCESSORY_DATA[OutfitData.ORC_NECK] = {'name': gls("Наплечник орка")};
			ACCESSORY_DATA[OutfitData.ORC_TAIL] = {'name': gls("Клык орка")};

			ACCESSORY_DATA[OutfitData.CHAPLIN_HAIRBAND] = {'name': gls("Усы Чаплина")};
			ACCESSORY_DATA[OutfitData.CHAPLIN_HANDS] = {'name': gls("Трость Чаплина")};

			ACCESSORY_DATA[OutfitData.SUMMER_HAIRBAND] = {'name': gls("Кепка моряка")};
			ACCESSORY_DATA[OutfitData.SUMMER_HANDS] = {'name': gls("Пляжный зонт")};
			ACCESSORY_DATA[OutfitData.SUMMER_NECK] = {'name': gls("Надувная уточка")};
			ACCESSORY_DATA[OutfitData.SUMMER_TAIL] = {'name': gls("Якорь")};

			ACCESSORY_DATA[OutfitData.FRUIT_GLASSES] = {'name': gls("Фруктовые очки")};
			ACCESSORY_DATA[OutfitData.FRUIT_HANDS] = {'name': gls("Смузи")};
			ACCESSORY_DATA[OutfitData.FRUIT_NECK] = {'name': gls("Фруктовое ожерелье")};
			ACCESSORY_DATA[OutfitData.FRUIT_TAIL] = {'name': gls("Арбуз на хвост")};
			ACCESSORY_DATA[OutfitData.FRUIT_HAIRBAND] = {'name': gls("Яблоко на голову")};

			ACCESSORY_DATA[OutfitData.AQUA_CLOAK] = {'name': gls("Акваланг")};
			ACCESSORY_DATA[OutfitData.AQUA_GLASSES] = {'name': gls("Подводные очки")};
			ACCESSORY_DATA[OutfitData.AQUA_HANDS] = {'name': gls("Аквариум")};
			ACCESSORY_DATA[OutfitData.AQUA_TAIL] = {'name': gls("Ракушка")};

			ACCESSORY_DATA[OutfitData.SCHOOL_BACK] = {'name': gls("Портфель ученика")};
			ACCESSORY_DATA[OutfitData.SCHOOL_GLASSES] = {'name': gls("Очки")};
			ACCESSORY_DATA[OutfitData.SCHOOL_HANDS] = {'name': gls("Букет")};
			ACCESSORY_DATA[OutfitData.SCHOOL_TAIL] = {'name': gls("Звонок")};
		}

		static public function getPreview(id:int):String
		{
			return  String(GameConfig.getPackageSkills(id)[0]);
		}

		static public function getTitleById(id:int):String
		{
			var item:Object = ACCESSORY_DATA[id];
			return item != null && 'name' in item ? item['name'] : "";
		}

		static public function getPackageDescriptionById(id:int):String
		{
			var item:Object = PACKAGES_DATA[id];
			return item != null && 'description' in item ? item['description'] : "";
		}

		static public function getPackageTitleById(id:int):String
		{
			var item:Object = PACKAGES_DATA[id];
			return item != null && 'name' in item ? item['name'] : "";
		}
	}
}