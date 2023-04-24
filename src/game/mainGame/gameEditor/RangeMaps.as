package game.mainGame.gameEditor
{
	public class RangeMaps
	{

		static private var maps:Array = [];

		static private var _seek:int = -1;

		static public function get currentMap():int
		{
			if (isEmpty)
				return -1;

			return maps[_seek];
		}

		static public function get first():int
		{
			if (isEmpty)
				return -1;

			return maps[0];
		}

		static public function get last():int
		{
			if (isEmpty)
				return -1;

			return maps[maps.length - 1];
		}

		static public function get isEmpty():Boolean
		{
			return maps.length <= 0;
		}

		static public function addMap(id:int):void
		{
			maps.push(id);

			maps.sort(Array.NUMERIC);

			_seek = 0;
		}

		static public function delMap(id:int):void
		{
			maps.splice(maps.indexOf(id), 1);
		}

		static public function nextMap():Boolean
		{
			if (_seek + 1 == maps.length)
				return false;

			_seek++;
			return true;
		}

		static public function prevMap():Boolean
		{
			if (_seek - 1 == -1)
				return false;

			_seek--;
			return true;
		}

		static public function clear():void
		{
			maps = [];
			_seek = -1;
		}
	}
}