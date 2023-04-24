package game.gameData
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import dialogs.Dialog;
	import dialogs.DialogPromo;
	import dialogs.DialogPromoGroup;
	import loaders.RuntimeLoader;
	import screens.Screens;

	import com.api.QuestEvent;
	import com.api.Services;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketPromoBonus;

	public class PromoManager
	{
		static public var promoCode:String = "";

		static private var timer:Timer = null;
		static private var dialogPromo:Dialog = null;
		static private var dialogGroup:Dialog = null;

		static private var sended:Boolean = false;

		static public function init():void
		{
			promoCode = decodeURIComponent(promoCode);
			if (promoCode == "" || promoCode.length > 50)
				return;
			Connection.listen(onPacket, PacketPromoBonus.PACKET_ID);

			if (Game.self.type == Config.API_SA_ID)
				onGroup(new QuestEvent(QuestEvent.GROUP));
			else
			{
				Services.listenGroup(onGroup);
				Services.requestGroup();
			}
		}

		static private function onGroup(e:QuestEvent = null):void
		{
			if (e.value)
			{
				if (sended)
					return;
				sended = true;

				Connection.sendData(PacketClient.PROMO_CODE, promoCode);
				if (timer)
					timer.stop();
			}
			else if (!timer)
			{
				RuntimeLoader.load(function():void
				{
					dialogGroup = new DialogPromoGroup();
					Screens.addCallback(function():void
					{
						dialogGroup.show();
					});
				}, true);

				timer = new Timer(5000);

				timer.addEventListener(TimerEvent.TIMER, onRequest);
				timer.reset();
				timer.start();
			}
		}

		private static function onRequest(event:TimerEvent):void
		{
			Services.requestGroup();
		}

		static private function onPacket(packet:PacketPromoBonus):void
		{
			if (dialogGroup)
				dialogGroup.hide();

			RuntimeLoader.load(function():void
			{
				dialogPromo = new DialogPromo(packet.state, packet.type > -1 ? packet.type : 0, packet.data > -1 ? packet.data : 0);
				Screens.addCallback(function():void
				{
					dialogPromo.show();
				});
			}, true);
		}
	}
}