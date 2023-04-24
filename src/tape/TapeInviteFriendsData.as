package tape
{
	import tape.events.TapeDataEvent;
	import tape.events.TapeElementEvent;

	import com.api.Services;

	public class TapeInviteFriendsData extends TapeData
	{
		static public const FRIENDS_COUNT:int = 8;
		static public const FRIENDS_COUNT_MINI:int = 5;

		public function TapeInviteFriendsData(mini:Boolean = false):void
		{
			super();

			var ids:Array = Game.allFriendsIds.filter(filterFriends);

			var len:int = ids.length;

			var object:TapeInviteFriendObject;
			var maxCount:int = mini ? FRIENDS_COUNT_MINI : FRIENDS_COUNT;
			for (var i:int = 0; (i < len && i < maxCount); i++)
			{
				object = new TapeInviteFriendObject(ids[i], mini);
				object.listen(onLoad);
			}

			Services.friends.loadInfo(ids.slice(0, i));
		}

		public function getInviteIds():Array
		{
			var ids:Array = [];
			for each(var item:TapeInviteFriendObject in this.objects)
				if (item.selected)
					ids.push(item.id);

			return ids;
		}

		public function selectAll():void
		{
			for each(var item:TapeInviteFriendObject in this.objects)
				item.selected = true;
		}

		private function onLoad(e:TapeElementEvent):void
		{
			addObject(e.element);

			dispatchEvent(new TapeDataEvent(TapeDataEvent.UPDATE, this));
		}

		private function filterFriends(item:*, index:int, array:Array):Boolean
		{
			if (index && array) {/*unused*/}

			return Game.friendsSocialIds.indexOf(item) < 0;
		}
	}
}