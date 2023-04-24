package tape.list
{
	import tape.list.events.ListDataEvent;
	import tape.list.events.ListElementEvent;

	public class ListPlayersData extends ListData
	{
		protected var shamanId:int = -1;
		protected var team:int;

		public function ListPlayersData(team:int = 2):void
		{
			this.team = team;
		}

		public function addPlayer(id:int):void
		{
			var element:ListPlayerElement = new ListPlayerElement(id, this.team);

			if (this.shamanId == id)
				element.shaman = true;

			pushObject(element);

			dispatchEvent(new ListDataEvent(ListDataEvent.UPDATE, this));
		}

		public function removePlayer(id:int):void
		{
			for (var i:int = 0; i < this.objects.length; i++)
			{
				if ((this.objects[i] as ListPlayerElement).player.id != id)
					continue;

				this.objects[i].removeEventListener(ListElementEvent.CHANGED, onObjectChanged);
				this.objects.splice(i, 1);
				break;
			}

			if (id == this.shamanId)
				this.shamanId = -1;

			dispatchEvent(new ListDataEvent(ListDataEvent.UPDATE, this));
		}

		public function setPlayers(ids:Vector.<int>):void
		{
			var data:Vector.<ListElement> = new Vector.<ListElement>();

			for (var i:int = 0; i < ids.length; i++)
			{
				var element:ListPlayerElement = new ListPlayerElement(ids[i], this.team);
				data.push(element);
			}

			setData(data);
			updateShaman();
		}

		public function setShaman(id:int):void
		{
			this.shamanId = id;

			updateShaman();
		}

		override public function onObjectChanged(e:ListElementEvent):void
		{
			dispatchEvent(new ListDataEvent(ListDataEvent.UPDATE, this));
		}

		protected function updateShaman():void
		{
			for (var i:int = 0; i < this.objects.length; i++)
				(this.objects[i] as ListPlayerElement).shaman = ((this.objects[i] as ListPlayerElement).player.id == this.shamanId);
		}
	}
}