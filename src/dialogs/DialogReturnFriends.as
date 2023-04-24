package dialogs
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import game.gameData.NotificationManager;
	import tape.TapeFriendReturnData;
	import tape.TapeFriendsReturnView;
	import tape.events.TapeDataEvent;
	import views.FriendsReturnCounter;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketReturnedFriend;

	public class DialogReturnFriends extends Dialog
	{
		static private var _instance:DialogReturnFriends = null;

		private var tapeFriends:TapeFriendsReturnView = null;
		private var tapeFriendsData:TapeFriendReturnData = null;
		private var counters:FriendsReturnCounter = null;
		private var selectedIds:Array = [];

		private var dialogNobodyReturn:DialogNobodyToReturn;

		public function DialogReturnFriends():void
		{
			super(null, false, false);

			init();

			_instance = this;
			Connection.listen(onPacket, [PacketReturnedFriend.PACKET_ID]);
		}

		static public function onSelected(playerId:int, selected:Boolean):void
		{
			if (_instance)
				_instance.onSelected(playerId, selected);
		}

		override public function show():void
		{
			if (this.tapeFriendsData.count > 0)
			{
				super.show();
				if (this.dialogNobodyReturn)
					this.dialogNobodyReturn.hide();
			}
			else
			{
				if (!this.dialogNobodyReturn)
					this.dialogNobodyReturn = new DialogNobodyToReturn();
				this.dialogNobodyReturn.show();
			}

			NotificationDispatcher.hide(NotificationManager.RETURN);
		}

		private function init():void
		{
			var background:DialogReturnFriendsBack = new DialogReturnFriendsBack();
			background.buttonClose.addEventListener(MouseEvent.CLICK, hide);
			background.buttonSelectAll.addEventListener(MouseEvent.CLICK, selectAll);
			addChild(background);

			var field:GameField = new GameField(gls("Верни друзей"), 0, 13, Dialog.FORMAT_CAPTION_29);
			field.filters = Dialog.FILTERS_CAPTION;
			field.x = int((background.width - field.textWidth) * 0.5);
			addChild(field);

			var button:ButtonBase = new ButtonBase(gls("Вернуть друзей"));
			button.x = 130;
			button.y = 375;
			button.addEventListener(MouseEvent.CLICK, returnFriends);
			addChild(button);

			addChild(new GameField(gls("Твоя максимально возможная\nнаграда за возвращение друзей:"), 92, 45, new TextFormat(null, 14, 0x4F3412, true, null, null, null, null, "center")));
			addChild(new GameField(gls("Выбери друзей, которых ты хочешь вернуть в игру:"), 30, 180, new TextFormat(null, 14, 0x4F3412, true)));

			this.counters = new FriendsReturnCounter();
			this.counters.x = 75;
			this.counters.y = 80;
			addChild(this.counters);

			this.tapeFriendsData = new TapeFriendReturnData();
			this.tapeFriendsData.addEventListener(TapeDataEvent.UPDATE, updateView);

			this.tapeFriends = new TapeFriendsReturnView();
			this.tapeFriends.x = 22;
			this.tapeFriends.y = 212;
			this.tapeFriends.setData(this.tapeFriendsData);
			addChild(this.tapeFriends);

			place();

			this.y -= 25;
		}

		private function selectAll(e:MouseEvent):void
		{
			this.tapeFriendsData.selectAll(this.selectedIds.length == 0);
		}

		private function returnFriends(e:MouseEvent):void
		{

			hide();
			if (this.selectedIds.length > 0)
				Connection.sendData(PacketClient.FRIENDS_RETURN, this.selectedIds);
		}

		private function onSelected(playerId:int, selected:Boolean):void
		{
			var index:int = this.selectedIds.indexOf(playerId);
			if (selected && index == -1)
				this.selectedIds.push(playerId);

			if (!selected && index != -1)
				this.selectedIds.splice(index, 1);

			updateView();
		}

		private function updateView(e:Event = null):void
		{
			this.counters.count = this.selectedIds.length;
			if (this.tapeFriendsData.count > 0)
				return;

			hide();
		}

		private function onPacket(packet:PacketReturnedFriend):void
		{
			var removedFriends:Array = [];

			for (var i:int = 0; i < packet.items.length; i++)
			{
				if (!packet.items[i].success)
					continue;

				removedFriends.push(packet.items[i].friendId);
				this.selectedIds.splice(this.selectedIds.indexOf(packet.items[i].friendId), 1);
			}

			if (removedFriends.length > 0)
				(new DialogInfo(gls("Приглашения друзьям отправлены"), "", false, null, 210)).showDialog();

			this.tapeFriendsData.removeItems(removedFriends);
			this.tapeFriends.offset = 0;
			updateView();
		}
	}
}