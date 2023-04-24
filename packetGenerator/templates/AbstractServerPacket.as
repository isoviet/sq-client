package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import utils.UInt64;
	import utils.NetId;
	import protocol.ByteArrayGame;

	public class AbstractServerPacket
	{
		public static var PACKET_ID: int = 0;
		public var packetId: int = 0;

		public function AbstractServerPacket(buffer: ByteArray = null)
		{
		}

		protected function readS(buffer: ByteArray): String
		{
			var result: String = buffer.readUTF();
			buffer.readByte();
			return result;
		}

		protected function readA(buffer: ByteArray): ByteArray
		{
			var length: uint = buffer.readUnsignedInt();
			var array: ByteArray = new ByteArrayGame();
			array.position = 0;
			array.endian = Endian.LITTLE_ENDIAN;
			if (length != 0)
				buffer.readBytes(array, 0, length);
			return array;
		}

		protected function readUnsignedByte(buffer: ByteArray): uint
		{
			var result: uint = (buffer.readByte()+256)%256;
			return result;
		}

		protected function convertJsonString(value: ByteArray): Object
		{
			try
			{
				return by.blooddy.crypto.serialization.JSON.decode(value.readUTF());
			}
			catch(error: Error)
			{
				Logger.add('Connection/receiveData convertJsonString error: ' + error.message);
			}
			return null;
		}
		
		protected function convertStringJson(value: *): Object
		{
			try
			{
				if (value is String)
					return by.blooddy.crypto.serialization.JSON.decode(value);
			}
			catch(error: Error)
			{
				Logger.add('Connection/receiveData convertStringJson error: ' + error.message);
			}
			return value;
		}
		
		protected function writeA(value: ByteArray, buffer: ByteArray):void
		{
			buffer.writeInt(value.length);
			buffer.writeBytes(value);
		}
		
		protected function writeUInt64(value: *, buffer: ByteArray):void
		{
			var result:UInt64 = new UInt64(value);
			result.write(buffer);
		}
		
		protected function writeNetId(value: String, buffer: ByteArray):void
		{
			var result:NetId = new NetId(value);
			buffer.writeInt(value.length);
			result.write(buffer);
		}
		
		public function build(buffer: ByteArray = null): ByteArray
		{
			return null;
		}
		
		public function read(array: Array): void
		{}

		protected function innerBuild(buffer: ByteArray): void
		{}
	}
}
