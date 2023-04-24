package
{
	import protocol.Connection;
	import protocol.PacketClient;

	public class TagManager
	{
		static public const START_VALUE:int = 3;
		static public const END_VALUE:int = 4;

		static public var tag:int = 0;

		static public function randTag():void
		{
			tag = START_VALUE + Math.random() * (END_VALUE - START_VALUE + 1);
		}

		static public function onShow():void
		{
			Connection.sendData(PacketClient.AB_GUI_ACTION, PacketClient.AB_GUI_SHOW);
		}

		static public function onUse():void
		{
			Connection.sendData(PacketClient.AB_GUI_ACTION, PacketClient.AB_GUI_USE);
		}
	}
}