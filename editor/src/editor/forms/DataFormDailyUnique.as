package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class DataFormDailyUnique extends DataForm
	{
		static private const ITEMS:Array = [
			{'title': "Ежедневный бонус", 'id': 1},
			{'title': "Монеты лепрекона", 'id': 3},
			{'title': "Праздничный бустер", 'id': 13}
		];

		private var values:Object = {};

		public function DataFormDailyUnique()
		{
			super(DataForm.DAILY_UNIQUE);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			this.values = {};
			for (var i:int = 0; i < countI; i++)
				this.values[data.readByte()] = data.readByte();

			for (i = 0; i < ITEMS.length; i++)
				this.checks[i].selected = ITEMS[i]['id'] in this.values && this.values[ITEMS[i]['id']] != 0;
		}

		override public function save():ByteArray
		{
			for (var i:int = 0; i < this.checks.length; i++)
				this.values[ITEMS[i]['id']] = this.checks[i].selected ? 1 : 0;

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

		override protected function get checkList():Array
		{
			var answer:Array = [];
			for (var i:int = 0; i < ITEMS.length; i++)
				answer.push(ITEMS[i]['title']);
			return answer;
		}

		override protected function get checkTitleWidth():int
		{
			return 115;
		}

		override protected function get checkOffset():int
		{
			return 15;
		}
	}
}