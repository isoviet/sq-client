package
{
	import protocol.PacketServer;

	public class Location
	{
		public var id:int = -1;
		public var name:String = "";
		public var level:int = 0;

		public var cost:int = 0;
		public var award:int = 0;

		public var teamMode:Boolean = false;
		public var multiMode:Boolean = false;
		public var multiMapMode:Boolean = false;
		public var game:Boolean = false;
		public var respawn:Boolean = false;

		public var nonHare:Boolean = false;
		public var nonPerk:Boolean = false;
		public var nonClothes:Boolean = false;
		public var nonItems:Boolean = false;

		public var subs:Array = null;
		public var modes:Array = null;
		public var mapModes:Array = null;

		public function Location(item:Object = null):void
		{
			if (item == null)
				return;

			if ("value" in item)
				this.id = item['value'];
			if ("name" in item)
				this.name = item['name'];
			if ("level" in item)
				this.level = item['level'];

			if ("cost" in item)
				this.cost = item['cost'];
			if ("award" in item)
				this.award = item['award'];

			if ("teamMode" in item)
				this.teamMode = Boolean(item['teamMode']);
			if ("game" in item)
				this.game = Boolean(item['game']);
			if ("respawn" in item)
				this.respawn = Boolean(item['respawn']);

			if ("nonHare" in item)
				this.nonHare = Boolean(item['nonHare']);
			if ("nonPerk" in item)
				this.nonPerk = Boolean(item['nonPerk']);
			if ("nonClothes" in item)
				this.nonClothes = Boolean(item['nonClothes']);
			if ("nonItems" in item)
				this.nonItems = Boolean(item['nonItems']);

			if ("subs" in item)
				this.subs = item['subs'];
			if ("modes" in item)
				this.modes = item['modes'];
			if ("mapModes" in item)
				this.mapModes = item['mapModes'];
			CONFIG::client
			{
				if ((Game.editor_access == PacketServer.EDITOR_FULL || Game.editor_access == PacketServer.EDITOR_SUPER) && item['mapModesFull'] != null)
					this.mapModes = this.mapModes.concat(item['mapModesFull']);
			}
			this.multiMode = this.modes != null && this.modes.length > 1;
			this.multiMapMode = this.mapModes != null && this.mapModes.length > 1;
		}
	}
}