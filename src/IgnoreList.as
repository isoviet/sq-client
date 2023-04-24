package
{
	public class IgnoreList
	{
		static private var ignored:Object = {};

		static public function ignore(id:int):void
		{
			if (isIgnored(id))
				return;

			ignored[id] = id;
		}

		static public function unignore(id:int):void
		{
			if (!isIgnored(id))
				return;

			delete ignored[id];
		}

		static public function isIgnored(id:int):Boolean
		{
			return id in ignored;
		}
	}
}