package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class DataFormSettings extends DataForm
	{
		private var count:int = 0;

		public function DataFormSettings()
		{
			super(DataForm.SETTINGS);
		}

		override public function load(data:ByteArray):void
		{
			this.count = data.readInt();

			this.fields[0].text = this.count.toString();
		}

		override public function save():ByteArray
		{
			this.count = int(this.fields[0].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.count);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Орехи"];
		}
	}
}