package tape
{
	import clans.Clan;
	import clans.ClanManager;
	import events.GameEvent;
	import tape.TapePlayersData;
	import tape.events.TapeDataEvent;
	import views.PlayerPlaceClanLeader;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketClanJoin;
	import protocol.packages.server.PacketClanLeave;
	import protocol.packages.server.PacketClanMembers;

	public class TapeClanData extends TapePlayersData
	{
		static public const REQUEST_FOR_SORT_MASK:uint = PlayerInfoParser.EXPERIENCE | PlayerInfoParser.ONLINE | PlayerInfoParser.CLAN;

		private var filterName:String = "";

		public var clanLeaderPlace:PlayerPlaceClanLeader;

		public function TapeClanData(filterName:String = ""):void
		{
			super();

			this.clanLeaderPlace = new PlayerPlaceClanLeader();

			this.filterName = filterName;
			this.requestMask = REQUEST_FOR_SORT_MASK;

			Game.listen(onLeaderLoaded);
			Connection.listen(onPacket, [PacketClanMembers.PACKET_ID, PacketClanJoin.PACKET_ID,
				PacketClanLeave.PACKET_ID]);
		}

		static private function sortByRankAndOnline(a:TapePlayer, b:TapePlayer):int
		{
			if ((a.player['clan_duty'] == Clan.DUTY_SUBLEADER) && (b.player['clan_duty'] != Clan.DUTY_SUBLEADER))
				return -1;
			if ((a.player['clan_duty'] != Clan.DUTY_SUBLEADER) && (b.player['clan_duty'] == Clan.DUTY_SUBLEADER))
				return 1;

			if (a.player['online'] && !b.player['online'])
				return -1;
			if (!a.player['online'] && b.player['online'])
				return 1;

			if (a.player['exp'] < b.player['exp'])
				return 1;
			return -1;
		}

		public function getIdsByName(name:String):Vector.<TapeObject>
		{
			var tapePlayers:Vector.<TapeObject> = new Vector.<TapeObject>();

			for (var i:int = 0; i < this.objects.length; i++)
			{
				if (((this.objects[i] as TapePlayer).player == null) || (((this.objects[i] as TapePlayer).player as Player).name.toLowerCase().indexOf(name.toLowerCase()) == -1))
					continue;

				tapePlayers.push(this.objects[i]);
			}

			return tapePlayers;
		}

		public function loadData(tapePlayers:Vector.<TapeObject>):void
		{
			this.objects = tapePlayers;
		}

		public function remove(playerId:int):void
		{
			for (var i:int = 0; i < this.objects.length; i++)
			{
				if ((this.objects[i] as TapePlayer).playerId != playerId)
					continue;

				this.objects[i].forget(onObjectChanged);
				this.objects.splice(i, 1);
				break;
			}

			dispatchEvent(new TapeDataEvent(TapeDataEvent.UPDATE, this));
		}

		override protected function sortItems():void
		{
			this.objects.sort(sortByRankAndOnline);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketClanMembers.PACKET_ID:
					var members: PacketClanMembers = packet as PacketClanMembers;

					if ((Game.self['clan_id'] != members.clanId) || (this.filterName != ""))
						return;

					var clan:Clan = ClanManager.getClan(Game.self['clan_id']);

					var players:Array = [];
					for (var i:int = 0; i < members.playerIds.length; i++)
					{
						if (members.playerIds[i] == clan.leaderId)
						{
							this.clanLeaderPlace.playerId = clan.leaderId;
							Game.request(this.clanLeaderPlace.playerId, PlayerInfoParser.NAME |
								PlayerInfoParser.EXPERIENCE | PlayerInfoParser.PHOTO |
								PlayerInfoParser.ONLINE | PlayerInfoParser.CLAN);
							continue;
						}

						players.push(new TapePlayer(members.playerIds[i], TapePlayer.TYPE_CLAN));
					}

					clear();
					set(players);
					break;
				case PacketClanJoin.PACKET_ID:
					var join: PacketClanJoin = packet as PacketClanJoin;

					if (this.filterName != "")
						break;
					if (join.playerId == Game.selfId)
						break;
					add(new TapePlayer(join.playerId, TapePlayer.TYPE_CLAN));
					break;
				case PacketClanLeave.PACKET_ID:
					remove((packet as PacketClanLeave).playerId);
					break;
			}
		}

		private function onLeaderLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player.id != this.clanLeaderPlace.playerId)
				return;

			this.clanLeaderPlace.setPlayer(player);

			dispatchEvent(new GameEvent(GameEvent.FRIENDS_UPDATE));
		}
	}
}