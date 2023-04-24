package editor.forms
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import game.gameData.GameConfig;

	public class DataFormExp extends DataForm
	{
		private var count:int = 0;

		static private function getLevel(exp:int):int
		{
			if (exp >= GameConfig.maxExperience)
				return GameConfig.maxLevel;

			for (var i:int = 0; i < GameConfig.maxLevel; i++)
			{
				if (exp < GameConfig.getExperienceValue(i))
					return i - 1;
			}
			return GameConfig.maxLevel;
		}

		public function DataFormExp()
		{
			super(DataForm.EXPERIENCE);
		}

		override protected function init():void
		{
			super.init();

			this.fields[1].addEventListener(KeyboardEvent.KEY_DOWN, inputKey);
		}

		override public function load(data:ByteArray):void
		{
			this.count = data.readInt();

			this.fields[0].text = this.count.toString();
			this.fields[1].text = getLevel(this.count).toString();
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
			return ["Опыт", "Уровень"];
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			this.fields[1].text = int(this.fields[1].text).toString();
			this.count = GameConfig.getExperienceValue(int(this.fields[1].text));
			this.fields[0].text = this.count.toString();
		}
	}
}