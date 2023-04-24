package
{
	import interfaces.IPlay;

	public class GameSoundsLib
	{
		public static var gameSounds:IPlay;
		public static function play(name:String):void
		{
			gameSounds.play(name);
		}
	}
}