package clans
{
	import flash.utils.getTimer;

	public class TotemSlots
	{
		private var _slotData:Object = {};

		public var lastUpdate:int = 0;

		public function parseTotems(dataP:Array):void
		{
			clear();

			for (var i:int = 0; i < dataP.length; i += 3)
			{
				if (!(dataP[i] in this._slotData))
					this._slotData[dataP[i]] = {};

				this._slotData[dataP[i]]['totem_id'] = dataP[i + 2];
				this._slotData[dataP[i]]['expires'] = dataP[i + 1];
				this._slotData[dataP[i]]['slot_id'] = dataP[i];
			}

			this.lastUpdate = getTimer() / 1000;
		}

		public function haveTotem(id:int):Boolean
		{
			for each (var slot:Object in this._slotData)
			{
				if (slot['totem_id'] != id)
					continue;

				return slot['slot_id'] == 0 || getTimer() / 1000 < this.lastUpdate + slot['expires'];
			}

			return false;
		}

		public function getSlotId(id:int):int
		{
			for each (var slot:Object in this._slotData)
			{
				if (slot['totem_id'] != id)
					continue;

				return slot['slot_id'];
			}

			return -1;
		}

		public function getTotemId(slotId:int):int
		{
			if (!(slotId in this._slotData))
				return -1;

			return this._slotData[slotId]['totem_id'];
		}

		public function get slotData():Object
		{
			return this._slotData;
		}

		private function clear():void
		{
			for each (var slot:Object in this._slotData)
			{
				slot['totem_id'] = -1;
				slot['expires'] = 0;
			}
		}
	}
}