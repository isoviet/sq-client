package game.mainGame.gameLearning
{
	import protocol.Connection;
	import protocol.PacketClient;

	public class TrainingCounter
	{
		static public const COMPLETE:int = 0;
		static public const DEAD:int = 1;

		static public const START:int = 0;
		static public const FINISH:int = 1;

		static private var counter:uint = 0;

		static public function next():void
		{
			counter += counter == START ? 2 : 1;

			send(COMPLETE);
		}

		static public function dead():void
		{
			send(DEAD);
		}

		static public function start():void
		{
			counter = START;

			send(COMPLETE);
		}

		static public function finish():void
		{
			counter = FINISH;

			send(COMPLETE);
		}

		static private function send(data:int = 0):void
		{
			Connection.sendData(PacketClient.COUNT, PacketClient.TRAINING_POINTS, (counter << 8) + data);
		}
	}
}