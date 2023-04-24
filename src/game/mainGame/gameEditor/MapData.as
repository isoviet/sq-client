package game.mainGame.gameEditor
{
	import protocol.packages.server.PacketMapsMap;

	import utils.StringUtil;

	public class MapData
	{
		public var number:int;
		public var location:int;
		public var subLocation:int;
		public var mode:int;
		public var authorId:int;
		public var map:String;
		public var time:int;
		public var positiveVotes:int;
		public var negativeVotes:int;
		public var exitVotes:int;
		public var exitDeads:int;
		public var playsCount:int;

		public function MapData():void
		{
			reset();
		}

		public function reset():void
		{
			this.number = -1;
			this.mode = 0;
			this.authorId = -1;
			this.map = "";
			this.time = 0;
		}

		public function isEqual(otherMap:MapData):Boolean
		{
			return (this.number == otherMap.number && this.location == otherMap.location && this.subLocation == otherMap.subLocation && this.mode == otherMap.mode && this.map == otherMap.map && this.time == otherMap.time);
		}

		public function copy(otherMap:MapData):void
		{
			this.location = otherMap.location;
			this.subLocation = otherMap.subLocation;
			this.mode = otherMap.mode;
			this.map = otherMap.map;
			this.time = otherMap.time;
			this.number = otherMap.number;
		}

		public function load(packet:PacketMapsMap):void
		{
			this.mode = packet.mode;
			this.authorId = packet.authorId;
			this.time = packet.duration;
			this.map = StringUtil.ByteArrayToMap(packet.data);
			this.positiveVotes = packet.positiveRating;
			this.negativeVotes = packet.negativeRating;
			this.exitVotes = packet.exitRating;
			this.exitDeads = packet.deadExits;
			this.playsCount = packet.playsCount;
		}
	}
}