package tape
{
	import flash.events.Event;

	import events.GameEvent;
	import game.gameData.NotificationManager;
	import tape.events.TapeDataEvent;

	public class TapeFriendReturnData extends TapePlayersData
	{
		static private var _instance:TapeFriendReturnData;

		static private var ids:Array = [];

		private var friendsIds:Array = [];

		public function TapeFriendReturnData():void
		{
			super();

			_instance = this;

			while (ids.length > 0)
				addTapeObject(ids.pop());

			Game.event(GameEvent.REMOVE_FRIEND, onRemoveFriend);
		}

		static public function addFriend(id:int):void
		{
			if (!_instance)
			{
				ids.push(id);
				return;
			}
			_instance.addTapeObject(id);
			NotificationDispatcher.show(NotificationManager.RETURN);
		}

		public function selectAll(selected:Boolean):void
		{
			for each (var tapeObject:TapePlayer in this.objects)
				(tapeObject as TapePlayerReturn).selected = selected;
		}

		public function removeItems(ids:Array):void
		{
			for (var i:int = ids.length - 1; i >= 0; i--)
			{
				for (var j:int = this.objects.length - 1; j >= 0; j--)
				{
					if (ids[i] != (this.objects[j] as TapePlayerReturn).playerId)
						continue;

					(this.objects[j] as TapePlayerReturn).forget(onObjectChanged);
					this.objects.splice(j, 1);
					break;
				}
			}
			dispatchEvent(new TapeDataEvent(TapeDataEvent.UPDATE, this));
		}

		private function addTapeObject(id:int):void
		{
			if (this.friendsIds.indexOf(id) != -1)
				return;

			this.friendsIds.push(id);
			var tapeObject:TapePlayerReturn = new TapePlayerReturn(id);
			tapeObject.selected = true;
			add(tapeObject);
			dispatchEvent(new TapeDataEvent(TapeDataEvent.UPDATE, this));
		}

		private function onRemoveFriend(e:Event):void
		{
			var removedIds:Array = [];
			for each (var object:TapeObject in this.objects)
			{
				var id:int = (object as TapePlayer).playerId;

				if (Game.isFriend(id) || id == Game.selfId)
					continue;

				removedIds.push(id);
			}
			removeItems(removedIds);
		}
	}
}