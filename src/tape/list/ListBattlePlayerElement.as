package tape.list
{
	import flash.text.StyleSheet;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundDie;

	public class ListBattlePlayerElement extends ListPlayerElement
	{
		static private const CSS:String = (<![CDATA[
			.blue {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #1e43bb;
				font-weight: bold;
			}
			.red {
				font-family: "Droid Sans";
				font-size: 11px;
				color: #BD0501;
				font-weight: bold;
			}
		]]>).toString();

		private var fragsField:GameField = null;

		private var _frags:int = 0;

		public function ListBattlePlayerElement(id:int, team:int):void
		{
			super(id, team);

			init();

			Connection.listen(onPacket, [PacketRoundDie.PACKET_ID]);
		}

		public function get frags():int
		{
			return this._frags;
		}

		public function set frags(value:int):void
		{
			this._frags = value;

			this.fragsField.htmlText = "<body><span class=\"" + (this.team == Hero.TEAM_RED ? "red" : "blue") + "\"><b>" + this._frags.toString() + "</b></span></body>";
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.fragsField = new GameField("<body><span class=\"" + (this.team == Hero.TEAM_RED ? "red" : "blue") + "\"><b>0</b></span></body>", 130, 0, style, 26);
			addChild(this.fragsField);
		}

		private function onPacket(packet:PacketRoundDie):void
		{
			if (packet.killerId <= 0 || this.player.id != packet.killerId)
				return;
			this.frags++;
		}
	}
}