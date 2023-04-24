package game.mainGame
{
	import flash.display.Sprite;

	import chat.ChatDeadServiceMessage;
	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundHollow;
	import protocol.packages.server.PacketRoundShaman;

	import utils.Sector;

	public class ReportView extends Sprite
	{
		static private const REPORT_TICK_COUNT_MAX:int = 10;
		static private const REPORT_COUNT_MAX:int = 5;

		static public const IMAGE_X:int = -20;
		static public const IMAGE_Y:int = -120;

		private var sector:Sector = new Sector();

		public var reportCount:int = 0;
		public var reportTickCount:int = 0;
		public var reportedPlayerId:int = 0;

		public function ReportView():void
		{
			var icon:KickImage = new KickImage();
			icon.x = IMAGE_X;
			icon.y = IMAGE_Y;
			addChild(icon);

			this.sector.start = 0;
			this.sector.radius = 39.65 / 2;
			this.sector.x = IMAGE_X + this.sector.radius;
			this.sector.y = IMAGE_Y + this.sector.radius;
			this.sector.color = 0xFF0000;
			this.sector.alpha = 0.5;
			this.sector.mouseEnabled = false;
			this.sector.mouseChildren = false;
			addChild(this.sector);

			Connection.listen(onPacket, [PacketRoundCommand.PACKET_ID, PacketRoundShaman.PACKET_ID,
				PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID, PacketRoundHollow.PACKET_ID]);
		}

		public function update(tick:Number):void
		{
			this.sector.end = Math.PI * 2 - tick / 100 * Math.PI * 2;
		}

		public function reset():void
		{
			this.sector.end	= Math.PI * 2;

			if (this.parent)
				this.parent.removeChild(this);
		}

		public function reportsClear():void
		{
			reset();

			EnterFrameManager.removePerSecondTimer(onTickReport);

			this.reportCount = 0;
			this.reportTickCount = 0;
			this.reportedPlayerId = 0;
		}

		private function onTickReport():void
		{
			if (!ScreenGame.squirrelExist(this.reportedPlayerId))
				return;

			this.reportTickCount++;

			if (this.reportTickCount == REPORT_TICK_COUNT_MAX)
			{
				reset();
				EnterFrameManager.removePerSecondTimer(onTickReport);

				ScreenGame.sendMessage(this.reportedPlayerId, "", ChatDeadServiceMessage.KICKED);

				if (this.reportedPlayerId == Game.selfId)
				{
					Hero.self.dieReason = Hero.DIE_REPORT;
					Hero.self.dead = true;
				}

				reportsClear();
			}

			update(reportTickCount / REPORT_TICK_COUNT_MAX * 100);
		}

		private function report(playerId:int, targetId:int):void
		{
			this.reportCount++;

			if (!ScreenGame.squirrelExist(playerId) || !ScreenGame.squirrelExist(targetId))
				return;

			if(!Hero.self || !Hero.self.game)
				return;

			var targetHero:Hero = Hero.self.game.squirrels.get(targetId);
			var playerHero:Hero = Hero.self.game.squirrels.get(playerId);

			if(!playerHero || !targetHero)
				return;

			if (!(targetHero.shaman && !targetHero.isDead) && this.reportCount < REPORT_COUNT_MAX)
				return;

			playerHero.addViewButton(this);

			this.reportedPlayerId = playerId;
			EnterFrameManager.addPerSecondTimer(onTickReport);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundCommand.PACKET_ID:
					var data:Object = (packet as PacketRoundCommand).dataJson;

					if (!("reportedPlayerId" in data && "targetPlayerId" in data))
						return;

					ScreenGame.sendMessage(int(data['reportedPlayerId']), "", ChatDeadServiceMessage.REPORT);
					report(int(data['reportedPlayerId']), int(data['targetPlayerId']));
					break;
				case PacketRoundShaman.PACKET_ID:
					if ((packet as PacketRoundShaman).playerId.indexOf(this.reportedPlayerId) != -1)
						reportsClear();
					break;
				case PacketRoundDie.PACKET_ID:
					if (this.reportedPlayerId == (packet as PacketRoundDie).playerId)
						reportsClear();
					break;
				case PacketRoomLeave.PACKET_ID:
					var id: int = (packet as PacketRoomLeave).playerId;
					if (this.reportedPlayerId == id || Game.selfId == id)
						reportsClear();
					break;
				case PacketRoundHollow.PACKET_ID:
					var hollow: PacketRoundHollow = packet as PacketRoundHollow;

					if (hollow.success == 1)
						return;
					if (this.reportedPlayerId == hollow.playerId)
						reportsClear();
					break;
			}
		}
	}
}