package game.mainGame.gameEvent
{
	import dialogs.DialogZombieResult;
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	import protocol.PacketServer;
	import protocol.packages.server.PacketRoomRound;

	public class SquirrelGameZombieNet extends SquirrelGameNet
	{
		private static var dialogResult:DialogZombieResult = null;

		public function SquirrelGameZombieNet()
		{
			super();

			Game.gameSprite.removeChild(this.rebornTimer);
			this.rebornTimer.dispose();
		}

		override public function toggleResultVisible():void
		{
			var scores:Array = (this.squirrels as SquirrelCollectionZombie).scores.concat();

			if (!Hero.self.isPlayedOnce)
			{
				for (var i:int = 0; i < scores.length; i++)
					if (Game.selfId in scores[i])
						delete scores[i][Game.selfId];
			}

			this.dialogResult.setResults(scores);

			if(this.dialogResult != null)
			{
				if (this.dialogResult.visible)
					this.dialogResult.hide();
				else
					this.dialogResult.show();
			}
		}

		override protected function choiceCharacter():void
		{}

		override protected function onDeath():void
		{
			if (!this.dialogResult.visible)
				this.dialogResult.show();
		}

		override public function round(packet:PacketRoomRound):void
		{
			super.round(packet);

			this.dialogResult.setResults((this.squirrels as SquirrelCollectionZombie).scores);
			this.dialogResult.waiting = packet.type == PacketServer.ROUND_RESULTS;

			if (packet.type == PacketServer.ROUND_RESULTS)
				this.dialogResult.show();
			else
				this.dialogResult.hide();
		}

		override protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapZombieNet(this);
			this.squirrels = new SquirrelCollectionZombie();
			this._dialogResult = this.dialogResult;
		}

		private function get dialogResult():DialogZombieResult
		{
			if (SquirrelGameZombieNet.dialogResult == null)
				SquirrelGameZombieNet.dialogResult = new DialogZombieResult();
			return SquirrelGameZombieNet.dialogResult;
		}
	}
}