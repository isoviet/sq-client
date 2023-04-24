package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class DataFormAmur extends DataForm
	{
		private var count:int = 0;
		private var rating:int = 0;
		private var gifts:int = 0;

		public function DataFormAmur()
		{
			super(DataForm.AMUR);
		}

		override public function load(data:ByteArray):void
		{
			this.count = data.readInt();
			this.rating = data.readInt();
			this.gifts = data.readInt();

			this.fields[0].text = this.count.toString();
			this.fields[1].text = this.rating.toString();
			this.fields[2].text = this.gifts.toString();
		}

		override public function save():ByteArray
		{
			this.count = int(this.fields[0].text);
			this.rating = int(this.fields[1].text);
			this.gifts = int(this.fields[2].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.count);
			byteArray.writeInt(this.rating);
			byteArray.writeInt(this.gifts);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Валентинки", "Рейтинг", "Подарки"];
		}
	}
}