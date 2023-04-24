package dialogs
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import fl.containers.ScrollPane;

	import screens.ScreenGame;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import statuses.Status;
	import tape.list.PlayerResultView;
	import tape.list.events.ListDataEvent;
	import views.MapInfoView;
	import views.PlayerResultListData;

	import protocol.Connection;
	import protocol.packages.server.PacketRoomRound;

	import utils.BitmapClip;
	import utils.FiltersUtil;

	public class DialogResults extends Dialog
	{
		static private const TEXT_FORMAT_RIBBON:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 30,
			0xffffff, null, null, null, null, null, TextFormatAlign.CENTER);
		static private const TEXT_FORMAT_REWARD:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0x857653,
			null, null, null, null, null, TextFormatAlign.CENTER);

		static private const TEXT_FORMAT_EXTEND:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 13, 0xffffff, false,
			null, null, null, null, TextFormatAlign.LEFT);

		static public const WIDTH:int = 359;
		static public const HEIGHT_BG:int = 264;
		static public const HEIGHT_MAX_BG:int = 117;

		private var buttonMinimize:Sprite = null;
		private var buttonMaximize:Sprite = null;

		protected var resultLayer:Sprite = null;

		private var nextButton:SimpleButton = null;
		protected var textReward:GameField = null;
		protected var mapInfo:MapInfoView = null;

		protected var listPlayers:PlayerResultView = null;
		protected var listData:PlayerResultListData = null;

		private var nextButtonLayer:Sprite = null;
		protected var bg:DialogBaseBackground = null;

		//------- HEADER ------
		protected var headerLayer:Sprite = null;
		protected var animation:MovieClip = null;
		protected var ribbon:BitmapClip = null;
		protected var ribbonText:GameField = null;

		private var bgHeight:int = 0;

		private var mapId:int = 0;
		private var authorId:int = 0;
		private var ratingValueNew:int = 0;

		protected var scrollPane:ScrollPane = null;
		protected var scrollSprite:Sprite = null;

		public function DialogResults(classHeader:Class):void
		{
			super(null, false, true, null, true);
			setDefaultSize();

			init(classHeader);

			this.canClose = true;
			initClose();
			this.buttonClose.x = 330;
			this.buttonClose.y = 32;

			this.sound = "";

			Connection.listen(onPacket, [PacketRoomRound.PACKET_ID]);
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = -150;
			this.rightOffset = 0;
			this.topOffset = -80;
			this.bottomOffset = 0;
		}

		override public function show():void
		{
			super.show();
			this.viewResult = false;
			placeInCenter();

			if(this.nextButton)
			{
				this.nextButton.enabled = true;
				this.nextButton.filters = null;
			}

			if (Hero.self)
				Hero.self.toggleBuff(false);
		}

		private function onPacket(packet:PacketRoomRound):void
		{
			this.mapId = packet.mapId > -1 ? packet.mapId : this.mapId;
			this.authorId = packet.mapAuthor > -1 ? packet.mapAuthor : this.authorId;
			this.ratingValueNew = packet.rating > -1 ? packet.rating : this.ratingValueNew;

			this.mapInfo.authorPrevId = this.authorId;
			this.mapInfo.playedMapId = this.mapId;
			this.mapInfo.ratingValue = this.ratingValueNew;
			this.mapInfo.update();
			this.mapInfo.visible = true;
		}

		protected function init(classHeader:Class):void
		{
			var bgHeight:int = HEIGHT_BG;
			//--------- HEADER MOVIE -------------
			this.headerLayer = new Sprite();
			addChild(this.headerLayer);

			this.animation = new classHeader();
			this.animation.x = 175;
			this.animation.y = 63;
			this.headerLayer.addChild(this.animation);

			//-------- BACKGROUND -----------------
			this.bg = new DialogBaseBackground();
			this.bg.width = WIDTH;
			this.bg.height = bgHeight;
			addChild(this.bg);

			this.ribbon = BitmapClip.replace(new ImageRibborn());
			this.ribbon.stop();
			addChild(this.ribbon);
			this.ribbon.x = -30;
			this.ribbon.y = -40;

			//-------- ADDITION -------------------
			var textMaximize:GameField = new GameField(gls("Развернуть"), 151, 0, TEXT_FORMAT_EXTEND, 190);
			this.buttonMaximize = new ButtonMaximize();
			this.buttonMaximize.buttonMode = true;
			this.buttonMaximize.addChild(textMaximize);
			this.buttonMaximize.x = 3;
			this.buttonMaximize.y = bgHeight-24;
			this.buttonMaximize.addEventListener(MouseEvent.CLICK, maximize);
			this.addChild(this.buttonMaximize);

			var textMinimize:GameField = new GameField(gls("Свернуть"), 151, 0, TEXT_FORMAT_EXTEND, 190);
			this.buttonMinimize = new ButtonMaximize();
			this.buttonMinimize.addChild(textMinimize);
			this.buttonMinimize.buttonMode = true;
			this.buttonMinimize.x = 3;
			this.buttonMinimize.y = bgHeight-24;
			this.buttonMinimize.addEventListener(MouseEvent.CLICK, minimize);
			this.addChild(this.buttonMinimize);

			this.ribbonText = new GameField('', -23, -19, TEXT_FORMAT_RIBBON, 401);
			this.ribbonText.filters = [new DropShadowFilter(0, 0, 0x081F3A, 1, 3, 3, 2)];
			addChild(this.ribbonText);

			this.textReward = new GameField(gls("твоя награда"), 0, 33, TEXT_FORMAT_REWARD, WIDTH);
			this.addChild(this.textReward);

			this.nextButtonLayer = new Sprite();
			this.nextButtonLayer.y = bgHeight - 96;
			addChild(this.nextButtonLayer);

			this.nextButton = new ButtonChangeRoom();
			this.nextButton.addEventListener(MouseEvent.CLICK, changeRoom);
			this.nextButton.x = int((WIDTH - this.nextButton.width) * 0.5);
			this.nextButton.y = 0;
			new Status(this.nextButton, gls("Перейти на следующую карту\nВнимание! Ты покинешь этих белок и присоединишься к другим!"));
			this.nextButtonLayer.addChild(this.nextButton);

			this.mapInfo = new MapInfoView();
			this.mapInfo.visible = false;
			this.mapInfo.x = 0;
			this.mapInfo.y = 40;
			this.nextButtonLayer.addChild(this.mapInfo);

			this.listData = new PlayerResultListData();
			this.listData.addEventListener(ListDataEvent.SORTED, updateSelfData);
			this.listData.addEventListener(ListDataEvent.UPDATE, updateListData);

			this.listPlayers = new PlayerResultView();
			this.listPlayers.x = WIDTH * 0.5 - 125;
			this.listPlayers.y = 36;
			this.listPlayers.setData(this.listData);
			GameSounds.play('next_round');

			GameSounds.play(SoundConstants.BUTTON_CLICK);

			this.resultLayer = new Sprite();
			this.addChild(resultLayer);

			this.scrollPane = new ScrollPane();
			this.resultLayer.addChild(this.scrollPane);
			this.scrollPane.setStyle("thumbUpSkin", ScrollPaneButton);
			this.scrollPane.setStyle("thumbDownSkin", ScrollPaneButton);
			this.scrollPane.setStyle("thumbOverSkin", ScrollPaneButton);
			this.scrollPane.setStyle("trackUpSkin", BgImageScrollResult);
			this.scrollPane.setStyle("trackDownSkin", BgImageScrollResult);
			this.scrollPane.setStyle("trackOverSkin", BgImageScrollResult);
			this.scrollPane.setStyle("downArrowDownSkin", ButtonDownScrollResult);
			this.scrollPane.setStyle("downArrowOverSkin", ButtonDownScrollResult);
			this.scrollPane.setStyle("downArrowUpSkin", ButtonDownScrollResult);
			this.scrollPane.setStyle("upArrowDownSkin", ButtonUpScrollResult);
			this.scrollPane.setStyle("upArrowOverSkin", ButtonUpScrollResult);
			this.scrollPane.setStyle("upArrowUpSkin", ButtonUpScrollResult);
			this.scrollPane.setStyle("thumbIcon", ScrollPaneThumb);

			this.scrollPane.x = 0;
			this.scrollPane.y = 25;
			this.scrollPane.setSize(350, 106);

			this.scrollSprite = new Sprite();
			this.scrollSprite.addChild(this.listPlayers);

			this.listPlayers.y = 0;

			this.scrollPane.source = this.scrollSprite;
			this.scrollPane.update();

			setBgHeight = 264;
		}

		protected function updateListData(event:ListDataEvent):void
		{
			if(this.scrollPane)
				this.scrollPane.update();
		}

		public function setSquirrels(ids:Vector.<int>):void
		{
			this.listData.set(ids);
			this.scrollPane.update();
		}

		public function addPlayer(id:int, time:int):void
		{
			this.listData.inHollow(id, time);
		}

		protected function updateSelfData(event:ListDataEvent):void
		{
			if(this.scrollPane)
				this.scrollPane.update();
		}

		protected function set setBgHeight(value:int):void
		{
			this.bgHeight = value;

			if(this.bg)
				this.bg.height = value;

			if(this.buttonMaximize && this.buttonMinimize)
			{
				this.buttonMaximize.y = value - 24;
				this.buttonMinimize.y = value - 24 + HEIGHT_MAX_BG;
			}

			this.resultLayer.y = value - 45;

			if(this.nextButtonLayer)
				this.nextButtonLayer.y = value - 106;
		}

		private function changeRoom(e:Event):void
		{
			ScreenGame.changeRoom();
			this.nextButton.enabled = false;
			this.nextButton.filters = FiltersUtil.GREY_FILTER;
		}

		protected function set viewResult(value:Boolean):void
		{
			this.resultLayer.visible = value;

			if (this.bg)
				this.bg.height = value ? (this.bgHeight + HEIGHT_MAX_BG) : this.bgHeight;

			if (this.buttonMaximize && this.buttonMinimize)
			{
				this.buttonMaximize.visible = !value;
				this.buttonMinimize.visible = value;
			}
		}

		private function maximize(e:MouseEvent):void
		{
			this.viewResult = true;
		}

		private function minimize(e:MouseEvent):void
		{
			this.viewResult = false;
		}
	}
}