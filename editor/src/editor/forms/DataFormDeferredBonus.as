package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class DataFormDeferredBonus extends DataForm
	{
		private var values:Object = {};

		public function DataFormDeferredBonus()
		{
			super(DataForm.DEFERRED_BONUSES);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			for (var i:int = 0; i < countI; i++)
			{
				var id:int = data.readInt();
				this.values[id] = {'award_reason': data.readByte(),
							'type': data.readByte(),
							'time': data.readInt(),
							'duration': data.readInt(),
							'bonus_id': data.readShort(),
							'bonus_count': data.readShort(),
							'bonus_duration': data.readInt()};
			}

			i = 0;
			for (var key:String in this.values)
			{
				this.fields[i * 8].text = key;
				this.fields[i * 8 + 1].text = this.values[key]['award_reason'].toString();
				this.fields[i * 8 + 2].text = this.values[key]['type'].toString();
				this.fields[i * 8 + 3].text = this.values[key]['time'].toString();
				this.fields[i * 8 + 4].text = this.values[key]['duration'].toString();
				this.fields[i * 8 + 5].text = this.values[key]['bonus_id'].toString();
				this.fields[i * 8 + 6].text = this.values[key]['bonus_count'].toString();
				this.fields[i * 8 + 7].text = this.values[key]['bonus_duration'].toString();
				i++;
			}
		}

		override public function save():ByteArray
		{
			//this.count = int(this.fields[0].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			//byteArray.writeInt(this.count);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["id", "Причина", "Тип", "Время", "Длительность", "Бонус", "Кол-во", "Время бонуса"];
		}
	}
}