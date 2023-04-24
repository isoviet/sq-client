package game.mainGame
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;

	public class Backgrounds
	{
		static private const ParallaxFlyIsland:Array = [
			[BackgroundFly0Layer0, BackgroundFly0Layer1],
			[BackgroundFly1Layer0, BackgroundFly1Layer1]
		];

		static private const ParallaxMounts:Array = [
			[BackgroundSnowMounts0Layer0, BackgroundSnowMounts0Layer1],
			[BackgroundSnowMounts1Layer0, BackgroundSnowMounts1Layer1]
		];

		static private const ParallaxSwamps:Array = [
			[BackgroundSwamp0Layer0, BackgroundSwamp0Layer1],
			[BackgroundSwamp1Layer0, BackgroundSwamp1Layer1]
		];

		static private const ParallaxHard:Array = [
			[BackgroundHard0Layer0, BackgroundHard0Layer1],
			[BackgroundHard1Layer0, BackgroundHard1Layer1]
		];

		static private const ParallaxDesert:Array = [
			BackgroundDesert0Layer0, BackgroundDesert0Layer1
		];

		static private const ParallaxAnomalousZone:Array = [
			[BackgroundAnomalyZone0Layer0, BackgroundAnomalyZone0Layer1],
			[BackgroundAnomalyZone1Layer0, BackgroundAnomalyZone1Layer1],
			[BackgroundAnomalyZone2Layer0, BackgroundAnomalyZone2Layer1]
		];

		static private const ParallaxWild:Array = [
			BackgroundWild0Layer0, BackgroundWild0Layer1
		];

		static private const DATA:Array = [
			"Background0",
			"Background1",
			"Background2",
			"Background3",
			"Background4",
			"Background5",
			"Background6",
			"SeaBackGround1",
			"SeaBackGround2",
			"SeaBackGround3",
			"SeaBackGround4",
			"MountainsBackground1",
			"PineryBackground1",
			"PineryBackground2",
			"AnomalBackground1",
			"AnomalBackground2",
			"AnomalBackground3",
			"Background7",
			"Background8",
			"DesertBackground1",
			"DesertBackground2",
			"DesertBackground3",
			"DesertBackground4"
			//"IcelandBackground"
		];

		static public const SIMPLE:int = 0;

		static public function getParallaxBackground(locationId:int):Array
		{
			switch (locationId)
			{
				case Locations.ISLAND_ID:
				case Locations.SANDBOX_ID:
					return ParallaxFlyIsland[int(ParallaxFlyIsland.length * Math.random())];
				case Locations.MOUNTAIN_ID:
					return ParallaxMounts[int(ParallaxMounts.length * Math.random())];
				case Locations.SWAMP_ID:
					return ParallaxSwamps[int(ParallaxSwamps.length * Math.random())];
				case Locations.HARD_ID:
					return ParallaxHard[int(ParallaxHard.length * Math.random())];
				case Locations.ANOMAL_ID:
					return ParallaxAnomalousZone[int(ParallaxAnomalousZone.length * Math.random())];
				case Locations.DESERT_ID:
					return ParallaxDesert;
				case Locations.WILD_ID:
					return ParallaxWild;
			}
			return null;
		}

		static public function get():Array
		{
			return DATA;
		}

		static public function getImage(id:int):DisplayObject
		{
			if (id >= DATA.length)
				id = 0;

			return new (getDefinitionByName(DATA[id]) as Class)();
		}

		static public function getId(className:String):int
		{
			for (var id:int = 0; id < DATA.length; id++)
			{
				if (className == DATA[id])
					return id;
			}

			return -1;
		}
	}
}