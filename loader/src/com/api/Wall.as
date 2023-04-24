package com.api
{
	public class Wall
	{
		static public const WALL_AWARD:String = "AWARD";
		static public const WALL_EXP:String = "EXP";
		static public const WALL_PRESENT:String = "PRESENT";

		protected var type:String = "";
		protected var id:int;

		public function savePlace(type:String, id:int):void
		{
			this.type = type;
			this.id = id;
		}
	}
}