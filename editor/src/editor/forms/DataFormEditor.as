package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import fl.data.DataProvider;

	public class DataFormEditor extends DataForm
	{
		private var value:int = 0;

		public function DataFormEditor()
		{
			super(DataForm.EDITOR_STATUS);
		}

		override public function load(data:ByteArray):void
		{
			this.value = data.readByte();

			this.combos[0].selectedIndex = this.value;
		}

		override public function save():ByteArray
		{
			this.value = int(this.combos[0].selectedItem['value']);

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeByte(this.value);
			return byteArray;
		}

		override protected function get comboList():Array
		{
			var editor:DataProvider = new DataProvider();
			var editorType:Array = ["Нет прав", "Полные права", "Права на удаление", "Ограниченные права", "Ограниченные права+", "Супер-Модератор"];
			for (var i:int = 0; i < editorType.length; i++)
				editor.addItem({'label': editorType[i], 'value': i});
			return [["Редактор", editor]];
		}
	}
}