package landing.game.mainGame.gameEditor
{
	public class MapData
	{
		public var number:int;
		public var location:int;
		public var authorId:int;
		public var map:String;
		public var time:int;

		public function MapData():void
		{
			reset();
		}

		public function reset():void
		{
			this.number = -1;
			this.authorId = -1;
			this.map = "";
			this.time = 0;
		}

		public function isEqual(otherMap:MapData):Boolean
		{
			return (this.number == otherMap.number && this.location == otherMap.location && this.map == otherMap.map && this.time == otherMap.time);
		}

		public function copy(otherMap:MapData):void
		{
			this.location = otherMap.location;
			this.map = otherMap.map;
			this.time = otherMap.time;
		}

		public function load(packet:Array):void
		{
			this.authorId = packet[0];
			this.time = packet[1];
			this.map = packet[2];
		}
	}
}