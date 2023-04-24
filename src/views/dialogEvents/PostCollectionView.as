package views.dialogEvents
{
	import flash.display.DisplayObject;
	import flash.events.TextEvent;
	import flash.text.TextFormat;

	import game.gameData.CollectionsData;
	import menu.MenuProfile;

	import com.api.Player;

	import protocol.PacketServer;

	import utils.HtmlTool;

	public class PostCollectionView extends PostElementView
	{
		private var caption:GameField = null;

		private var playerId:int = -1;
		private var hisItemId:int = -1;
		private var myItemId:int = -1;

		public function PostCollectionView(id:int, playerId:int, data:int, time:int):void
		{
			super(id, PacketServer.EXCHANGE_EVENT, time);

			this.playerId = playerId;

			this.myItemId = data & 255;
			this.hisItemId = data >> 8;
		}

		override public function onShow():void
		{
			if (this.caption != null)
				return;

			super.onShow();

			var background:CollectionMailBackground = new CollectionMailBackground();
			background.width = background.height = 80;
			addChild(background);

			var iconClass:Class = CollectionsData.getIconClass(this.hisItemId);
			var icon:DisplayObject = new iconClass();
			icon.x = int((80 - icon.width) * 0.5);
			icon.y = int((80 - icon.height) * 0.5);
			addChild(icon);

			addChild(new GameField("<body>" + gls("Игрок") + "</body>", 85, 10, style));

			this.caption = new GameField("", 125, 10, style);
			this.caption.addEventListener(TextEvent.LINK, onLink);
			addChild(this.caption);

			addChild(new GameField("<body>" + gls("обменялся с тобой!") + "<body>", 85, 25, style));

			var firstItemField:GameField = new GameField(CollectionsData.regularData[this.myItemId]['tittle'], 85, 40, new TextFormat(null, 13, 0x00CC33, true));
			addChild(firstItemField);

			var arrows:ExchangeArrowsView = new ExchangeArrowsView();
			arrows.scaleX = arrows.scaleY = 0.65;
			arrows.x = firstItemField.x + firstItemField.textWidth + 7;
			arrows.y = 42;
			addChild(arrows);

			addChild(new GameField(CollectionsData.regularData[this.hisItemId]['tittle'], arrows.x + arrows.width, 40, new TextFormat(null, 13, 0x0099FF, true)));

			var player:Player = Game.getPlayer(this.playerId);
			player.addEventListener(PlayerInfoParser.NAME, onPlayerLoad);

			Game.request(this.playerId, PlayerInfoParser.NAME);
		}

		private function onLink(e:TextEvent):void
		{
			MenuProfile.showMenu(this.playerId);
		}

		private function onPlayerLoad(player:Player):void
		{
			if (type) {/*unused*/}

			player.removeEventListener(onPlayerLoad);

			this.caption.htmlText = "<body><b>" + HtmlTool.anchor(player.name, "event:" + player.id) + "</b></body>";
		}
	}
}