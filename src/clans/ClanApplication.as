package clans
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import com.api.Player;
	import com.api.PlayerEvent;

	public class ClanApplication extends EventDispatcher
	{
		public var playerId:int = 0;
		public var selected:Boolean = false;
		public var level:int = -1;
		public var time:int = -1;

		public var player:Player = null;

		public function ClanApplication(id:int, time:int):void
		{
			super();

			this.playerId = id;
			this.time = time;

			Game.listen(onPlayerLoaded);
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (player.id != this.playerId)
				return;

			this.player = player;
			this.level = player['level'];

			Game.forget(onPlayerLoaded);
			dispatchEvent(new Event("LOADED"));
		}
	}
}