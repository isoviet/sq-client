package editor
{
	import flash.display.Sprite;
	import flash.text.TextField;

	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	public class QuestsSprite extends Sprite
	{
		static private const QUESTS_COUNT:int = 2;

		static private const DATA:Array = [{'name': "Напарник", 'value': [[5, 4, 4, 3, 3, 2], [10, 8, 8, 6, 6, 4]],
						'short': "Напарников сопровождено: ", 'text': "Некоторые посылки требуют повышенного внимания. Отправляйся на локацию #loc и сопроводи моих курьеров до дупла. Не спускай с них глаз и не отходи далеко от них."},
						{'name': "Срочная доставка", 'value': [[5, 5, 5, 5, 5, 5], [10, 10, 10, 10, 10, 10]],
						'short': "Посылок доставлено: ", 'text': "Доставка не терпит промедления. Отправляйся на локацию #loc и донеси посылки до дупла пока не истекло время."},
						{'name': "Без жалости", 'value': [[1, 1, 1, 1, 1, 1], [3, 3, 3, 3, 3, 3]],
						'short': "Убито связанных: ", 'text': "Сможешь ли ты преодолеть чувство жалости и избавиться от белки, которая мешает достигнуть цели? Отправляйся на локацию Шторм и в режиме \"Связанные\" доберись до дупла, убив связанную с тобой белку."},
						{'name': "Скрытые сокровища", 'value': [[20, 18, 15, 8, 7, 5], [30, 28, 25, 18, 16, 14]],
						'short': "Сокровищ добыто: ", 'text': "Совершенная технология неотличима от магии. Самый современный локатор поможет отыскать то, что скрыто от невооружённого глаза. Отыщи с помощью локатора призрачное золото на локации #loc."},
						{'name': "Дикие орехи", 'value': [[6, 5, 4, 2, 2, 1], [15, 12, 8, 6, 6, 3]],
						'short': "Урожая выращено: ", 'text': "Мы вывели новый тип орехов, и хотим выяснить, в каком климате они смогут произрастать. Места для рассады уже подготовлены. Тебе необходимо посадить по 3 ореха в каждом раунде на локации #loc."},
						{'name': "Руками не трогать!", 'value': [[5, 4, 4, 3, 3, 1], [10, 8, 8, 6, 6, 2]],
						'short': "Артефактов собрано: ", 'text': "Археологи бывают крайне рассеянными. На этот раз они растеряли древние реликвии. Будь очень аккуратен и не трогай древности руками. Возьми эти триангуляторы и установи их на локации #loc  так, чтобы артефакт оказался внутри периметра."},
						{'name': "Золотая лихорадка", 'value': [[20, 18, 15, 8, 7, 5], [30, 28, 25,18, 16, 14]],
						'short': "Слитков собрано: ", 'text': "На локации #loc стали попадаться слитки настоящего золота! Или этот металл просто очень похож, но золотая лихорадка в самом разгаре. Не пытайся унести много сразу - слитки очень тяжёлые."},
						{'name': "Терпение", 'value': [[5, 4, 4,3, 3, 1], [10, 8, 8, 6, 6, 2]],
						'short': "Тотемов доставлено: ", 'text': "Этот проклятый тотем был создан могущественным шаманом, чтобы привить своим ученикам терпение. Если ты достаточно терпелив, ты легко донесёшь этот опасный груз до дупла на локации #loc."},
						{'name': "Аномальный дождь", 'value': [[20, 18, 15, 8, 7, 4], [40, 36, 34, 28, 26, 20]],
						'short': "Образцов собрано: ", 'text': "Белки замечают аномальные тучи на всех локациях. С помощью специальной колбы необходимо собрать из них дождь. Отправляйся на локацию #loc и принеси несколько образцов."},
						{'name': "Кладоискатель", 'value': [[7, 6, 6, 5, 5, 4], [15, 12, 12, 10, 10, 8]],
						'short': "Найдено кладов: ", 'text': "Используй все возможные средства для поиска клада. Благодаря новому компасу, ты сможешь узнать, насколько близко ты подобрался к своей цели. Испытай его в деле - отправляйся на локацию #loc и отыщи клад."},
						{'name': "Совершенно секретно", 'value': [[5, 4, 4, 3, 3, 1], [10, 8, 8, 6, 6, 2]],
						'short': "Свёртков доставлено: ", 'text': "Не стоит рассказывать всем подряд о своих планах. Постарайся, чтобы этот свёрток с древними картами не попался шаману на глаза. Отправляйся на локацию #loc и доберись до дупла, не приближаясь к шаману."},
						{'name': "Наперегонки", 'value': [[5, 4, 4, 3, 3, 2], [10, 8, 8, 6, 6, 4]],
						'short': "Поручений выполнено: ", 'text': "Не думай, что ты единственный, кто способен быстро выполнить поручение. На твоё место есть очередной претендент. Отправляйся на локацию #loc и приди к дуплу быстрее своего соперника."},
						{'name': "Внутренний страх", 'value': [[5, 4, 4, 2, 2, 1], [10, 8, 8, 5, 5, 3]],
						'short': "Артефактов доставлено: ", 'text': "Страшно опасное задание - донеси этот проклятый артефакт на локации #loc до дупла. Будь осторожен, древние призраки будут мешать тебе в этом деле."},
						{'name': "Экстракт бессмертия", 'value': [[5, 5, 5, 10, 10, 10], [15, 15, 15, 30, 30, 30]],
						'short': "Душ собрано: ", 'text': "Даже смерть может приносить пользу - из душ погибших белок могущественные шаманы готовят Экстракт Бессмертия. Отправляйся на локацию #loc и собирай души погибших белок."}];

		static private var locations:Array = null;
		private var quests:Array = [];
		private var spriteInfo:Sprite = new Sprite();
		private var spriteValue:Sprite = new Sprite();

		public function QuestsSprite():void
		{
			super();
			init();
		}

		public function update(values:Array):void
		{
			for each (var item:Object in this.quests)
			{
				item['info']['visible'] = false;
				item['value']['visible'] = false;
			}
			if (values == null)
				return;

			for (var i:int = 0; i < QUESTS_COUNT; i++)
			{
				if (values.length <= i * 4)
					continue;
				if (values[i * 4] >= DATA.length)
					continue;

				this.quests[i]['info']['visible'] = true;
				this.quests[i]['value']['visible'] = true;
				(this.quests[i]['type'] as ComboBox).selectedIndex = values[i * 4];
				(this.quests[i]['loc'] as ComboBox).selectedIndex = getLocationId(values[i * 4 + 1]);
				this.quests[i]['field']['text'] = values[i * 4 + 2];
				this.quests[i]['total']['text'] = " / " + DATA[values[i * 4]]['value'][i][getLocationId(values[i * 4 + 1])];
				this.quests[i]['time'] = values[i * 4 + 3];
			}
		}

		public function onEdit():void
		{
			this.spriteInfo.visible = true;
			this.spriteValue.visible = true;
			for each (var quest:Object in this.quests)
			{
				FormUtils.switchField(quest['field'], true);
				quest['total']['visible'] = true;
			}
		}

		public function save():Array
		{
			var answerQuest:Array = [];

			for (var i:int = 0; i < this.quests.length; i++)
			{
				FormUtils.switchField(this.quests[i]['field'], false);
				this.quests[i]['total']['visible'] = false;
				if (!this.quests[i]['value']['visible'])
					continue;

				answerQuest.push((this.quests[i]['type'] as ComboBox).selectedItem['value'], (this.quests[i]['loc'] as ComboBox).selectedItem['value'], int(this.quests[i]['field']['text']), this.quests[i]['time']);
			}

			return answerQuest;
		}

		private function getLocationId(location:int):int
		{
			if (!locations)
				locations = [Locations.ISLAND_ID, Locations.MOUNTAIN_ID, Locations.SWAMP_ID, Locations.DESERT_ID, Locations.STORM_ID, Locations.ANOMAL_ID];
			return locations.indexOf(location);
		}

		private function init():void
		{
			var typeProvider:DataProvider = new DataProvider();
			for (var i:int = 0; i < DATA.length; i++)
				typeProvider.addItem({'label': DATA[i]['name'], 'value': i});

			var locProvider:DataProvider = new DataProvider();
			var locations:Array = [Locations.ISLAND_ID, Locations.MOUNTAIN_ID, Locations.SWAMP_ID, Locations.DESERT_ID, Locations.STORM_ID, Locations.ANOMAL_ID];
			var locationsName:Array = ["Солнечные долины", "Снежные хребты", "Топи", "Пустыня", "Шторм", "Аномальная зона"];
			for (i = 0; i < locations.length; i++)
				locProvider.addItem({'label': locationsName[i], 'value': locations[i]});

			addChild(this.spriteInfo);
			addChild(this.spriteValue);

			for (i = 0; i < QUESTS_COUNT; i++)
			{
				var spriteInfo:Sprite = new Sprite();
				var spriteValue:Sprite = new Sprite();
				addChild(spriteInfo);
				addChild(spriteValue);

				var nameBox:ComboBox = new ComboBox();
				FormUtils.setComboBox(nameBox, spriteValue, typeProvider, i * 210, 20, 190);

				var locBox:ComboBox = new ComboBox();
				FormUtils.setComboBox(locBox, spriteValue, locProvider, i * 210, 80, 190);

				var titleValue:EditorField = new EditorField("Прогресс: ", i * 210, 110, Formats.FORMAT_EDIT);
				spriteValue.addChild(titleValue);

				var fieldEditValue:TextField = new TextField();
				FormUtils.setTextField(fieldEditValue, spriteValue, i * 210 + 60, 110, 40);

				var fieldTotal:EditorField = new EditorField("", i * 210 + 100, 110, Formats.FORMAT_EDIT);
				fieldTotal.visible = false;
				spriteValue.addChild(fieldTotal);

				this.quests.push({'info': spriteInfo, 'type': nameBox, 'loc': locBox, 'field': fieldEditValue, 'total': fieldTotal, 'value': spriteValue});

				if (i == 0)
					continue;

				spriteInfo.graphics.lineStyle(2, 0x999999);
				spriteInfo.graphics.moveTo(210 * i - 20, 50);
				spriteInfo.graphics.lineTo(210 * i - 20, 140);
			}
		}
	}
}