package game.gameData
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.utils.getTimer;

	import loaders.RuntimeLoader;

	import com.api.Services;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DialogOfferManager
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 16px;
				color: #2D1B00;
				text-align: center
			}
			.red {
				color: #CC0000;
				font-weight: bold;
			}
			]]>).toString();

		static private const OFFERS:Array = [{'start': 1471305600, 'end': 1471564800, 'button': ButtonOfferOK0, 'view': OfferOKView0, 'text': "<body>Только <span class='red'>16, 17 и 18-го авгутса</span> – участвуй в <span class='red'>беспроигрышной лотерее!</span>\nПолучай лотерейный билет за покупку ОК-ов, который предоставит тебе <span class='red'>бонус 40%</span> на все покупки <span class='red'>ОК-ов</span> любыми средствами в течение суток!</body>"},
							{'start': 1472515200, 'end': 1472774400, 'button': ButtonOfferOK0, 'view': OfferOKView0, 'text': "<body>Только <span class='red'>30, 31 августа и 1-го сентября</span> – участвуй в <span class='red'>беспроигрышной лотерее!</span>\nПолучай лотерейный билет за покупку ОК-ов, который предоставит тебе <span class='red'>бонус 40%</span> на все покупки <span class='red'>ОК-ов</span> любыми средствами в течение суток!</body>"}
							//{'start': 1464566400, 'end': 1464739200, 'button': ButtonOfferOK0, 'view': OfferOKView0, 'text': "<body>Только <span class='red'>30 и 31-го мая</span> – участвуй в <span class='red'>беспроигрышной лотерее!</span>\nПолучай лотерейный билет за покупку ОК-ов, который предоставит тебе <span class='red'>бонус от 20% до 60%</span> на все покупки <span class='red'>ОК-ов</span> любыми средствами в течение суток!</body>"}
							//{'start': 1451347200, 'end': 1451520000, 'button': ButtonOfferOK1, 'view': OfferOKView1, 'text': "<body>\nТолько <span class='red'>29 и 30-го декабря</span> – для абонентов <span class='red'>Билайн, Мегафон и МТС</span>\nпри покупке ОКов стоимость <span class='red'>1 ОК = 1 рубль</span></body>"}];
							];

		static private const SHOWED:int = 0;
		static private const USED:int = 1;

		static public const VIP_GAME:int = 0;
		static public const VIP_REBUY:int = 1;
		static public const PACKAGE_REBUY:int = 2;
		static public const NEWS:int = 3;
		static public const VIP_GAME_STATUS:int = 4;
		static public const INVITE_TIMEOUT:int = 5;

		static public const NAMES:Array = ['vip_game'];
		static private const TIMEOUT:Array = [24 * 60 * 60];

		static private var offers:Object = {};
		static private var times:Object = {};

		static private var style:StyleSheet = new StyleSheet();

		static public function init():void
		{
			style.parseCSS(CSS);
			times = SettingsStorage.load(SettingsStorage.DIALOGS_BUYING);
			SettingsStorage.addCallback(SettingsStorage.DIALOGS_BUYING, onLoad);
		}

		static public function showed(type:int):void
		{
			if (!(type in offers))
				offers[type] = 0;
			offers[type]++;

			Connection.sendData(PacketClient.COUNT, PacketClient.DIALOG_CTR, (type << 16) + (offers[type] << 8) + SHOWED);
		}

		static public function used(type:int):void
		{
			Connection.sendData(PacketClient.COUNT, PacketClient.DIALOG_CTR, (type << 16) + (offers[type] << 8) + USED);
		}

		static public function getAllow(type:int):Boolean
		{
			var time:int = getTimer() / 1000 + Game.unix_time;
			var lastShow:int = NAMES[type] in times ? times[NAMES[type]] : 0;

			if (time < lastShow + TIMEOUT[type])
				return false;

			times[NAMES[type]] = time;
			SettingsStorage.save(SettingsStorage.DIALOGS_BUYING, times);
			return true;
		}

		static public function getButtonOfferOK():SimpleButton
		{
			var answer:SimpleButton = null;

			for (var i:int = 0; i < OFFERS.length; i++)
			{
				if (Game.unix_time < OFFERS[i]['start'] || OFFERS[i]['end'] < Game.unix_time)
					continue;
				var viewClass:Class = OFFERS[i]['button'];
				answer = new viewClass();
			}
			return answer;
		}

		static public function getViewOfferOK():MovieClip
		{
			var answer:MovieClip = null;

			for (var i:int = 0; i < OFFERS.length; i++)
			{
				if (Game.unix_time < OFFERS[i]['start'] || OFFERS[i]['end'] < Game.unix_time)
					continue;
				var viewClass:Class = OFFERS[i]['view'];
				answer = new viewClass();
				answer.buttonBank.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
				{
					RuntimeLoader.load(function():void
					{
						Services.bank.open();
					});

					Connection.sendData(PacketClient.COUNT, PacketClient.COUNT_OFFER_OK);
				});

				var field:GameField = new GameField(OFFERS[i]['text'], 21, 42, style, 655);
				answer.addChild(field);
			}
			return answer;
		}

		static private function onLoad():void
		{
			times = SettingsStorage.load(SettingsStorage.DIALOGS_BUYING);
		}
	}
}