package views
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import game.mainGame.GameMap;

	import com.greensock.TweenLite;

	import protocol.Connection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoom;
	import protocol.packages.server.PacketRoomRound;

	public class RoundStartingView extends Sprite
	{
		static private var _instance:RoundStartingView = null;

		private var timer:Timer =null;

		private var tween:TweenLite = null;

		private var background:Sprite = new RoundBackground();

		private var progress:Sprite = new RoundProgress();
		private var progressFrame:Sprite = new RoundLoadFrameProgress();

		private var fieldDelay:GameField = null;
		private var fieldCaption:GameField = null;
		private var fieldModeCaption:GameField = null;
		private var fieldModeText:GameField = null;

		private var _widthProgress: int = 0;
		private var _needWidth: int = 0;

		private var locationId:int;
		private var mode:int;

		static public function get instance():RoundStartingView
		{
			return _instance;
		}

		public function RoundStartingView():void
		{
			_instance = this;

			init();

			Connection.listen(onPacket, [PacketRoom.PACKET_ID, PacketRoomRound.PACKET_ID]);
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onFullScreen);
		}

		public function onFullScreen(e: Event = null): void
		{
			this.x = 0;
			this.y = 0;

			this.progressFrame.x = int(Game.starling.stage.stageWidth / 2);
			this.progressFrame.y = int(Game.starling.stage.stageHeight / 2) + 130;

			this.background.x = int( Game.starling.stage.stageWidth / 2);
			this.background.y = int(Game.starling.stage.stageHeight / 2);
			this.background.scaleX = Game.starling.stage.stageWidth / Config.GAME_WIDTH;
			this.background.scaleY = Game.starling.stage.stageHeight / Config.GAME_HEIGHT;
		}

		override public function set visible(value:Boolean):void
		{
			this.progress.visible = value;
			super.visible = value;
		}

		public function show(delay:int):void
		{
			onFullScreen();

			if (delay <= 0)
				return;

			this.visible = true;
			this.fieldDelay.text = "";
			this.progress.width = 0;
			_needWidth = 0;

			this.timer.reset();
			this.timer.repeatCount = delay * 10;
			this.timer.start();

			onTick();
		}

		public function hide():void
		{
			this.visible = false;

			this.timer.stop();
			this.fieldDelay.text = "";
			this.progress.width = 0;
			_needWidth = 0;
			if (this.tween)
				this.tween.kill();
		}

		public function dispose():void
		{
			if (this.tween)
				this.tween.kill();

			this.tween = null;
		}

		private function init():void
		{
			this.addChild(this.background);

			this.progressFrame.x = int(GameMap.gameScreenWidth / 2);
			this.progressFrame.y = int(GameMap.gameScreenHeight / 2) + 25;

			this.progress = new RoundProgress();
			this.progress.x = -179;
			this.progress.y = -19;
			this.background.x = int(GameMap.gameScreenWidth / 2);
			this.background.y = int(GameMap.gameScreenHeight / 2);
			_widthProgress = this.progress.width;
			this.progress.width = 0;
			this.progress.height = 34;
			_needWidth = 0;

			addChild(this.progressFrame);
			this.progressFrame.addChild(this.progress);

			this.fieldDelay = new GameField("  ", 0, 0, new TextFormat(GameField.PLAKAT_FONT, 34, 0xFFFFFF));
			this.fieldDelay.antiAliasType = AntiAliasType.NORMAL;
			this.fieldDelay.x = -this.fieldDelay.width / 2;
			this.fieldDelay.y = -this.fieldDelay.height / 2;
			this.progressFrame.addChild(this.fieldDelay);

			this.fieldCaption = new GameField(gls("Игра сейчас начнется"), 0, 0, new TextFormat(GameField.PLAKAT_FONT, 32, 0xffffff));
			this.fieldCaption.antiAliasType = AntiAliasType.NORMAL;
			this.fieldCaption.x = -this.fieldCaption.width / 2;
			this.fieldCaption.y = -290;
			this.fieldCaption.filters = [new DropShadowFilter(0, 0, 0, 0.9, 4, 4, 2, 2)];
			this.progressFrame.addChild(this.fieldCaption);

			this.fieldModeCaption = new GameField("", 0, 0, new TextFormat(GameField.PLAKAT_FONT, 20, 0xFFE52D));
			this.fieldModeCaption.antiAliasType = AntiAliasType.NORMAL;

			this.progressFrame.addChild(this.fieldModeCaption);

			this.fieldModeText = new GameField("", 0, 0, new TextFormat(null, 16, 0xFFFFFF, true, null, null, null, null, "center"));
			this.fieldModeText.antiAliasType = AntiAliasType.NORMAL;
			this.progressFrame.addChild(this.fieldModeText);

			this.timer = new Timer(100);
			this.timer.addEventListener(TimerEvent.TIMER, onTick);
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoom.PACKET_ID:
					this.locationId = (packet as PacketRoom).locationId;
					break;
				case PacketRoomRound.PACKET_ID:
					var mode: int = (packet as PacketRoomRound).mode;
					if (mode > -1)
						this.mode = Locations.getGameMode(mode);

					if (Locations.getLocation(this.locationId).teamMode)
					{
						this.fieldModeCaption.text = gls("Битва");
						this.fieldModeText.text = gls("Убивай вражеских белок ядрами!\nНе дай себя убить!");
					}
					else
					{
						this.fieldModeCaption.text = Locations.MODES[this.mode]['caption'];
						this.fieldModeText.text = Locations.MODES[this.mode]['text'];
					}

					this.fieldModeCaption.x = -this.fieldModeCaption.width / 2;
					this.fieldModeCaption.y = -221;

					this.fieldModeText.x = -this.fieldModeText.width / 2;
					this.fieldModeText.y = -190;
					break;
			}
		}

		private function onTick(e:TimerEvent = null):void
		{
			var valuePercent:Number = this.timer.currentCount / this.timer.repeatCount;
			this.fieldDelay.text = String(int(valuePercent * 100)) + "%";
			this.fieldDelay.x = -this.fieldDelay.width / 2 + 5;
			this.fieldDelay.y = -23;
			_needWidth = _widthProgress * valuePercent * 0.883;
			tweenDigit();
		}

		private function tweenDigit():void
		{
			if (this.tween)
				this.tween.kill();

			this.tween = TweenLite.to(this.progress, 1, {'width': _needWidth , 'onComplete': onComplete1});
		}

		private function onComplete1():void
		{
			this.tween.kill();
		}
	}
}