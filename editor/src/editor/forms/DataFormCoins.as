package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.EditorField;
	import editor.Formats;

	public class DataFormCoins extends DataForm
	{
		private var coinsFree:int = 0;
		private var coinsPaid:int = 0;

		public function DataFormCoins()
		{
			super(DataForm.COINS);
		}

		override protected function init():void
		{
			addChild(new EditorField("Монеты", 0, 0, Formats.FORMAT_EDIT));
			this.lastY += 20;

			super.init();

			//coinsPaid can't be changed
			this.fields[1].selectable = false;
			this.fields[1].mouseEnabled = false;
		}

		override public function load(data:ByteArray):void
		{
			this.coinsFree = data.readInt();
			this.coinsPaid = data.readInt();

			this.fields[0].text = this.coinsFree.toString();
			this.fields[1].text = this.coinsPaid.toString();
		}

		override public function save():ByteArray
		{
			this.coinsFree = int(this.fields[0].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.coinsFree);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Бесплатные", "Платные"];
		}
	}
}