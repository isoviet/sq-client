package editor.forms
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import utils.DateUtil;

	public class DataFormExpirations extends DataForm
	{
		static private const ITEMS:Array = [
			//{'title': "mana", 'id': 0},
			//{'title': "subscribe", 'id': 1},
			{'title': "vip", 'id': 2},
			//{'title': "chest", 'id': 4},
			//{'title': "return_bonus", 'id': 5},
			//{'title': "friend_bonus", 'id': 6},
			{'title': "golden_cup", 'id': 7},
			//{'title': "mana_for_object", 'id': 8},
			//{'title': "unlimited_mana", 'id': 9},
			//{'title': "free_first_perk", 'id': 10},
			//{'title': "unlimited_energy", 'id': 11},
			//{'title': "shaman_freeplay", 'id': 12},
			{'title': "mana_regeneration", 'id': 13},
			//{'title': "bundle_newbie_rich", 'id': 14},
			//{'title': "bundle_newbie_poor", 'id': 15},
			//{'title': "bundle_legendary", 'id': 16},
			{'title': "holiday_booster", 'id': 17},
			//{'title': "birthday_2015", 'id': 18}
		];

		private var values:Object = {};

		public function DataFormExpirations()
		{
			super(DataForm.EXPIRATIONS);
		}

		override protected function init():void
		{
			super.init();

			for (var i:int = 0; i < this.fields.length; i++)
			{
				if (i % 2 == 0)
				{
					this.fields[i].name = i.toString();
					this.fields[i].addEventListener(KeyboardEvent.KEY_DOWN, inputKey);
				}
				else
				{
					this.fields[i].selectable = false;
					this.fields[i].mouseEnabled = false;
				}
			}
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			this.values = {};
			for (var i:int = 0; i < countI; i++)
			{
				var type:int = data.readByte();
				var exist:int = data.readByte();
				var time:int = data.readInt();
				this.values[type] = time;
			}

			for (i = 0; i < ITEMS.length; i++)
			{
				var value:int = ITEMS[i]['id'] in this.values ? this.values[ITEMS[i]['id']] : 0;
				this.fields[i * 2].text = value.toString();
				this.fields[i * 2 + 1].text = DateUtil.durationDayTime(value);
			}
		}

		override public function save():ByteArray
		{
			for (var i:int = 0; i < ITEMS.length; i++)
				this.values[ITEMS[i]['id']] = int(this.fields[i * 2].text);

			var length:int = 0;
			for (var key:String in this.values)
				length++;

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(length);

			for (key in this.values)
			{
				byteArray.writeByte(int(key));
				byteArray.writeInt(this.values[key]);
			}
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			var answer:Array = [];
			for (var i:int = 0; i < ITEMS.length; i++)
				answer.push(ITEMS[i]['title'], "Окончание через");
			return answer;
		}

		override protected function get fieldTitleWidth():int
		{
			return 120;
		}

		override protected function get fieldOffset():int
		{
			return 10;
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			var index:int = int(e.currentTarget.name);
			this.fields[index + 1].text = DateUtil.durationDayTime(int(this.fields[index].text));
		}
	}
}