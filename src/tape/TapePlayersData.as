package tape
{
	import tape.events.TapeDataEvent;
	import tape.events.TapeElementEvent;

	import com.api.Player;

	public class TapePlayersData extends TapeData
	{
		protected var requestMask:uint = 0;
		protected var loadingIds:Array = [];

		public function TapePlayersData()
		{
			super(TapePlayer);
		}

		override public function onObjectChanged(e:TapeElementEvent):void
		{
			for each (var data:TapeObject in this.objects)
			{
				if (data.loaded)
					continue;
				return;
			}

			sort();
		}

		public function add(data:TapePlayer):void
		{
			set([data]);
		}

		public function set(datas:Array):void
		{
			if (datas.length == 0)
				return;

			var ids:Array = [];

			for each (var data:TapePlayer in datas)
			{
				data.listen(onObjectChanged);
				data.player.addEventListener(this.requestMask, onPlayerLoaded);
				this.objects.unshift(data);

				ids.push(data.playerId);
			}

			setLengthCutRight(int.MAX_VALUE);

			requestData(ids);
		}

		override protected function sort():void
		{
			if (this.loadingIds.length > 0)
				return;

			sortItems();

			dispatchEvent(new TapeDataEvent(TapeDataEvent.UPDATE, this));
		}

		protected function sortItems():void
		{
			super.sort();
		}

		protected function requestData(ids:Array):void
		{
			if (this.requestMask == 0)
				return;

			this.loadingIds = loadingIds.concat(ids);
			Game.request(ids, this.requestMask, true);
		}

		protected function onPlayerLoaded(player:Player):void
		{
			var index:int = loadingIds.indexOf(player.id);
			if (index == -1)
				return;

			loadingIds.splice(index, 1);
			if (loadingIds.length == 0)
				sort();
		}
	}
}