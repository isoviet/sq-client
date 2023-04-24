package game.mainGame.perks.hare
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class HarePerkFactory
	{
		static public var perkData:Dictionary = new Dictionary(false);
		static public var i:* = HarePerkFactory.init();

		static public var perkCollection:Array = [
			PerkEarthQuake,
			PerkStone,
			PerkRun,
			PerkRebornHare,
			PerkGum,
			PerkSpit
		];

		static public function init():void
		{
			perkData[PerkEarthQuake] =
			{
				'name': gls("Землетрясение"),
				'description': gls("Устраивает землетрясение"),
				'buttonClass': HareEarthquakeButton,
				'inc': 5,
				'dec': 20
			};

			perkData[PerkStone] =
			{
				'name': gls("Окаменение"),
				'description': gls("Превращает тебя в камень. Так ты можешь мешаться на пути других белок, толкать их и не отдавать орех"),
				'buttonClass': HareStoneButton,
				'inc': 5,
				'dec': 5
			};

			perkData[PerkRun] =
			{
				'name': gls("Ускорение"),
				'description': gls("Увеличивает твою скорость в 3 раза"),
				'buttonClass': HareSpeed,
				'inc': 10,
				'dec': 20
			};

			perkData[PerkRebornHare] =
			{
				'name': gls("Возрождение"),
				'description': gls("Автоматически возрождает тебя рядом с шаманом через 10 секунд после смерти"),
				'buttonClass': HareRebornButton,
				'inc': 10,
				'dec': 0
			};

			perkData[PerkGum] =
			{
				'name': gls("Жвачка"),
				'description': gls("Плюнь жвачкой и склей белок!"),
				'buttonClass': HareGumButton,
				'inc': 5,
				'dec': 0
			};

			perkData[PerkSpit] =
			{
				'name': gls("Плевок"),
				'description': gls("Залепи жвачкой весь экран!"),
				'buttonClass': HareSpitButton,
				'inc': 0,
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