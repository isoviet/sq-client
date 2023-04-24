package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import fl.data.DataProvider;

	import editor.EditorField;
	import editor.Formats;

	import utils.BanUtil;
	import utils.DateUtil;

	public class DataFormBan extends DataForm
	{
		static public const TYPES:Array = ["Нет", "Кляп", "Бан"];

		private var reason:int = 0;
		private var repeated:Boolean = false;

		private var moderator:int = 0;
		private var time:int = 0;

		public function DataFormBan()
		{
			super(DataForm.BAN);
		}

		override protected function init():void
		{
			addChild(new EditorField("Бан", 0, 0, Formats.FORMAT_EDIT));
			this.lastY += 20;

			super.init();

			//moderator, time can't be changed
			this.fields[0].selectable = false;
			this.fields[0].mouseEnabled = false;

			this.fields[1].selectable = false;
			this.fields[1].mouseEnabled = false;

			this.fields[2].selectable = false;
			this.fields[2].mouseEnabled = false;
		}

		override public function load(data:ByteArray):void
		{
			var type:int = data.readByte();

			this.repeated = false;
			this.reason = data.readByte();

			this.moderator = data.readInt();
			this.time = data.readInt();

			this.fields[0].text = this.moderator.toString();
			this.fields[1].text = DateUtil.durationDayTime(this.time);
			this.fields[2].text = TYPES[type];

			this.checks[0].selected = this.repeated;
			this.combos[0].selectedIndex = this.reason;
		}

		override public function save():ByteArray
		{
			this.repeated = this.checks[0].selected;
			this.reason = int(this.combos[0].selectedItem['value']);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeByte(this.reason);
			byteArray.writeByte(this.repeated ? 1 : 0);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Модератор", "Окончание через", "Тип бана"];
		}

		override protected function get comboList():Array
		{
			var banProvider:DataProvider = new DataProvider();
			for (var i:int = 0; i < BanUtil.reasons.length; i++)
				banProvider.addItem({'label': BanUtil.reasons[i]['title'], 'value': i});
			return [["Причина", banProvider]];
		}

		override protected function get checkList():Array
		{
			return ["Повторное нарушение"];
		}
	}
}