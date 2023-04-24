package
{
	import protocol.PacketClient;

	public class DrinkItemsData
	{
		static public const ENERGY_BIG_ID:int = 0;
		static public const MANA_BIG_ID:int = 1;
		static public const REGENERATION_ID:int = 2;

		static public const DATA:Array = [
			{'type': PacketClient.BUY_ENERGY_BIG,		'title': gls("Энергетический Напиток"),			'description': gls("Прибавляет 250 энергии к имеющейся, независимо от того, сколько у тебя её сейчас.")},
			{'type': PacketClient.BUY_MANA_BIG,		'title': gls("Колдовской Отвар"),			'description': gls("Прибавляет {0} маны к имеющейся, независимо от того, сколько у тебя ее сейчас.", 400)},
			{'type': PacketClient.BUY_MANA_REGENERATION,	'title': gls("Зелье Могущества"),			'description': gls("Прибавляет 25 маны в минуту. Не может превысить максимум.")}
		];

		static public function get itemsCount():int
		{
			return DATA.length;
		}

		static public function get items():Array
		{
			return [ENERGY_BIG_ID, MANA_BIG_ID, REGENERATION_ID];
		}

		static public function getTitle(id:int):String
		{
			return DATA[id]['title'];
		}

		static public function getDescription(id:int):String
		{
			if (id == MANA_BIG_ID && DiscountManager.haveDiscount(DiscountManager.DOUBLE_MANA_NP))
				return gls("Прибавляет {0} маны к имеющейся, независимо от того, сколько у тебя ее сейчас.", 1000);
			return DATA[id]['description'];
		}

		static public function getType(id:int):int
		{
			return DATA[id]['type'];
		}
	}
}