package protocol
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.packages.ManagerPackets;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketHello;

	public class Connection extends Socket
	{
		static public const CONNECTION_CLOSED:String = "connectionClosed";
		static public const CONNECTION_ERROR:String = "connectionError";

		static private var _instance:Connection;
		static private var id:int = 0;

		static private var pingDelay:int = 30 * 1000;

		private var pingTimer:Timer = new Timer(pingDelay);
		private var length:uint = 0;
		private var host:String;
		private var ports:Array;
		private var timer:Timer = new Timer(1000, 1);

		private var timeOutTimer:Timer = new Timer(5000, 1);

		private var listeners:Vector.<Array> = new Vector.<Array>();
		private var listenersPriority:Vector.<Array> = new Vector.<Array>();

		public function Connection():void
		{
			super();

			_instance = this;

			for (var i:int = 0; i < ManagerPackets.instance.getSize(); i++)
			{
				this.listeners.push([]);
				this.listenersPriority.push([]);
			}

			endian = Endian.LITTLE_ENDIAN;

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onReconnect);
			this.timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeOut);

			addEventListener(Event.CLOSE, closeEvent);
			addEventListener(IOErrorEvent.IO_ERROR, errorEvent);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEvent);
			addEventListener(ProgressEvent.SOCKET_DATA, dataEvent);
			addEventListener(Event.CONNECT, onConnectionEstablished);
		}

		static public function listen(listener:Function, packets:*, priority:int = 0):void
		{
			if (!(packets is Array))
				packets = [packets];
			if (priority == 0)
				for (var i:int = 0; i < (packets as Array).length; i++)
					_instance.listeners[packets[i]].push(listener);
			else
				for (i = 0; i < (packets as Array).length; i++)
				{
					_instance.listenersPriority[packets[i]].push({'function': listener, 'priority': priority});
					_instance.listenersPriority[packets[i]].sort(sortByPriority);
				}
		}

		static public function receiveFake(type:int, data:Array):void
		{
			Logger.add("receiveFake", type, "data:" + data);
			var packet:AbstractServerPacket = ManagerPackets.instance.createPackageById(type, data);

			for (var i:int = 0; i < _instance.listenersPriority[packet.packetId].length; i++)
				_instance.listenersPriority[packet.packetId][i]['function'](packet);
			for (i = 0; i < _instance.listeners[packet.packetId].length; i++)
				_instance.listeners[packet.packetId][i](packet);
		}

		static public function forget(listener:Function, packets:*):void
		{
			if (!(packets is Array))
				packets = [packets];
			for (var i:int = 0; i < (packets as Array).length; i++)
			{
				var index:int = _instance.listeners[packets[i]].indexOf(listener);
				if (index != -1)
					_instance.listeners[packets[i]].splice(index, 1);

				for (index = 0; index < _instance.listenersPriority[packets[i]].length; index++)
				{
					if (_instance.listenersPriority[packets[i]][index]['function'] != listener)
						continue;
					_instance.listenersPriority[packets[i]].splice(index, 1);
					break;
				}
			}
		}

		static public function connect(host:String, port:*):void
		{
			Connection.id = 0;

			_instance.host = host;

			if (!(port is Array))
				_instance.ports = [port];
			else
				_instance.ports = port.slice();

			port = _instance.ports.shift();

			Logger.add("Connecting to: " + host + ":" + port);
			_instance.connect(host, port);
		}

		static public function disconnect():void
		{
			if (!_instance.connected)
				return;
			_instance.close();
			_instance.closeEvent(null);
		}

		static public function sendPacket(packet:PacketClient):void
		{
			if (!_instance.connected)
				return;

			try
			{
				_instance.writeUnsignedInt(packet.length + 4);
				_instance.writeUnsignedInt(Connection.id++);
				_instance.writeBytes(packet);
				_instance.flush();

				_instance.pingTimer.reset();
				_instance.pingTimer.start();
			}
			catch (e:Error)
			{
				Logger.add("Socket disconnected");
			}
		}

		static public function sendData(type:int, ...rest):void
		{
			var packet:PacketClient = new PacketClient(type);
			switch (packet.type)
			{
				case PacketClient.ROUND_HERO:
					break;
				default:
					Logger.add("Sending packet with type " + packet.type + ", " + packet.name);
					var data:String = "";
					for (var i :int = 0; i < rest.length; i++)
						data += (rest[i] is ByteArray ? ("[A: length " + rest[i].length + "]") : rest[i]) + (i != rest.length - 1 ? ", " : "");
					Logger.add("Data: " + data);
					break;
			}

			CONFIG::client
			{
				RecorderCollection.addDataClient(type, rest);

				/*if (!ReportManager.recorder.isNet)
					return;*/
			}

			packet.load(rest);

			sendPacket(packet);
		}

		static private function sortByPriority(a:Object, b:Object):int
		{
			return a['priority'] > b['priority'] ? 1 : -1;
		}

		private function onConnectionEstablished(e:Event):void
		{
			e.stopImmediatePropagation();
			e.stopPropagation();
			timeOutTimer.reset();
			timeOutTimer.start();

			sendData(PacketClient.HELLO);
		}

		private function receiveData(buffer:ByteArray):void
		{
			var id: int = buffer.readUnsignedShort();
			var packet:AbstractServerPacket = ManagerPackets.instance.getPackageById(id, buffer);

			if (packet == null)
				throw new Error("Received server packet with wrong type " + id);

			CONFIG::client{RecorderCollection.addDataServer(packet);}

			Logger.add("Received server packet " + packet);
			Logger.add(by.blooddy.crypto.serialization.JSON.encode(packet));

			var handlers:Array = this.listenersPriority[id].concat();
			for (var i: int = 0; i < handlers.length; i++)
				handlers[i]['function'](packet);

			handlers = this.listeners[id].concat();
			for (i = 0; i < handlers.length; i++)
				handlers[i](packet);

			if (id != PacketHello.PACKET_ID)
				return;

			this.pingTimer.addEventListener(TimerEvent.TIMER, onPing);
			this.pingTimer.reset();
			this.pingTimer.start();

			this.timeOutTimer.stop();
			removeEventListener(Event.CONNECT, onConnectionEstablished);
			dispatchEvent(new Event(Event.CONNECT));
		}

		private function errorEvent(e:Event):void
		{
			Logger.add("Socket error " + e);
			if (e is IOErrorEvent && (e as IOErrorEvent).text.indexOf("Error #2031") > -1 && ports.length > 0)
			{
				e.stopImmediatePropagation();
				e.stopPropagation();

				close();

				this.timer.reset();
				this.timer.start();
				return;
			}

			close();
			dispatchEvent(new Event(CONNECTION_ERROR));
		}

		private function onReconnect(e:Event):void
		{
			Connection.connect(this.host, this.ports);
		}

		private function closeEvent(e:Event):void
		{
			dispatchEvent(new Event(CONNECTION_CLOSED));
		}

		private function dataEvent(e:Event):void
		{
			var buffer:ByteArray = new ByteArray();
			buffer.endian = Endian.LITTLE_ENDIAN;

			while (true)
			{
				if (!this.connected || this.bytesAvailable < 4)
					return;

				if (this.length == 0)
					this.length = readUnsignedInt();

				if (this.length > this.bytesAvailable)
					return;

				readBytes(buffer, 0, this.length);
				this.length = 0;
				receiveData(buffer);

				buffer.length = 0;
				buffer.position = 0;
			}
		}

		private function onTimeOut(e:TimerEvent):void
		{
			errorEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "Error #2031"));
		}

		private function onPing(e:Event):void
		{
/*			if (Game.analystics != null)
				Game.analystics.ping();*/
			sendData(PacketClient.PING, 0);
		}
	}
}