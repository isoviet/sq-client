package game.mainGame.perks.mana
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import game.mainGame.perks.PerkData;

	public class PerkFactory
	{
		static public const SKILL_INVISIBLE:int = 1;
		static public const SKILL_BOLT:int = 2;
		static public const SKILL_HIGH_JUMP:int = 3;
		static public const SKILL_DOUBLE_JUMP:int = 4;
		static public const SKILL_FLYING:int = 5;
		static public const SKILL_ROUGH:int = 6;
		static public const SKILL_BARBARIAN:int = 7;
		static public const SKILL_RESURECTION:int = 8;
		static public const SKILL_TELEPORT:int = 9;
		static public const SKILL_TINY:int = 10;

		static public const MAX_TYPE:int = 11;

		static public const PERK_TOOLBAR:Array = [
			SKILL_INVISIBLE,
			SKILL_BOLT,
			SKILL_ROUGH,
			SKILL_TINY,
			SKILL_BARBARIAN,
			SKILL_HIGH_JUMP,
			SKILL_FLYING,
			SKILL_DOUBLE_JUMP,
			SKILL_TELEPORT,
			SKILL_RESURECTION
		];

		static public var perkData:Dictionary = new Dictionary(false);
		static public var i:* = PerkFactory.init();

		static public function init():void
		{
			perkData[SKILL_INVISIBLE] = new PerkData(gls("Невидимка"), gls("Делает Белку прозрачной, в неё не попадают шары"), InvisibleButton, PerkInvisible);
			perkData[SKILL_BOLT] = new PerkData(gls("Белка-молния"), gls("Белка бегает быстрее на 20%"), HighSpeedButton, PerkHighSpeed);
			perkData[SKILL_ROUGH] = new PerkData(gls("Цепкие лапки"), gls("Белка не скользит ни по земле, ни по льду"), HightFrictionButton, PerkHighFriction);
			perkData[SKILL_HIGH_JUMP] = new PerkData(gls("Высокий прыжок"), gls("Белка прыгает выше на 16%"), HighJumpButton, PerkHighJump);
			perkData[SKILL_FLYING] = new PerkData(gls("Белка-летяга"), gls("Если жать клавишу «вверх», белка вместо быстрого падения медленно парит"), SlowFallButton, PerkSlowFall);
			perkData[SKILL_DOUBLE_JUMP] = new PerkData(gls("Двойной прыжок"), gls("Белка сможет делать двойные прыжки, второй раз отталкиваясь от воздуха"), DoubleJumpButton, PerkDoubleJump);
			perkData[SKILL_BARBARIAN] = new PerkData(gls("Белка-варвар"), gls("Позволяет ходить по головам других белок"), HeadWalkerButton, PerkHeadWalker);
			perkData[SKILL_RESURECTION] = new PerkData(gls("Реинкарнация"), gls("Воскрешает Белку рядом с шаманом"), ReincarnationButton, PerkReborn);
			perkData[SKILL_TELEPORT] = new PerkData(gls("Телепортация"), gls("Мгновенное перемещение к шаману"), TeleportButton, PerkTeleport);
			perkData[SKILL_TINY] = new PerkData(gls("Малыш"), gls("Уменьшение размера белки"), SmallSizeButton, PerkSmallSize);
		}

		static public function getNewImage(id:int):DisplayObject
		{
			return new (perkData[id] as PerkData).image;
		}

		static public function getImageClass(id:int):Class
		{
			return (perkData[id] as PerkData).image;
		}

		static public function getName(id:int):String
		{
			return (perkData[id] as PerkData).name;
		}

		static public function getDescription(id:int):String
		{
			return (perkData[id] as PerkData).description;
		}

		static public function getPerkClass(id:int):Class
		{
			if (id in perkData)
				return (perkData[id] as PerkData).perk;
			return null;
		}

		static public function getData(object:*):Object
		{
			for(var objectClass:* in perkData)
			{
				if (getQualifiedClassName(objectClass) == getQualifiedClassName(object))
					return perkData[objectClass];
			}
			return null;
		}
	}
}