package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import game.gameData.GameConfig;

	public class DataFormAccessories extends DataForm
	{
		private var values:Object = {};

		public function DataFormAccessories()
		{
			super(DataForm.ACCESSORIES, 300);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			this.values = {};
			for (var i:int = 0; i < countI; i++)
			{
				var type:int = data.readShort();
				var worn:int = data.readByte();
				var reason:int = data.readByte();
				this.values[type] = {'worn': worn, 'reason': reason};
			}

			for (i = 0; i < GameConfig.accessoryCount; i++)
			{
				this.checks[i * 2].selected = i in this.values;
				this.checks[i * 2 + 1].selected = (i in this.values) && (this.values[i]['worn'] != 0);
				this.fields[i].text = (i in this.values) ? (this.values[i]['reason']) : "0";
			}
		}

		override public function save():ByteArray
		{
			this.values = {};
			for (var i:int = 0; i < GameConfig.accessoryCount; i++)
			{
				if (!this.checks[i * 2].selected)
					continue;
				this.values[i] = {'worn': this.checks[i * 2 + 1].selected ? 1 : 0, 'reason': int(this.fields[i].text)};
			}

			var length:int = 0;
			for (var key:String in this.values)
				length++;

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(length);

			for (key in this.values)
			{
				byteArray.writeShort(int(key));
				byteArray.writeByte(this.values[key]['worn']);
				byteArray.writeByte(this.values[key]['reason']);
			}
			return byteArray;
		}

		override protected function drawItems():void
		{
			ClothesData.init();

			for (var i:int = 0; i < GameConfig.accessoryCount; i++)
			{
				addCheck(ClothesData.getTitleById(i));
				addCheck("Надет");
				addField("Причина", this.fieldWidth);
			}
		}

		override protected function get checkTitleWidth():int
		{
			return this.checks.length % 2 == 0 ? 150 : 0;
		}
	}
}