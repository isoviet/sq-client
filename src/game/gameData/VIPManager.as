package game.gameData
{
	import flash.events.EventDispatcher;

	import dialogs.DialogRebuyVIP;
	import events.GameEvent;
	import screens.Screens;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketBuy;

	public class VIPManager
	{
		static public const VIP_DAY:int = 0;
		static public const VIP_WEEK:int = 1;
		static public const VIP_MONTH:int = 2;
		static public const VIP_HOUR:int = 3;
		static public const VIP_PACK:int = 4;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var lastState:Boolean = false;
		static public var respawnAfterBuy:Boolean = false;

		static public function init():void
		{
			Connection.listen(onPacket, PacketBuy.PACKET_ID);

			ExpirationsManager.addEventListener(GameEvent.EXPIRATIONS_CHANGE, onExpiration);
		}

		static private function onExpiration(e:GameEvent):void
		{
			if (e.data['type'] != ExpirationsManager.VIP)
				return;
			if (lastState == ExpirationsManager.haveExpiration(ExpirationsManager.VIP))
				return;
			lastState = ExpirationsManager.haveExpiration(ExpirationsManager.VIP);
			dispatcher.dispatchEvent(new GameEvent(lastState ? GameEvent.VIP_START : GameEvent.VIP_END));
			dispatcher.dispatchEvent(new GameEvent(GameEvent.CHANGED));

			if (!lastState)
				Screens.addCallback(DialogRebuyVIP.show);
		}

		static public function buy(type:int):Boolean
		{
			return Game.buyWithoutPay(PacketClient.BUY_VIP, GameConfig.getVIPCoinsPrice(type), 0, Game.selfId, type);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function get durationString():String
		{
			return ExpirationsManager.getDurationString(ExpirationsManager.VIP);
		}

		static public function get haveVIP():Boolean
		{
			return ExpirationsManager.haveExpiration(ExpirationsManager.VIP);
		}

		static private function onPacket(packet:PacketBuy):void
		{
			if (packet.status != PacketServer.BUY_SUCCESS || packet.targetId != Game.selfId)
				return;
			switch (packet.goodId)
			{
				case PacketClient.BUY_VIP:
					if (packet.data != VIP_DAY || !respawnAfterBuy)
						break;
					respawnAfterBuy = false;
					Connection.sendData(PacketClient.ROUND_RESPAWN, PacketServer.RESPAWN_VIP);
					break;
			}
		}
	}
}