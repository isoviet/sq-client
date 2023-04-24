package editor
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	import by.blooddy.crypto.MD5;

	import editor.forms.DataForm;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketAdminInfo;
	import protocol.packages.server.PacketAdminInfoClan;
	import protocol.packages.server.PacketLogin;
	import protocol.packages.server.PacketRequestPromo;

	public class Loader
	{
		static public var unix_time:int = 0;
		public var urlScript:String = "";

		private var adminKeyCode:String = "";

		public function Loader(adminKeyCode:String = ""):void
		{
			this.adminKeyCode = adminKeyCode;
			var connection:Connection = new Connection();

			Connection.listen(packetReceived, [PacketLogin.PACKET_ID, PacketAdminInfo.PACKET_ID,
				PacketAdminInfoClan.PACKET_ID, PacketRequestPromo.PACKET_ID]);

			connection.addEventListener(Event.CONNECT, onConnected);
			connection.addEventListener(Connection.CONNECTION_ERROR, onError);
			connection.addEventListener(Connection.CONNECTION_CLOSED, onError);
		}

		public function connect(host:String, port:int):void
		{
			Connection.connect(host, port);
		}

		public function clear():void
		{
			Connection.sendData(PacketClient.ADMIN_CLEAR, MainForm.player.uid);
		}

		public function requestField(type:int):void
		{
			Connection.sendData(PacketClient.ADMIN_REQUEST_INNER, MainForm.player.uid, type);
		}

		public function requestFieldClan(type:int, id:int):void
		{
			Connection.sendData(PacketClient.ADMIN_REQUEST_CLAN, id, type);
		}

		public function request(id:int, type:int):void
		{
			if (type == -1)
				Connection.sendData(PacketClient.ADMIN_REQUEST_INNER, id, DataForm.PROFILE);
			else
				Connection.sendData(PacketClient.ADMIN_REQUEST_NET, type, id, DataForm.PROFILE);
		}

		public function requestPays(id:int, loadComplete:Function):void
		{
			var variables:URLVariables = new URLVariables("auth_key=" + MD5.hash(this.adminKeyCode) + "&inner_id=" + id);

			var request:URLRequest = new URLRequest(this.urlScript);
			var payLoader:URLLoader = new URLLoader();
			request.method = URLRequestMethod.POST;
			request.data = variables;

			payLoader.addEventListener(Event.COMPLETE, loadComplete);
			payLoader.load(request);
		}

		public function save(type:int, data:ByteArray):void
		{
			Connection.sendData(PacketClient.ADMIN_EDIT_PLAYER, MainForm.player.uid, type, data);
		}

		public function saveClan(id:int, type:int, data:ByteArray):void
		{
			Connection.sendData(PacketClient.ADMIN_EDIT_CLAN, id, type, data);
		}

		public function message(text:String):void
		{
			Connection.sendData(PacketClient.ADMIN_MESSAGE, text);
		}

		private function onError(e:Event):void
		{
			trace("onError", e);
		}

		private function onConnected(e:Event):void
		{
			Connection.sendData(PacketClient.LOGIN, EditorConfig.ADMIN_NET_ID, EditorConfig.ADMIN_TYPE, 0, this.adminKeyCode, 0, 0, 0);
		}

		private function packetReceived(packet: AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketLogin.PACKET_ID:
					var login: PacketLogin = packet as PacketLogin;

					switch (login.status)
					{
						case PacketServer.LOGIN_SUCCESS:
							LoginSprite.textConnect.text = "LOGIN_SUCCESS";
							LoginSprite.textConnect.visible = false;
							MainForm.textID = true;
							unix_time = login.unixTime - int(getTimer() / 1000);

							trace("LOGIN_SUCCESS");

							MainForm.onLogin();
							break;
						case PacketServer.LOGIN_EXIST:
							LoginSprite.textConnect.text = "LOGIN_EXIST";
							MainForm.textID = false;
							trace("LOGIN_EXIST");
							break;
						case PacketServer.LOGIN_FAILED:
							LoginSprite.textConnect.text = "LOGIN_FAILED";
							MainForm.textID = false;
							trace("LOGIN_FAILED");
							break;
						case PacketServer.LOGIN_BLOCKED:
							LoginSprite.textConnect.text = "LOGIN_BLOCKED";
							MainForm.textID = false;
							trace("LOGIN_BLOCKED");
							break;
						case PacketServer.LOGIN_WRONG_VERSION:
							LoginSprite.textConnect.text = "LOGIN_WRONG_VERSION";
							MainForm.textID = false;
							trace("LOGIN_WRONG_VERSION");
							break;
					}
					break;
				case PacketAdminInfo.PACKET_ID:
					var adminInfo:PacketAdminInfo = packet as PacketAdminInfo;
					if (adminInfo.data != null)
						MainForm.load(adminInfo);
					break;
				case PacketAdminInfoClan.PACKET_ID:
					var adminInfoClan:PacketAdminInfoClan = packet as PacketAdminInfoClan;
					if (adminInfoClan.data != null)
						MainForm.loadClan(adminInfoClan);
					break;
				case PacketRequestPromo.PACKET_ID:
					var requestPromo:PacketRequestPromo = packet as PacketRequestPromo;
					MainForm.loadPromo(requestPromo);
					break;
			}
		}
	}
}