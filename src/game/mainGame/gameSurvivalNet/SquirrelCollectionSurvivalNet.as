package game.mainGame.gameSurvivalNet
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.GameMap;
	import game.mainGame.gameNet.SquirrelCollectionNet;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundDie;

	public class SquirrelCollectionSurvivalNet extends SquirrelCollectionNet
	{
		public function SquirrelCollectionSurvivalNet():void
		{
			super();

			this.heroClass = HeroSurvival;
		}

		override public function place():void
		{
			if (!GameMap.instance)
				return;

			var position:Vector.<b2Vec2> = GameMap.instance.squirrelsPosition;
			var index:int = 0;

			if (position.length != 0)
			{
				for each (var player:Hero in this.players)
				{
					if (player.shaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}

			position = (GameMap.instance as GameMapSurvivalNet).blackShamansPosition;
			if (this.shamans.length > 0 && this.players[this.shamans[0]] is Hero)
				this.players[this.shamans[0]].position = position[0];
		}

		override public function checkSquirrelsCount(resetAvailable:Boolean = true):void
		{}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundDie.PACKET_ID:
					var id:int = (packet as PacketRoundDie).playerId;
					if (Hero.self && id != Game.selfId && Hero.self.shaman && get(id).transparent)
						Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.INVISIBLE_KILLS, 1);
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}