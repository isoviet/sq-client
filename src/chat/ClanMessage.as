package chat
{
	import clans.Clan;
	import clans.ClanManager;

	import com.api.Player;

	import utils.HtmlTool;

	public class ClanMessage extends ChatMessage
	{
		public function ClanMessage(player:Player, message:String):void
		{
			super(player, message);
		}

		override public function get text():String
		{
			return formatName() + HtmlTool.span(message, "message");
		}

		override protected function formatName():String
		{
			var clan:Clan = ClanManager.getClan(player.clan_id);
			var leader:Boolean = (clan.leaderId == player.id);

			var link:String = (player.id == Game.selfId) ? player.name : HtmlTool.anchor(player.name + (player.moderator && Game.self.moderator ? "[M]" : ""), "event:id=" + player.id);

			if (leader)
				var spanClass:String = "leaderName";
			else if (player.clan_duty == Clan.DUTY_SUBLEADER)
				spanClass = "subLeaderName";
			else
				spanClass = "playerName";

			return HtmlTool.span(link + " [" + Experience.getTextLevel(player['exp']) + "]: ", spanClass);
		}
	}
}