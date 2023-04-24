package game.mainGame.gameBattleNet
{
	import Box2D.Common.Math.b2Vec2;

	import chat.ChatDeadServiceMessage;
	import footers.FooterGame;
	import game.mainGame.CastItem;
	import game.mainGame.GameMap;
	import game.mainGame.ITeams;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.battle.BouncingPoise;
	import game.mainGame.entity.battle.GhostPoise;
	import game.mainGame.entity.battle.GravityPoise;
	import game.mainGame.entity.battle.GrenadePoise;
	import game.mainGame.entity.battle.SpikePoise;
	import game.mainGame.events.CastEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.achieves.AchievementController;
	import game.mainGame.gameNet.SquirrelCollectionNet;
	import headers.HeaderShort;
	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundRespawn;
	import protocol.packages.server.PacketRoundTeam;

	public class SquirrelCollectionBattleNet extends SquirrelCollectionNet implements ITeams
	{
		static private const START_AMMO:int = 10;

		private var redTeam:Vector.<int> = new Vector.<int>();
		private var blueTeam:Vector.<int> = new Vector.<int>();

		public var achievements:AchievementController = null;

		public function SquirrelCollectionBattleNet():void
		{
			super();

			this.heroClass = HeroBattle;

			this.achievements = new AchievementController(SquirrelGame.instance);

			Connection.listen(onPacket, PacketRoundTeam.PACKET_ID, 1);
		}

		override public function round(packet:PacketRoomRound):void
		{
			super.round(packet);

			switch (packet.type)
			{
				case PacketServer.ROUND_START:
					if (ScreenGame.cheaterId != 0)
						break;

					SquirrelGame.instance.camera.enabled = true;

					Hero.self.castItems.add(new CastItem(SpikePoise, CastItem.TYPE_ROUND, START_AMMO));
					Hero.self.castItems.add(new CastItem(BouncingPoise, CastItem.TYPE_ROUND, 0));
					Hero.self.castItems.add(new CastItem(GhostPoise, CastItem.TYPE_ROUND, 0));
					Hero.self.castItems.add(new CastItem(GravityPoise, CastItem.TYPE_ROUND, 0));
					Hero.self.castItems.add(new CastItem(GrenadePoise, CastItem.TYPE_ROUND, 0));
					break;
			}
		}

		public function get redTeamIds():Vector.<int>
		{
			if (this.blueTeam.indexOf(Game.selfId) == -1 && this.redTeam.indexOf(Game.selfId) != -1)
				return this.blueTeam;
			return this.redTeam;
		}

		public function get blueTeamIds():Vector.<int>
		{
			if (this.redTeam.indexOf(Game.selfId) != -1)
				return this.redTeam;
			return this.blueTeam;
		}

		override protected function initCastItems():void
		{}

		override public function checkSquirrelsCount(resetAvailable:Boolean = true):void
		{}

		override public function remove(id:int):void
		{
			super.remove(id);

			if (this.redTeam != null)
			{
				var index:int = this.redTeam.indexOf(id);
				if (index != -1)
					this.redTeam.splice(index, 1);
			}

			if (this.blueTeam != null)
			{
				index = this.blueTeam.indexOf(id);
				if (index != -1)
					this.blueTeam.splice(index, 1);
			}
		}

		override public function dispose():void
		{
			super.dispose();

			this.achievements.dispose();

			Connection.forget(onPacket, PacketRoundTeam.PACKET_ID);
		}

		override public function place():void
		{
			var map:GameMapBattleNet = (GameMap.instance as GameMapBattleNet);

			var posRedSquirrel:Vector.<b2Vec2> = map.redSquirrelsPosition;
			var posBlueSquirrel:Vector.<b2Vec2> = map.blueSquirrelsPosition;

			if (!check(posRedSquirrel) || !check(posBlueSquirrel))
				return;

			var index:int = 0;
			var pos:Vector.<b2Vec2>;
			for each (var player:Hero in this.players)
			{
				pos = GameMap.instance.squirrelsPosition;
				if (player.team == Hero.TEAM_RED)
					pos = posRedSquirrel;
				if (player.team == Hero.TEAM_BLUE)
					pos =  posBlueSquirrel;
				player.position = pos[index % pos.length];
				index++;
			}
		}

		override protected function onSelfDie(e:SquirrelEvent = null):void
		{
			SquirrelGame.instance.camera.enabled = false;

			if (Hero.self.lastKiller != -1)
				Connection.sendData(PacketClient.ROUND_DIE, Hero.self.position.x, Hero.self.position.y, Hero.self.dieReason, Hero.self.lastKiller);
			else
				Connection.sendData(PacketClient.ROUND_DIE, Hero.self.position.x, Hero.self.position.y, Hero.self.dieReason);
		}

		override protected function initSquirrels():void
		{
			this.achievements.reset();
			setTeams(this.redTeam, this.blueTeam);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundTeam.PACKET_ID:
					var team: PacketRoundTeam = packet as PacketRoundTeam;

					if (FooterGame.gameState != PacketServer.ROUND_START)
						HeaderShort.setTeams([] as Vector.<int>, [] as Vector.<int>);
					resetTeams();
					this.redTeam = team.redPlayerId;
					this.blueTeam = team.bluePlayerId;
					setTeams(team.redPlayerId, team.bluePlayerId);
					HeaderShort.clear();
					HeaderShort.setTeams(this.redTeamIds, this.blueTeamIds);
					break;
				case PacketRoundDie.PACKET_ID:
					var die: PacketRoundDie = packet as PacketRoundDie;

					super.onPacket(packet);
					if (die.killerId > 0 && get(die.killerId))
					{
						get(die.killerId).frags++;

						if (die.killerId == Game.selfId)
							ScreenGame.sendMessage(die.playerId, "", ChatDeadServiceMessage.FRAG);
						else if ((get(die.playerId) as HeroBattle) != null && (get(die.playerId) as HeroBattle).isAssist)
							ScreenGame.sendMessage(die.playerId, "", ChatDeadServiceMessage.ASSIST);

						if (die.playerId == Game.selfId)
							ScreenGame.sendMessage(die.killerId, "", ChatDeadServiceMessage.KILLER);
					}
					break;
				case PacketRoundRespawn.PACKET_ID:
					var respawn: PacketRoundRespawn = packet as PacketRoundRespawn;

					var hero:Hero = get(respawn.playerId);
					if (!hero.isDead || respawn.status == PacketServer.RESPAWN_FAIL)
						break;

					hero.respawn(1);

					switch (get(respawn.playerId).team)
					{
						case Hero.TEAM_RED:
						case Hero.TEAM_NONE:
							if (respawn.playerId != Game.selfId)
								break;
							var position:Vector.<b2Vec2> = (GameMap.instance as GameMapBattleNet).redSquirrelsPosition;
							hero.position = position[int(Math.random() * position.length)];
							break;
						case Hero.TEAM_BLUE:
							if (respawn.playerId != Game.selfId)
								break;
							position = (GameMap.instance as GameMapBattleNet).blueSquirrelsPosition;
							hero.position = position[int(Math.random() * position.length)];
							break;
					}
					hero.sendLocation();

					if (respawn.playerId != Game.selfId)
						break;
					SquirrelGame.instance.camera.enabled = true;
					hero.castItems.add(new CastItem(SpikePoise, CastItem.TYPE_ROUND, START_AMMO));
					hero.castItems.add(new CastItem(BouncingPoise, CastItem.TYPE_ROUND, 0));
					hero.castItems.add(new CastItem(GhostPoise, CastItem.TYPE_ROUND, 0));
					hero.castItems.add(new CastItem(GravityPoise, CastItem.TYPE_ROUND, 0));
					hero.castItems.add(new CastItem(GrenadePoise, CastItem.TYPE_ROUND, 0));
					hero.game.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, SpikePoise));
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		private function check(posSquirrel:Vector.<b2Vec2>):Boolean
		{
			if (posSquirrel.length + GameMap.instance.squirrelsPosition.length == 0)
				return false;
			return true;
		}

		override public function setShamans(shamans:Vector.<int>, withReset:Boolean = true):void
		{}

		override protected function resetTeams():void
		{
			this.redTeam = null;
			this.blueTeam = null;
			for each (var hero:Hero in this.players)
				hero.team = Hero.TEAM_NONE;
		}

		private function setTeams(reds:Vector.<int>, blue:Vector.<int>):void
		{
			if (Hero.self)
				Hero.self.team = reds.indexOf(Game.selfId) != -1 ? Hero.TEAM_RED : Hero.TEAM_BLUE;

			for (var i:int = 0; i < reds.length; i++)
			{
				var hero:HeroBattle = get(reds[i]) as HeroBattle;
				if (hero == null || hero.team == Hero.TEAM_RED)
					continue;
				hero.team = Hero.TEAM_RED;
			}

			for (i = 0; i < blue.length; i++)
			{
				hero = get(blue[i]) as HeroBattle;
				if (hero == null || hero.team == Hero.TEAM_BLUE)
					continue;
				hero.team = Hero.TEAM_BLUE;
			}
		}
	}
}