package chat
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import com.api.Player;

	public class ChatMessage extends EventDispatcher
	{
		static private const LOAD_MASK:uint = PlayerInfoParser.NAME | PlayerInfoParser.CLAN | PlayerInfoParser.EXPERIENCE | PlayerInfoParser.VIP_INFO | PlayerInfoParser.MODERATOR;

		protected var player:Player;
		protected var message:String;

		public function ChatMessage(player:Player, message:String):void
		{
			this.player = player;
			this.message = message;

			if (canAdd)
				return;

			this.player.addEventListener(LOAD_MASK, onPlayerLoaded);

			Game.request(player.id, LOAD_MASK);
		}

		public function get text():String
		{
			return (this.player ? formatName() : "") + message;
		}

		public function get userId(): int
		{
			return this.player ? this.player.id: -1;
		}

		public function get canAdd():Boolean
		{
			return !this.player || this.player.isLoaded(PlayerInfoParser.NAME | PlayerInfoParser.CLAN | PlayerInfoParser.EXPERIENCE) || this.player['id'] == 0;
		}

		protected function formatName():String
		{
			return "[" + this.player['name'] + "]: ";
		}

		private function onPlayerLoaded(player:Player):void
		{
			if (!canAdd)
				return;

			this.dispatchEvent(new Event("MESSAGE_UPDATE"));
			player.removeEventListener(onPlayerLoaded);
		}
	}
}