package game.mainGame.gameBattleNet.achieves
{
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	import game.mainGame.events.AchieveEvent;

	import interfaces.IDispose;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundDie;

	public class AchieveKills extends EventDispatcher implements IDispose
	{
		static private const BONUS_DELAY:int = 10000;

		private var counter:int = 0;
		private var lastKillTime:int = 0;

		public function AchieveKills():void
		{
			Connection.listen(onPacket, PacketRoundDie.PACKET_ID);
		}

		public function dispose():void
		{
			Connection.forget(onPacket, PacketRoundDie.PACKET_ID);
		}

		public function kill():void
		{
			var currentTime:int = getTimer();
			if (currentTime - this.lastKillTime < BONUS_DELAY)
			{
				this.counter++;
				this.lastKillTime = currentTime;
				switch(this.counter)
				{
					case 2:
						dispatchEvent(new AchieveEvent(AchieveEvent.DOUBLE_KILL));
						break;
					case 3:
						dispatchEvent(new AchieveEvent(AchieveEvent.TRIPLE_KILL));
						break;
					case 4:
						dispatchEvent(new AchieveEvent(AchieveEvent.MEGA_KILL));
						break;
				}
				return;
			}

			this.counter = 1;
			this.lastKillTime = currentTime;
		}

		private function onPacket(packet:PacketRoundDie):void
		{
			if (packet.reason != Game.selfId)
				return;

			kill();
		}
	}
}