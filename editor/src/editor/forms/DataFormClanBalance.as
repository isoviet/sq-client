package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.ClanSprite;
	import editor.EditorField;
	import editor.Formats;

	public class DataFormClanBalance extends DataForm
	{
		private var coins:int = 0;
		private var nuts:int = 0;

		public function DataFormClanBalance()
		{
			super(ClanSprite.ADMIN_BALANCE);
		}

		override public function get isClan():Boolean
		{
			return true;
		}

		override protected function init():void
		{
			addChild(new EditorField("Баланс Клана", 0, 0, Formats.FORMAT_EDIT));
			this.lastY += 20;

			super.init();
		}

		override public function load(data:ByteArray):void
		{
			this.coins = data.readInt();
			this.nuts = data.readInt();

			this.fields[0].text = this.coins.toString();
			this.fields[1].text = this.nuts.toString();
		}

		override public function save():ByteArray
		{
			this.coins = int(this.fields[0].text);
			this.nuts = int(this.fields[1].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.coins);
			byteArray.writeInt(this.nuts);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Монеты", "Орехи"];
		}
	}
}