﻿package utils
{
	public class CountryUtil
	{
		static private const DATA:Array = [
			{'iso': "AU", 'id': 188, 'vkId': 19, 'name': "Австралия"},
			{'iso': "AT", 'id': 143, 'vkId': 20, 'name': "Австрия"},
			{'iso': "AZ", 'id': 141, 'vkId': 5, 'name': "Азербайджан"},
			{'iso': "AL", 'id': 241, 'vkId': 21, 'name': "Албания"},
			{'iso': "DZ", 'id': 242, 'vkId': 22, 'name': "Алжир"},
			{'iso': "AS", 'id': 243, 'vkId': 23, 'name': "Американское Самоа"},
			{'iso': "AI", 'id': 244, 'vkId': 24, 'name': "Ангилья"},
			{'iso': "AO", 'id': 245, 'vkId': 25, 'name': "Ангола"},
			{'iso': "AD", 'id': 246, 'vkId': 26, 'name': "Андорра"},
			{'iso': "AG", 'id': 189, 'vkId': 27, 'name': "Антигуа и Барбуда"},
			{'iso': "AR", 'id': 182, 'vkId': 28, 'name': "Аргентина"},
			{'iso': "AM", 'id': 142, 'vkId': 6, 'name': "Армения"},
			{'iso': "AW", 'id': 247, 'vkId': 29, 'name': "Аруба"},
			{'iso': "AF", 'id': 248, 'vkId': 30, 'name': "Афганистан"},
			{'iso': "BS", 'id': 190, 'vkId': 31, 'name': "Багамские острова"},
			{'iso': "BD", 'id': 249, 'vkId': 32, 'name': "Бангладеш"},
			{'iso': "BB", 'id': 191, 'vkId': 33, 'name': "Барбадос"},
			{'iso': "BH", 'id': 250, 'vkId': 34, 'name': "Бахрейн"},
			{'iso': "BY", 'id': 185, 'vkId': 3, 'name': "Беларусь"},
			{'iso': "BZ", 'id': 192, 'vkId': 35, 'name': "Белиз"},
			{'iso': "BE", 'id': 144, 'vkId': 36, 'name': "Бельгия"},
			{'iso': "BJ", 'id': 251, 'vkId': 37, 'name': "Бенин"},
			{'iso': "BM", 'id': 252, 'vkId': 38, 'name': "Бермуды"},
			{'iso': "BG", 'id': 145, 'vkId': 39, 'name': "Болгария"},
			{'iso': "BO", 'id': 253, 'vkId': 40, 'name': "Боливия"},
			{'iso': "BQ", 'id': 254, 'vkId': 235, 'name': "Бонайре, Синт-Эстатиус и Саба"},
			{'iso': "BA", 'id': 255, 'vkId': 41, 'name': "Босния и Герцеговина"},
			{'iso': "BW", 'id': 193, 'vkId': 42, 'name': "Ботсвана"},
			{'iso': "BR", 'id': 179, 'vkId': 43, 'name': "Бразилия"},
			{'iso': "BN", 'id': 256, 'vkId': 44, 'name': "Бруней"},
			{'iso': "BF", 'id': 257, 'vkId': 45, 'name': "Буркина Фасо"},
			{'iso': "BI", 'id': 258, 'vkId': 46, 'name': "Бурунди"},
			{'iso': "BT", 'id': 259, 'vkId': 47, 'name': "Бутан"},
			{'iso': "VU", 'id': 194, 'vkId': 48, 'name': "Вануату"},
			{'iso': "VA", 'id': 260, 'vkId': 233, 'name': "Ватикан"},
			{'iso': "GB", 'id': 146, 'vkId': 49, 'name': "Великобритания"},
			{'iso': "HU", 'id': 147, 'vkId': 50, 'name': "Венгрия"},
			{'iso': "VE", 'id': 261, 'vkId': 51, 'name': "Венесуэла"},
			{'iso': "VG", 'id': 262, 'vkId': 52, 'name': "Британские Виргинские острова"},
			{'iso': "VI", 'id': 263, 'vkId': 53, 'name': "Американские Виргинские острова"},
			{'iso': "TL", 'id': 264, 'vkId': 54, 'name': "Восточный Тимор"},
			{'iso': "VN", 'id': 265, 'vkId': 55, 'name': "Вьетнам"},
			{'iso': "GA", 'id': 266, 'vkId': 56, 'name': "Габон"},
			{'iso': "HT", 'id': 267, 'vkId': 57, 'name': "Гаити"},
			{'iso': "GY", 'id': 195, 'vkId': 58, 'name': "Гайана"},
			{'iso': "GM", 'id': 196, 'vkId': 59, 'name': "Гамбия"},
			{'iso': "GH", 'id': 197, 'vkId': 60, 'name': "Гана"},
			{'iso': "GP", 'id': 268, 'vkId': 61, 'name': "Гваделупа"},
			{'iso': "GT", 'id': 269, 'vkId': 62, 'name': "Гватемала"},
			{'iso': "GN", 'id': 270, 'vkId': 63, 'name': "Гвинея"},
			{'iso': "GW", 'id': 271, 'vkId': 64, 'name': "Гвинея-Бисау"},
			{'iso': "DE", 'id': 148, 'vkId': 65, 'name': "Германия"},
			{'iso': "GI", 'id': 272, 'vkId': 66, 'name': "Гибралтар"},
			{'iso': "HN", 'id': 273, 'vkId': 67, 'name': "Гондурас"},
			{'iso': "HK", 'id': 274, 'vkId': 68, 'name': "Гонконг"},
			{'iso': "GD", 'id': 198, 'vkId': 69, 'name': "Гренада"},
			{'iso': "GL", 'id': 275, 'vkId': 70, 'name': "Гренландия"},
			{'iso': "GR", 'id': 149, 'vkId': 71, 'name': "Греция"},
			{'iso': "GE", 'id': 171, 'vkId': 7, 'name': "Грузия"},
			{'iso': "GU", 'id': 276, 'vkId': 72, 'name': "Гуам"},
			{'iso': "DK", 'id': 150, 'vkId': 73, 'name': "Дания"},
			{'iso': "DJ", 'id': 277, 'vkId': 231, 'name': "Джибути"},
			{'iso': "DM", 'id': 199, 'vkId': 74, 'name': "Доминика"},
			{'iso': "DO", 'id': 278, 'vkId': 75, 'name': "Доминиканская Республика"},
			{'iso': "EG", 'id': 167, 'vkId': 76, 'name': "Египет"},
			{'iso': "ZM", 'id': 200, 'vkId': 77, 'name': "Замбия"},
			{'iso': "EH", 'id': 279, 'vkId': 78, 'name': "Западная Сахара"},
			{'iso': "ZW", 'id': 201, 'vkId': 79, 'name': "Зимбабве"},
			{'iso': "IL", 'id': 168, 'vkId': 8, 'name': "Израиль"},
			{'iso': "IN", 'id': 172, 'vkId': 80, 'name': "Индия"},
			{'iso': "ID", 'id': 280, 'vkId': 81, 'name': "Индонезия"},
			{'iso': "JO", 'id': 281, 'vkId': 82, 'name': "Иордания"},
			{'iso': "IQ", 'id': 282, 'vkId': 83, 'name': "Ирак"},
			{'iso': "IR", 'id': 283, 'vkId': 84, 'name': "Иран"},
			{'iso': "IE", 'id': 203, 'vkId': 85, 'name': "Ирландия"},
			{'iso': "IS", 'id': 284, 'vkId': 86, 'name': "Исландия"},
			{'iso': "ES", 'id': 151, 'vkId': 87, 'name': "Испания"},
			{'iso': "IT", 'id': 152, 'vkId': 88, 'name': "Италия"},
			{'iso': "YE", 'id': 285, 'vkId': 89, 'name': "Йемен"},
			{'iso': "CV", 'id': 286, 'vkId': 90, 'name': "Кабо-Верде"},
			{'iso': "KZ", 'id': 85, 'vkId': 4, 'name': "Казахстан"},
			{'iso': "KH", 'id': 287, 'vkId': 91, 'name': "Камбоджа"},
			{'iso': "CM", 'id': 204, 'vkId': 92, 'name': "Камерун"},
			{'iso': "CA", 'id': 177, 'vkId': 10, 'name': "Канада"},
			{'iso': "QA", 'id': 288, 'vkId': 93, 'name': "Катар"},
			{'iso': "KE", 'id': 205, 'vkId': 94, 'name': "Кения"},
			{'iso': "CY", 'id': 289, 'vkId': 95, 'name': "Кипр"},
			{'iso': "KI", 'id': 206, 'vkId': 96, 'name': "Кирибати"},
			{'iso': "CN", 'id': 173, 'vkId': 97, 'name': "Китай"},
			{'iso': "CO", 'id': 290, 'vkId': 98, 'name': "Колумбия"},
			{'iso': "KM", 'id': 291, 'vkId': 99, 'name': "Коморы"},
			{'iso': "CG", 'id': 292, 'vkId': 100, 'name': "Республика Конго"},
			{'iso': "CD", 'id': 293, 'vkId': 101, 'name': "ДР Конго"},
			{'iso': "CR", 'id': 294, 'vkId': 102, 'name': "Коста-Рика"},
			{'iso': "CI", 'id': 295, 'vkId': 103, 'name': "Кот-д’Ивуар"},
			{'iso': "CU", 'id': 296, 'vkId': 104, 'name': "Куба"},
			{'iso': "KW", 'id': 297, 'vkId': 105, 'name': "Кувейт"},
			{'iso': "KG", 'id': 135, 'vkId': 11, 'name': "Киргизия"},
			{'iso': "CW", 'id': 298, 'vkId': 138, 'name': "Кюрасао"},
			{'iso': "LA", 'id': 299, 'vkId': 106, 'name': "Лаос"},
			{'iso': "LV", 'id': 159, 'vkId': 12, 'name': "Латвия"},
			{'iso': "LS", 'id': 207, 'vkId': 107, 'name': "Лесото"},
			{'iso': "LR", 'id': 208, 'vkId': 108, 'name': "Либерия"},
			{'iso': "LB", 'id': 300, 'vkId': 109, 'name': "Ливан"},
			{'iso': "LY", 'id': 301, 'vkId': 110, 'name': "Ливия"},
			{'iso': "LT", 'id': 160, 'vkId': 13, 'name': "Литва"},
			{'iso': "LI", 'id': 302, 'vkId': 111, 'name': "Лихтенштейн"},
			{'iso': "LU", 'id': 303, 'vkId': 112, 'name': "Люксембург"},
			{'iso': "MU", 'id': 209, 'vkId': 113, 'name': "Маврикий"},
			{'iso': "MR", 'id': 304, 'vkId': 114, 'name': "Мавритания"},
			{'iso': "MG", 'id': 305, 'vkId': 115, 'name': "Мадагаскар"},
			{'iso': "MO", 'id': 306, 'vkId': 116, 'name': "Макао"},
			{'iso': "MK", 'id': 307, 'vkId': 117, 'name': "Республика Македония"},
			{'iso': "MW", 'id': 210, 'vkId': 118, 'name': "Малави"},
			{'iso': "MY", 'id': 308, 'vkId': 119, 'name': "Малайзия"},
			{'iso': "ML", 'id': 309, 'vkId': 120, 'name': "Мали"},
			{'iso': "MV", 'id': 310, 'vkId': 121, 'name': "Мальдивы"},
			{'iso': "MT", 'id': 211, 'vkId': 122, 'name': "Мальта"},
			{'iso': "MA", 'id': 311, 'vkId': 123, 'name': "Марокко"},
			{'iso': "MQ", 'id': 312, 'vkId': 124, 'name': "Мартиника"},
			{'iso': "MH", 'id': 212, 'vkId': 125, 'name': "Маршалловы"},
			{'iso': "MX", 'id': 313, 'vkId': 126, 'name': "Мексика"},
			{'iso': "FM", 'id': 235, 'vkId': 127, 'name': "Федеративные Штаты Микронезии"},
			{'iso': "MZ", 'id': 314, 'vkId': 128, 'name': "Мозамбик"},
			{'iso': "MD", 'id': 136, 'vkId': 15, 'name': "Молдова"},
			{'iso': "MC", 'id': 315, 'vkId': 129, 'name': "Монако"},
			{'iso': "MN", 'id': 316, 'vkId': 130, 'name': "Монголия"},
			{'iso': "MS", 'id': 317, 'vkId': 131, 'name': "Монтсеррат"},
			{'iso': "MM", 'id': 318, 'vkId': 132, 'name': "Мьянма"},
			{'iso': "NA", 'id': 213, 'vkId': 133, 'name': "Намибия"},
			{'iso': "NR", 'id': 214, 'vkId': 134, 'name': "Науру"},
			{'iso': "NP", 'id': 319, 'vkId': 135, 'name': "Непал"},
			{'iso': "NE", 'id': 320, 'vkId': 136, 'name': "Нигер"},
			{'iso': "NG", 'id': 215, 'vkId': 137, 'name': "Нигерия"},
			{'iso': "NL", 'id': 153, 'vkId': 139, 'name': "Нидерланды"},
			{'iso': "NI", 'id': 321, 'vkId': 140, 'name': "Никарагуа"},
			{'iso': "NU", 'id': 322, 'vkId': 141, 'name': "Ниуэ"},
			{'iso': "NZ", 'id': 215, 'vkId': 142, 'name': "Новая Зеландия"},
			{'iso': "NC", 'id': 323, 'vkId': 143, 'name': "Новая Каледония"},
			{'iso': "NO", 'id': 154, 'vkId': 144, 'name': "Норвегия"},
			{'iso': "AE", 'id': 169, 'vkId': 145, 'name': "ОАЭ"},
			{'iso': "OM", 'id': 324, 'vkId': 146, 'name': "Оман"},
			{'iso': "IM", 'id': 325, 'vkId': 147, 'name': "Остров Мэн"},
			{'iso': "NF", 'id': 326, 'vkId': 148, 'name': "Остров Норфолк"},
			{'iso': "KY", 'id': 327, 'vkId': 149, 'name': "Каймановы острова"},
			{'iso': "CK", 'id': 328, 'vkId': 150, 'name': "Острова Кука"},
			{'iso': "TC", 'id': 329, 'vkId': 151, 'name': "Тёркс и Кайкос"},
			{'iso': "PK", 'id': 216, 'vkId': 152, 'name': "Пакистан"},
			{'iso': "PW", 'id': 217, 'vkId': 153, 'name': "Палау"},
			{'iso': "PS", 'id': 330, 'vkId': 154, 'name': "Палестина"},
			{'iso': "PA", 'id': 331, 'vkId': 155, 'name': "Панама"},
			{'iso': "PG", 'id': 218, 'vkId': 156, 'name': "Папуа"},
			{'iso': "PY", 'id': 332, 'vkId': 157, 'name': "Парагвай"},
			{'iso': "PE", 'id': 333, 'vkId': 158, 'name': "Перу"},
			{'iso': "PN", 'id': 334, 'vkId': 159, 'name': "Острова Питкэрн"},
			{'iso': "PL", 'id': 155, 'vkId': 160, 'name': "Польша"},
			{'iso': "PT", 'id': 335, 'vkId': 161, 'name': "Португалия"},
			{'iso': "PR", 'id': 336, 'vkId': 162, 'name': "Пуэрто-Рико"},
			{'iso': "RE", 'id': 337, 'vkId': 163, 'name': "Реюньон"},
			{'iso': "RU", 'id': 183, 'vkId': 1, 'name': "Россия"},
			{'iso': "RW", 'id': 219, 'vkId': 164, 'name': "Руанда"},
			{'iso': "RO", 'id': 338, 'vkId': 165, 'name': "Румыния"},
			{'iso': "US", 'id': 178, 'vkId': 9, 'name': "США"},
			{'iso': "SV", 'id': 339, 'vkId': 166, 'name': "Сальвадор"},
			{'iso': "WS", 'id': 220, 'vkId': 167, 'name': "Самоа"},
			{'iso': "SM", 'id': 340, 'vkId': 168, 'name': "Сан-Марино"},
			{'iso': "ST", 'id': 341, 'vkId': 169, 'name': "Сан-Томе и Принсипи"},
			{'iso': "SA", 'id': 342, 'vkId': 170, 'name': "Саудовская Аравия"},
			{'iso': "SZ", 'id': 221, 'vkId': 171, 'name': "Свазиленд"},
			{'iso': "SH", 'id': 343, 'vkId': 172, 'name': "Остров Святой Елены"},
			{'iso': "KP", 'id': 344, 'vkId': 173, 'name': "КНДР"},
			{'iso': "MP", 'id': 345, 'vkId': 174, 'name': "Северные Марианские острова"},
			{'iso': "SC", 'id': 222, 'vkId': 175, 'name': "Сейшелы"},
			{'iso': "SN", 'id': 346, 'vkId': 176, 'name': "Сенегал"},
			{'iso': "VC", 'id': 223, 'vkId': 177, 'name': "Сент-Винсент и Гренадины"},
			{'iso': "KN", 'id': 224, 'vkId': 178, 'name': "Сент-Китс и Невис"},
			{'iso': "LC", 'id': 225, 'vkId': 179, 'name': "Сент-Люсия"},
			{'iso': "PM", 'id': 347, 'vkId': 180, 'name': "Сен-Пьер и Микелон"},
			{'iso': "RS", 'id': 156, 'vkId': 181, 'name': "Сербия"},
			{'iso': "SG", 'id': 226, 'vkId': 182, 'name': "Сингапур"},
			{'iso': "SX", 'id': 348, 'vkId': 234, 'name': "Синт-Мартен"},
			{'iso': "SY", 'id': 349, 'vkId': 183, 'name': "Сирия"},
			{'iso': "SK", 'id': 157, 'vkId': 184, 'name': "Словакия"},
			{'iso': "SI", 'id': 158, 'vkId': 185, 'name': "Словения"},
			{'iso': "SB", 'id': 227, 'vkId': 186, 'name': "Соломоновы Острова"},
			{'iso': "SO", 'id': 350, 'vkId': 187, 'name': "Сомали"},
			{'iso': "SD", 'id': 228, 'vkId': 188, 'name': "Судан"},
			{'iso': "SR", 'id': 351, 'vkId': 189, 'name': "Суринам"},
			{'iso': "SL", 'id': 229, 'vkId': 190, 'name': "Сьерра-Леоне"},
			{'iso': "TJ", 'id': 137, 'vkId': 16, 'name': "Таджикистан"},
			{'iso': "TH", 'id': 174, 'vkId': 191, 'name': "Таиланд"},
			{'iso': "TW", 'id': 352, 'vkId': 192, 'name': "Китайская Республика"},
			{'iso': "TZ", 'id': 230, 'vkId': 193, 'name': "Танзания"},
			{'iso': "TG", 'id': 353, 'vkId': 194, 'name': "Того"},
			{'iso': "TK", 'id': 354, 'vkId': 195, 'name': "Токелау"},
			{'iso': "TO", 'id': 231, 'vkId': 196, 'name': "Тонга"},
			{'iso': "TT", 'id': 232, 'vkId': 197, 'name': "Тринидад и Тобаго"},
			{'iso': "TV", 'id': 233, 'vkId': 198, 'name': "Тувалу"},
			{'iso': "TN", 'id': 355, 'vkId': 199, 'name': "Тунис"},
			{'iso': "TM", 'id': 138, 'vkId': 17, 'name': "Туркмения"},
			{'iso': "TR", 'id': 170, 'vkId': 200, 'name': "Турция"},
			{'iso': "UG", 'id': 234, 'vkId': 201, 'name': "Уганда"},
			{'iso': "UZ", 'id': 139, 'vkId': 18, 'name': "Узбекистан"},
			{'iso': "UA", 'id': 184, 'vkId': 2, 'name': "Украина"},
			{'iso': "WF", 'id': 356, 'vkId': 202, 'name': "Уоллис и Футуна"},
			{'iso': "UY", 'id': 357, 'vkId': 203, 'name': "Уругвай"},
			{'iso': "FO", 'id': 358, 'vkId': 204, 'name': "Фарерские острова"},
			{'iso': "FJ", 'id': 236, 'vkId': 205, 'name': "Фиджи"},
			{'iso': "PH", 'id': 237, 'vkId': 206, 'name': "Филиппины"},
			{'iso': "FI", 'id': 162, 'vkId': 207, 'name': "Финляндия"},
			{'iso': "FK", 'id': 359, 'vkId': 208, 'name': "Фолклендские острова"},
			{'iso': "FR", 'id': 163, 'vkId': 209, 'name': "Франция"},
			{'iso': "GF", 'id': 360, 'vkId': 210, 'name': "Французская Гвиана"},
			{'iso': "PF", 'id': 361, 'vkId': 211, 'name': "Французская Полинезия"},
			{'iso': "HR", 'id': 362, 'vkId': 212, 'name': "Хорватия"},
			{'iso': "CF", 'id': 363, 'vkId': 213, 'name': "ЦАР"},
			{'iso': "TD", 'id': 364, 'vkId': 214, 'name': "Чад"},
			{'iso': "ME", 'id': 365, 'vkId': 230, 'name': "Черногория"},
			{'iso': "CZ", 'id': 164, 'vkId': 215, 'name': "Чехия"},
			{'iso': "CL", 'id': 366, 'vkId': 216, 'name': "Чили"},
			{'iso': "CH", 'id': 165, 'vkId': 217, 'name': "Швейцария"},
			{'iso': "SE", 'id': 166, 'vkId': 218, 'name': "Швеция"},
			{'iso': "SJ", 'id': 367, 'vkId': 219, 'name': "Шпицберген и Ян Майен"},
			{'iso': "LK", 'id': 368, 'vkId': 220, 'name': "Шри-Ланка"},
			{'iso': "EC", 'id': 369, 'vkId': 221, 'name': "Эквадор"},
			{'iso': "GQ", 'id': 370, 'vkId': 222, 'name': "Экваториальная Гвинея"},
			{'iso': "ER", 'id': 237, 'vkId': 223, 'name': "Эритрея"},
			{'iso': "EE", 'id': 161, 'vkId': 14, 'name': "Эстония"},
			{'iso': "ET", 'id': 371, 'vkId': 224, 'name': "Эфиопия"},
			{'iso': "KR", 'id': 175, 'vkId': 226, 'name': "Южная Корея"},
			{'iso': "ZA", 'id': 238, 'vkId': 227, 'name': "Южно-Африканская Республика"},
			{'iso': "SS", 'id': 239, 'vkId': 232, 'name': "Южный Судан"},
			{'iso': "JM", 'id': 240, 'vkId': 228, 'name': "Ямайка"},
			{'iso': "JP", 'id': 176, 'vkId': 229, 'name': "Япония"},
			{'iso': "AB", 'id': 140, 'name': "Абхазия"},
			{'iso': "", 'id': 181, 'name': "Другая"}
		];

		static public function convertId(value:String, net:int):String
		{
			switch (net)
			{
				case Config.API_VK_ID:
					for (var i:int = 0; i < DATA.length; i++)
					{
						if (!('vkId' in DATA[i]) || int(value) != int(DATA[i]['vkId']))
							continue;
						return DATA[i]['id'];
					}
					break;
			}
			return value;
		}
	}
}