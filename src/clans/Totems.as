package clans
{
	public class Totems
	{
		private var _totemData:Object = {};

		public function parseTotemsRangs(dataP:Array):void
		{
			for (var i:int = 0; i < dataP.length; i += 4)
			{
				if (!(dataP[i] in this._totemData))
					this._totemData[dataP[i]] = {};

				this._totemData[dataP[i]]['totem_id'] = dataP[i];
				this._totemData[dataP[i]]['level'] = dataP[i + 1];
				this._totemData[dataP[i]]['exp'] = dataP[i + 2];
				this._totemData[dataP[i]]['max_exp'] = Number(dataP[i + 3]);
			}
		}

		public function parseTotemsBonuses(dataP:Array):void
		{
			for (var i:int = 0; i < dataP.length; i += 2)
			{
				if (!(dataP[i] in this._totemData))
					this._totemData[dataP[i]] = {};

				this._totemData[dataP[i]]['totem_id'] = dataP[i];
				this._totemData[dataP[i]]['bonus'] = dataP[i + 1];
			}
		}

		public function getTotemBonus(id:int):int
		{
			if (!(id in this._totemData))
				return 0;

			return this._totemData[id]['bonus'];
		}

		public function getTotemData(id:int):Object
		{
			if (!(id in this._totemData))
				return null;

			return this._totemData[id];
		}
	}
}