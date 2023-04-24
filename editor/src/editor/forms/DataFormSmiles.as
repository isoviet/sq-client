package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import game.gameData.EmotionManager;

	import editor.EditorField;
	import editor.Formats;

	public class DataFormSmiles extends DataForm
	{
		private var smiles:Vector.<int> = new <int>[];

		public function DataFormSmiles()
		{
			super(DataForm.SMILES);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			this.smiles = new <int>[];
			for (var i:int = 0; i < countI; ++i)
				this.smiles.push(data.readByte());
			for (i = 0; i < this.checks.length; i++)
				this.checks[i].selected = this.smiles.indexOf(i) != -1;
		}

		override public function save():ByteArray
		{
			this.smiles = new <int>[];

			for (var i:int = 0; i < this.checks.length; i++)
			{
				if (!this.checks[i].selected)
					continue;
				this.smiles.push(i);
			}

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(this.smiles.length);
			for (i = 0; i < this.smiles.length; i++)
				byteArray.writeByte(this.smiles[i]);
			return byteArray;
		}

		override protected function drawItems():void
		{
			for (var i:int = 0; i < this.checkList.length; i++)
			{
				switch (i)
				{
					case 10:
						this.lastX = 0;
						this.lastY += 25;
						this.spriteView.addChild(new EditorField("Пасха", 150, this.lastY, Formats.FORMAT_EDIT_BOLD));
						this.lastX = 0;
						this.lastY += 25;
						break;
					case 15:
						this.lastX = 0;
						this.lastY += 25;
						this.spriteView.addChild(new EditorField("Новый год", 150, this.lastY, Formats.FORMAT_EDIT_BOLD));
						this.lastX = 0;
						this.lastY += 25;
						break;
					case 25:
						this.lastX = 0;
						this.lastY += 25;
						this.spriteView.addChild(new EditorField("Новые", 150, this.lastY, Formats.FORMAT_EDIT_BOLD));
						this.lastX = 0;
						this.lastY += 25;
						break;
				}
				addCheck(this.checkList[i]);
			}
		}

		override protected function get checkList():Array
		{
			var answer:Array = [];
			for (var i:int = 0; i < EmotionManager.NAMES.length; i++)
				answer.push(EmotionManager.NAMES[i]);
			return answer;
		}
	}
}