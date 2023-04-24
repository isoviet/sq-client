package game.mainGame
{
	public class CollisionGroup
	{
		static public const OBJECT_NONE_CATEGORY:int = 0;
		static public const OBJECT_CATEGORY:int = 1;
		static public const OBJECT_GHOST_CATEGORY:int = 2;
		static public const OBJECT_GHOST_TO_OBJECT_CATEGORY:int = 4;
		static public const HERO_CATEGORY:int = 8;
		static public const HERO_SENSOR_CATEGORY:int = 16;
		static public const HERO_DETECTOR_CATEGORY:int = 32;
		static public const HERO_HEAD_WALKER:int = 64;
		static public const HERO_HEAD_WALKER_SENSOR:int = 128;
		static public const HARE_CATEGORY:int = 256;
		static public const HERO_GUMMED:int = 512;
		static public const HERO_NINJA:int = 1024;
		static public const HERO_NINJA_CLOUD:int = 2048;
	}
}