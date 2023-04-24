package utils
{
	import protocol.Connection;
	import protocol.PacketClient;

	public class WearUtil
	{
		static public function unwearAndSave(clothId:int):void
		{
			if (!('weared' in Game.self))
				return;

			var selfClothesIds:Array = Game.self['weared'];

			var index:int = selfClothesIds.indexOf(clothId);
			if (index == -1)
				return;

			selfClothesIds.splice(index, 1);

			Game.self['weared'] = selfClothesIds;

			Connection.sendData(PacketClient.WEAR, [clothId, 0]);
		}
	}
}