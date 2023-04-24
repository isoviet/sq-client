package game.gameData
{
	public class ConfigData
	{
		static public function get data():Object
		{
			//JSON START
			return {
				"payments": {
					"GOLDENCUP_DURATION": 2592000,
					"GOLDENCUP_COINS_AWARD": 12,
					"CHEETOS_NUTS": 100,
					"CHEETOS_COINS": 5,
					"CHEETOS_COINS_DURATION": 604800
				},
				"player": {
					"MAX_LEVEL": 200,
					"MAX_FREE_GAMES_LEVEL": 3,
					"levels": [
						{
							"experience": 0,
							"title": gls("Новичок")
						},
						{
							"experience": 10,
							"title": gls("Новичок")
						},
						{
							"experience": 50,
							"title": gls("Новичок")
						},
						{
							"experience": 110,
							"title": gls("Новичок")
						},
						{
							"experience": 200,
							"title": gls("Обаяшка")
						},
						{
							"experience": 300,
							"title": gls("Обаяшка")
						},
						{
							"experience": 425,
							"title": gls("Обаяшка")
						},
						{
							"experience": 590,
							"title": gls("Надежда племени")
						},
						{
							"experience": 1090,
							"title": gls("Надежда племени")
						},
						{
							"experience": 2565,
							"title": gls("Надежда племени")
						},
						{
							"experience": 5015,
							"title": gls("Любитель орехов")
						},
						{
							"experience": 8640,
							"title": gls("Любитель орехов")
						},
						{
							"experience": 13340,
							"title": gls("Любитель орехов")
						},
						{
							"experience": 19115,
							"title": gls("Упрямец")
						},
						{
							"experience": 25965,
							"title": gls("Упрямец")
						},
						{
							"experience": 33890,
							"title": gls("Упрямец")
						},
						{
							"experience": 42890,
							"title": gls("Исследователь")
						},
						{
							"experience": 50640,
							"title": gls("Исследователь")
						},
						{
							"experience": 57230,
							"title": gls("Исследователь")
						},
						{
							"experience": 62840,
							"title": gls("Орехбургер")
						},
						{
							"experience": 67610,
							"title": gls("Орехбургер")
						},
						{
							"experience": 71670,
							"title": gls("Орехбургер")
						},
						{
							"experience": 75125,
							"title": gls("Виртуоз")
						},
						{
							"experience": 78065,
							"title": gls("Виртуоз")
						},
						{
							"experience": 80565,
							"title": gls("Виртуоз")
						},
						{
							"experience": 83065,
							"title": gls("Гордость семьи")
						},
						{
							"experience": 86055,
							"title": gls("Гордость семьи")
						},
						{
							"experience": 89635,
							"title": gls("Гордость семьи")
						},
						{
							"experience": 93915,
							"title": gls("Любимец племени")
						},
						{
							"experience": 99035,
							"title": gls("Любимец племени")
						},
						{
							"experience": 105165,
							"title": gls("Любимец племени")
						},
						{
							"experience": 112500,
							"title": gls("Герой")
						},
						{
							"experience": 121275,
							"title": gls("Герой")
						},
						{
							"experience": 131775,
							"title": gls("Герой")
						},
						{
							"experience": 139515,
							"title": gls("Ураган")
						},
						{
							"experience": 147580,
							"title": gls("Ураган")
						},
						{
							"experience": 155985,
							"title": gls("Ураган")
						},
						{
							"experience": 164740,
							"title": gls("Старожил")
						},
						{
							"experience": 173860,
							"title": gls("Старожил")
						},
						{
							"experience": 183360,
							"title": gls("Старожил")
						},
						{
							"experience": 193260,
							"title": gls("Чемпион")
						},
						{
							"experience": 203575,
							"title": gls("Чемпион")
						},
						{
							"experience": 214325,
							"title": gls("Чемпион")
						},
						{
							"experience": 225525,
							"title": gls("Славный воин")
						},
						{
							"experience": 237195,
							"title": gls("Славный воин")
						},
						{
							"experience": 249350,
							"title": gls("Славный воин")
						},
						{
							"experience": 262015,
							"title": gls("Матерая белка")
						},
						{
							"experience": 275210,
							"title": gls("Матерая белка")
						},
						{
							"experience": 288955,
							"title": gls("Матерая белка")
						},
						{
							"experience": 303275,
							"title": gls("Рыжий зверь")
						},
						{
							"experience": 318195,
							"title": gls("Рыжий зверь")
						},
						{
							"experience": 333740,
							"title": gls("Рыжий зверь")
						},
						{
							"experience": 349935,
							"title": gls("Избранный")
						},
						{
							"experience": 366805,
							"title": gls("Избранный")
						},
						{
							"experience": 384385,
							"title": gls("Избранный")
						},
						{
							"experience": 402700,
							"title": gls("Красная масть")
						},
						{
							"experience": 421780,
							"title": gls("Красная масть")
						},
						{
							"experience": 441660,
							"title": gls("Красная масть")
						},
						{
							"experience": 462370,
							"title": gls("Звезда")
						},
						{
							"experience": 483950,
							"title": gls("Звезда")
						},
						{
							"experience": 506430,
							"title": gls("Звезда")
						},
						{
							"experience": 529850,
							"title": gls("Огненный смерч")
						},
						{
							"experience": 554250,
							"title": gls("Огненный смерч")
						},
						{
							"experience": 579670,
							"title": gls("Огненный смерч")
						},
						{
							"experience": 606160,
							"title": gls("Комета")
						},
						{
							"experience": 633755,
							"title": gls("Комета")
						},
						{
							"experience": 662505,
							"title": gls("Комета")
						},
						{
							"experience": 691255,
							"title": gls("Игроман")
						},
						{
							"experience": 719795,
							"title": gls("Игроман")
						},
						{
							"experience": 748130,
							"title": gls("Игроман")
						},
						{
							"experience": 776260,
							"title": gls("Неуловимый")
						},
						{
							"experience": 804185,
							"title": gls("Неуловимый")
						},
						{
							"experience": 831905,
							"title": gls("Неуловимый")
						},
						{
							"experience": 859425,
							"title": gls("Молниеносный")
						},
						{
							"experience": 886745,
							"title": gls("Молниеносный")
						},
						{
							"experience": 913865,
							"title": gls("Молниеносный")
						},
						{
							"experience": 940790,
							"title": gls("Властитель")
						},
						{
							"experience": 967520,
							"title": gls("Властитель")
						},
						{
							"experience": 994055,
							"title": gls("Властитель")
						},
						{
							"experience": 1020395,
							"title": gls("Космобелка")
						},
						{
							"experience": 1046545,
							"title": gls("Космобелка")
						},
						{
							"experience": 1072745,
							"title": gls("Космобелка")
						},
						{
							"experience": 1099120,
							"title": gls("Орехоман")
						},
						{
							"experience": 1125670,
							"title": gls("Орехоман")
						},
						{
							"experience": 1152400,
							"title": gls("Орехоман")
						},
						{
							"experience": 1179310,
							"title": gls("Смельчак")
						},
						{
							"experience": 1206400,
							"title": gls("Смельчак")
						},
						{
							"experience": 1233670,
							"title": gls("Смельчак")
						},
						{
							"experience": 1261125,
							"title": gls("Бывалый")
						},
						{
							"experience": 1288765,
							"title": gls("Бывалый")
						},
						{
							"experience": 1316590,
							"title": gls("Бывалый")
						},
						{
							"experience": 1344600,
							"title": gls("Весельчак")
						},
						{
							"experience": 1372800,
							"title": gls("Весельчак")
						},
						{
							"experience": 1401190,
							"title": gls("Весельчак")
						},
						{
							"experience": 1429770,
							"title": gls("Гончий")
						},
						{
							"experience": 1458540,
							"title": gls("Гончий")
						},
						{
							"experience": 1487500,
							"title": gls("Гончий")
						},
						{
							"experience": 1516660,
							"title": gls("Неистовый")
						},
						{
							"experience": 1546010,
							"title": gls("Неистовый")
						},
						{
							"experience": 1575560,
							"title": gls("Неистовый")
						},
						{
							"experience": 1605310,
							"title": gls("Шумахер")
						},
						{
							"experience": 1635260,
							"title": gls("Шумахер")
						},
						{
							"experience": 1665410,
							"title": gls("Шумахер")
						},
						{
							"experience": 1695760,
							"title": gls("Стремительный")
						},
						{
							"experience": 1726310,
							"title": gls("Стремительный")
						},
						{
							"experience": 1757070,
							"title": gls("Стремительный")
						},
						{
							"experience": 1788035,
							"title": gls("Просветленный")
						},
						{
							"experience": 1819205,
							"title": gls("Просветленный")
						},
						{
							"experience": 1850585,
							"title": gls("Просветленный")
						},
						{
							"experience": 1882175,
							"title": gls("Долгожитель")
						},
						{
							"experience": 1913975,
							"title": gls("Долгожитель")
						},
						{
							"experience": 1945990,
							"title": gls("Долгожитель")
						},
						{
							"experience": 1978220,
							"title": gls("Знаток")
						},
						{
							"experience": 2010665,
							"title": gls("Знаток")
						},
						{
							"experience": 2043330,
							"title": gls("Знаток")
						},
						{
							"experience": 2076215,
							"title": gls("Ветеран")
						},
						{
							"experience": 2109320,
							"title": gls("Ветеран")
						},
						{
							"experience": 2142645,
							"title": gls("Ветеран")
						},
						{
							"experience": 2176195,
							"title": gls("Непоседа")
						},
						{
							"experience": 2209970,
							"title": gls("Непоседа")
						},
						{
							"experience": 2243970,
							"title": gls("Непоседа")
						},
						{
							"experience": 2278370,
							"title": gls("Профессионал")
						},
						{
							"experience": 2314270,
							"title": gls("Профессионал")
						},
						{
							"experience": 2351735,
							"title": gls("Профессионал")
						},
						{
							"experience": 2390830,
							"title": gls("Следопыт")
						},
						{
							"experience": 2431630,
							"title": gls("Следопыт")
						},
						{
							"experience": 2474210,
							"title": gls("Следопыт")
						},
						{
							"experience": 2518645,
							"title": gls("Хвастунишка")
						},
						{
							"experience": 2565015,
							"title": gls("Хвастунишка")
						},
						{
							"experience": 2613405,
							"title": gls("Хвастунишка")
						},
						{
							"experience": 2663905,
							"title": gls("Экстремал")
						},
						{
							"experience": 2716605,
							"title": gls("Экстремал")
						},
						{
							"experience": 2771605,
							"title": gls("Экстремал")
						},
						{
							"experience": 2828995,
							"title": gls("МегаБелка")
						},
						{
							"experience": 2888890,
							"title": gls("МегаБелка")
						},
						{
							"experience": 2951395,
							"title": gls("МегаБелка")
						},
						{
							"experience": 3016625,
							"title": gls("Вождь")
						},
						{
							"experience": 3084695,
							"title": gls("Вождь")
						},
						{
							"experience": 3155735,
							"title": gls("Вождь")
						},
						{
							"experience": 3229865,
							"title": gls("Просвещенный")
						},
						{
							"experience": 3307225,
							"title": gls("Просвещенный")
						},
						{
							"experience": 3387960,
							"title": gls("Просвещенный")
						},
						{
							"experience": 3472210,
							"title": gls("Царь-Белка")
						},
						{
							"experience": 3560130,
							"title": gls("Царь-Белка")
						},
						{
							"experience": 3651885,
							"title": gls("Царь-Белка")
						},
						{
							"experience": 3747635,
							"title": gls("Самая лучшая белка")
						},
						{
							"experience": 3847560,
							"title": gls("Самая лучшая белка")
						},
						{
							"experience": 3951840,
							"title": gls("Самая лучшая белка")
						},
						{
							"experience": 4060665,
							"title": gls("Чак Норрис")
						},
						{
							"experience": 4174230,
							"title": gls("Чак Норрис")
						},
						{
							"experience": 4292745,
							"title": gls("Чак Норрис")
						},
						{
							"experience": 4416425,
							"title": gls("Чудесный")
						},
						{
							"experience": 4545495,
							"title": gls("Чудесный")
						},
						{
							"experience": 4680190,
							"title": gls("Чудесный")
						},
						{
							"experience": 4820755,
							"title": gls("Неустрашимый")
						},
						{
							"experience": 4967445,
							"title": gls("Неустрашимый")
						},
						{
							"experience": 5120525,
							"title": gls("Неустрашимый")
						},
						{
							"experience": 5280275,
							"title": gls("Терпеливый")
						},
						{
							"experience": 5446985,
							"title": gls("Терпеливый")
						},
						{
							"experience": 5620960,
							"title": gls("Терпеливый")
						},
						{
							"experience": 5799935,
							"title": gls("Суровый")
						},
						{
							"experience": 5989405,
							"title": gls("Суровый")
						},
						{
							"experience": 6187135,
							"title": gls("Суровый")
						},
						{
							"experience": 6393480,
							"title": gls("Созерцатель")
						},
						{
							"experience": 6608815,
							"title": gls("Созерцатель")
						},
						{
							"experience": 6833535,
							"title": gls("Созерцатель")
						},
						{
							"experience": 7068045,
							"title": gls("Проницательный")
						},
						{
							"experience": 7312775,
							"title": gls("Проницательный")
						},
						{
							"experience": 7568175,
							"title": gls("Проницательный")
						},
						{
							"experience": 7834700,
							"title": gls("Обожаемый")
						},
						{
							"experience": 8112840,
							"title": gls("Обожаемый")
						},
						{
							"experience": 8403100,
							"title": gls("Обожаемый")
						},
						{
							"experience": 8706010,
							"title": gls("Неукротимый")
						},
						{
							"experience": 9022120,
							"title": gls("Неукротимый")
						},
						{
							"experience": 9352005,
							"title": gls("Неукротимый")
						},
						{
							"experience": 9696265,
							"title": gls("Магистр")
						},
						{
							"experience": 10055525,
							"title": gls("Магистр")
						},
						{
							"experience": 10430440,
							"title": gls("Магистр")
						},
						{
							"experience": 10733350,
							"title": gls("Необузданный")
						},
						{
							"experience": 11084726,
							"title": gls("Необузданный")
						},
						{
							"experience": 11492322,
							"title": gls("Необузданный")
						},
						{
							"experience": 11965133,
							"title": gls("Магистр")
						},
						{
							"experience": 12513594,
							"title": gls("Магистр")
						},
						{
							"experience": 13149808,
							"title": gls("Магистр")
						},
						{
							"experience": 13887817,
							"title": gls("Искатель")
						},
						{
							"experience": 14743907,
							"title": gls("Искатель")
						},
						{
							"experience": 15736972,
							"title": gls("Искатель")
						},
						{
							"experience": 16888927,
							"title": gls("Бесстрашный")
						},
						{
							"experience": 18225195,
							"title": gls("Бесстрашный")
						},
						{
							"experience": 19775266,
							"title": gls("Бесстрашный")
						},
						{
							"experience": 21573348,
							"title": gls("Неумолимый")
						},
						{
							"experience": 23659123,
							"title": gls("Неумолимый")
						},
						{
							"experience": 26078622,
							"title": gls("Неумолимый")
						},
						{
							"experience": 28885241,
							"title": gls("Бессмертный")
						},
						{
							"experience": 32140919,
							"title": gls("Бессмертный")
						},
						{
							"experience": 35917505,
							"title": gls("Бессмертный")
						},
						{
							"experience": 40298345,
							"title": gls("Испытанный")
						},
						{
							"experience": 45380120,
							"title": gls("Испытанный")
						},
						{
							"experience": 51274979,
							"title": gls("Испытанный")
						},
						{
							"experience": 58113015,
							"title": gls("Божественный")
						},
						{
							"experience": 66045137,
							"title": gls("Чокнутый")
						}
					],
					"vip": [
						{
							"coins_price": 10,
							"duration": 86400
						},
						{
							"coins_price": 56,
							"duration": 604800
						},
						{
							"coins_price": 199,
							"duration": 2592000
						},
						{
							"coins_price": 0,
							"duration": 3600
						},
						{
							"coins_price": 0,
							"duration": 86400
						}
					],
					"skills": [0, 5, 10, 20, 30, 20, 10, 20, 50, 40, 15, 10, 5, 20, 15, 20, 15, 15, 20, 20, 5, 30, 20, 10, 20, 15, 10, 25, 20, 15, 20, 25, 25, 10, 20, 25, 5, 15, 5, 10, 20, 20, 25, 15, 15, 15, 20, 15, 15, 15, 15, 20, 5, 25, 20, 10, 0, 20, 10, 10, 5, 25, 10, 15, 15, 25, 10, 10, 20, 20, 15, 10, 25, 5, 15, 10, 25, 15, 20, 15, 10, 10, 5, 20, 20, 15, 10, 15, 15, 20, 15, 15, 5, 10, 5, 20, 20, 15, 15, 5, 10, 20, 20, 5, 20, 20, 5, 15, 5, 15, 10, 5, 5, 5, 5, 15, 10, 5]
				},
				"virality": {
					"quests": [
						5,
						2,
						3,
						4,
						0,
						1
					],
					"bonuses": [
						{
							"energy": 4,
							"mana": 5
						},
						{
							"energy": 6,
							"mana": 5
						},
						{
							"energy": 5,
							"mana": 5
						},
						{
							"energy": 5,
							"mana": 5
						},
						{
							"energy": 10,
							"mana": 10
						}
					]
				},
				"items": {
					"info": [
						{
							"nuts_price": 300,
							"coins_set_price": 5,
							"fast_coins_price": 3,
							"fast_count": 5
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 300,
							"coins_set_price": 5,
							"fast_coins_price": 3,
							"fast_count": 5
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 300,
							"coins_set_price": 5,
							"fast_coins_price": 3,
							"fast_count": 5
						},
						{
							"nuts_price": 600,
							"coins_set_price": 10,
							"fast_coins_price": 5,
							"fast_count": 5
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 600,
							"coins_set_price": 10,
							"fast_coins_price": 5,
							"fast_count": 5
						},
						{
							"nuts_price": 600,
							"coins_set_price": 10,
							"fast_coins_price": 5,
							"fast_count": 5
						},
						{
							"nuts_price": 600,
							"coins_set_price": 10,
							"fast_coins_price": 5,
							"fast_count": 5
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 150,
							"coins_set_price": 5,
							"fast_coins_price": 3,
							"fast_count": 5
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 600,
							"coins_set_price": 10,
							"fast_coins_price": 5,
							"fast_count": 5
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 150,
							"coins_set_price": 5,
							"fast_coins_price": 3,
							"fast_count": 5
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						},
						{
							"nuts_price": 0,
							"coins_set_price": 0,
							"fast_coins_price": 0,
							"fast_count": 0
						}
					]
				},
				"clothes": {
					"accessories" :
						[
							{"coins_price" : 49,	"place" : 1,	"character" : 0},
							{"coins_price" : 49,	"place" : 1},
							{"coins_price" : 49,	"place" : 1,	"character" : 0},
							{"coins_price" : 0,	"place" : 1},
							{"coins_price" : 49,	"place" : 1},
							{"coins_price" : 49,	"place" : 1,	"character" : 0},
							{"coins_price" : 49,	"place" : 0},
							{"coins_price" : 49,	"place" : 0},
							{"coins_price" : 49,	"place" : 0},
							{"coins_price" : 49,	"place" : 0,	"character" : 0},
							{"coins_price" : 49,	"place" : 0},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2,	"character" : 0},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2,	"character" : 0},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 2,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 0,	"place" : 3},
							{"coins_price" : 49,	"place" : 3},
							{"coins_price" : 0,	"place" : 3,	"character" : 0},
							{"coins_price" : 49,	"place" : 3,	"character" : 0},
							{"coins_price" : 49,	"place" : 3,	"character" : 0},
							{"coins_price" : 49,	"place" : 3,	"character" : 0},
							{"coins_price" : 0,	"place" : 3},
							{"coins_price" : 49,	"place" : 5},
							{"coins_price" : 49,	"place" : 3},
							{"coins_price" : 49,	"place" : 3,	"character" : 0},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 0},
							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 0},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 0,	"place" : 0},
							{"coins_price" : 0,	"place" : 3},
							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 0,	"place" : 3,	"character" : 0},
							{"coins_price" : 49,	"place" : 2,	"character" : 0},
							{"coins_price" : 49,	"place" : 4,	"character" : 0},

							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 0,	"place" : 0},
							{"coins_price" : 0,	"place" : 0},
							{"coins_price" : 0,	"place" : 0,	"character" : 0},
							{"coins_price" : 0,	"place" : 5,	"character" : 0},

							{"coins_price" : 49,	"place" : 0},
							{"coins_price" : 49,	"place" : 2},

							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 5},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 0},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 3},
							{"coins_price" : 0,	"place" : 0},

							{"coins_price" : 0,	"place" : 5,	"character" : 0},
							{"coins_price" : 0,	"place" : 1,	"character" : 0},
							{"coins_price" : 0,	"place" : 1,	"character" : 0},

							{"coins_price" : 0,	"place" : 0,	"character" : 0},
							{"coins_price" : 0,	"place" : 1,	"character" : 0},
							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 0,	"place" : 5,	"character" : 0},

							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 0,	"place" : 5},
							{"coins_price" : 0,	"place" : 0},
							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 0,	"place" : 1},
							{"coins_price" : 0,	"place" : 2},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 0,	"place" : 3},
							{"coins_price" : 0,	"place" : 4},
							{"coins_price" : 0,	"place" : 5},

							{"coins_price" : 0,	"place" : 0,	"character" : 0},
							{"coins_price" : 0,	"place" : 1,	"character" : 0},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 0,	"place" : 5,	"character" : 0},
							{"coins_price" : 0,	"place" : 5,	"character" : 0},

							{"coins_price" : 49,	"place" : 3},
							{"coins_price" : 49,	"place" : 2},
							{"coins_price" : 49,	"place" : 4},
							{"coins_price" : 49,	"place" : 5},
							{"coins_price" : 49,	"place" : 2},

							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 0,	"place" : 3,	"character" : 0},
							{"coins_price" : 0,	"place" : 5,	"character" : 0},

							{"coins_price" : 0,	"place" : 1,	"character" : 0},
							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 0,	"place" : 3,	"character" : 0},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},
							{"coins_price" : 0,	"place" : 5,	"character" : 0},

							{"coins_price" : 0,	"place" : 0,	"character" : 0},
							{"coins_price" : 0,	"place" : 1,	"character" : 0},
							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 0,	"place" : 4,	"character" : 0},

							{"coins_price" : 0,	"place" : 0,	"character" : 0},
							{"coins_price" : 0,	"place" : 1,	"character" : 0},
							{"coins_price" : 0,	"place" : 2,	"character" : 0},
							{"coins_price" : 0,	"place" : 4,	"character" : 0}
						],
					"packages" :
						[
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [54],	"skills" : {"11" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {"14" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {"13" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [76],	"skills" : {"12" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [66],	"skills" : {"15" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {"16" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"17" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"18" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"19" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [],	"skills" : {"20" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"21" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"22" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"23" : 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [142, 143, 144],	"skills" : {"24" : 0}},
							{"coins_price" : 149*0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},//{"25" : 0}},
							{"coins_price" : 149*0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},//{"26" : 0}},
							{"coins_price" : 999,	"max_level" : 0,	"accessories" : [26, 64],	"skills" : {"27" : 0}},
							{"coins_price" : 999,	"max_level" : 0,	"accessories" : [27, 65],	"skills" : {"28" : 0}},
							{"coins_price" : 999,	"max_level" : 0,	"accessories" : [],	"skills" : {"29" : 0}},
							{"coins_price" : 999*0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},//{"30" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"31" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"32" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"34" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"33" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [8, 30, 71],	"skills" : {"35" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [7, 16, 51],	"skills" : {"36" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [12, 40],	"skills" : {"37" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [34],	"skills" : {"38" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"40" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [77],	"skills" : {"39" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [45],	"skills" : {"41" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [25, 63],	"skills" : {"42" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [19, 56],	"skills" : {"43" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"44" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [50],	"skills" : {"45" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [37, 82],	"skills" : {"46" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [52],	"skills" : {"47" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"50" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"51" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [],	"skills" : {"52" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [10, 79],	"skills" : {"53" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"54" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {"55" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [],	"skills" : {"56" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [],	"skills" : {"57" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [4],	"skills" : {"58" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [],	"skills" : {"59" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [],	"skills" : {"60" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [46],	"skills" : {"61" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {"62" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [1],	"skills" : {"63" : 0}},
							{"coins_price" : 49,	"max_level" : 0,	"accessories" : [62],	"skills" : {}},//{"64" : 0}},
							{"coins_price" : 49,	"max_level" : 0,	"accessories" : [],	"skills" : {}},//{"65" : 0}},
							{"coins_price" : 49,	"max_level" : 0,	"accessories" : [32, 48],	"skills" : {}},//{"66" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [44, 85],	"skills" : {"67" : 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [38, 83],	"skills" : {"68" : 0, "69" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [36, 81],	"skills" : {"70" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [23, 60],	"skills" : {"71" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [78],	"skills" : {"72" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [72],	"skills" : {"73" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [29, 69],	"skills" : {"74" : 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [80],	"skills" : {"76" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [47],	"skills" : {"75" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [35, 96],	"skills" : {"77" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [13],	"skills" : {"78" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [75],	"skills" : {"79" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {"80" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [22, 59],	"skills" : {"81" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [73, 84],	"skills" : {"82" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [86],	"skills" : {"83" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [70, 92, 93],	"skills" : {"84" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"85" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [6, 41],	"skills" : {"86" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [14],	"skills" : {}},//{"87" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [15, 43],	"skills" : {"88" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"89" : 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"90" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [31],	"skills" : {"91" : 0}},
							{"coins_price" : 49,	"max_level" : 0,	"accessories" : [18],	"skills" : {"92" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [21, 58],	"skills" : {"93" : 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [67],	"skills" : {"94" : 0}},
							{"coins_price" : 0,	"max_level" : 10,	"accessories" : [11, 95],	"skills" : {"95" : 0, "96" : 5}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [33],	"skills" : {"97" : 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [20],	"skills" : {"98" : 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},//{"48" : 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},//{"49" : 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 49,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 49,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [3, 68, 91],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [97, 98],	"skills" : {"99": 1, "100": 5, "101": 10, "102": 13, "0": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [99],	"skills" : {"0": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [103],	"skills" : {"0": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {"0": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [100, 101, 102],	"skills" : {"0": 0}},
							{"coins_price" : 99,	"max_level" : 0,	"accessories" : [106],	"skills" : {"103": 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [107],	"skills" : {"104": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [110, 108, 109, 113],	"skills" : {"105": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [111, 108, 109, 113],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [112, 108, 109, 113],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [112, 108, 109, 113],	"skills" : {}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [114, 115],	"skills" : {"106": 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"107": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [],	"skills" : {}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [116, 117, 118],	"skills" : {"108": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [119, 120, 121],	"skills" : {"109": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [122, 123, 124],	"skills" : {"110": 0}},
							{"coins_price" : 149*0,	"max_level" : 0,	"accessories" : [],	"skills" : {"111": 0}},
							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [],	"skills" : {"112": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [133, 134, 135],	"skills" : {"113": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [136, 137, 138],	"skills" : {"114": 0}},
							{"coins_price" : 0,	"max_level" : 0,	"accessories" : [139, 140, 141],	"skills" : {"115": 0}},

							{"coins_price" : 349,	"max_level" : 0,	"accessories" : [150, 151, 152],	"skills" : {"116": 0}},
							{"coins_price" : 149,	"max_level" : 0,	"accessories" : [153, 154],	"skills" : {"117": 0}}
						],
					"outfits" :
						[
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [110, 115, 133]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [0, 1, 2, 3]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [4, 5, 6, 134]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [7, 8, 9, 10]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [11, 12, 13, 14, 15]},
							{"rent_coins_price" : 99,	"character" : 0,	"packages" : [16, 17, 18, 19, 118]},
							{"rent_coins_price" : 99,	"character" : 0,	"packages" : [20, 21, 22, 23]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [24, 25]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [26, 27, 119]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [28, 29, 126, 128]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [30, 31, 120]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [32, 33, 137]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [34, 129, 136]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [35, 36]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [37, 117, 132]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [38, 39, 40, 41]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [42, 43, 44]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [45, 46, 47]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [48, 49, 131]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [50, 51, 52, 53, 54]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [55]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [56, 57, 58, 59, 60, 116]},
							{"rent_coins_price" : 99,	"character" : 0,	"packages" : [62, 135]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [63]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [64, 65, 66, 125]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [67, 68, 69]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [70, 71, 130]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [72, 73, 74, 75, 76]},
							{"rent_coins_price" : 14,	"character" : 0,	"packages" : [77, 78, 79, 80]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [81]},
							{"rent_coins_price" : 34,	"character" : 0,	"packages" : [82, 83]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [111, 84, 85, 86, 87, 88, 89, 90, 91]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [112, 92, 93, 94, 95, 96, 97, 98, 99]},
							{"rent_coins_price" : 9,	"character" : 1,	"packages" : [100, 101, 102]},
							{"rent_coins_price" : 34,	"character" : 1,	"packages" : [103, 104]},
							{"rent_coins_price" : 34,	"character" : 1,	"packages" : [106, 107, 108, 109]},
							{"rent_coins_price" : 34,	"character" : 1,	"packages" : [105]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [113]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [114]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [121, 122, 123, 124]},
							{"rent_coins_price" : 0,	"character" : 1,	"packages" : [127]},
							{"rent_coins_price" : 0,	"character" : 0,	"packages" : [61]}
						]
				},
				"smiles": {
					"packages": [
						{
							"coins_price": 49,
							"nuts_price": 0,
							"elements": [
								0,
								1,
								2,
								3,
								4,
								5,
								6,
								7,
								8,
								9,
								25,
								26,
								27,
								28
							]
						},
						{
							"coins_price": 0,
							"nuts_price": 0,
							"elements": [
								10,
								11,
								12,
								13,
								14
							]
						},
						{
							"coins_price": 50,
							"nuts_price": 0,
							"elements": [
								15,
								16,
								17,
								18,
								19,
								20,
								21,
								22,
								23,
								24
							]
						}
					]
				},
				"bans": {
					"bans": [
						{
							"title": gls("Нет бана"),
							"hide": true
						},
						{
							"title": gls("Флуд"),
							"hide": false
						},
						{
							"title": gls("Нарушение в чате"),
							"hide": false
						},
						{
							"title": gls("Ненорматив в имени"),
							"hide": false
						},
						{
							"title": gls("Грубое нарушение на карте"),
							"hide": false
						},
						{
							"title": gls("Использование стороннего ПО"),
							"hide": false
						},
						{
							"title": gls("Использование стороннего ПО"),
							"hide": true
						},
						{
							"title": gls("Использование стороннего ПО"),
							"hide": true
						},
						{
							"title": gls("Использование стороннего ПО"),
							"hide": true
						},
						{
							"title": gls("Грубое нарушение в чате"),
							"hide": true
						},
						{
							"title": gls("Использование стороннего ПО"),
							"hide": true
						},
						{
							"title": gls("Использование стороннего ПО"),
							"hide": true
						},
						{
							"title": gls("Оскорбление администрации"),
							"hide": true
						},
						{
							"title": gls("Покупка/Продажа аккаунта"),
							"hide": true
						}
					]
				},
				"maps": {
					"ADDITION_NUTS_PRICE": 200,
					"locations": [
						{
							"energy_price": 10,
							"energy_refund_ratio": 0.5,
							"min_level": 0,
							"addition_nuts_award": 3500,
							"is_gaming": true
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 0.5,
							"min_level": 8,
							"addition_nuts_award": 3500,
							"is_gaming": true
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 0.5,
							"min_level": 14,
							"addition_nuts_award": 5000,
							"is_gaming": true
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 1,
							"min_level": 21,
							"addition_nuts_award": 7500,
							"is_gaming": true
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 1,
							"min_level": 32,
							"addition_nuts_award": 6500,
							"is_gaming": true
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 1,
							"min_level": 18,
							"addition_nuts_award": 10000,
							"is_gaming": true
						},
						{
							"energy_price": 15,
							"energy_refund_ratio": 0.5,
							"min_level": 0,
							"addition_nuts_award": 10000,
							"is_gaming": true
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 1,
							"min_level": 27,
							"addition_nuts_award": 6500,
							"is_gaming": true
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 0,
							"min_level": 7,
							"addition_nuts_award": 0,
							"is_gaming": true
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 0,
							"energy_refund_ratio": 0,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": false
						},
						{
							"energy_price": 10,
							"energy_refund_ratio": 0.5,
							"min_level": 0,
							"addition_nuts_award": 0,
							"is_gaming": true
						}
					],
					"location_round_info": [
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						}
					],
					"mode_round_info": [
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": true,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": true,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": false,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": true,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": true,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": false,
							"has_buying_dragon": false,
							"has_buying_rabbit": false,
							"has_buying_shaman": false,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						},
						{
							"valid": true,
							"has_shaman": true,
							"has_buying_dragon": true,
							"has_buying_rabbit": false,
							"has_buying_shaman": true,
							"has_many_rabbits": false
						}
					],
					"default_round_info": {
						"valid": false,
						"has_shaman": false,
						"has_buying_dragon": false,
						"has_buying_rabbit": false,
						"has_buying_shaman": false,
						"has_many_rabbits": false
					}
				},
				"room": {
					"respawns_duration": [
						0,
						0,
						3,
						0,
						5,
						3,
						3,
						3,
						0,
						0,
						0,
						0
					]
				},
				"searching": {},
				"quest": {
					"MIN_LEVEL": 4,
					"quests": [
						[
							[
								5,
								4,
								4,
								3,
								2,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								3,
								0,
								0,
								0,
								0,
								0
							],
							[
								5,
								5,
								5,
								5,
								5,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0
							],
							[
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								1,
								0,
								0,
								0,
								0,
								0
							],
							[
								20,
								18,
								15,
								8,
								5,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								7,
								0,
								0,
								0,
								0,
								0
							],
							[
								6,
								5,
								4,
								2,
								1,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								2,
								0,
								0,
								0,
								0,
								0
							],
							[
								5,
								4,
								4,
								3,
								1,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								3,
								0,
								0,
								0,
								0,
								0
							],
							[
								20,
								18,
								15,
								8,
								5,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								7,
								0,
								0,
								0,
								0,
								0
							],
							[
								5,
								4,
								4,
								3,
								1,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								3,
								0,
								0,
								0,
								0,
								0
							],
							[
								20,
								18,
								15,
								8,
								4,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								7,
								0,
								0,
								0,
								0,
								0
							],
							[
								7,
								6,
								6,
								5,
								4,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								5,
								0,
								0,
								0,
								0,
								0
							],
							[
								5,
								4,
								4,
								3,
								1,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								3,
								0,
								0,
								0,
								0,
								0
							],
							[
								5,
								4,
								4,
								3,
								2,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0
							],
							[
								5,
								4,
								4,
								2,
								1,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								2,
								0,
								0,
								0,
								0,
								0
							],
							[
								0,
								5,
								5,
								10,
								10,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								10,
								0,
								0,
								0,
								0,
								0
							]
						],
						[
							[
								10,
								8,
								8,
								6,
								4,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								6,
								0,
								0,
								0,
								0,
								0
							],
							[
								10,
								10,
								10,
								10,
								10,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0
							],
							[
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								3,
								0,
								0,
								0,
								0,
								0
							],
							[
								30,
								28,
								25,
								18,
								14,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								16,
								0,
								0,
								0,
								0,
								0
							],
							[
								15,
								12,
								8,
								6,
								3,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								6,
								0,
								0,
								0,
								0,
								0
							],
							[
								10,
								8,
								8,
								6,
								2,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								6,
								0,
								0,
								0,
								0,
								0
							],
							[
								30,
								28,
								25,
								18,
								14,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								16,
								0,
								0,
								0,
								0,
								0
							],
							[
								10,
								8,
								8,
								6,
								2,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								6,
								0,
								0,
								0,
								0,
								0
							],
							[
								40,
								36,
								34,
								28,
								20,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								26,
								0,
								0,
								0,
								0,
								0
							],
							[
								15,
								12,
								12,
								10,
								8,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								10,
								0,
								0,
								0,
								0,
								0
							],
							[
								10,
								8,
								8,
								6,
								2,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								6,
								0,
								0,
								0,
								0,
								0
							],
							[
								10,
								8,
								8,
								6,
								4,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0
							],
							[
								10,
								8,
								8,
								5,
								3,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								5,
								0,
								0,
								0,
								0,
								0
							],
							[
								0,
								15,
								15,
								30,
								30,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								30,
								0,
								0,
								0,
								0,
								0
							]
						]
					],
					"awards": [
						{
							"nuts": 50,
							"mana": 30,
							"experience": [
								{
									"min_level": 0,
									"experience": 30
								},
								{
									"min_level": 8,
									"experience": 50
								},
								{
									"min_level": 14,
									"experience": 70
								},
								{
									"min_level": 18,
									"experience": 120
								}
							]
						},
						{
							"nuts": 80,
							"mana": 40,
							"experience": [
								{
									"min_level": 0,
									"experience": 60
								},
								{
									"min_level": 8,
									"experience": 100
								},
								{
									"min_level": 14,
									"experience": 140
								},
								{
									"min_level": 18,
									"experience": 240
								}
							]
						}
					]
				},
				"interior": {
					"decorations": [
						{
							"type": 0,
							"coins_price": 0,
							"nuts_price": 0
						},
						{
							"type": 0,
							"coins_price": 32,
							"nuts_price": 5000
						},
						{
							"type": 0,
							"coins_price": 35,
							"nuts_price": 0
						},
						{
							"type": 1,
							"coins_price": 0,
							"nuts_price": 0
						},
						{
							"type": 1,
							"coins_price": 23,
							"nuts_price": 3000
						},
						{
							"type": 1,
							"coins_price": 25,
							"nuts_price": 0
						},
						{
							"type": 2,
							"coins_price": 9,
							"nuts_price": 1000
						},
						{
							"type": 2,
							"coins_price": 15,
							"nuts_price": 2000
						},
						{
							"type": 2,
							"coins_price": 19,
							"nuts_price": 0
						},
						{
							"type": 3,
							"coins_price": 0,
							"nuts_price": 0
						},
						{
							"type": 3,
							"coins_price": 35,
							"nuts_price": 5000
						},
						{
							"type": 3,
							"coins_price": 39,
							"nuts_price": 0
						},
						{
							"type": 4,
							"coins_price": 29,
							"nuts_price": 4000
						},
						{
							"type": 4,
							"coins_price": 32,
							"nuts_price": 5000
						},
						{
							"type": 4,
							"coins_price": 35,
							"nuts_price": 0
						},
						{
							"type": 5,
							"coins_price": 0,
							"nuts_price": 0
						},
						{
							"type": 5,
							"coins_price": 15,
							"nuts_price": 2000
						},
						{
							"type": 5,
							"coins_price": 15,
							"nuts_price": 0
						},
						{
							"type": 6,
							"coins_price": 9,
							"nuts_price": 1000
						},
						{
							"type": 6,
							"coins_price": 15,
							"nuts_price": 2000
						},
						{
							"type": 6,
							"coins_price": 19,
							"nuts_price": 0
						},
						{
							"type": 7,
							"coins_price": 0,
							"nuts_price": 0
						},
						{
							"type": 7,
							"coins_price": 46,
							"nuts_price": 6000
						},
						{
							"type": 7,
							"coins_price": 49,
							"nuts_price": 0
						},
						{
							"type": 8,
							"coins_price": 8,
							"nuts_price": 1000
						},
						{
							"type": 8,
							"coins_price": 15,
							"nuts_price": 2000
						},
						{
							"type": 8,
							"coins_price": 19,
							"nuts_price": 0
						},
						{
							"type": 9,
							"coins_price": 7,
							"nuts_price": 1000
						},
						{
							"type": 9,
							"coins_price": 7,
							"nuts_price": 1000
						},
						{
							"type": 9,
							"coins_price": 9,
							"nuts_price": 0
						},
						{
							"type": 10,
							"coins_price": 15,
							"nuts_price": 2000
						},
						{
							"type": 10,
							"coins_price": 23,
							"nuts_price": 3000
						},
						{
							"type": 10,
							"coins_price": 25,
							"nuts_price": 0
						},
						{
							"type": 11,
							"coins_price": 23,
							"nuts_price": 3000
						},
						{
							"type": 11,
							"coins_price": 29,
							"nuts_price": 4000
						},
						{
							"type": 11,
							"coins_price": 29,
							"nuts_price": 0
						},
						{
							"type": 12,
							"coins_price": 29,
							"nuts_price": 4000
						},
						{
							"type": 12,
							"coins_price": 39,
							"nuts_price": 5000
						},
						{
							"type": 12,
							"coins_price": 39,
							"nuts_price": 0
						}
					],
					"default_set": [
						0,
						3,
						9,
						15,
						21
					]
				},
				"shaman": {
					"MAX_LEVEL": 50,
					"SKILL_FREE_LEVELS": 3,
					"SKILL_PAID_LEVELS": 3,
					"PAID_PER_FEATHERS": 2,
					"levels": [
						80,
						300,
						720,
						1400,
						2400,
						3780,
						5600,
						7920,
						10800,
						14300,
						18480,
						23400,
						29120,
						35700,
						40044,
						45408,
						52152,
						60636,
						71220,
						84264,
						100128,
						119172,
						141756,
						168240,
						198984,
						234348,
						274692,
						320376,
						371760,
						403274,
						436469,
						471883,
						510058,
						551532,
						596846,
						646541,
						701155,
						761230,
						827304,
						899918,
						979613,
						1066927,
						1162402,
						1266576,
						1330905,
						1399713,
						1474442,
						1556531,
						1647419,
						1748548
					],
					"learn_coins_price": [
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							50,
							50,
							5
						],
						[
							50,
							50,
							5
						],
						[
							50,
							50,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							50,
							50,
							5
						],
						[
							50,
							50,
							5
						],
						[
							50,
							50,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							0,
							0,
							0
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							35,
							35,
							5
						],
						[
							50,
							50,
							5
						],
						[
							50,
							50,
							5
						],
						[
							50,
							50,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						],
						[
							70,
							70,
							5
						]
					]
				},
				"achievements": {},
				"collections": {
					"unique_set": [
						[
							0,
							1,
							2,
							3,
							4
						],
						[
							5,
							6,
							7,
							8,
							9
						],
						[
							10,
							11,
							12,
							13,
							14
						],
						[
							15,
							16,
							17,
							18,
							19
						],
						[
							20,
							21,
							22,
							23,
							24
						],
						[
							25,
							26,
							27,
							28,
							29
						],
						[
							30,
							31,
							32,
							33,
							34
						],
						[
							35,
							36,
							37,
							38,
							39
						],
						[
							40,
							41,
							42,
							43,
							44
						],
						[
							45,
							46,
							47,
							48,
							49
						],
						[],
						[
							55,
							56,
							57,
							58,
							59
						],
						[
							60,
							61,
							62,
							63,
							64
						],
						[],
						[],
						[],
						[],
						[],
						[
							70,
							71,
							72,
							73,
							74
						],
						[
							75,
							76,
							77,
							78,
							79
						],
						[
							80,
							81,
							82,
							83,
							84
						],
						[
							85,
							86,
							87,
							88,
							89
						],
						[
							90,
							91,
							92,
							93,
							94
						],
						[
							95,
							96,
							97,
							98,
							99
						],
						[
							100,
							101,
							102,
							103,
							104
						],
						[
							105,
							106,
							107,
							108,
							109
						],
						[
							110,
							111,
							112,
							113,
							114
						],
						[
							115,
							116,
							117,
							118,
							119
						],
						[
							120,
							121,
							122,
							123,
							124
						],
						[
							125,
							126,
							127,
							128,
							129
						],
						[
							130,
							131,
							132,
							133,
							134
						],
						[
							135,
							136,
							137,
							138,
							139
						],
						[
							140,
							141,
							142,
							143,
							144
						],
						[
							145,
							146,
							147,
							148,
							149
						]
					],
					"trophy_set": [
						[
							0,
							1,
							2,
							3,
							4,
							5,
							6,
							7,
							24,
							25,
							20,
							21
						],
						[],
						[
							0,
							1,
							2,
							3,
							4,
							5,
							6,
							7,
							26,
							27,
							22,
							23
						],
						[
							6,
							7,
							28,
							29,
							32,
							33,
							30,
							31,
							26,
							27,
							20,
							21
						],
						[
							6,
							7,
							28,
							29,
							32,
							33,
							30,
							31,
							26,
							27,
							20,
							21
						],
						[
							5,
							6,
							19,
							28,
							12,
							32,
							9,
							30,
							24,
							27,
							20,
							23
						],
						[
							5,
							6,
							19,
							28,
							12,
							32,
							9,
							30,
							24,
							27,
							20,
							23
						],
						[
							4,
							7,
							18,
							29,
							11,
							33,
							8,
							31,
							24,
							25,
							22,
							23
						],
						[
							4,
							7,
							18,
							29,
							11,
							33,
							8,
							31,
							24,
							25,
							22,
							23
						],
						[
							6,
							7,
							28,
							29,
							32,
							33,
							30,
							31,
							25,
							26,
							21,
							22
						],
						[
							6,
							7,
							28,
							29,
							32,
							33,
							30,
							31,
							25,
							26,
							21,
							22
						],
						[
							6,
							7,
							28,
							29,
							11,
							12,
							8,
							9,
							26,
							27,
							22,
							23
						],
						[
							6,
							7,
							28,
							29,
							11,
							12,
							8,
							9,
							26,
							27,
							22,
							23
						],
						[
							4,
							5,
							18,
							19,
							32,
							33,
							30,
							31,
							24,
							25,
							20,
							21
						],
						[
							4,
							5,
							18,
							19,
							32,
							33,
							30,
							31,
							24,
							25,
							20,
							21
						],
						[
							5,
							6,
							19,
							28,
							12,
							32,
							9,
							30,
							25,
							26,
							20,
							23
						],
						[
							5,
							6,
							19,
							28,
							12,
							32,
							9,
							30,
							25,
							26,
							20,
							23
						],
						[
							5,
							6,
							19,
							28,
							12,
							32,
							9,
							30,
							24,
							27,
							21,
							22
						],
						[
							5,
							6,
							19,
							28,
							12,
							32,
							9,
							30,
							24,
							27,
							21,
							22
						]
					],
					"regular_coins_price": [
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						10,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						20,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						0,
						0,
						0,
						0,
						0,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						0,
						0,
						0,
						0,
						0,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						15,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						40,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						50,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30,
						30
					],
					"unique_experience": [
						500,
						500,
						750,
						750,
						1000,
						1000,
						1000,
						1000,
						2500,
						2500,
						0,
						2000,
						2000,
						0,
						0,
						0,
						0,
						0,
						1500,
						1500,
						500,
						500,
						500,
						500,
						1500,
						1500,
						1500,
						1500,
						1500,
						1500,
						2500,
						2500,
						2000,
						2000
					]
				},
				"replays": {},
				"chat": {},
				"training": {},
				"ratings": {
					"leagues": [
						[
							{
								"name": gls("Нет"),
								"min_scores": 0
							},
							{
								"name": gls("Бронза"),
								"min_scores": 500
							},
							{
								"name": gls("Серебро"),
								"min_scores": 2500
							},
							{
								"name": gls("Золото"),
								"min_scores": 6000
							},
							{
								"name": gls("Мастер"),
								"min_scores": 10000
							},
							{
								"name": gls("Алмаз"),
								"min_scores": 50000
							},
							{
								"name": gls("Чемпион"),
								"min_scores": 100000
							}
						],
						[
							{
								"name": gls("Нет"),
								"min_scores": 0
							},
							{
								"name": gls("Бронза"),
								"min_scores": 500
							},
							{
								"name": gls("Серебро"),
								"min_scores": 2500
							},
							{
								"name": gls("Золото"),
								"min_scores": 6000
							},
							{
								"name": gls("Мастер"),
								"min_scores": 10000
							},
							{
								"name": gls("Алмаз"),
								"min_scores": 50000
							},
							{
								"name": gls("Чемпион"),
								"min_scores": 100000
							}
						]
					]
				}
			};
			//JSON END
		}
	}
}