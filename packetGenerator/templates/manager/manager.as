package protocol.packages
{
	import protocol.packages.server.*;
	import flash.utils.ByteArray;
	
	public class ManagerPackets
	{
		private static var _instance: ManagerPackets = null;

		private var collections: Array = [
			{{LIST}}
		];

		public function ManagerPackets()
		{
		}

		public static function get instance(): ManagerPackets {
			if(_instance == null)
				_instance = new ManagerPackets();
			return _instance;
		}

		public function getPackageById(index: int, buff: ByteArray): AbstractServerPacket {
			return index < collections.length && index > -1 ? (new collections[index](buff) as AbstractServerPacket) : null;
		}
		
		public function createPackageById(index: int, buff: Array): AbstractServerPacket {
			if (index >= collections.length || index < 0)
				return null;
			
			var packet: AbstractServerPacket = new collections[index]();
			packet.read(buff);
			return packet;
		}
		
		public function getSize(): int {
			return collections.length;
		}
	}
}
