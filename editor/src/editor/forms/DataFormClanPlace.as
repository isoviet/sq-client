package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.ClanSprite;

	public class DataFormClanPlace extends DataForm
	{
		private var places:int = 0;

		public function DataFormClanPlace()
		{
			super(ClanSprite.PLACES);
		}

		override public function get isClan():Boolean
		{
			return true;
		}

		override public function load(data:ByteArray):void
		{
			this.places = data.readInt();

			this.fields[0].text = this.places.toString();
		}

		override public function save():ByteArray
		{
			this.places = int(this.fields[0].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.places);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Места клана"];
		}
	}
}