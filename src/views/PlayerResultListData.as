package views
{
	import game.mainGame.perks.mana.PerkFactory;
	import screens.ScreenGame;
	import tape.list.ListData;
	import tape.list.ListElement;
	import tape.list.PlayerResultListElement;
	import tape.list.events.ListDataEvent;
	import tape.list.events.ListElementEvent;

	import com.api.Player;
	import com.api.PlayerEvent;

	import interfaces.IDispose;
	import interfaces.IStandby;

	import protocol.Connection;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomJoin;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundRespawn;
	import protocol.packages.server.PacketRoundShaman;
	import protocol.packages.server.PacketRoundSkill;

	import utils.ArrayUtil;

	public class PlayerResultListData extends ListData implements IDispose, IStandby
	{
		static private const LOAD_MASK:uint = PlayerInfoParser.NAME | PlayerInfoParser.CLAN | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.VIP_INFO;

		private var requestIds:Object;

		public var shamansIds:Vector.<int>;

		public function PlayerResultListData()
		{
			super();
			this.requestIds = {};

			standby(false);
		}

		public function standby(value:Boolean):void
		{
			if(value)
			{
				Connection.forget(onPacket, [PacketRoomJoin.PACKET_ID, PacketRoundShaman.PACKET_ID,
					PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID,
					PacketRoundRespawn.PACKET_ID, PacketRoundSkill.PACKET_ID]);
			}
			else
			{
				Connection.listen(onPacket, [PacketRoomJoin.PACKET_ID, PacketRoundShaman.PACKET_ID,
					PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID,
					PacketRoundRespawn.PACKET_ID, PacketRoundSkill.PACKET_ID]);
			}
		}

		public function dispose():void
		{
			Connection.forget(onPacket, [PacketRoomJoin.PACKET_ID, PacketRoundShaman.PACKET_ID,
				PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID,
				PacketRoundRespawn.PACKET_ID, PacketRoundSkill.PACKET_ID]);

			Game.forget(onPlayerLoaded);
		}

		public function set(ids:Vector.<int>):void
		{
			clearData();

			this.requestIds = {};

			for each (var id:int in ids)
				this.requestIds[id] = 1;

			Game.listen(onPlayerLoaded);
			Game.request(ArrayUtil.parseIntVector(ids), PlayerResultListData.LOAD_MASK);
		}

		public function inHollow(id:int, time:int):void
		{
			var playerListElement:PlayerResultListElement = getPlayerResultElement(id);
			if (playerListElement == null)
				return;

			playerListElement.time = time;
		}

		public function get self():PlayerResultListElement
		{
			return getPlayerResultElement(Game.selfId);
		}

		protected function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (!(player.id in this.requestIds))
				return;

			if (!player.isLoaded(PlayerResultListData.LOAD_MASK))
				return;

			add(player);
			delete this.requestIds[player.id];
		}

		private function add(player:Player):void
		{
			var playerListElement:PlayerResultListElement = new PlayerResultListElement(player);
			playerListElement.number = this.objects.length;
			playerListElement.shaman = (this.shamansIds ? (this.shamansIds.indexOf(player.id) != -1) : false);

			pushObject(playerListElement);
			sortByTimeAndDeath();
		}

		override public function onObjectChanged(e:ListElementEvent):void
		{
			sortByTimeAndDeath();
		}

		private function sortByTimeAndDeath():void
		{
			this.objects.sort(sortByTimeAndDeathMethod);
			dispatchEvent(new ListDataEvent(ListDataEvent.UPDATE, this));
		}

		private function sortByNumberMethod(a:PlayerResultListElement, b:PlayerResultListElement):int
		{
			var player1:PlayerResultListElement = a, player2:PlayerResultListElement = b;
			if (player1.number > player2.number)
				return 1;
			return -1;
		}

		private function sortByTimeAndDeathMethod(a:PlayerResultListElement, b:PlayerResultListElement):int
		{
			var player1:PlayerResultListElement = a, player2:PlayerResultListElement = b;

			if (player1.shaman && player2.shaman)
				return (player1.player.id > player2.player.id) ? -1 : 1;
			if (player1.shaman || player2.shaman)
				return player1.shaman ? -1 : 1;
			if (player1.isDead && player2.isDead)
				return (player1.player.id > player2.player.id) ? -1 : 1;
			if (player1.isDead || player2.isDead)
				return player1.isDead ? 1 : -1;
			if (player1.time == player2.time)
				return (player1.number < player2.number) ? -1 : 1;

			return player1.time > player2.time ? 1 : -1;
		}

		private function setShaman(ids:Vector.<int>):void
		{
			this.shamansIds = ids;

			if (!this.shamansIds || this.shamansIds.length == 0)
				return;

			var objectsCopy:Vector.<ListElement> = this.objects.concat();

			for each (var element:PlayerResultListElement in objectsCopy)
				element.shaman = false;

			for each (var id:int in this.shamansIds)
			{
				var playerElementSham:PlayerResultListElement = getPlayerResultElement(id);
				if (playerElementSham == null)
					return;

				playerElementSham.shaman = true;
			}
		}

		private function join(id:int):void
		{
			var playerElement:PlayerResultListElement = getPlayerResultElement(id);
			if (playerElement != null)
			{
				playerElement.isDead = false;
				return;
			}

			this.requestIds[id] = 1;

			Game.request(id, PlayerResultListData.LOAD_MASK);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoomJoin.PACKET_ID:
					var roomJoin: PacketRoomJoin = packet as PacketRoomJoin;
					if (roomJoin.isPlaying != PacketServer.JOIN_START)
						return;
					join(roomJoin.playerId);
					break;
				case PacketRoundShaman.PACKET_ID:
					this.shamansIds = (packet as PacketRoundShaman).playerId;
					setShaman(this.shamansIds);
					break;
				case PacketRoundDie.PACKET_ID:
					var die:PacketRoundDie = packet as PacketRoundDie;
					if (ScreenGame.squirrelHare(die.playerId))
						break;
					var playerElement:PlayerResultListElement = getPlayerResultElement(die.playerId);
					if (playerElement == null)
						break;
					playerElement.isDead = true;

					if (this.shamansIds != null && playerElement.player != null)
					{
						var index:int = this.shamansIds.indexOf(playerElement.player.id);
						if (index != -1)
							this.shamansIds.splice(index, 1);
					}
					playerElement.shaman = false;
					break;
				case PacketRoomLeave.PACKET_ID:
					playerElement = getPlayerResultElement((packet as PacketRoomLeave).playerId);
					if (playerElement == null || playerElement.time < int.MAX_VALUE)
						break;
					playerElement.isDead = true;

					if (this.shamansIds != null && playerElement.player != null)
					{
						index = this.shamansIds.indexOf(playerElement.player.id);
						if (index != -1)
							this.shamansIds.splice(index, 1);
					}
					playerElement.shaman = false;
					break;
				case PacketRoundRespawn.PACKET_ID:
					var respawn: PacketRoundRespawn = packet as PacketRoundRespawn;
					if (respawn.status == PacketServer.RESPAWN_FAIL)
						break;
					playerElement = getPlayerResultElement(respawn.playerId);
					if (playerElement == null)
						break;
					playerElement.isDead = false;
					break;
				case PacketRoundSkill.PACKET_ID:
					var skill:PacketRoundSkill = packet as PacketRoundSkill;
					if (skill.type != PerkFactory.SKILL_RESURECTION)
						break;
					playerElement = getPlayerResultElement(skill.playerId);
					if (playerElement == null)
						break;
					playerElement.isDead = false;
					break;
			}
		}

		private function getPlayerResultElement(id:int):PlayerResultListElement
		{
			for each (var element:PlayerResultListElement in this.objects)
			{
				if (element.player.id != id)
					continue;

				return element;
			}
			return null;
		}
	}
}