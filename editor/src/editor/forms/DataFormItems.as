package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class DataFormItems extends DataForm
	{
		static private const ITEMS:Array = [
			{'title': "Палка", 'id': 0},
			{'title': "Ящик", 'id': 2},
			{'title': "Гиря", 'id': 8},
			{'title': "Батут", 'id': 9},
			{'title': "Ядро", 'id': 11},
			{'title': "Синий портал", 'id': 12},
			{'title': "Красный портал", 'id': 13},
			{'title': "Удаление", 'id': 16},
			{'title': "Шарик", 'id': 18},
			{'title': "Хлопушка", 'id': 23},
			{'title': "Молоток", 'id': 27}
		];

		private var counts:Vector.<int> = null;

		public function DataFormItems()
		{
			super(DataForm.SHAMAN_ITEMS);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			this.counts = new Vector.<int>(countI);
			for (var i:int = 0; i < countI; ++i)
				this.counts[i] = data.readShort();

			for (i = 0; i < ITEMS.length; i++)
				this.fields[i].text = this.counts[ITEMS[i]['id']].toString();
		}

		override public function save():ByteArray
		{
			for (var i:int = 0; i < this.fields.length; i++)
				this.counts[ITEMS[i]['id']] = int(this.fields[i].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.counts.length);
			for (i = 0; i < this.counts.length; i++)
				byteArray.writeShort(this.counts[i]);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			var answer:Array = [];
			for (var i:int = 0; i < ITEMS.length; i++)
				answer.push(ITEMS[i]['title']);
			return answer;
		}

		override protected function get fieldWidth():int
		{
			return 30;
		}

		override protected function get fieldTitleWidth():int
		{
			return 100;
		}

		override protected function get fieldOffset():int
		{
			return 25;
		}
	}
}