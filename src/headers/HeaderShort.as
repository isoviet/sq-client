package headers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import buttons.ButtonBase;
	import dialogs.DialogScreenshot;
	import screens.ScreenGame;
	import screens.ScreenLearning;
	import screens.ScreenSchool;
	import screens.Screens;
	import sounds.GameSounds;
	import statuses.Status;
	import views.PlayersCountView;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoomLeave;

	import utils.DateUtil;
	import utils.FiltersUtil;

	public class HeaderShort extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #000000;
				line-height: 1.5;
			}
			.count {
				font-size: 13px;
				color: #000000;
			}
			a {
				text-decoration: underline;
			}
		]]>).toString();

		static private const TYPE_NONE:int = -1;
		static private const TYPE_GAME:int = 0;
		static private const TYPE_LEARNING:int = 1;
		static private const TYPE_SCHOOL:int = 2;

		static private var _instance:HeaderShort;

		private var fieldTime:GameField;
		private var clock:ImageClock;

		private var playersCountView:PlayersCountView;

		private var variableItems:Array = [];

		private var screenShotStatus:Status;

		private var middleSprite:Sprite = null;
		private var rightSprite:Sprite = null;

		public function HeaderShort():void
		{
			_instance = this;

			super();

			this.visible = false;

			init();

			Connection.listen(onPacket, [PacketRoomLeave.PACKET_ID], 1);
		}

		static public function show():void
		{
			_instance.visible = true;

			if (Screens.active is ScreenGame)
				_instance.toggleHeader(TYPE_GAME);
			else if (Screens.active is ScreenLearning)
				_instance.toggleHeader(TYPE_LEARNING);
			else if (Screens.active is ScreenSchool)
				_instance.toggleHeader(TYPE_SCHOOL);
			else
				_instance.toggleHeader(TYPE_NONE);
		}

		static public function hide():void
		{
			_instance.visible = false;
		}

		static public function clear():void
		{
			_instance.fieldTime.text = "";

			_instance.clock.visible = false;

			_instance.playersCountView.hide();
		}

		static public function updateTimer(value:int):void
		{
			_instance.fieldTime.text = String(DateUtil.formatTime(value));
			_instance.fieldTime.visible = true;
			_instance.clock.visible = true;
		}

		static public function getTime():String
		{
			return _instance.fieldTime.text;
		}

		static public function getTimeInt():int
		{
			return int(_instance.fieldTime.text.split(":")[1]) + int(_instance.fieldTime.text.split(":")[0]) * 60;
		}

		static public function setSquirrels(ids:Vector.<int>):void
		{
			_instance.playersCountView.setSquirrels(ids.length);
		}

		static public function setTeams(redTeamIds:Vector.<int>, blueTeamIds:Vector.<int>):void
		{
			_instance.playersCountView.setTeams(redTeamIds, blueTeamIds);
		}

		static public function setPlayersFrags(fragData:Array):void
		{
			_instance.playersCountView.battlePlayers.setFrags(fragData);
		}

		static public function setMap(number:int):void
		{
			_instance.playersCountView.battlePlayers.setMap(number);
		}

		static public function setGameLocation(id:int):void
		{
			_instance.playersCountView.show(id == Locations.BATTLE_ID);
		}

		static public function onFullScreen():void
		{
			if (!_instance)
				return;
			_instance.middleSprite.x = int((Game.starling.stage.stageWidth - 110) * 0.5);
			_instance.rightSprite.x = int((Game.starling.stage.stageWidth - _instance.rightSprite.width));
		}

		static public function set enableButtons(value:Boolean):void
		{
			for each (var item:* in _instance.variableItems)
			{
				var button:ButtonBase = item['object'] as ButtonBase;
				if(button != null)
				{
					button.enabled = value;
					button.filters = !value ? FiltersUtil.GREY_FILTER : [];
				}
			}
		}

		static public function set enableMiddleHeader(value:Boolean):void
		{
			_instance.middleSprite.visible = value;
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var back:DisplayObject = new HeaderLeftBack();
			back.x = -90;
			addChild(back);

			this.middleSprite = new Sprite();
			this.middleSprite.x = 395;
			this.middleSprite.addChild(new HeaderGameMiddle());
			addChild(this.middleSprite);

			this.rightSprite = new Sprite();
			this.rightSprite.x = int((Game.starling.stage.stageWidth - 110) * 0.5);
			this.rightSprite.addChild(new HeaderGameRight());
			addChild(this.rightSprite);

			this.fieldTime = new GameField("", 25, 13, new TextFormat(null, 13, 0xFFFFFF, true));
			this.middleSprite.addChild(this.fieldTime);
			this.variableItems.push({'object': this.fieldTime, 'types': [TYPE_GAME]});

			this.clock = new ImageClock();
			this.clock.x = 7;
			this.clock.y = 13;
			this.clock.cacheAsBitmap = true;
			this.middleSprite.addChild(this.clock);
			this.variableItems.push({'object': this.clock, 'types': [TYPE_GAME]});

			this.playersCountView = new PlayersCountView();
			this.playersCountView.x = 35;
			this.playersCountView.y = 13;
			this.middleSprite.addChild(this.playersCountView);
			this.variableItems.push({'object': this.playersCountView, 'types': [TYPE_GAME]});

			var buttonPhoto:ButtonPhotoHeader = new ButtonPhotoHeader();
			buttonPhoto.x = 36;
			buttonPhoto.y = 10;
			buttonPhoto.upState.cacheAsBitmap = true;
			buttonPhoto.addEventListener(MouseEvent.CLICK, showDialogScreenshot);
			this.rightSprite.addChild(buttonPhoto);
			this.screenShotStatus = new Status(buttonPhoto, gls("Снимок экрана"));

			var buttonExit:ButtonBase = new ButtonBase(gls("Выход"));
			buttonExit.scaleX = buttonExit.scaleY = 0.65;
			buttonExit.x = 96;
			buttonExit.y = 15;
			buttonExit.addEventListener(MouseEvent.CLICK, onExit);
			this.rightSprite.addChild(buttonExit);
			this.variableItems.push({'object': buttonExit, 'types': [TYPE_GAME]});

			buttonExit = new ButtonBase(gls("Выход"));
			buttonExit.scaleX = buttonExit.scaleY = 0.65;
			buttonExit.x = 96;
			buttonExit.y = 15;
			buttonExit.addEventListener(MouseEvent.CLICK, onExitLearning);
			this.rightSprite.addChild(buttonExit);
			this.variableItems.push({'object': buttonExit, 'types': [TYPE_LEARNING]});

			buttonExit = new ButtonBase(gls("Выход"));
			buttonExit.scaleX = buttonExit.scaleY = 0.65;
			buttonExit.x = 96;
			buttonExit.y = 15;
			buttonExit.addEventListener(MouseEvent.CLICK, onExitSchool);
			this.rightSprite.addChild(buttonExit);
			this.variableItems.push({'object': buttonExit, 'types': [TYPE_SCHOOL]});

			toggleHeader(TYPE_GAME);
		}

		private function showDialogScreenshot(e:MouseEvent):void
		{
			this.screenShotStatus.visible = false;
			DialogScreenshot.show();
			this.screenShotStatus.visible = true;
		}

		private function soundClick(e:MouseEvent):void
		{
			GameSounds.play("click", true);
		}

		private function onExit(e:MouseEvent):void
		{
			Connection.sendData(PacketClient.LEAVE);
		}

		private function onExitLearning(e:MouseEvent):void
		{
			Screens.show("Location");
		}

		private function onExitSchool(e:MouseEvent):void
		{
			Screens.show(Screens.screenToComeback);
		}

		private function toggleHeader(type:int):void
		{
			for each (var item:* in this.variableItems)
				item['object'].visible = item['types'].indexOf(type) != -1;
		}

		private function onPacket(packet:PacketRoomLeave):void
		{
			this.playersCountView.onRemove(packet.playerId);
		}
	}
}