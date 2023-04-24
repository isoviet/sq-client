package tape.list
{
	import tape.list.events.ListDataEvent;

	public class ListBattlePlayersData extends ListPlayersData
	{
		public function ListBattlePlayersData(team:int = 2):void
		{
			super(team);
		}

		override public function addPlayer(id:int):void
		{
			var element:ListBattlePlayerElement = new ListBattlePlayerElement(id, this.team);

			if (this.shamanId == id)
				element.shaman = true;

			pushObject(element);

			dispatchEvent(new ListDataEvent(ListDataEvent.UPDATE, this));
		}

		override public function setPlayers(ids:Vector.<int>):void
		{
			if (ids == null)
				return;

			var data:Vector.<ListElement> = new Vector.<ListElement>();

			var frags:Object = {};
			for each (var element:ListBattlePlayerElement in this.objects)
				frags[element.player.id] = element.frags;

			for (var i:int = 0; i < ids.length; i++)
			{
				element = new ListBattlePlayerElement(ids[i], this.team);
				if (ids[i] in frags)
					element.frags = frags[ids[i]];
				data.push(element);
			}

			setData(data);
			updateShaman();
		}

		public function setPlayerFrags(id:int, frags:int):void
		{
			for each (var element:ListBattlePlayerElement in this.objects)
			{
				if (element.player.id != id)
					continue;

				element.frags = frags;
				break;
			}
		}
	}
}