package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.ClanSprite;

	public class DataFormClanSize extends DataForm
	{
		private var size:int = 0;

		public function DataFormClanSize()
		{
			super(ClanSprite.SIZE);
		}

		override public function get isClan():Boolean
		{
			return true;
		}

		override public function load(data:ByteArray):void
		{
			this.size = data.readInt();

			this.fields[0].text = this.size.toString();
		}

		override public function save():ByteArray
		{
			this.size = int(this.fields[0].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.size);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Размер Клана"];
		}
	}
}