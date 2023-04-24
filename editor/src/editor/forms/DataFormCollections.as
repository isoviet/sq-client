package editor.forms
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import editor.CollectionsData;
	import editor.EditorField;
	import editor.Formats;

	public class DataFormCollections extends DataForm
	{
		private var values:Object = {};

		public function DataFormCollections()
		{
			super(DataForm.COLLECTIONS, 300);
		}

		override public function load(data:ByteArray):void
		{
			var countI:int = data.readInt();
			for (var i:int = 0; i < countI; i++)
			{
				var type:int = data.readByte();
				var element:int = (data.readByte() + 256) % 256;
				var count:int = data.readInt();

				if (!(type in this.values))
					this.values[type] = {};
				this.values[type][element] = count;
			}

			var index:int = 0;
			for (var j:int = 0; j < CollectionsData.COLLECTIONS.length; j++)
				for (i = 0; i < CollectionsData.COLLECTIONS[j].length; i++)
				{
					if (j in this.values && i in this.values[j])
						this.fields[index].text = this.values[j][i].toString();
					else
						this.fields[index].text = "0";
					index++
				}
		}

		override public function save():ByteArray
		{
			this.values = {};
			var index:int = 0;
			for (var j:int = 0; j < CollectionsData.COLLECTIONS.length; j++)
				for (var i:int = 0; i < CollectionsData.COLLECTIONS[j].length; i++)
				{
					if (int(this.fields[index].text) > 0)
						this.values[index] = {'type': j, 'element': i, 'count': int(this.fields[index].text)};
					index++
				}

			var length:int = 0;
			for (var key:String in this.values)
				length++;

			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt(length);

			for (key in this.values)
			{
				byteArray.writeByte(this.values[key]['type']);
				byteArray.writeByte(this.values[key]['element']);
				byteArray.writeInt(this.values[key]['count']);
			}
			return byteArray;
		}

		override protected function drawItems():void
		{
			var count:int = 0;
			for (var j:int = 0; j < CollectionsData.COLLECTIONS.length; j++)
			{
				for (var i:int = 0; i < CollectionsData.COLLECTIONS[j].length; i++)
				{
					if (CollectionsData.COLLECTIONS[j][i] == null)
					{
						var dx:int = this.lastX;
						var dy:int = this.lastY;

						addField("", this.fieldWidth, false);

						this.lastX = dx;
						this.lastY = dy;
					}
					else
					{
						addField(CollectionsData.COLLECTIONS[j][i]['title'], this.fieldWidth);

						count++;
						if (j == 0 && count % 5 == 0)
						{
							this.lastX = 0;
							this.lastY += 25;
						}
					}
				}
				if (j == 1)
					continue;
				this.spriteView.addChild(new EditorField("Золотые Коллекции", 150, this.lastY, Formats.FORMAT_EDIT_BOLD));
				this.lastY += 25;
			}
		}

		override protected function get fieldWidth():int
		{
			return 30;
		}

		override protected function get fieldTitleWidth():int
		{
			return 115;
		}
	}
}