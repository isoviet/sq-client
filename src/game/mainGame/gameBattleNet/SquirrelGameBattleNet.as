package game.mainGame.gameBattleNet
{
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;

	import dialogs.DialogBattleWinners;
	import game.mainGame.IScore;
	import game.mainGame.gameNet.SquirrelGameNet;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundFrags;

	public class SquirrelGameBattleNet extends SquirrelGameNet implements IScore
	{
		static private const FORMAT:TextFormat = new TextFormat(null, 30, 0xFFFFFF, true, null, null, null, null, "center");
		static private const FILTER:DropShadowFilter = new DropShadowFilter(0, 0, 0x2E2006, 1, 3, 3, 8);

		protected static var dialogResult:DialogBattleWinners = null;

		private var fieldBlue:GameField = null;
		private var fieldRed:GameField = null;

		public function SquirrelGameBattleNet():void
		{
			super();

			var roomScore:ScoreFlagsView = new ScoreFlagsView();
			roomScore.x = 12;
			roomScore.y = 14;
			addChild(roomScore);

			this.fieldBlue = new GameField("", 0, 24, FORMAT, 47);
			this.fieldBlue.filters = [FILTER];
			roomScore.addChild(this.fieldBlue);

			this.fieldRed = new GameField("", 830, 24, FORMAT, 47);
			this.fieldRed.filters = [FILTER];
			roomScore.addChild(this.fieldRed);

			Connection.listen(onPacket, [PacketRoundFrags.PACKET_ID, PacketRoundDie.PACKET_ID], 1);
		}

		override protected function choiceCharacter():void
		{}

		override public function round(packet:PacketRoomRound):void
		{
			super.round(packet);

			switch (packet.type)
			{
				case PacketServer.ROUND_START:
					this.fieldRed.text = "0";
					this.fieldBlue.text = "0";
					break;
			}
		}

		override public function dispose():void
		{
			super.dispose();

			this.rebornTimer.dispose();

			Connection.forget(onPacket, [PacketRoundFrags.PACKET_ID, PacketRoundDie.PACKET_ID]);
		}

		public function getScore():Array
		{
			return [int(this.fieldRed.text), int(this.fieldBlue.text)];
		}

		override protected function init():void
		{
			this.cast = new CastBattleNet(this);
			this.map = new GameMapBattleNet(this);
			this.squirrels = new SquirrelCollectionBattleNet();

			this._dialogResult = this.dialogResult;
		}

		private function get dialogResult():DialogBattleWinners
		{
			if (SquirrelGameBattleNet.dialogResult == null)
				SquirrelGameBattleNet.dialogResult = new DialogBattleWinners();
			return SquirrelGameBattleNet.dialogResult;
		}

		override protected function onDeath():void
		{}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundFrags.PACKET_ID:
					var frags: PacketRoundFrags = packet as PacketRoundFrags;

					if (!Hero.self || Hero.self.team == Hero.TEAM_BLUE)
					{
						this.fieldRed.text = frags.redFrags.toString();
						this.fieldBlue.text = frags.blueFrags.toString();
					}
					else
					{
						this.fieldBlue.text = frags.redFrags.toString();
						this.fieldRed.text = frags.blueFrags.toString();
					}
					break;
				case PacketRoundDie.PACKET_ID:
					var die: PacketRoundDie = packet as PacketRoundDie;

					if (Game.isFriend(die.playerId) && die.killerId > 0 && die.killerId == Game.selfId)
						Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.KILL_FRIEND, 1);
					if (this.squirrels.get(die.playerId).team == (Hero.self ? Hero.self.team : Hero.TEAM_BLUE))
						this.fieldRed.text = String(int(this.fieldRed.text) + 1);
					else
						this.fieldBlue.text = String(int(this.fieldBlue.text) + 1);
					break;
			}
		}
	}
}