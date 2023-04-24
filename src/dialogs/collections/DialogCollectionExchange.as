package dialogs.collections
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import dialogs.Dialog;
	import views.CollectionPlayerExchangeView;
	import views.CollectionResultExchangeView;
	import views.OnlineIcon;
	import views.ProfilePhoto;

	import com.api.Player;
	import com.api.PlayerEvent;

	import protocol.Connection;
	import protocol.PacketClient;

	public class DialogCollectionExchange extends Dialog
	{
		static private const SELECT_TO_GET:int = 0;
		static private const SELECT_TO_GIVE:int = 1;
		static private const CONFIRM:int = 2;

		static private const FRIEND_REQUEST:int = 5;

		static private const STATUSES:Array = [gls("Выбери предмет, который хочешь получить."), gls("Выбери предмет, который хочешь отдать взамен."), gls("Для подтверждения нажмите кнопку «Обменять»")];

		static private var _instance:DialogCollectionExchange = null;

		static public var byFriends:Boolean = false;

		private var playerId:int = -1;
		private var friends:Array = [];
		private var lastIndex:int = 0;

		private var playerPlace:ProfilePhoto;
		private var onlineIcon:OnlineIcon = null;

		private var resultView:CollectionResultExchangeView;

		private var selfCollectionSet:CollectionPlayerExchangeView;
		private var playerCollectionSet:CollectionPlayerExchangeView;

		private var buttonSearch:ButtonBase;

		private var spriteNoFriends:Sprite;

		private var searched:Boolean = false;
		private var isHide:Boolean = false;
		private var statusField:GameField = null;

		public function DialogCollectionExchange():void
		{
			super(gls("Обменяться коллекцией с друзьями"), true, true, null, false);

			init();

			this.graphics.beginFill(0x000000, 0.1);
			this.graphics.drawRect(-this.x, -this.y, Config.GAME_WIDTH, Config.GAME_HEIGHT);
		}

		static public function setPlayer(playerId:int = -1):void
		{
			if (!_instance)
				_instance = new DialogCollectionExchange();
			_instance.setPlayer(playerId);
		}

		override public function show():void
		{
			if (this.isHide)
				return;

			if (this.playerId != -1)
			{
				this.playerPlace.setPlayer(Game.getPlayer(this.playerId));
				this.onlineIcon.setPlayer(Game.getPlayer(this.playerId));
			}

			super.show();

			changeExchangeView();
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide(e);

			this.playerId = -1;

			byFriends = false;
		}

		override protected function effectOpen():void
		{}

		private function init():void
		{
			var image:DisplayObject = new DilaogCollectionBack();
			image.y = 86;
			addChild(image);

			this.resultView = new CollectionResultExchangeView();
			this.resultView.x = 225;
			this.resultView.y = 245;
			this.resultView.addEventListener(Event.CHANGE, exchange);
			addChild(this.resultView);

			this.selfCollectionSet = new CollectionPlayerExchangeView(true);
			this.selfCollectionSet.y = 10;
			this.selfCollectionSet.addEventListener(Event.CHANGE, changeExchangeView);
			addChild(this.selfCollectionSet);

			this.playerCollectionSet = new CollectionPlayerExchangeView(false);
			this.playerCollectionSet.x = -30;
			this.playerCollectionSet.y = 140;
			this.playerCollectionSet.addEventListener(Event.CHANGE, changeExchangeView);
			addChild(this.playerCollectionSet);

			this.playerPlace = new ProfilePhoto(65);
			this.playerPlace.x = 45;
			this.playerPlace.y = 135;
			this.playerPlace.mouseEnabled = false;
			this.playerPlace.mouseChildren = false;
			addChild(this.playerPlace);

			var ratingPlaceButton:RatingPlaceButton = new RatingPlaceButton();
			ratingPlaceButton.width = this.playerPlace.width;
			ratingPlaceButton.height = this.playerPlace.height;
			this.playerPlace.addChild(ratingPlaceButton);

			this.onlineIcon = new OnlineIcon(8);
			this.onlineIcon.x = 97;
			this.onlineIcon.y = 140;
			addChild(this.onlineIcon);

			this.buttonSearch = new ButtonBase(gls("Поиск по друзьям"));
			this.buttonSearch.x = int((this.selfCollectionSet.width - this.buttonSearch.width) * 0.5);
			this.buttonSearch.y = 75;
			this.buttonSearch.addEventListener(MouseEvent.CLICK, onSearch);
			addChild(this.buttonSearch);

			this.spriteNoFriends = new Sprite();
			this.spriteNoFriends.x = 155;
			this.spriteNoFriends.y = 70;
			this.spriteNoFriends.addChild(new GameField(gls("К сожалению, у тебя нет друзей, которые\nобмениваются коллекциями"), 0 ,0, new TextFormat(null, 16, 0x663300, false, null, null, null, null, "center")));
			var buttonInvite:ButtonBase = new ButtonBase(gls("Пригласить друзей"));
			buttonInvite.x = int((this.spriteNoFriends.width - buttonInvite.width) * 0.5);
			buttonInvite.y = 90;
			buttonInvite.addEventListener(MouseEvent.CLICK, onInvite);
			this.spriteNoFriends.addChild(buttonInvite);
			image = new ImageNoFriends();
			image.x = this.spriteNoFriends.width - 45;
			image.y = 20;
			image.scaleX = image.scaleY = 0.6;
			this.spriteNoFriends.addChild(image);
			addChild(this.spriteNoFriends);

			var statusFormat:TextFormat = new TextFormat(null, 12, 0x6D6351, true);
			statusFormat.align = TextFormatAlign.CENTER;

			var sprite:Sprite = new Sprite();
			sprite.x = 25;
			sprite.y = 240;
			sprite.graphics.beginFill(0xFFFFFF);
			sprite.graphics.drawRoundRect(0, 0, 175, 70, 10, 10);
			sprite.graphics.drawTriangles(Vector.<Number>([175, 25, 175, 45, 185, 35]));
			sprite.filters = [new DropShadowFilter(1, 45, 0x000000, 1, 9, 9, 0.5)];
			addChild(sprite);

			this.statusField = new GameField(gls("Выбери предмет, который хочешь получить."), 0, 0, statusFormat);
			this.statusField.autoSize = TextFieldAutoSize.CENTER;
			this.statusField.multiline = true;
			this.statusField.wordWrap = true;
			this.statusField.width = 175;
			sprite.addChild(this.statusField);

			place();

			this.width = 650;
			this.height = 370;

			Game.listen(onPlayerLoaded);
		}

		private function onSearch(e:MouseEvent):void
		{
			setPlayer(-1);
		}

		private function onInvite(e:MouseEvent):void
		{
			Game.inviteFriends();

			hide();
		}

		private function setPlayer(playerId:int = -1):void
		{
			this.isHide = false;

			this.playerId = playerId;

			this.spriteNoFriends.visible = false;

			this.playerPlace.visible = true;
			this.onlineIcon.visible = true;
			this.playerCollectionSet.visible = true;
			this.buttonSearch.visible = true;

			if (this.playerId != -1)
				Game.request(this.playerId, PlayerInfoParser.COLLECTION_EXCHANGE | PlayerInfoParser.EXPERIENCE, true);
			else
			{
				if (Game.friendsIds.length == 0)
				{
					this.spriteNoFriends.visible = true;

					this.playerPlace.visible = false;
					this.onlineIcon.visible = false;
					this.playerCollectionSet.visible = false;
					this.buttonSearch.visible = false;

					if (byFriends)
						Connection.sendData(PacketClient.COUNT, PacketClient.EXCHANGE_USED, 1);

					show();
					return;
				}
				if (this.lastIndex >= Game.friendsIds.length)
				{
					this.lastIndex = 0;
					if (!this.searched)
						showError();
					else
						setPlayer(-1);
					this.searched = false;
				}
				else
				{
					var count:int = FRIEND_REQUEST - this.friends.length;
					this.friends = this.friends.concat(Game.friendsIds.slice(this.lastIndex, Math.min(Game.friendsIds.length, this.lastIndex + count)));
					Game.request(this.friends, PlayerInfoParser.COLLECTION_EXCHANGE | PlayerInfoParser.EXPERIENCE, true);
					this.lastIndex += count;
				}
			}
		}

		private function setStatus(statusId:int):void
		{
			this.statusField.text = STATUSES[statusId];
			this.statusField.y = 35 - int(this.statusField.textHeight * 0.5);
		}

		private function exchange(e:Event):void
		{
			if (Game.balanceNuts < Game.COLLECTION_EXCHANGE_COST)
				return;

			if (byFriends)
				Connection.sendData(PacketClient.COUNT, PacketClient.EXCHANGE_USED, 1);

			Connection.sendData(PacketClient.COLLECTION_EXCHANGE, this.playerId, this.selfCollectionSet.selectedId, this.playerCollectionSet.selectedId);
			hide();
		}

		private function onPlayerLoaded(e:PlayerEvent):void
		{
			var player:Player = e.player;

			if (this.playerId == -1 ? this.friends.indexOf(player.id) == -1 : player.id != this.playerId)
				return;

			if (this.playerId == -1)
				this.friends.splice(this.friends.indexOf(player.id), 1);

			if (!checkExchange(player))
			{
				if (this.playerId != -1)
					showError();
				else if (this.friends.length == 0)
					setPlayer(-1);
				return;
			}
			else if (!this.visible)
				show();

			if (this.playerId == -1)
				this.searched = true;
			this.playerId = player.id;

			this.playerCollectionSet.setPlayer(player, Experience.selfLevel);
			this.selfCollectionSet.setPlayer(Game.self, player.level);

			changeExchangeView();
		}

		private function showError():void
		{
			super.hide();

			this.isHide = true;
			this.playerId = -1;

			DialogCollectionNoItems.show();
		}

		private function changeExchangeView(e:Event = null):void
		{
			this.resultView.change(this.playerCollectionSet.selectedId, this.selfCollectionSet.selectedId);

			if (this.selfCollectionSet.selectedId == -1)
				setStatus(DialogCollectionExchange.SELECT_TO_GIVE);
			else if (this.playerCollectionSet.selectedId == -1)
				setStatus(DialogCollectionExchange.SELECT_TO_GET);
			else
				setStatus(DialogCollectionExchange.CONFIRM);
		}

		private function checkExchange(player:Player):Boolean
		{
			return (("collection_exchange" in player) && player['collection_exchange'].length != 0);
		}
	}
}