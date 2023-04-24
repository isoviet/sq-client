package game.mainGame.perks.dragon
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class DragonPerkFactory
	{
		static public var perkData:Dictionary = new Dictionary(false);
		static public var i:* = DragonPerkFactory.init();

		static public var perkCollection:Array = [
			PerkRebornDragon,
			PerkFire
		];

		static public function init():void
		{
			perkData[PerkRebornDragon] =
			{
				'name': gls("Возрождение"),
				'description': gls("Автоматически возрождает тебя рядом с шаманом через 10 секунд после смерти"),
				'buttonClass': DragonRebornButton,
				'inc': 8,
				'dec': 0
			};

			perkData[PerkFire] =
			{
				'name': gls("Огненное дыхание"),
				'description': gls("Позволяет поджигать других белок"),
				'buttonClass': DragonFireButton,
				'inc': 20,
				'dec': 0
			};
		}

		static public function getPerk(id:int):Class
		{
			return perkCollection[id];
		}

		static public function getIconClassById(id:int):Class
		{
			return perkData[perkCollection[id]]['buttonClass'];
		}

		static public function getId(object:*):int
		{
			for (var id:int = 0; id < perkCollection.length; id++)
			{
				if (object is Class && object == perkCollection[id])
					return id;

				if (getQualifiedClassName(object) == getQualifiedClassName(perkCollection[id]))
					return id;
			}

			return -1;
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