package game.gameData
{
	import protocol.Connection;
	import protocol.Flag;
	import protocol.packages.server.PacketFlags;

	public class FlagsManager
	{
		static private var flags:Vector.<Flag> = Vector.<Flag>([]);

		static private var inited:Boolean = false;

		static private var listeners:Vector.<Function> = Vector.<Function>([]);

		static public function init():void
		{
			if (inited)
				return;
			inited = true;

			Connection.listen(onPacket, PacketFlags.PACKET_ID);
		}

		static public function has(flagType:int):Boolean
		{
			return find(flagType).value != 0;
		}

		static public function set(flagType:int):void
		{
			find(flagType).setValue(1);
		}

		static public function unset(flagType:int):void
		{
			find(flagType).setValue(0);
		}

		static public function find(flagType:int):Flag
		{
			for each(var flag:Flag in flags)
				if (flag.type == flagType)
					return flag;

			flag = new Flag(flagType);
			flags.push(flag);

			return flag;
		}

		static public function onLoad(listener:Function):void
		{
			listeners.push(listener);
		}

		static private function onPacket(packet: PacketFlags):void
		{
			for (var i:int = 0, len: int = packet.items.length; i < len; i++)
				find(packet.items[i].type).setValue(packet.items[i].value, false);

			var listener:Function;
			while(listeners.length > 0)
			{
				listener = listeners.shift();
				listener.apply();
			}
		}
	}
}