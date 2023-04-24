package views
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

	import dialogs.DialogSnowmanHelp;
	import game.gameData.FlagsManager;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketNyModePlace;
	import protocol.packages.server.PacketRoomRound;

	public class NewYearSnowBar extends Sprite
	{
		static private const FILTER:GlowFilter = new GlowFilter(0xFFFFFF, 1.0, 3, 3);

		private var view:MovieClip;//SnowModeBarView;
		private var fieldSnow:GameField;
		private var fieldSnowflake:GameField;

		public function NewYearSnowBar():void
		{
			this.view = new MovieClip();//new SnowModeBarView();
			addChild(this.view);

			var format:TextFormat = new TextFormat(null, 15, 0x0C3F85, true);
			this.fieldSnow = new GameField("0/100", 115, 15, format);
			this.fieldSnow.filters = [FILTER];
			addChild(this.fieldSnow);

			this.fieldSnowflake = new GameField("0/10", 490, 15, format);
			this.fieldSnowflake.filters = [FILTER];
			addChild(this.fieldSnowflake);

			Connection.listen(onPacket, [PacketRoomRound.PACKET_ID, PacketNyModePlace.PACKET_ID]);

			this.count = 0;
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoomRound.PACKET_ID:
					if((packet as PacketRoomRound).type != PacketServer.ROUND_START)
						return;

					this.count = 0;

					if (this.visible && !DialogSnowmanHelp.showed && !FlagsManager.has(Flag.SNOWMAN_HELP))
					{
						new DialogSnowmanHelp().show();
						DialogSnowmanHelp.showed = true;
						FlagsManager.set(Flag.SNOWMAN_HELP);
					}
					break;
				case PacketNyModePlace.PACKET_ID:
					this.count = (packet as PacketNyModePlace).count;
					break;
			}
		}

		private function set count(value:int):void
		{
			this.fieldSnow.text = value + "/100";
			this.fieldSnowflake.text = int(Math.max(0, value - 10) / 9) + "/10";

			//this.view.snowBar.gotoAndStop(int(value * 0.5));
		}
	}
}