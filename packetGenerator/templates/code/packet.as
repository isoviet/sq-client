package protocol.packages.server
{
	import by.blooddy.crypto.serialization.JSON;
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;

	// {{PACKET_ID}}
	public class {{PACKET_NAME}} extends AbstractServerPacket
	{
		public static var PACKET_ID: int = {{PACKET_ID}};
		
		{{VARIABLES}}
		
		public function {{PACKET_NAME}}(buffer: ByteArray = null)
		{
			//set id of packet
			packetId = {{PACKET_ID}};
			
			if (buffer === null)
				return;

			{{PARSING}}
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			buffer = new ByteArray();

			innerBuild(buffer);

			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			{{READING}}
		}

		override protected function innerBuild(buffer: ByteArray): void
		{
			{{BUILDING}}
		}
	}
}