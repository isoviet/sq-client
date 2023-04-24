package dialogs
{
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;

	import buttons.ButtonBase;
	import tape.TapeInviteFriendsView;

	import com.api.Services;

	import utils.HtmlTool;

	public class DialogInviteFriends extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body
			{
				font-family: "Droid Sans";
				font-size: 14px;
				color: #000000;
				font-weight: bold;
			}
			.red {
				font-family: "a_PlakatTitul";
				color: #FF7E3F;
				font-size: 23px;
			}
		]]>).toString();

		static private const FILTERS_CAPTION:Array = [
			new BevelFilter(1.0, 58, 0xFFFFFF, 1.0, 0x996600, 1.0, 2, 2),
			new GlowFilter(0x663300, 1.0, 4, 4, 8),
			new DropShadowFilter(2, 45, 0x000000, 1.0, 2, 2, 0.25)
		];

		static private var _instance:DialogInviteFriends;

		private	var tapeFriendsView:TapeInviteFriendsView;

		private var style:StyleSheet;

		private var tmpIds:Array = [];

		public function DialogInviteFriends()
		{
			super(gls("Пригласи друга"));

			init();
		}

		static public function show():void
		{
			if (!_instance)
				_instance = new DialogInviteFriends();

			_instance.show();
		}

		private function init():void
		{
			this.style = new StyleSheet();
			this.style.parseCSS(CSS);

			var field:GameField = new GameField("<body>" + gls("За каждого приглашенного друга, который достигнет {0} уровня, ты получишь", Game.LEVEL_TO_FRIEND_INVITE) + "</body>", 5, 5, this.style);
			field.mouseEnabled = false;
			addChild(field);

			field = new GameField("<body>" + HtmlTool.span("+" + Game.COINS_FOR_INVITE, "red") + "</body>", field.x + (field.textWidth >> 1) - 110, 30, this.style);
			field.mouseEnabled = false;
			field.filters = FILTERS_CAPTION;
			addChild(field);

			var imageCoin:ImageIconCoins = new ImageIconCoins();
			imageCoin.mouseEnabled = false;
			imageCoin.x = field.x + field.textWidth + 5;
			imageCoin.y = 33;
			addChild(imageCoin);

			field = new GameField("<body>" + HtmlTool.span(gls("В подарок!"), "red") + "</body>", imageCoin.x + imageCoin.width + 5, 30, this.style);
			field.mouseEnabled = false;
			field.filters = FILTERS_CAPTION;
			addChild(field);

			this.tapeFriendsView = new TapeInviteFriendsView();
			this.tapeFriendsView.x = 24;
			this.tapeFriendsView.y = 70;
			addChild(this.tapeFriendsView);

			var inviteButton:ButtonBase = new ButtonBase(gls("Пригласить"));
			inviteButton.x = 225;
			inviteButton.y = 350;
			inviteButton.addEventListener(MouseEvent.CLICK, onClick);
			addChild(inviteButton);

			place();

			this.width = 600;
			this.height = 450;
		}

		override public function show():void
		{
			super.show();

			this.tapeFriendsView.selectAll();
		}

		private function onClick(e:MouseEvent):void
		{
			this.tmpIds = this.tapeFriendsView.getInviteIds().slice();

			onComplete();

			hide();
		}

		private function onComplete(answer:Object = null):void
		{
			if (answer) {/*unused*/}

			if (this.tmpIds.length == 0)
				return;

			Services.inviteFriendsById(this.tmpIds.shift());
		}
	}
}