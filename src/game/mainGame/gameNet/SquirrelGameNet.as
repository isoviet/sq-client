package game.mainGame.gameNet
{
	import dialogs.Dialog;
	import dialogs.DialogChoiceCharacter;
	import dialogs.DialogDeath;
	import dialogs.DialogRoundResult;
	import dialogs.DialogRoundTime;
	import dialogs.DialogWinShaman;
	import dialogs.DialogWinSquirrel;
	import game.gameData.EducationQuestManager;
	import game.gameData.VIPManager;
	import game.mainGame.SquirrelGame;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.events.SquirrelGameEvent;
	import screens.ScreenGame;
	import views.GameEventListView;
	import views.RebornTimer;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundHollow;

	public class SquirrelGameNet extends SquirrelGame
	{
		private static var _dialogDeath:DialogDeath = null;
		private static var _dialogWin:DialogWinSquirrel = null;
		private static var _dialogShaman:DialogWinShaman = null;
		private static var _dialogRoundResult:DialogRoundResult = null;
		private static var _dialogChoiceCharacter:DialogChoiceCharacter = null;

		public function SquirrelGameNet():void
		{
			init();

			super();

			this.rebornTimer = new RebornTimer(this);
			this.rebornTimer.x = int(Config.GAME_WIDTH / 2);
			this.rebornTimer.y = int(Config.GAME_HEIGHT / 2);
			Game.gameSprite.addChild(this.rebornTimer);

			Hero.listenSelf([SquirrelEvent.DIE], onDeath);
			Hero.listenSelf([SquirrelEvent.RESPAWN], onRespawn);

			Connection.listen(onHollow, [PacketRoundHollow.PACKET_ID]);
		}

		private function onRespawn():void
		{
			this.dialogDeath.hide();
		}

		override public function toggleResultVisible():void
		{
			if (this.currentDialog)
				this.currentDialog.hide();

			if (Hero.self && !Hero.selfAlive)
			{
				if (Hero.self.shaman)
					this._dialogResult = this.dialogShaman;
				else if(Hero.self.inHollow)
					this._dialogResult = this.dialogWinSquirrel;
				else
					this._dialogResult = this.dialogDeath;
			}
			else
				this._dialogResult = this.dialogRoundResult;

			this.currentDialog.show();
		}

		private function onHollow(packet:AbstractServerPacket):void
		{
			if(packet.packetId != PacketRoundHollow.PACKET_ID)
				return;

			var roundHollow: PacketRoundHollow = packet as PacketRoundHollow;
			if (roundHollow.success == 1)
				return;

			this.dialogDeath.addPlayer(roundHollow.playerId, roundHollow.gameTime);
			this.dialogShaman.addPlayer(roundHollow.playerId, roundHollow.gameTime);
			this.dialogWinSquirrel.addPlayer(roundHollow.playerId, roundHollow.gameTime);
			this.dialogRoundResult.addPlayer(roundHollow.playerId, roundHollow.gameTime);

			if (ScreenGame.location == Locations.SWAMP_ID && EducationQuestManager.done(EducationQuestManager.SWAMP))
			{
				Connection.sendData(PacketClient.LEAVE);
				ScreenGame.stopChangeRoom();
			}

			if (this.squirrels && roundHollow.playerId == Game.selfId)
			{
				FPSCounter.sendAlterAnalytics();
				DialogRoundTime.instance.hide();
				TagManager.onUse();

				if (this.currentDialog)
					this.currentDialog.hide();
				if (Hero.self.shaman)
					this._dialogResult = this.dialogShaman;
				else
					this._dialogResult = this.dialogWinSquirrel;

				this.currentDialog.show();

				GameEventListView.show();
			}
		}

		protected function onDeath():void
		{
			var squirrelsNet:SquirrelCollectionNet = this.squirrels as SquirrelCollectionNet;

			if (Experience.selfLevel <= Game.LEVEL_TO_FREE_RESPAWN)
				this.dialogDeath.update(DialogDeath.RESPAWN_STATUS);
			else if (VIPManager.haveVIP && squirrelsNet.VIPRespawnCount < 1)
				this.dialogDeath.update(DialogDeath.RESPAWN_VIP_STATUS);
			else if (squirrelsNet.locationId == Locations.HARD_ID && squirrelsNet.hardRespawnCount < 1)
				this.dialogDeath.update(DialogDeath.RESPAWN_HARD_STATUS);
			else if (!VIPManager.haveVIP)
				this.dialogDeath.update(DialogDeath.RESPAWN_BUY_VIP_STATUS);
			else
				this.dialogDeath.update(DialogDeath.RESPAWN_OTHER);

			this.dialogDeath.isLastSquirrel = squirrelsNet.activeSquirrelCount == 0;

			if (this.currentDialog)
				this.currentDialog.hide();
			this._dialogResult = this.dialogDeath;
			this.currentDialog.show();
		}

		override public function round(packet: PacketRoomRound):void
		{
			Logger.add("SquirrelGameNet:Round", packet.type);
			this.cast.round(packet);
			this.map.round(packet);
			this.squirrels.round(packet);

			clearHintArrows();

			Logger.add("dialogChoiceCharacter");
			if (packet.type == PacketServer.ROUND_STARTING)
				choiceCharacter();
			else
				this.dialogChoiceCharacter.hide();

			switch (packet.type)
			{
				case PacketServer.ROUND_WAITING:
					Logger.add("GameState: ROUND_WAITING");
				case PacketServer.ROUND_STARTING:
					if (this.currentDialog)
						this.currentDialog.hide();
				case PacketServer.ROUND_RESULTS:
					Logger.add("GameState: ROUND_STARTING");
					this.simulate = false;
					break;
				case PacketServer.ROUND_PLAYING:
					Logger.add("GameState: ROUND_PLAYING");
				case PacketServer.ROUND_START:
					Logger.add("GameState: ROUND_START");
					this.simulate = true;
					(this.map as GameMapNet).createElements();

					this.dialogDeath.setSquirrels(this.squirrels.getIds());
					this.dialogShaman.setSquirrels(this.squirrels.getIds());
					this.dialogWinSquirrel.setSquirrels(this.squirrels.getIds());
					this.dialogRoundResult.setSquirrels(this.squirrels.getIds());
					break;
				case PacketServer.ROUND_CUT:
					Logger.add("GameState: ROUND_CUT");
					break;
			}
		}

		protected function choiceCharacter():void
		{
			if (this.dialogChoiceCharacter.available)
				this.dialogChoiceCharacter.show();
			else
				this.dialogChoiceCharacter.hide();
		}

		override public function dispose():void
		{
			this.dialogDeath.hide();
			this.dialogShaman.hide();
			this.dialogWinSquirrel.hide();
			this.dialogChoiceCharacter.hide();
			this.dialogRoundResult.hide();

			super.dispose();

			Hero.forget(onDeath);
			Hero.forget(onRespawn);

			Connection.forget(onHollow, [PacketRoundHollow.PACKET_ID]);

			if (Game.gameSprite.contains(this.rebornTimer))
				Game.gameSprite.removeChild(this.rebornTimer);

			this.rebornTimer.dispose();
		}

		override public function onError():void
		{
			Connection.sendData(PacketClient.LEAVE);
		}

		protected function init():void
		{
			this.cast = new CastNet(this);
			this.map = new GameMapNet(this);
			this.squirrels = new SquirrelCollectionNet();

			this.squirrels.addEventListener(SquirrelGameEvent.UPDATE_BONUS, updateBonuses);
			this._dialogResult = this.dialogWinSquirrel;
		}

		private function updateBonuses(event:SquirrelGameEvent):void
		{
			this.dialogWinSquirrel.updateBonus();
			this.dialogShaman.updateBonus();
		}

		//======================================================== singleton

		private function get currentDialog():Dialog
		{
			return _dialogResult;
		}

		private function get dialogDeath():DialogDeath
		{
			if (_dialogDeath == null)
				_dialogDeath = new DialogDeath();
			return _dialogDeath;
		}

		private function get dialogWinSquirrel():DialogWinSquirrel
		{
			if (_dialogWin == null)
				_dialogWin = new DialogWinSquirrel();
			return _dialogWin;
		}

		private function get dialogShaman():DialogWinShaman
		{
			if (_dialogShaman == null)
				_dialogShaman = new DialogWinShaman();
			return _dialogShaman;
		}

		private function get dialogChoiceCharacter():DialogChoiceCharacter
		{
			if (_dialogChoiceCharacter == null)
				_dialogChoiceCharacter = new DialogChoiceCharacter();
			return _dialogChoiceCharacter;
		}

		private function get dialogRoundResult():DialogRoundResult
		{
			if (_dialogRoundResult == null)
				_dialogRoundResult = new DialogRoundResult();
			return _dialogRoundResult;
		}
	}
}