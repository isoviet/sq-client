package protocol
{
	import flash.utils.ByteArray;

	public class ByteArrayGame extends ByteArray
	{
		override public function toString():String
		{
			return "[BA: Length:" + this.length + "]";
		}
	}
}