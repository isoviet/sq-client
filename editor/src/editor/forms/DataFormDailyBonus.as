package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.EditorField;
	import editor.Formats;

	public class DataFormDailyBonus extends DataForm
	{
		private var start:int = 0;
		private var current:int = 0;
		private var enters:int = 0;
		private var day:int = 0;

		public function DataFormDailyBonus()
		{
			super(DataForm.DAILY_BONUS);
		}

		override protected function init():void
		{
			addChild(new EditorField("Ежедневный бонус", 0, 0, Formats.FORMAT_EDIT));
			this.lastY += 20;

			super.init();
		}

		override public function load(data:ByteArray):void
		{
			this.start = data.readShort();
			this.current = data.readShort();
			this.enters = data.readShort();
			this.day = data.readByte();

			this.fields[0].text = this.start.toString();
			this.fields[1].text = this.current.toString();
			this.fields[2].text = this.enters.toString();
			this.fields[3].text = this.day.toString();
		}

		override public function save():ByteArray
		{
			this.start = int(this.fields[0].text);
			this.current = int(this.fields[1].text);
			this.enters = int(this.fields[2].text);
			this.day = int(this.fields[3].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeShort(this.start);
			byteArray.writeShort(this.current);
			byteArray.writeShort(this.enters);
			byteArray.writeByte(this.day);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Начало", "Текущий", "Входы", "День"];
		}

		override protected function get fieldWidth():int
		{
			return 50;
		}
	}
}