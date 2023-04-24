package utils.anchorHelp
{
	public class AnchorEnum
	{
		private static const GAME_MAGIC_ANCHOR:String = 'gameMagicAnchor';
		private static const GAME_MANNA_ANCHOR:String = 'gameMannaAnchor';

		private var _type:String = '';

		public static var GameMagicAnchor:AnchorEnum = new AnchorEnum(GAME_MAGIC_ANCHOR);
		public static var GameMannaAnchor:AnchorEnum = new AnchorEnum(GAME_MANNA_ANCHOR);

		public function AnchorEnum(type:String)
		{
			_type = type;
		}

		public function toString():String
		{
			return _type;
		}
	}
}