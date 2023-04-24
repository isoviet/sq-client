package tape
{
	import flash.display.SimpleButton;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import statuses.Status;
	import tape.TapeObject;

	public class TapePrivateRoomElement extends TapeObject
	{
		static private const CAPACITY:int = 15;

		private var _id:int = -1;
		private var _type:int = 0;
		private var count:int = 0;
		private var modes:uint = 0;

		private var button:SimpleButton;

		public function TapePrivateRoomElement(id:int, type:int, count:int, modes:uint, button:SimpleButton)
		{
			super();

			this.id = id;
			this.type = type;
			this.count = count;
			this.modes = modes;

			this.button = button;

			init();
		}

		public function set id (_id:int):void
		{
			this._id = _id;
		}

		public function get id ():int
		{
			return this._id;
		}

		public function set type (_type:int):void
		{
			this._type = _type;
		}

		public function get type ():int
		{
			return this._type;
		}

		private function init():void
		{
			addChild(this.button);

			var countFormat:TextFormat = new TextFormat(null, 11, 0x0101FF, true);

			var countField:GameField = new GameField(this.count + "/" + CAPACITY, 100, 3, countFormat);
			countField.mouseEnabled = false;
			addChild(countField);

			var nameFormat:TextFormat = new TextFormat(null, 10, 0x3C2402, true);
			nameFormat.align = TextFormatAlign.CENTER;
			nameFormat.leading = -3;

			var nameField:GameField = new GameField(gls("{0} №{1}", Locations.getLocation(this._type).name, this.id), 66, 13, nameFormat);
			nameField.text = nameField.text.replace(" ", "\n");
			nameField.mouseEnabled = false;
			nameField.x -= nameField.width / 2;
			nameField.y -= nameField.height / 2;
			addChild(nameField);

			if (!Locations.getLocation(this._type).multiMode || this.modes == 0)
				return;

			var modesString:String = gls("Режимы:");

			for each (var index:int in Locations.getLocation(this._type).modes)
			{
				var bit:uint = 1 << index;

				if ((this.modes & bit) == 0)
					continue;

				modesString += "\n" + Locations.MODES[index]['name'];
			}

			new Status(this, modesString);
		}
	}
}