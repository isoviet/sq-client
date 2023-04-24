package game.mainGame.gameEvent
{
	import game.mainGame.GameMap;
	import game.mainGame.IHealth;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameNet.SquirrelCollectionNet;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundRespawn;

	public class SquirrelCollectionVolcano extends SquirrelCollectionNet
	{
		private var scoresSurvival:Object = {};

		public function SquirrelCollectionVolcano()
		{
			super();

			this.heroClass = HeroVolcano;
		}

		public function get scores():Object
		{
			var health:Object = {};
			for each (var hero:Hero in this.players)
				health[hero.id] = (hero as IHealth).health;
			return {"time": this.scoresSurvival, "health": health};
		}

		public function set scores(value:Object):void
		{
			this.scoresSurvival = value['time'];
			var health:Object = value['health'];
			for each (var hero:Hero in this.players)
				(hero as IHealth).health = hero.id in health ? health[hero.id] : 0;
		}

		override public function checkSquirrelsCount(resetAvailable:Boolean = true):void
		{}

		override protected function initCastItems():void
		{}

		override public function reset():void
		{
			super.reset();

			this.scoresSurvival = {};

			for each (var hero:Hero in this.players)
				this.scoresSurvival[hero.id] = 0;

			checkSquirrelsCount();
		}

		override protected function onSelfDie(e:SquirrelEvent = null):void
		{
			Connection.sendData(PacketClient.ROUND_DIE, Hero.self.position.x, Hero.self.position.y, Hero.self.dieReason);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundRespawn.PACKET_ID:
					break;
				case PacketRoundDie.PACKET_ID:
					super.onPacket(packet);

					var map:GameMapVolcanoNet = GameMap.instance as GameMapVolcanoNet;
					if (!map)
						return;
					this.scoresSurvival[(packet as PacketRoundDie).playerId] = map.startTimer + map.volcanoTimer;
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}