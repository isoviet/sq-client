package game.gameData
{
	import flash.events.EventDispatcher;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	import events.GameEvent;
	import game.gameData.GameConfig;
	import views.CloseoutTimerView;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketClothesCloseout;

	import utils.DateUtil;

	public class CloseoutManager
	{
		static private const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFFC77);
		static public const FILTERS_CAPTION:Array = [new BevelFilter(1.0, 58, 0xFFFFFF, 1.0, 0xFFCC00, 1.0, 2, 2),
			new GlowFilter(0x003366, 1.0, 4, 4, 8),
			new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)];

		static public const DISCOUNT:Number = 0.8;
		static public const DISCOUNT_TEXT:int = 20;

		static private var dispatcher:EventDispatcher = new EventDispatcher();

		static private var time:int = 0;
		static private var packageIds:Vector.<int> = new <int>[];

		static public function init():void
		{
			Connection.listen(onPacket, PacketClothesCloseout.PACKET_ID);
		}

		static public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}

		static public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}

		static public function closeoutDiscount(id:int):Number
		{
			for (var i:int = 0; i < ids.length; i++)
				if (GameConfig.getOutfitPackages(OutfitData.packageToOutfit(ids[i])).indexOf(id) != -1)
					return DISCOUNT;
			return 1.0;
		}

		static public function get ids():Vector.<int>
		{
			return packageIds;
		}

		static public function get timeString():String
		{
			return DateUtil.durationDayTime(time);
		}

		static private function onPacket(packet:PacketClothesCloseout):void
		{
			time = packet.expirationTime - Game.unix_time - int(getTimer() / 1000);
			packageIds = packet.packages;

			dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOSEOUT_START));
			EnterFrameManager.addPerSecondTimer(onTimer);
		}

		static private function onTimer():void
		{
			time--;

			CloseoutTimerView.update(time);

			if (time != 0)
				return;
			EnterFrameManager.removePerSecondTimer(onTimer);

			dispatcher.dispatchEvent(new GameEvent(GameEvent.CLOSEOUT_END));

			Connection.sendData(PacketClient.CLOTHES_REQUEST_CLOSEOUTS);
		}
	}
}