package editor.forms
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;

	import game.gameData.GameConfig;
	import game.gameData.OutfitData;

	import editor.Loader;

	import utils.DateUtil;

	public class DataFormPackages extends DataForm
	{
		//PACKAGES
		//[package_id:W, level:B, expiration_time:I, weared:B, slot:W, reason:B]

		private var values:Object = {};

		public function DataFormPackages()
		{
			super(DataForm.PACKAGES, 300);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			this.values = {};
			for (var i:int = 0; i < countI; i++)
			{
				var type:int = data.readShort();
				var level:int = data.readByte();
				var time:int = data.readInt();
				var worn:int = data.readByte();
				var slot:int = data.readShort();
				var reason:int = data.readByte();
				this.values[type] = {'worn': worn, 'reason': reason, 'level': level, 'time': time, 'slot': slot};
			}

			for (i = 0; i < GameConfig.packageCount; i++)
			{
				this.checks[i * 2].selected = i in this.values;
				this.checks[i * 2 + 1].selected = (i in this.values) && (this.values[i]['worn'] != 0);
				this.fields[i * 5].text = (i in this.values) ? (this.values[i]['level']) : "0";
				this.fields[i * 5 + 1].text = (i in this.values) ? (this.values[i]['reason']) : "0";
				this.fields[i * 5 + 2].text = (i in this.values) ? (this.values[i]['slot']) : "0";

				if (this.fields[i * 5 + 3] != null)
				{
					time = (i in this.values) ? (this.values[i]['time']) : 0;
					if (time > 0)
						time -= (Loader.unix_time + int(getTimer() / 1000));
					this.fields[i * 5 + 3].text = time.toString();
					this.fields[i * 5 + 4].text = DateUtil.durationDayTime(time);
				}
			}
		}

		override public function save():ByteArray
		{
			this.values = {};
			for (var i:int = 0; i < GameConfig.packageCount; i++)
			{
				if (!this.checks[i * 2].selected)
					continue;
				this.values[i] = {};
				this.values[i]['worn'] = this.checks[i * 2 + 1].selected ? 1 : 0;
				this.values[i]['level'] = int(this.fields[i * 5].text);
				this.values[i]['reason'] = int(this.fields[i * 5 + 1].text);
				this.values[i]['slot'] = int(this.fields[i * 5 + 2].text);

				if (this.fields[i * 5 + 3] == null)
					this.values[i]['time'] = 0;
				else
					this.values[i]['time'] = int(this.fields[i * 5 + 3].text);
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
				byteArray.writeByte(this.values[key]['level']);
				if (this.values[key]['time'] == 0)
					byteArray.writeInt(this.values[key]['time']);
				else
					byteArray.writeInt(this.values[key]['time'] + Loader.unix_time + int(getTimer() / 1000));
				byteArray.writeByte(this.values[key]['worn']);
				byteArray.writeShort(this.values[key]['slot']);
				byteArray.writeByte(this.values[key]['reason']);
			}
			return byteArray;
		}

		override protected function drawItems():void
		{
			ClothesData.init();
			OutfitData.init();

			for (var i:int = 0; i < GameConfig.packageCount; i++)
			{
				addCheck(ClothesData.getPackageTitleById(i));
				addCheck("Надет");
				addField("Уровень", 25);
				addField("Причина", 25);
				addField("Слот", 25, false);

				if (OutfitData.isBaseSkin(i))
				{
					this.lastX = 0;
					this.lastY += 25;

					addField("Время", 100);
					this.fields[this.fields.length - 1].name = i.toString();
					this.fields[this.fields.length - 1].addEventListener(KeyboardEvent.KEY_DOWN, inputKey);

					addField("Окончание ", 125, false);
				}
				else
					this.fields.push(null, null);
			}
		}

		override protected function get checkTitleWidth():int
		{
			return this.checks.length % 2 == 0 ? 125 : 0;
		}

		private function inputKey(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER)
				return;
			var index:int = int(e.currentTarget.name);
			this.fields[index * 5 + 4].text = DateUtil.durationDayTime(int(e.currentTarget.text));
			if (int(e.currentTarget.text) != 0)
				this.checks[index * 2].selected = true;
		}
	}
}