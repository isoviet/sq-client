package
{
	import flash.display.Sprite;
	import flash.utils.getTimer;

	import utils.DateUtil;

	public class DailyQuest
	{
		static private const DATA:Array = [{'name': gls("Мастер слежения"), 'value': [[5, 4, 4, 3, 3, 2], [10, 8, 8, 6, 6, 4]],
						'short': gls("Курьеров сопровождено: "), 'text': gls("Курьер должен доставить экспонат в Музей Истории на локацию #loc. Не отходи от белки, отмеченной стрелкой, а то артефакт украдут. Доберёшься до дупла - получишь награду.")},
						{'name': gls("Срочная доставка"), 'value': [[5, 5, 5, 5, 5, 5], [10, 10, 10, 10, 10, 10]],
						'short': gls("Артефактов доставлено: "), 'text': gls("Ты обнаружил древний артефакт! Его нужно срочно доставить на локацию #loc. Забеги в дупло за отведённое время и будешь щедро вознаграждён!")},
						{'name': gls("Поручение Зайца"), 'value': [[1, 1, 1, 1, 1, 1], [3, 3, 3, 3, 3, 3]],
						'short': gls("Белок погибло: "), 'text': gls("У Зайца НеСудьбы есть для тебя работа. Отправляйся в Шторм, в режим “связанные”. Убей белку, связанную с тобой, и доберись до дупла. Справишься, и Заяц наградит тебя.")},
						{'name': gls("Призрачное золото"), 'value': [[20, 18, 15, 8, 7, 5], [30, 28, 25, 18, 16, 14]],
						'short': gls("Найдено золота: "), 'text': gls("На локации #loc было найдено призрачное золото! Используй локатор, чтобы найти его, а затем забеги в дупло - и тогда ты получишь награду!")},
						{'name': gls("Спасительные орехи"), 'value': [[6, 5, 4, 2, 2, 1], [15, 12, 8, 6, 6, 3]],
						'short': gls("Урожая выращено: "), 'text': gls("Группа археологов ведет раскопки на локации #loc, и им нужен источник пищи. Посади в каждом раунде не менее 3 орехов в подготовленных местах, зайди в дупло и получи заслуженную награду.")},
						{'name': gls("Триангуляция"), 'value': [[5, 4, 4, 3, 3, 1], [10, 8, 8, 6, 6, 2]],
						'short': gls("Артефактов отмечено: "), 'text': gls("Команда учёных спешит на локацию #loc для исследования артефакта. Поставь три триангулятора вокруг артефакта, чтобы учёные знали, куда им идти, доберись до дупла, и награда станет твоей.")},
						{'name': gls("Золотые слитки"), 'value': [[20, 18, 15, 8, 7, 5], [30, 28, 25, 18, 16, 14]],
						'short': gls("Слитков собрано: "), 'text': gls("На локации #loc были найдены золотые слитки. Собирай их и помни: чем больше слитков ты поднимешь, тем медленнее будешь передвигаться. Доберёшься до дупла - получишь награду.")},
						{'name': gls("Безумное испытание"), 'value': [[5, 4, 4, 3, 3, 1], [10, 8, 8, 6, 6, 2]],
						'short': gls("Пройдено испытаний: "), 'text': gls("Безумный шаман готов наградить тебя, если ты сможешь пройти его испытание на локации #loc. Добеги до дупла под действием проклятия дезориентации, и награда станет твоей!")},
						{'name': gls("Волшебная вода"), 'value': [[20, 18, 15, 8, 7, 4], [40, 36, 34, 28, 26, 20]],
						'short': gls("Воды собрано: "), 'text': gls("Волшебная вода встречается крайне редко и высоко ценится! Чтобы получить награду, отправляйся на локацию #loc, найди Чудесную Тучу и лови её, пока не наберёшь нужное количество воды!")},
						{'name': gls("Компас"), 'value': [[7, 6, 6, 5, 5, 4], [15, 12, 12, 10, 10, 8]],
						'short': gls("Артефактов найдено: "), 'text': gls("Охотник за сокровищами должен уметь пользоваться компасом, краснеющим при приближении к цели. Используй его, чтобы найти артефакт на локации #loc, доберись до дупла и получи награду.")},
						{'name': gls("Опасный шаман"), 'value': [[5, 4, 4, 3, 3, 1], [10, 8, 8, 6, 6, 2]],
						'short': gls("Сокровищ спасено: "), 'text': gls("Шаман тоже ищет сокровища на локации #loc. А вдруг он захочет украсть твои? Доберись до дупла, не приближаясь к шаману, и получишь награду!")},
						{'name': gls("Конкурент"), 'value': [[5, 4, 4, 3, 3, 2], [10, 8, 8, 6, 6, 4]],
						'short': gls("Конкурентов повержено: "), 'text': gls("У тебя появился конкурент - он охотится за твоими сокровищами! Беги на локацию #loc и доберись до дупла раньше белки, отмеченной стрелкой, чтобы получить заслуженную награду!")},
						{'name': gls("Злой дух"), 'value': [[5, 4, 4, 2, 2, 1], [10, 8, 8, 5, 5, 3]],
						'short': gls("Сокровищ получено: "), 'text': gls("Твои сокровища находятся в дупле на локации #loc, но их охраняет злой дух. Не дай призраку коснуться тебя и доберись до дупла, чтобы получить заслуженную награду.")},
						{'name': gls("Экстракт бессмертия"), 'value': [[5, 5, 5, 10, 10, 10], [15, 15, 15, 30, 30, 30]],
						'short': gls("Душ собрано: "), 'text': gls("Из душ погибших белок могущественные шаманы готовят Экстракт Бессмертия. Отправляйся на локацию #loc, собери души погибших белок, отнеси их в дупло и получи награду.")}];

		static private const EXP_AWARD:Array = [{'level': 7, 'exp': 30},
							{'level': 13, 'exp': 50},
							{'level': 17, 'exp': 70},
							{'level': 999, 'exp': 120}];

		static private var locations:Array = null;
		static private var images:Array = null;
		static private var icons:Array = null;

		public var type:int = -1;
		public var difficulty:int = -1;
		public var location:int = -1;
		public var value:int = -1;
		public var time:int = -1;

		public function DailyQuest(type:int, location:int, value:int, time:int, difficulty:int):void
		{
			this.type = type;
			this.difficulty = difficulty;
			this.location = location;
			this.value = value;
			this.time = time + getTimer() / 1000;
		}

		static public function getLocationId(location:int):int
		{
			if (!locations)
				locations = [Locations.ISLAND_ID, Locations.MOUNTAIN_ID, Locations.SWAMP_ID, Locations.DESERT_ID, Locations.STORM_ID, Locations.ANOMAL_ID];
			return Math.max(0, locations.indexOf(location));
		}

		public function get isComplete():Boolean
		{
			return this.value >= this.maxValue;
		}

		public function get maxValue():int
		{
			return DATA[this.type]['value'][this.difficulty][this.locationIndex];
		}

		public function get name():String
		{
			return DATA[this.type]['name'];
		}

		public function get text():String
		{
			return DATA[this.type]['text'].replace("#loc", "<b>" + Locations.getLocation(this.location).name + "</b>");
		}

		public function get short():String
		{
			return DATA[this.type]['short'];
		}

		public function get image():Sprite
		{
			if (!images)
				images = [QuestImage0, QuestImage1, QuestImage2, QuestImage3, QuestImage4, QuestImage5, QuestImage6, QuestImage7, QuestImage8, QuestImage9, QuestImage10, QuestImage11, QuestImage12, QuestImage13];
			return new images[this.type];
		}

		public function get icon():Sprite
		{
			if (!icons)
				icons = [QuestIcon0, QuestIcon1, QuestIcon2, QuestIcon3, QuestIcon4, QuestIcon5, QuestIcon6, QuestIcon7, QuestIcon8, QuestIcon9, QuestIcon10, QuestIcon11, QuestIcon12, QuestIcon13];
			return new icons[this.type];
		}

		public function get award():String
		{
			var answer:String = this.difficulty == 0 ? "#Ac 50   #Mn 30   #Ex " : "#Ac 80   #Mn 40   #Ex ";
			for (var i:int = 0; i < EXP_AWARD.length; i++)
			{
				if (EXP_AWARD[i]['level'] < Experience.selfLevel)
					continue;
				answer += EXP_AWARD[i]['exp'] * (this.difficulty == 0 ? 1 : 2);
				break;
			}
			return answer;
		}

		public function get leftTime():String
		{
			return DateUtil.durationDayTime(this.time - getTimer() / 1000);
		}

		private function get locationIndex():int
		{
			return getLocationId(this.location);
		}
	}
}