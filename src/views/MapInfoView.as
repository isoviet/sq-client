package views
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import dialogs.DialogResults;
	import menu.MenuProfile;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.PlayerUtil;

	public class MapInfoView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
		font-family: "Droid Sans";
		font-size: 12px;
		color: #7E5836;
	}
	.center{
		text-align:center;
	}
		a:hover{
		text-decoration: underline;
	}
		]]>).toString();

		static private const VOTE_NEGATIVE:int = 0;
		static private const VOTE_POSITIVE:int = 1;

		private var mapField:GameField;
		private var authorField:GameField;
		private var ratingField:GameField;

		private var formatPositive:TextFormat;
		private var formatNegative:TextFormat;

		private var ratePositiveButton:SimpleButton = null;
		private var rateNegativeButton:SimpleButton = null;

		public var ratingValue:int = 0;
		public var playedMapId:int = 0;
		public var authorPrevId:int = 0;

		public var mapRated:Boolean = false;

		private var ratingLabel:GameField = null;

		public function MapInfoView():void
		{
			super();
			init();
		}

		public function clear():void
		{
			this.mapField.text = "";
			this.authorField.text = "";
			this.ratingField.text = "";

			this.ratePositiveButton.visible = false;
			this.rateNegativeButton.visible = false;
		}

		public function update():void
		{
			this.mapField.htmlText = gls("<body><b>Карта №: {0}</b></body>", String(this.playedMapId));

			var author:Player = Game.getPlayer(this.authorPrevId);
			author.addEventListener(PlayerInfoParser.NAME | PlayerInfoParser.TYPE | PlayerInfoParser.MODERATOR, onPlayerLoaded);

			Game.request(this.authorPrevId, PlayerInfoParser.NAME | PlayerInfoParser.TYPE | PlayerInfoParser.MODERATOR);
			setRating();
		}

		public function dispose():void
		{
			Game.forget(onPlayerLoaded);
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.mapField = new GameField("", 0, 0, style);
			addChild(this.mapField);

			this.authorField = new GameField("", 0, 16, style, DialogResults.WIDTH);
			this.authorField.addEventListener(MouseEvent.MOUSE_UP, showMenu);
			addChild(this.authorField);

			this.ratingLabel = new GameField(gls("<body><b>Оценка: </b></body>"), 115, 0, style);
			addChild(this.ratingLabel);

			this.authorField.htmlText = gls("<body><span class = 'center'><b>Создатель: </b><a href = 'event:#'>{0}</a></span></body>", "56756");
			//this.authorField.userData = player.id;

			this.formatPositive = new TextFormat(null, 12, 0x127011, true);
			this.formatNegative = new TextFormat(null, 12, 0x8C0000, true);

			this.ratingField = new GameField("", 0, 0, this.formatPositive);
			this.ratingField.y = this.ratingLabel.y;
			addChild(this.ratingField);

			this.ratePositiveButton = new ButtonRatePositive();
			this.ratePositiveButton.y = this.ratingField.y + 2;
			this.ratePositiveButton.addEventListener(MouseEvent.CLICK, ratePositive);
			addChild(this.ratePositiveButton);

			this.rateNegativeButton = new ButtonRateNegative();
			this.rateNegativeButton.y = this.ratingField.y + 2;
			this.rateNegativeButton.addEventListener(MouseEvent.CLICK, rateNegative);
			addChild(this.rateNegativeButton);

			align();
		}

		private function align():void
		{
			var padding:Number = 10;
			var width:Number = this.mapField.width + padding + this.ratingLabel.width + padding +
				this.ratingField.textWidth + padding + this.ratePositiveButton.width;
			var offset:Number = DialogResults.WIDTH/2 - width/2;

			this.mapField.x = offset;
			this.ratingLabel.x = int(this.mapField.textWidth + padding) + this.mapField.x;
			this.ratingField.x = int(this.ratingLabel.x + this.ratingLabel.textWidth + padding);
			this.authorField.x = 0;//int(this.ratingField.x + this.ratingField.textWidth + padding);

			this.ratePositiveButton.x = this.ratingField.x + 2;
			this.rateNegativeButton.x = this.ratePositiveButton.x + this.ratePositiveButton.width + 2;
		}

		private function ratePositive(e:MouseEvent):void
		{
			Connection.sendData(PacketClient.ROUND_VOTE, this.playedMapId, VOTE_POSITIVE);

			this.ratingValue++;
			this.mapRated = true;
			setRating();
		}

		private function rateNegative(e:MouseEvent):void
		{
			Connection.sendData(PacketClient.ROUND_VOTE, this.playedMapId, VOTE_NEGATIVE);

			this.ratingValue--;
			this.mapRated = true;
			setRating();
		}

		private function setRating():void
		{
			var ratingString:String = (this.ratingValue > 0 ? "+" : "");
			if (Math.abs(this.ratingValue) > 999999999)
				ratingString += String(int(this.ratingValue / 1000000)) + gls("M");
			else if (Math.abs(this.ratingValue) > 999999)
				ratingString += String(int(this.ratingValue / 1000)) + "K";
			else
				ratingString = String(this.ratingValue);

			this.ratingField.text = ratingString;

			this.rateNegativeButton.visible = !this.mapRated;
			this.ratePositiveButton.visible = !this.mapRated;
			this.ratingField.visible = this.mapRated;

			this.ratingField.setTextFormat(this.ratingValue >= 0 ? this.formatPositive : this.formatNegative);

			align();
		}

		private function showMenu(e:MouseEvent):void
		{
			MenuProfile.showMenu(int(this.authorField.userData));
		}

		private function onPlayerLoaded(player:Player):void
		{
			player.removeEventListener(onPlayerLoaded);
			PlayerUtil.formatName(this.authorField, player, 150);

			this.authorField.htmlText = gls("<body><span class = 'center'><b>Создатель: </b><a href = 'event:#'>{0}</a></span></body>", this.authorField.text);
			this.authorField.userData = player.id;

			align();
		}
	}
}