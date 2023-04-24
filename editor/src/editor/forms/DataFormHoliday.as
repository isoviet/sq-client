package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class DataFormHoliday extends DataForm
	{
		private var elements:int = 0;
		private var tickets:int = 0;
		private var rating:int = 0;

		public function DataFormHoliday()
		{
			super(DataForm.HOLIDAY);
		}

		override public function load(data:ByteArray):void
		{
			this.elements = data.readShort();
			this.tickets = data.readByte();
			this.rating = data.readInt();

			this.fields[0].text = this.elements.toString();
			this.fields[1].text = this.tickets.toString();
			this.fields[2].text = this.rating.toString();
		}

		override public function save():ByteArray
		{
			this.elements = int(this.fields[0].text);
			this.tickets = int(this.fields[1].text);
			this.rating = int(this.fields[2].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeShort(this.elements);
			byteArray.writeByte(this.tickets);
			byteArray.writeInt(this.rating);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Ингредиенты", "Билеты", "Рейтинг"];
		}

		override protected function get fieldWidth():int
		{
			return 50;
		}
	}
}