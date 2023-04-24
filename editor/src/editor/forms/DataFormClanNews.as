package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.ClanSprite;
	import editor.EditorField;
	import editor.Formats;

	public class DataFormClanNews extends DataForm
	{
		private var message:String = "";

		public function DataFormClanNews()
		{
			super(ClanSprite.NEWS);
		}

		override public function get isClan():Boolean
		{
			return true;
		}

		override protected function init():void
		{
			addChild(new EditorField("Новость Клана", 0, 0, Formats.FORMAT_EDIT));
			this.lastY += 20;

			super.init();

			this.fields[0].height = 54;
			this.fields[0].multiline = true;
			this.fields[0].wordWrap = true;

			this.changed = true;
			this.changed = false;
		}

		override public function load(data:ByteArray):void
		{
			this.message = data.readUTF();

			this.fields[0].text = this.message;
		}

		override public function save():ByteArray
		{
			this.message = this.fields[0].text;

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeUTF(this.message);
			byteArray.writeByte(0);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return [""];
		}

		override protected function get fieldWidth():int
		{
			return 250;
		}
	}
}