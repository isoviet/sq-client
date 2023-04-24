package landing.game
{
	public class Location
	{
		public var id:int = -1;
		public var name:String = "";
		public var level:int = -1;

		public function Location(id:int, name:String, level:int):void
		{
			this.id = id;
			this.name = name;
			this.level = level;
		}
	}
}