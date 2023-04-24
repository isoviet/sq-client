package game.gameData
{
	import events.NotificationEvent;
	import views.NotificationView;
	import views.TvView;

	import protocol.Connection;
	import protocol.packages.server.PacketClothesCloseout;

	public class NotificationManager
	{
		static private var _instance:NotificationManager;

		static private var type:int = 0;

		static public const COLLECTION:uint = (1 << type);
		static public const LEPRECHAUN:uint = (1 << ++type);
		static public const SHOP:uint = (1 << ++type);
		static public const RETURN:uint = (1 << ++type);
		static public const MAIL:uint = (1 << ++type);
		static public const NEWS:uint = (1 << ++type);
		static public const DAILY_QUEST:uint = (1 << ++type);

		private var notifications:Vector.<NotificationData> = Vector.<NotificationData>([]);

		private var closeoutPeriod:int = 0;
		public var lastNews:int = -1;

		private var activeType:uint = 0;

		public function NotificationManager()
		{
			SettingsStorage.addCallback(SettingsStorage.NOTIFICATIONS, onLoad);

			NotificationDispatcher.instance.addEventListener(NotificationEvent.SHOW, onShow);
			NotificationDispatcher.instance.addEventListener(NotificationEvent.HIDE, onHide);

			Connection.listen(onPacket, PacketClothesCloseout.PACKET_ID);
		}

		static public function get instance():NotificationManager
		{
			return _instance ||= new NotificationManager();
		}

		public function register(type:uint, notification:NotificationView):void
		{
			for each(var data:NotificationData in this.notifications)
				if (data.view == notification)
					new Error("This notification by type #" + type + " already registered!");

			notification.active = false;
			this.notifications.push(new NotificationData(type, notification));
		}

		public function saveNewsData(newsId:int):void
		{
			var data:Object = SettingsStorage.load(SettingsStorage.NOTIFICATIONS);
			data['news_id'] = newsId;
			SettingsStorage.save(SettingsStorage.NOTIFICATIONS, data);

			NotificationDispatcher.hide(NEWS);
		}

		private function onLoad():void
		{
			var data:Object = SettingsStorage.load(SettingsStorage.NOTIFICATIONS);

			if (data['news_id'] != TvView.last_news)
			{
				this.lastNews = data['news_id'];
				NotificationDispatcher.show(NEWS);
			}
		}

		private function onPacket(packet:PacketClothesCloseout):void
		{
			//TODO
			this.closeoutPeriod = 0;//packet.closeoutIndex;
		}

		private function onHide(e:NotificationEvent):void
		{
			this.activeType &= ~e.notificationType;

			update();
		}

		private function onShow(e:NotificationEvent):void
		{
			this.activeType |= e.notificationType;

			update();
		}

		private function update():void
		{
			for each(var data:NotificationData in this.notifications)
				data.view.active = (data.type & this.activeType) > 0;
		}
	}
}

import views.NotificationView;

internal class NotificationData
{
	public var type:uint = 0;
	public var view:NotificationView;

	public function NotificationData(type:uint, view:NotificationView)
	{
		this.type = type;
		this.view = view;
	}
}