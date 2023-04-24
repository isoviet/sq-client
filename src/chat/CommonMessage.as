package chat
{
	import flash.text.TextFormat;

	import com.api.Player;

	import utils.HtmlTool;
	import utils.StringUtil;

	public class CommonMessage extends ChatMessage
	{
		static private var textField:GameField = new GameField("", 0, 0, new TextFormat(null, 12, null, true));

		public function CommonMessage(player:Player, message:String)
		{
			super(player, message);
		}

		override public function get userId(): int {
			var id: int = int(player ? player.id : -1);
			return id;
		}

		override public function get text():String
		{
			return "<body>" + (this.player ? formatName() : "") + styleTextLink(message) + "</body>";
		}

		public function get canBan():Boolean
		{
			return false;//this.player && !(this.player.id == Game.selfId || this.player['moderator'] || Game.self['moderator']);
		}

		override protected function formatName():String
		{
			var name:String = styleNameLink() + " [" + Experience.getTextLevel(this.player['exp']) + "]:";

			return styleNameColor(name) + " ";
		}

		private function styleNameLink():String
		{
			textField.text = this.player.name;
			StringUtil.shortByWidth(textField, 90);
			var name:String = textField.text + (textField.text.length < this.player.name.length ? "..." : "");

			if (this.player.id != Game.selfId)
				name = HtmlTool.anchor(name, "event:" + this.player.id);
			return name;
		}

		private function styleNameColor(name:String = ""):String
		{
			if (!name)
				name = this.player.name + (this.player.moderator && Game.self.moderator ? "[M]" : "");

			if (this.player['moderator'] && !Config.isEng)
				return HtmlTool.span(name, "name_moderator");

			if (this.player['vip_exist'] > 0)
				return HtmlTool.span(name, "color" + this.player['vip_color']);

			return HtmlTool.span(name, "name");
		}

		protected function styleTextLink(text:String):String
		{
			if (this.player == null)
				text = HtmlTool.span(text, "service_message");
			else if (this.player['vip_exist'] > 0)
				text = HtmlTool.span(text, "vip_message");

			if (!this.canBan)
				return text;
			return "<a href = \"event:complain_" + this.player.id + "\"><span class = \"complain\">" + text + "</span></a>";
		}

	}
}