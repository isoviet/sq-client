package chat
{
	import clans.ClanManager;

	import utils.HtmlTool;

	public class ClanNoticeMessage extends ChatMessage
	{
		static public const UPDATE_NEWS:int = 0;

		private var type:int = 0;

		public function ClanNoticeMessage(type:int = UPDATE_NEWS):void
		{
			super(null, "");

			this.type = type;
		}

		override public function get text():String
		{
			if (this.type == UPDATE_NEWS)
				return HtmlTool.span(gls("Новость дня: "), "leaderName") + HtmlTool.span(ClanManager.selfClanNews, "message");

			return "-1";
		}

		override public function get canAdd():Boolean
		{
			return true;
		}
	}
}