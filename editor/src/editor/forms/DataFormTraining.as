package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import fl.data.DataProvider;

	public class DataFormTraining extends DataForm
	{
		static private const ITEMS:Array = [
			{'title': "Обучение завершенно", 'id': 0},
			{'title': "Первые шаги", 'id': 1},
			{'title': "Дом, милый дом", 'id': 15},
			{'title': "Приоденься!", 'id': 7},
			{'title': "Белки-Летяги", 'id': 2},
			{'title': "Магия нас связала", 'id': 3},
			{'title': "По магазинам!", 'id': 4},
			{'title': "Всегда в курсе", 'id': 5},
			{'title': "Вам письмо, танцуйте!", 'id': 8},
			{'title': "Пятый элемент", 'id': 9},
			{'title': "Только ачивки...", 'id': 10},
			{'title': "Таинственные топи", 'id': 11},
			{'title': "Реши свою судьбу!", 'id': 14},
			{'title': "Быть шаманом", 'id': 12},
			{'title': "Духи прошлого", 'id': 13},
			{'title': "С ветки на ветку", 'id': 16},
			{'title': "Быстрее, выше, сильнее!", 'id': 6}
		];

		private var values:Object = {};

		public function DataFormTraining()
		{
			super(DataForm.TRAINING, 200);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			this.values = {};
			for (var i:int = 0; i < countI; i++)
				this.values[data.readByte()] = data.readByte();

			for (i = 0; i < ITEMS.length; i++)
				this.combos[i].selectedIndex = ITEMS[i]['id'] in this.values ? this.values[ITEMS[i]['id']] : 0;
		}

		override public function save():ByteArray
		{
			for (var i:int = 0; i < this.combos.length; i++)
				this.values[ITEMS[i]['id']] = int(this.combos[i].selectedItem['value']);

			var length:int = 0;
			for (var key:String in this.values)
				length++;

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(length);

			for (key in this.values)
			{
				byteArray.writeByte(int(key));
				byteArray.writeByte(this.values[key]);
			}
			return byteArray;
		}

		override protected function get comboList():Array
		{
			var valueData:DataProvider = new DataProvider();
			var valueType:Array = ["Нет", "Выполнен", "Завершён"];
			for (var i:int = 0; i < valueType.length; i++)
				valueData.addItem({'label': valueType[i], 'value': i});

			var answer:Array = [];
			for (i = 0; i < ITEMS.length; i++)
				answer.push([ITEMS[i]['title'], valueData]);
			return answer;
		}

		override protected function get comboTitleWidth():int
		{
			return 165;
		}

		override protected function get comboOffset():int
		{
			return WIDTH;
		}
	}
}