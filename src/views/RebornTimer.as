package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import game.mainGame.gameBattleNet.SquirrelGameBattleNet;
	import game.mainGame.gameNet.SquirrelGameNet;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundDie;

	public class RebornTimer extends Sprite
	{
		static private const NUMBERS:Array = [RebornNumber0, RebornNumber1, RebornNumber2, RebornNumber3, RebornNumber4, RebornNumber5, RebornNumber6, RebornNumber7, RebornNumber8, RebornNumber9];

		private var timer:Timer = new Timer(1000, 10);

		private var currentNumber:DisplayObject = null;
		private var createdNumbers:Array = [];

		private var game:SquirrelGameNet = null;

		public function RebornTimer(game:SquirrelGameNet):void
		{
			this.game = game;

			this.timer.addEventListener(TimerEvent.TIMER, onTickDelay);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteDelay);

			for (var i:int = 0; i < NUMBERS.length; i++)
				this.createdNumbers.push(new NUMBERS[i]());

			Connection.listen(onPacket, [PacketRoundDie.PACKET_ID, PacketRoomRound.PACKET_ID]);
		}

		public function dispose():void
		{
			reset();

			this.game = null;

			Connection.forget(onPacket, [PacketRoundDie.PACKET_ID, PacketRoomRound.PACKET_ID]);
		}

		public function reset():void
		{
			this.timer.stop();

			clear();
		}

		public function startDelay():void
		{
			this.timer.reset();
			this.timer.start();

			updateDelayField(this.timer.repeatCount);
		}

		private function clear():void
		{
			if (this.currentNumber == null || !contains(this.currentNumber))
				return;

			removeChild(this.currentNumber);
			this.currentNumber = null;
		}

		private function onTickDelay(e:TimerEvent):void
		{
			updateDelayField(this.timer.repeatCount - int(e.currentTarget.currentCount));
		}

		private function onCompleteDelay(e:TimerEvent):void
		{
			Connection.sendData(PacketClient.ROUND_RESPAWN);

			clear();
		}

		private function updateDelayField(value:int):void
		{
			clear();

			if (value <= 0 || (value >= this.createdNumbers.length))
				return;

			this.currentNumber = this.createdNumbers[value];
			addChild(this.currentNumber);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundDie.PACKET_ID:
					if ((packet as PacketRoundDie).playerId != Game.selfId)
						break;
					if (!Hero.self || Hero.self.isHare || Hero.self.isDragon || Hero.self.healedByDeath)
						break;
					if (!(this.game is SquirrelGameBattleNet))
						break;
					startDelay();
					break;
				case PacketRoomRound.PACKET_ID:
					reset();
					break;
			}
		}
	}
}