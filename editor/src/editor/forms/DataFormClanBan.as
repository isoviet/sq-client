package editor.forms
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.ClanSprite;
	import editor.EditorField;
	import editor.Formats;

	import utils.DateUtil;

	public class DataFormClanBan extends DataForm
	{
		private var time:int = 0;

		public function DataFormClanBan()
		{
			super(ClanSprite.BAN);
		}

		override public function get isClan():Boolean
		{
			return true;
		}

		override protected function init():void
		{
			addChild(new EditorField("Бан Клана", 0, 0, Formats.FORMAT_EDIT));
			this.lastY += 20;

			super.init();

			this.fields[0].addEventListener(KeyboardEvent.KEY_DOWN, inputKey);

			this.fields[1].selectable = false;
			this.fields[1].mouseEnabled = false;
		}

		override public function load(data:ByteArray):void
		{
			this.time = data.readInt();

			this.fields[0].text = this.time.toString();
			this.fields[1].text = DateUtil.durationDayTime(this.time);
		}

		override public function save():ByteArray
		{
			this.time = int(this.fields[0].text);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.time);
			return byteArray;
		}

		override protected function get fieldList():Array
		{
			return ["Время", "Окончание через"];
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			this.fields[1].text = DateUtil.durationDayTime(int(this.fields[0].text));
		}
	}
}