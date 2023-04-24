package game.mainGame.gameEvent
{
	import dialogs.DialogVolcanoResult;
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	import protocol.PacketServer;
	import protocol.packages.server.PacketRoomRound;

	public class SquirrelGameVolcanoNet extends SquirrelGameNet
	{
		protected static var dialogResult:DialogVolcanoResult = null;

		public function SquirrelGameVolcanoNet()
		{
			super();

			Game.gameSprite.removeChild(this.rebornTimer);
			this.rebornTimer.dispose();
		}

		override public function toggleResultVisible():void
		{
			this.dialogResult.setResults((this.squirrels as SquirrelCollectionVolcano).scores);
			if (this.dialogResult.visible)
				this.dialogResult.hide();
			else
				this.dialogResult.show();
		}

		override protected function onDeath():void
		{
			this.dialogResult.setResults((this.squirrels as SquirrelCollectionVolcano).scores);
			if (!this.dialogResult.visible)
				this.dialogResult.show();
		}

		override protected function choiceCharacter():void
		{}

		override public function round(packet:PacketRoomRound):void
		{
			super.round(packet);

			this.dialogResult.setResults((this.squirrels as SquirrelCollectionVolcano).scores);
			this.dialogResult.waiting = packet.type == PacketServer.ROUND_RESULTS;
			if (packet.type == PacketServer.ROUND_RESULTS)
				this.dialogResult.show();
			else
				this.dialogResult.hide();
		}

		override protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapVolcanoNet(this);
			this.squirrels = new SquirrelCollectionVolcano();

			this._dialogResult = this.dialogResult;
		}

		private function get dialogResult():DialogVolcanoResult
		{
			if (SquirrelGameVolcanoNet.dialogResult == null)
				SquirrelGameVolcanoNet.dialogResult = new DialogVolcanoResult();
			return SquirrelGameVolcanoNet.dialogResult;
		}
	}
}