package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class DataFormModerator extends DataForm
	{
		private var value:Boolean = false;

		public function DataFormModerator()
		{
			super(DataForm.MODERATOR_STATUS);
		}

		override public function load(data:ByteArray):void
		{
			this.value = data.readByte() != 0;

			this.checks[0].selected = this.value;
		}

		override public function save():ByteArray
		{
			this.value = this.checks[0].selected;

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeByte(this.value ? 1 : 0);
			return byteArray;
		}

		override protected function get checkList():Array
		{
			return ["Модератор"];
		}
	}
}