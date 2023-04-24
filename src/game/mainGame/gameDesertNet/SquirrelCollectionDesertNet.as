package game.mainGame.gameDesertNet
{
	import game.mainGame.gameRopedNet.SquirrelCollectionRopedNet;

	import protocol.PacketServer;
	import protocol.packages.server.PacketRoomRound;

	public class SquirrelCollectionDesertNet extends SquirrelCollectionRopedNet implements IThirst
	{
		private var _thirstController:ThirstController;

		public function SquirrelCollectionDesertNet(isRoped:Boolean = false):void
		{
			super(false, isRoped);

			this.heroClass = HeroDesert;

			this._thirstController = new ThirstController(this);
		}

		public function get thirstController():ThirstController
		{
			return this._thirstController;
		}

		override public function round(packet:PacketRoomRound):void
		{
			this.thirstController.active = false;

			super.round(packet);

			switch (packet.type)
			{
				case PacketServer.ROUND_PLAYING:
				case PacketServer.ROUND_START:
					this.thirstController.active = true;
					break;
			}
		}

		override public function dispose():void
		{
			super.dispose();

			this.thirstController.dispose();
			this._thirstController = null;
		}
	}
}