package protocol.packages.server.structs
{
	import flash.utils.ByteArray;
	import utils.NetId;
	import utils.UInt64;
	import protocol.packages.server.structs.*;
	import protocol.packages.server.AbstractServerPacket;

	public class {{STRUCT_NAME}} extends AbstractServerPacket
	{
		{{VARIABLES}}

		public function {{STRUCT_NAME}}(buffer: ByteArray)
		{
			{{PARSING}}
		}

		override public function build(buffer: ByteArray = null): ByteArray
		{
			{{BUILDING}}
			
			return buffer;
		}

		override public function read(array: Array): void
		{
			var arraySize: int = array.length;

			{{READING}}
		}
	}
}