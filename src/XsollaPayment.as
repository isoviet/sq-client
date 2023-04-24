package
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import com.api.Services;
	import com.api.XsollaPaymentEvent;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketXsollaSignature;

	public class XsollaPayment
	{
		static private const PACKETS:Array = [PacketXsollaSignature.PACKET_ID];

		private var url:String = "";

		public function XsollaPayment():void
		{
			Logger.add("Xsolla Payment Created");

			Services.addEventListener(XsollaPaymentEvent.NAME, onXsollaPay, false, 0, false, Services.isOAuth);
			Connection.listen(onPacket, PACKETS);
		}

		private function onXsollaPay(e:XsollaPaymentEvent):void
		{
			if (this.url != "")
				return;

			this.url = e.url;

			Connection.sendData(PacketClient.SIGN_XSOLLA, e.info);
		}

		private function onPacket(packet:PacketXsollaSignature):void
		{
			if (this.url == "")
				return;

			this.url += "&sign=" + packet.singature;
			navigateToURL(new URLRequest(this.url));

			Logger.add("Xsolla PayStation open payment url=",this.url);
			this.url = "";
		}
	}
}