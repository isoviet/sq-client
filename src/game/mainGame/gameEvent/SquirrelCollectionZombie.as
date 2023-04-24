package game.mainGame.gameEvent
{
	import chat.ChatDeadServiceMessage;
	import game.mainGame.gameNet.SquirrelCollectionNet;
	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundRespawn;
	import protocol.packages.server.PacketRoundZombie;

	public class SquirrelCollectionZombie extends SquirrelCollectionNet
	{
		static private const BASE_SPEED:Number = 1.5;
		static private const SPEEDS:Array = [{'value': 0.8, 'speed': 1.25},
						{'value': 0.6, 'speed': 1.0},
						{'value': 0.4, 'speed': 0.9},
						{'value': 0.3, 'speed': 0.8}];

		private var scoresZombie:Object = {};
		private var scoresSurvival:Object = {};

		public var speedFactor:Number = BASE_SPEED;

		public function SquirrelCollectionZombie()
		{
			super();

			this.heroClass = HeroZombie;

			Connection.listen(onPacket, [PacketRoundZombie.PACKET_ID], 1);
		}

		public function get scores():Array
		{
			return [this.scoresSurvival, this.scoresZombie];
		}

		override protected function initCastItems():void
		{}

		override public function reset():void
		{
			super.reset();

			this.scoresZombie = {};
			this.scoresSurvival = {};

			for each (var hero:Hero in this.players)
			{
				this.scoresZombie[hero.id] = 0;
				this.scoresSurvival[hero.id] = 0;
			}

			checkSquirrelsCount();
		}

		override public function checkSquirrelsCount(resetAvailable:Boolean = true):void
		{
			var total:int = 0;
			var zombie:int = 0;

			for each (var hero:HeroZombie in this.players)
			{
				total += !hero.isDead ? 1 : 0;
				zombie += !hero.isDead && (hero.isZombie || hero.timerZombie > 0) ? 1 : 0;
			}

			if (zombie == 1)
			{
				this.speedFactor = BASE_SPEED;
				return;
			}

			var value:Number = (total + 1 - zombie) / total;
			for (var i:int = 0; i < SPEEDS.length; i++)
			{
				if (value < SPEEDS[i]['value'])
					continue;
				this.speedFactor = SPEEDS[i]['speed'];
				break;
			}
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundZombie.PACKET_ID:
					var zombie: PacketRoundZombie = packet as PacketRoundZombie;

					if (zombie.isFirst == false)
						this.survivalScore = zombie.victimId;
					if (zombie.player > 0)
						this.zombieScore = zombie.player;

					var hero:HeroZombie = get(zombie.victimId) as HeroZombie;
					if (!hero)
						return;
					if (zombie.isFirst == false)
						hero.infect();
					else
						hero.first = true;

					if (zombie.player > 0)
					{
						if (zombie.player == Game.selfId)
							ScreenGame.sendMessage(Game.selfId, gls("Ты заразил игрока {0}. Скоро он превратится в зомби.", hero.playerName), ChatDeadServiceMessage.ZOMBIE_MODE);
						else if (zombie.victimId == Game.selfId)
							ScreenGame.sendMessage(Game.selfId, gls("Игрок {0} заразил тебя. Лови других белок и заражай их!", get(zombie.player).playerName), ChatDeadServiceMessage.ZOMBIE_MODE);
					}
					else
					{
						if (zombie.victimId == Game.selfId)
							ScreenGame.sendMessage(Game.selfId, gls("Ты стал зомби. Лови других белок и заражай их!"), ChatDeadServiceMessage.ZOMBIE_MODE);
						else
							ScreenGame.sendMessage(Game.selfId, gls("Игрок {0} стал зомби. Не дай зомби себя заразить.", hero.playerName), ChatDeadServiceMessage.ZOMBIE_MODE);
					}

					checkSquirrelsCount();
					break;
				case PacketRoundRespawn.PACKET_ID:
					super.onPacket(packet);

					checkSquirrelsCount();
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function set zombieScore(playerId:int):void
		{
			if (!(playerId in this.scoresZombie))
				this.scoresZombie[playerId] = 0;
			this.scoresZombie[playerId]++;
		}

		private function set survivalScore(playerId:int):void
		{
			for each (var hero:Hero in this.players)
			{
				if (hero.id == playerId || !hero.isSquirrel)
					continue;
				if (!(hero.id in this.scoresSurvival))
					this.scoresSurvival[hero.id] = 0;
				this.scoresSurvival[hero.id]++;
			}
		}
	}
}