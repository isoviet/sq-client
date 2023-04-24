﻿package
{
	import utils.StringUtil;

	public class WordFilter
	{

		static private const BAD_PATTERNS:Object = {
			"ru": [

			//основные
			".*ху(й|и|я|е|ли|ле).*", ".*пи(з|с)д.*", ".*бля(д|т|ц).*", "(с|сц)ук(а|о|и).*",
			".*уеб.*", "заеб.*", ".*пид(о|е|а)р.*",
			"г(а|о)ндон.*", ".*залуп.*", "ебите",
			//дополнительные
			"тупорыл", "жопой",
			"долбаеб", "сучары", "сучара", "ебат",
			"бля[тд]ь", "бл[ие]а[тд]ь", "блядин[аы]", "[б6]ля", "бульбаш","сученыш",
			"выбл[яе]док", "выкидыш","вагинальный червь", "вагина",
			"г[ао][вм]но", "г[ао][вм]н[ао][её]б", "гнид[аы]","гнид(а)",
			"д[еи]бил", "д[еи]рьмо", "д[ие]г[ие]н[ие]рат", "дрочил[оа]", "подрочи","дрочиил[ао]",
			"[её]бырь", "ебантяй", "ебл?ан", "ебись", "ебучий", "[её]банн?ый", "ебать", "ебал", "ебанутый",
			"ебля", "епал", "ебалай", "ебалайка", "епать", "еб[оа]тня",
			"жопа", "жопень","жидовка", "жид", "жопошник", "жополиз",
			"з[оа]лупа", "залупанец", "залупа",
			"курва", "фак", "потрахаться", "трахаться", "потрахайся", "трахни", "трахайся",
			"идиот", "идеот",
			"л[о0]х", "л[оа]шара",
			"мудак", "мудила", "мудо[её]б", "манда", "масть", "мамко[её]б", "м[оа]скаль", "мамк[ау]",
			"мразиш", "мразюка",
			"охуел(а)",
			"п[ие]д[аео]р(ас)?", "п[еи]дрила", "п[еи]здопро[её]бище", "п[еи]зда", "пидр", "п[еи][сз][тд]ец",
			"пр[ие]дурок", "пр[ао]ститутка", "петух", "падлюка", "падонки", "подонок",
			"пиздолиз", "п[ие]зденыш", "п[ие]довка", "педик", "педрил[ао]",
			"нигер", "[ао]н[оа]нист",
			"су[уч4]ка", "суч[её]нок", "су[ч4]ара", "[цс]ук[аи]", "сцук[иа]", "ск[ао]т[ао]база","свино[её]б",
			"соси", "секс", "срак[ау]",
			"тупица", "тварь", "тварина", "трахни", "член[оа]сос", "чурка",
			"уебашка", "уебатор", "у[её]бище", "у[её]ба", "у[её]бан", "ушлюханка", "ушлюхан", "укроп",
			"ху[ий]ло", "хуйня", "херня", "хули", "хуй", "ху[ея]путало", "хуерыга", "хохол",
			"шлюшка", "шлюх",
			"fuck", "4мо", "чмо", "чмарь",

			"впизду",
			"нахуй", "нахер","нед[оа]носок",
			"похуй"],

			"en": [
			"c *u *n *t", "hooker", "pimp",
			"bastard", "vile", "ugly", "shitass", "simpleton", "loser", "asshole", "assfool", "gooner", "sissy",
			"depraved", "b *i *t *c *h", "whoremonger", "slut",
			"crud", "boobs", "tits", "knockers", "nay[ -]nay","naynay", "whore", "pussy",
			"nerd", "crap", "queer", "geek", "bollocks",
			"fagg?ot", "quee?r", "faggy", "fag",
			"motherfucker", "balls", "a *s *s",
			"fu[ck][ck]er", "fu[ck][ck]ing", "f *u *[ck] *[ck]",
			"boomboom", "butts", "buttocks", "bullshit","boongies",
			"cосk", "knob", "s *u *[ck] *[ck]",
			"damn", "d *i *[ck] *[ck]", "su[ck][ck]er", "jerk",
			"wtf", "stfu", "i *d *i *o *t",
			"pissflaps", "piss", "c *r *e *t *i *n",
			"scheiss?e", "shit", "r *e *t *a *r *d",
			"rubber", "condom", "c *o *c *k",
			"stupid", "dunce", "cherry", "crabby", "cunt", "clad",
			"masturbator", "pricktease",
			"fool", "knut", "bananas ?truck", "bonehead",
			"slea[sz]e[ -]ball", "bang", "blow[ -]job", "blowjob",
			"bong", "bump", "hump", "bonk",
			"bush", "butch", "j[ae]ck off",
			"button one'?s lip", "call ?girl", "carry away", "jailbait", "pubic ?hair", "cunt ?chaser", "hotel ?hosty", "acid ?head", "choke ?chicken", "choke the chicken"

	]};

		static private const GOOD_PATTERNS:Object = {
			"ru":[
			"ожидать", "ожидание", "ожидаю", "жидкость",
			"(херсон|штрихуй|скипидар|гребущий|загребущий|отгребу|скребущий|перебинтованный|перебинтовать" +
			"|перебинтоваться|перебинтовывание|перебинтовывать|перебинтовываться|плебисцит|плебисцитарный" +
			"|плебисцитный|по-ястребиному|погребица|погребицкий|погребище|хлебина|ястребинка|ястребиные" +
			"|ястребица|автоколебания|алебастр|алебастровый|выгребание|выскребание|выхлебанный|загребание" +
			"|икебана|калебас|калебасовый|колебание|колебания|кочебас|кулебасить|нагребание|небанальность|" +
			"небанальный|отгребание|отскребание|перебанить|подгребание|подскребание|пригребание|прогребание|проскребание" +
			"|разгребание|сан-себастьян|сгребание|себастры|себастьян|скребануть|соскребание|стебанутый" +
			"|стебануть|хлебание|хлебануть|хлебанье|чебан|чебанить|эстебан|аблятив|абляционный|абляция" +
			"|блябла|блягирь|блязик|блямба|бляха|бляхин|бляшки|вглубляться|влюблять|влюбляться|воглубляться" +
			"|возлюблять|выдублять|вызноблять|выскоблять|выщерблять|выщербляться|заглублять|заглубляться" +
			"|заграблять|загублять|задублять|зазноблять|залюблять|зарыблять|зарыбляться|заскоблять" +
			"|злоупотреблять|изгублять|издроблять|издробляться|издыблять|иззноблять|излюблять|истреблять" +
			"|истребляться|нагорблять|надублять|надубляться|наздоблять|наслаблять|обособлять|обособляться" +
			"|ограблять|ограбляться|огрублять|огрубляться|озлоблять|озлобляться|озноблять|ознобляться|" +
			"осклаблять|осклабляться|оскорблять|оскорбляться|ослаблять|ослабляться|оснадоблять|отреблять|" +
			"отщерблять|передроблять|передробляться|погублять|подсоблять|позноблять|послаблять|пособлять|" +
			"потреблять|потребляться|приглублять|приглубляться|приослаблять|присоблять|приспособлять|" +
			"приспособляться|приусугублять|проглублять|прогублять|продублять|прослаблять|разграблять|" +
			"разграбляться|раздроблять|раздробляться|разлюблять|разлюбляться|расподобляться|расслаблять" +
			"|расслабляться|сгублять|сдобляться|сдроблять|слюбляться|снадоблять|содроблять|сподоблять|" +
			"сподобляться|способляться|стребляти|углублять|углубляться|угрублять|уподоблять|уподобляться|" +
			"употреблять|употребляться|усклаблятися|ускорблять|успособлять|устрабляти|усугублять|" +
			"усугубляться|ущерблять|ущербляться|неплохой|неплохо|блоха|сосиска|факел|плохо|неплохая|плохая)", "*.факт.*", "сукно", "фактически", "факт", "факты",
			"((за)|(под))?страхуй(те)?","(за)?штрихуй(те)?","^(анти|пере)?бан(а|е|я|у)*", "степан(дос(а|у)?)?",
			"(не)?(\s)*бан([ияю]т?(ся?)|(ь)?те)", "(не)?психуй(те)?", "^колебани(я|е|ю|й)", "((полу)?са|[оа]гло|гре|к[оа]ра|ру|сте|ансам)бля(ми)?",
			"бля(ха|шка)", "([оа]сл[оа]|[оа]ск[оа]р|п[оа]дс[ао]|п[оа]с(л)?[оа]|п[оа]тр[еи]|углу|(пр[еи])?усугу|разгра|рас(с)?ла|пр[еи]сп[оа]с[оа]|уп[оа]д[оа]|употре|истр[еи]|влю|зл[оа]уп[оа]тр[еи]|[оа]б[оа]с[оа]|[оа]зл[оа])бля(л|ть|е([шщ][ьъ]?|т(е)?|м(ое|ая)?)|ю|й|ют([ьъ])?(ся)?)",
			 "барсук(и|а|ов)?", "астрахан(ь|ск(ий|ого)|и)", "(за)?страх(а|и|ов(о(й)?|ые|ая|ка|ать|[оа]н(н)?(ая|а|ы(е|й)?)?))?", "хулиган(ит(ь)?|ск(ий|ая|ое|ие)ств(о(вать)?|а)|ь[её])?",
			"(хл|угр|соскр|сгр|(ра(з|с)|пр(и|о)|от|под|по|на|пере|до|вз)?гр|(по)?кол|захл|ск|изг)(е|и)бать",
			"(по)?залупля(ть|л(а|и)?|ют|ем|й(те)?","гр(е|ё)бан(н)?(ый|ая|(о|ы)е)", "(за|от|в|на|при)липать", "гепатит(а|у|ов|ик)?",
			"termin(ator(a|s)?)?", "фламанд|ком(м)?анд|саламандр|com(m)?ando|мандат|норманд|мандрагор|МАНДЕЛЬШТАМ|МАНДАРИН|КАТМАНДУ|mander",
			"телепат(ия)?", "трепа(ния|т)", "н(и|е)п(о|а)нятн(о|а)", "(мн|теб|т)е[\s]+бан","Аманда", "д(е|и)р(е|и)жабля",
			"сно(к|г)(с)?ш(е|и)бат(е|и)льн(н)?(о|ый|ая|ое)", "((кило|санти|деци|мили)?ме|к(и|е)н(о|а)т(е|и)а)трах",
			"трахе(я|ю|ей|И)", "ошиба(т|й)", "((о|а)т|у)?(ш|щ)л(е|ё)па(й|т|н)", "ск(и|е)пид(а|о)р", "не(\s)*патриотичн",
			"^потреп(п)?аться", "^бан", "дебат(ы|ов|ами)", "н(е|и)п(о|а)луч(и|е)т", "кордебалет", "(г)?ипот(аксис|аламус|еза|ензив|енуз|ерм|ерио|оничес|ония|ека)",
			"слепой", "(н(а)?|пр)(и|е)б(о|а)л(ьш|е)", "н(е|и)(\s)*пон(я|И)", "муниципал", "перепонк",
			"неплох", "ошиблась", "т(е|ё)пл", "закипал", "не(\s)*пал", "Не(\s)*благодар", "не(\s)*балуй",
			"перепись", "не(\s)*понтуйся", ".*психу.*", ".*к(о|а)манд.*", ".*истр(е|и)блять.*", ".*л(о|а)х(о|а)трон.*", ".*(о|а)ск(о|а)рблять.*", "хул(е|и)ган", ".*м(а|о)нд(а|о)рин.*",
				".*р(а|о)ссл(а|о)блять.*", ".*п(о|а)тр(е|и)блять.*"
			], "en":[]};

		static private const CONVERT:Object = {
		/*	"a": "а",
			"b": "в",
			"c": "с",
			"e": "е",
			"f": "ф",
			"g": "д",
			"h": "н",
			"i": "и",
			"k": "к",
			"l": "л",
			"m": "м",
			"n": "н",
			"o": "о",
			"p": "р",
			"r": "р",
			"s": "с",
			"t": "т",
			"u": "у",
			"v": "в",
			"x": "х",
			"y": "у",
			"w": "ш",
			"z": "з",
			"6": "б",
			"0": "о"*/
		};

		static private const DELIMETERS:String = "[^а-яА-ЯёЁa-zA-Z0-9]*";

		static private var expressions:Array = [];
		static private var exception:Array = [];

		static public function init():void
		{
			for each (var word:String in BAD_PATTERNS[Config.LOCALE])
				WordFilter.expressions.push(compile(word));
			for each (word in GOOD_PATTERNS[Config.LOCALE])
				WordFilter.exception.push(compile(word));
		}

		static public function filter(str:String):String
		{
			var words:Array = str.split(" ");
			str = "";
			for (var i:int = 0; i < words.length; i++)
			{
				var word:String = (Config.LOCALE == "ru") ? _symbolConvert(words[i]) : words[i];
				if(!_isGoodWord(word))
				{
					for each (var exp:RegExp in WordFilter.expressions)
						word = word.replace(exp, " ");
				}
				str += word + ((i == words.length-1) ? '' : ' ');

			}

			return StringUtil.trim(str);
		}

		static  private function _symbolConvert(word:String):String
		{
			for (var j:int = 0; j < word.length; j++) {
				for (var key:String in CONVERT) {
					if (word.charAt(j) == key)
						word = word.substring(0, j) + CONVERT[key]
							+ word.substring(j + 1, word.length)
				}
			}

			return word;
		}

		static  private function _isGoodWord(word:String):Boolean
		{

			for each (var exp:RegExp in WordFilter.exception)
				if(exp.test(word)) return true;

			return false;
		}

		static private function compile(word:String):RegExp
		{
			var newWord:String = "";
			var bracket:Boolean = false;

			for (var i:int = 0; i < word.length; i++)
			{
				var sym:String = word.charAt(i);
				var code:int = word.charCodeAt(i);

				if (sym == "[")
				{
					bracket = true;
					newWord += "[";
					continue;
				}

				if (sym == "]")
				{
					bracket = false;
					newWord += getEnding(word, i);
					continue;
				}

				if (code < 0x430 || code > 0x451)
				{
					newWord += sym;
					continue;
				}

				if (!bracket)
					newWord += "[";

				newWord += sym;

				if (code == 0x451)
					newWord += "Ё";
				else
					newWord += String.fromCharCode(code - 0x20);

				switch (code)
				{
					case 0x443:
						newWord += "y";
						break;
					case 0x43E:
						newWord += "o";
						break;
					case 0x440:
						newWord += "p";
						break;
					case 0x435:
						newWord += "e";
						break;
					case 0x430:
						newWord += "a";
						break;
					case 0x43A:
						newWord += "k";
						break;
					case 0x445:
						newWord += "x";
						break;
					case 0x441:
						newWord += "c";
						break;
				}

				newWord += sym;

				if (!bracket)
					newWord += getEnding(word, i);
			}
			return new RegExp(newWord, "gi");
		}

		static private function getEnding(word:String, pos:int):String
		{
			if (pos >= word.length - 1)
				return "]";
			if (word.charAt(pos + 1) == "?")
				return "]";
			return "]" + DELIMETERS;
		}
	}
}