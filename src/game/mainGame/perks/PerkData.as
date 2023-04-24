package game.mainGame.perks
{
	public class PerkData
	{
		private var _name:String = "";
		private var _description:String = "";
		private var _image:Class = null;
		private var _perk:Class = null;

		public function PerkData(name:String, description:String, image:Class, perk:Class):void
		{
			this._name = name;
			this._description = description;
			this._image = image;
			this._perk = perk;
		}

		public function get name():String
		{
			return this._name;
		}

		public function get description():String
		{
			return this._description;
		}

		public function get image():Class
		{
			return this._image;
		}

		public function get perk():Class
		{
			return this._perk;
		}
	}
}