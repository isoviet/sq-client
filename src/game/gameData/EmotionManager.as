package game.gameData
{
	import flash.events.EventDispatcher;

	import events.GameEvent;

	import protocol.Connection;
	import protocol.packages.server.PacketSmiles;

	public class EmotionManager
	{
		static public const PACKS_NAME:Array = [gls("Смайлы «Белки»")];
		static public const PACKS_TEXT:Array = [gls("Большой набор смайлов для белки.\nПоказывайте игрокам свои уникальные эмоции.")];

		static public const NAMES:Array = [gls("Улыбаюсь"), gls("Смеюсь"), gls("Смущаюсь"), gls("Целую"),
			gls("Лицо рука"),gls("Cкууучно"),gls("Удивлён"), gls("Грущу"), gls("Плачу"), gls("Злюсь"),
			//Пасха
			gls("Смеюсь"), gls("Целую"), gls("Плачу"), gls("Смущаюсь"), gls("В отчаянии"),
			//Новый год
			gls("Смеюсь"), gls("Улыбаюсь"), gls("Смущаюсь"), gls("Целую"), gls("В отчаянии"),
			gls("Сплю"),gls("Удивлён"), gls("Огорчён"), gls("Плачу"), gls("Злюсь"),
			//дополнительные 25
			gls("Умиляюсь"), gls("В шоке"), gls("Дразню"), gls("Извини")];

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static public var smiles:Vector.<int> = new <int>[];

		static public function init():void
		{
			Connection.listen(onPacket, PacketSmiles.PACKET_ID);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static private function onPacket(packet:PacketSmiles):void
		{
			smiles = packet.smiles;

			dispatcher.dispatchEvent(new GameEvent(GameEvent.SMILES_CHANGED));
		}
	}
}