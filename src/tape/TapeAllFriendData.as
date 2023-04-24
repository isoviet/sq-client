package tape
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import events.GameEvent;
	import events.ScreenEvent;
	import screens.ScreenGame;
	import screens.ScreenLocation;
	import screens.ScreenProfile;
	import screens.Screens;

	import com.api.Player;

	import protocol.Connection;
	import protocol.packages.server.PacketFriends;

	public class TapeAllFriendData extends TapePlayersData
	{
		static public const REQUEST_FOR_SORT_MASK:uint = PlayerInfoParser.EXPERIENCE | PlayerInfoParser.ONLINE | PlayerInfoParser.IS_GONE;

		private var updateTimer:Timer = new Timer(15 * 60 * 1000);

		private var friendsIds:Array = [];
		private var sortedObjects:Vector.<TapeObject> = new Vector.<TapeObject>();
		private var top:Array = [];

		public function TapeAllFriendData()
		{
			super();

			this.requestMask = REQUEST_FOR_SORT_MASK;

			Game.event(GameEvent.ADD_FRIEND, onAddFriend);
			Game.event(GameEvent.REMOVE_FRIEND, onRemoveFriend);

			this.updateTimer.addEventListener(TimerEvent.TIMER, onTimer);
			Connection.listen(onPacket, [PacketFriends.PACKET_ID]);
		}

		override protected function sortItems():void
		{
			if (Game.self && this.friendsIds.indexOf(Game.selfId) < 0)
			{
				this.friendsIds.push(Game.selfId);
				add(new TapePlayer(Game.selfId, TapePlayer.TYPE_FRIEND));
			}

			this.objects.sort(sortByOnlineExp);

			this.sortedObjects = this.objects.slice();
			this.sortedObjects.sort(sortByExp);
			for (var i:int = 0; i < this.sortedObjects.length; i++)
			{
				if (this.sortedObjects[i] is TapeInviteFriends)
					continue;
				(this.sortedObjects[i] as TapePlayer).friendsRatingPlace = i + 1;
			}

			setTop();
		}

		override protected function onPlayerLoaded(player:Player):void
		{
			super.onPlayerLoaded(player);

			if ("is_gone" in player && player['is_gone'])
				TapeFriendReturnData.addFriend(player.id);
		}

		private function setTop():void
		{
			for (var i:int = 0; i < this.top.length; i++)
				(this.top[i] as TapePlayer).setTopPlaceFrame(-1);

			this.top.splice(0);

			var firstTop:Vector.<TapeObject> = this.sortedObjects.slice(0, 3);
			for (i = 0; i < firstTop.length; i++)
			{
				if (firstTop[i] is TapeInviteFriends)
					continue;

				this.top.push(firstTop[i]);
				(firstTop[i] as TapePlayer).setTopPlaceFrame(i + 1);
			}
		}

		private function sortByOnlineExp(a:TapeObject, b:TapeObject):int
		{
			if (a is TapeInviteFriends)
				return 1;
			if (b is TapeInviteFriends)
				return -1;

			var player1:TapePlayer = a as TapePlayer, player2:TapePlayer = b as TapePlayer;

			if (player1.player['online'] && !player2.player['online'])
				return -1;
			if (!player1.player['online'] && player2.player['online'])
				return 1;

			return sortByExp(a, b);
		}

		private function sortByExp(a:TapeObject, b:TapeObject):int
		{
			if (a is TapeInviteFriends)
				return 1;
			if (b is TapeInviteFriends)
				return -1;

			var player1:TapePlayer = a as TapePlayer, player2:TapePlayer = b as TapePlayer;

			if (player1.player['exp'] == player2.player['exp'])
				return (player1.playerId < player2.playerId) ? 1 : -1;
			if (player1.player['exp'] < player2.player['exp'])
				return 1;
			return -1;
		}

		private function onTimer(e:TimerEvent):void
		{
			if (Screens.active is ScreenGame)
			{
				this.updateTimer.stop();
				Screens.instance.addEventListener(ScreenEvent.SHOW, sortLater);
				return;
			}

			requestData(this.friendsIds);
		}

		private function sortLater(e:ScreenEvent):void
		{
			if ( !(Screens.active is ScreenLocation) && !(Screens.active is ScreenProfile))
				return;

			Screens.instance.removeEventListener(ScreenEvent.SHOW, sortLater);

			requestData(this.friendsIds);

			this.updateTimer.reset();
			this.updateTimer.start();
		}

		private function onAddFriend(e:Event):void
		{
			if (!Game.friends)
				return;

			var addFriends:Array = [];

			for (var id:String in Game.friends)
			{
				if (this.friendsIds.indexOf(int(id)) > -1)
					continue;

				this.friendsIds.push(int(id));
				addFriends.push(new TapePlayer(int(id), TapePlayer.TYPE_FRIEND));
			}

			removeEmpty(addFriends.length);
			set(addFriends);
		}

		private function onRemoveFriend(e:Event):void
		{
			for each (var object:TapeObject in this.objects)
			{
				if (!(object is TapePlayer))
					continue;

				var id:int = (object as TapePlayer).playerId;

				if (Game.isFriend(id) || id == Game.selfId)
					continue;

				remove(id);
			}

			sort();
		}

		private function remove(playerId:int):void
		{
			for (var i:int = 0; i < this.objects.length; i++)
			{
				if (!(this.objects[i] is TapePlayer) || (this.objects[i] as TapePlayer).playerId != playerId)
					continue;

				this.objects[i].forget(onObjectChanged);
				this.objects.splice(i, 1);
				fillEmpty();
				break;
			}

			for (i = 0; i < this.friendsIds.length; i++)
			{
				if (this.friendsIds[i] != playerId)
					continue;

				this.friendsIds.splice(i, 1);
			}
		}

		private function onPacket(packet: PacketFriends):void
		{
			var friends:Array = [];

			for (var i:int = 0; i < packet.items.length; i++)
			{
				if (packet.items[i].removed == 1)
					continue;

				friends.push(new TapePlayer(packet.items[i].friend, TapePlayer.TYPE_FRIEND));
				this.friendsIds.push(packet.items[i].friend);
			}

			if (this.objects.length == 0)
			{
				if (Game.self)
				{
					friends.push(new TapePlayer(Game.selfId, TapePlayer.TYPE_FRIEND));
					this.friendsIds.push(Game.selfId);
				}
				this.updateTimer.start();
			}

			set(friends);
			fillEmpty();
			sort();

			dispatchEvent(new GameEvent(GameEvent.FRIENDS_UPDATE));
		}

		private function fillEmpty():void
		{
			var emptyCount:int = (this.count < TapeFriendsView.MAX_SHOW) ? (TapeFriendsView.MAX_SHOW - this.count) : 0;
			for (var i:int = 0; i < emptyCount; i++)
				addObject(new TapeInviteFriends());
		}

		private function removeEmpty(emptyCount:int):void
		{
			for (var i:int = 0; i < this.count; i++)
			{
				if (!(this.objects[i] is TapeInviteFriends))
					continue;

				if (emptyCount-- == 0)
					break;

				this.objects.splice(i, 1);
				i--;
			}
		}
	}
}