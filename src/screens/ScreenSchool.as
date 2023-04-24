package screens
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import events.ShamanEvent;
	import footers.FooterGame;
	import game.gameData.FlagsManager;
	import game.mainGame.events.CastEvent;
	import game.mainGame.gameSchool.SquirrelGameSchool;
	import game.mainGame.gameSchool.SquirrelGameSchoolBattle;
	import game.mainGame.perks.mana.PerkDoubleJump;
	import game.mainGame.perks.mana.PerkHeadWalker;
	import game.mainGame.perks.mana.PerkHighFriction;
	import game.mainGame.perks.mana.PerkHighJump;
	import game.mainGame.perks.mana.PerkHighSpeed;
	import game.mainGame.perks.mana.PerkInvisible;
	import game.mainGame.perks.mana.PerkReborn;
	import game.mainGame.perks.mana.PerkSlowFall;
	import game.mainGame.perks.mana.PerkSmallSize;
	import game.mainGame.perks.mana.PerkTeleport;
	import game.mainGame.perks.mana.ui.PerksToolBar;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketMapsMap;

	import utils.GuardUtil;
	import utils.StringUtil;

	public class ScreenSchool extends Screen
	{
		static private const START_DELAY:int = 1;

		static private const PERK_INVISIBLE_MAP:int = 244128;
		static private const PERK_HIGH_SPEED_MAP:int = 244134;
		static private const PERK_HIGH_FRICTION_MAP:int = 244431;
		static private const PERK_SMALL_SIZE_MAP:int = 244609;
		static private const PERK_HEAD_WALKER_MAP:int = 244454;
		static private const PERK_HIGH_JUMP_MAP:int = 244142;
		static private const PERK_SLOW_FALL_MAP:int = 244402;
		static private const PERK_DOUBLE_JUMP_MAP:int = 244212;
		static private const PERK_TELEPORT_MAP:int = 400084;
		static private const PERK_REBORN_MAP:int = 244509;

		static public const MAGIC:int = 0;
		static public const SHAMAN:int = 1;
		static public const BATTLE:int = 2;

		static private var _instance:ScreenSchool;

		static public var type:int = 0;

		static public var allowedPerks:Object = {};

		private var squirrelGame:SquirrelGameSchool;
		private var mapsData:Object = {};
		private var requestedId:int = -1;
		private var playingId:int = -1;
		private var mapsCount:int = 0;
		private var delayField:GameField = null;
		private var delayTimer:Timer = new Timer(1000);

		public function ScreenSchool():void
		{
			_instance = this;

			init();
		}

		static public function newGame():void
		{
			var timer:Timer = new Timer(1, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteTimerInNewGame);
			timer.reset();
			timer.start();
			FooterGame.gameState = PacketServer.ROUND_STARTING;
			allowedPerks = {};
		}

		static public function restart():void
		{
			var timer:Timer = new Timer(1, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteTimerInRestart);
			timer.reset();
			timer.start();
			FooterGame.gameState = PacketServer.ROUND_STARTING;
			allowedPerks = {};
		}

		private static function onCompleteTimerInNewGame(e:Event):void
		{
			if (_instance)
				_instance.newGame();
		}

		private static function onCompleteTimerInRestart(e:Event):void
		{
			if (_instance)
				_instance.restart();
		}

		static public function onPerksShown(shown:Boolean):void
		{
			_instance.onPerksShown(shown);
		}

		static private function get maps():Array
		{
			switch (type)
			{
				case MAGIC:
					return [PERK_INVISIBLE_MAP, PERK_HIGH_SPEED_MAP, PERK_HIGH_FRICTION_MAP, PERK_SMALL_SIZE_MAP, PERK_HEAD_WALKER_MAP, PERK_HIGH_JUMP_MAP, PERK_SLOW_FALL_MAP, PERK_DOUBLE_JUMP_MAP, PERK_TELEPORT_MAP, PERK_REBORN_MAP];
				case SHAMAN:
					return [28419, 32045, 288119, 10771, 28279, 28426, 31615, 28455, 29040, 288253, 288191, 360235, 382138, 383967, 384030, 1158183, 1286170];
				case BATTLE:
					return [1503586, 1503587, 1503588, 1503589, 1503590, 1503591];
			}
			return [];
		}

		static private function get currentStep():int
		{
			switch (type)
			{
				case MAGIC:
					return FlagsManager.find(Flag.MAGIC_SCHOOL_STEP).value;
				case SHAMAN:
					return FlagsManager.find(Flag.SHAMAN_SCHOOL_STEP).value;
				case BATTLE:
					return FlagsManager.find(Flag.BATTLE_SCHOOL_STEP).value;
			}
			return 0;
		}

		static private function set currentStep(value:int):void
		{
			switch (type)
			{
				case MAGIC:
					FlagsManager.find(Flag.MAGIC_SCHOOL_STEP).setValue(value);
					break;
				case SHAMAN:
					FlagsManager.find(Flag.SHAMAN_SCHOOL_STEP).setValue(value);
					break;
				case BATTLE:
					FlagsManager.find(Flag.BATTLE_SCHOOL_STEP).setValue(value);
					break;
			}
		}

		static private function get finished():Boolean
		{
			switch (type)
			{
				case MAGIC:
					return FlagsManager.find(Flag.MAGIC_SCHOOL_FINISH).value != 0;
				case SHAMAN:
					return FlagsManager.find(Flag.SHAMAN_SCHOOL_FINISH).value != 0;
				case BATTLE:
					return FlagsManager.find(Flag.BATTLE_SCHOOL_FINISH).value != 0;
			}
			return false;
		}

		static private function set finished(value:Boolean):void
		{
			switch (type)
			{
				case MAGIC:
					FlagsManager.find(Flag.MAGIC_SCHOOL_FINISH).setValue(value ? 1 : 0);
					break;
				case SHAMAN:
					FlagsManager.find(Flag.SHAMAN_SCHOOL_FINISH).setValue(value ? 1 : 0);
					break;
				case BATTLE:
					FlagsManager.find(Flag.BATTLE_SCHOOL_FINISH).setValue(value ? 1 : 0);
					break;
			}
		}

		override public function show():void
		{
			super.show();

			GuardUtil.startRecheck();

			this.mapsCount = currentStep;

			this.squirrelGame = type == BATTLE ? new SquirrelGameSchoolBattle() : new SquirrelGameSchool();
			this.addChild(this.squirrelGame);

			ScreenStarling.upLayer.addChild(this.squirrelGame.getStarlingView());
			FooterGame.hero = null;
			FooterGame.listenShaman(onShaman);

			Connection.listen(onPacket, PacketMapsMap.PACKET_ID);
			newGame();
		}

		override public function hide():void
		{
			super.hide();
			if (this.squirrelGame != null)
			{
				//ScreenStarling.upLayer.removeChild(this.squirrelGame.getStarlingView());
				if (contains(this.squirrelGame))
					removeChild(this.squirrelGame);

				this.squirrelGame.dispose();
				this.squirrelGame = null;
			}

			FooterGame.hero = null;
			FooterGame.removeListenerShaman(onShaman);

			Connection.forget(onPacket, PacketMapsMap.PACKET_ID);

			GuardUtil.stopRecheck();
			BitmapPhotoCollector.clearBitmapData(true);
		}

		private function init():void
		{
			this.delayField = new GameField("", 0, 240, new TextFormat(null, 60, 0xFFF52C, true));
			this.delayField.filters = [new DropShadowFilter(0, 45, 0x003584, 1, 4, 4, 5, 1)];
			this.delayField.width = Config.GAME_WIDTH;
			this.delayField.autoSize = TextFieldAutoSize.CENTER;
			addChild(this.delayField);

			this.delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteDelay);
		}

		private function onCompleteDelay(e:TimerEvent):void
		{
			this.delayField.text = "";

			if (this.squirrelGame == null)
				return;

			this.squirrelGame.start();
		}

		private function updateDelayField():void
		{
			this.delayField.text = gls("Урок {0}", this.mapsCount);
		}

		private function newGame():void
		{
			var mapsIds:Array = maps;

			currentStep = this.mapsCount;
			this.mapsCount++;

			if ((mapsIds.length < this.mapsCount) && !finished)
			{
				Screens.show("Location");

				finished = true;
				ScreenLocation.sortMenu();

				type = -1;
				return;
			}

			if (this.mapsCount > mapsIds.length)
				mapsCount = 1;

			var mapId:int = mapsIds[this.mapsCount - 1];

			if (mapId in mapsData)
			{
				setMap(mapId, mapsData[mapId]);
				return;
			}

			this.requestedId = mapId;
			Connection.sendData(PacketClient.MAPS_GET, mapId);
		}

		private function onShaman(e:ShamanEvent):void
		{
			if (this.squirrelGame == null)
				return;

			this.squirrelGame.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, e.className));
		}

		private function onPacket(packet:PacketMapsMap):void
		{
			if (this.requestedId != packet.id)
				return;

			if (!GuardUtil.timer.running)
				Connection.sendData(PacketClient.PING, 1);

			setMap(requestedId, StringUtil.ByteArrayToMap(packet.data));

			this.requestedId = -1;
		}

		private function setMap(id:int, data:String):void
		{
			if (!this.squirrelGame)
				return;

			if (this.squirrelGame.squirrels)
				this.squirrelGame.squirrels.clear();
			this.squirrelGame.clearHintArrows();

			this.playingId = id;
			mapsData[id] = data;
			this.squirrelGame.map.deserialize(data);

			startDelayTimer();
		}

		private function startDelayTimer():void
		{
			addChild(this.delayField);

			this.delayTimer.reset();
			this.delayTimer.repeatCount = START_DELAY;

			this.delayTimer.start();

			updateDelayField();
		}

		private function restart():void
		{
			setMap(this.playingId, mapsData[this.playingId]);
		}

		private function onPerksShown(shown:Boolean):void
		{
			if (!this.squirrelGame)
				return;

			if (!shown)
			{
				PerksToolBar.instance().hideArrow();
				return;
			}
			this.squirrelGame.removeHintArrow("magicArrow");

			switch (this.playingId)
			{
				case PERK_INVISIBLE_MAP:
					PerksToolBar.instance().showArrow(PerkInvisible);
					break;
				case PERK_HIGH_SPEED_MAP:
					PerksToolBar.instance().showArrow(PerkHighSpeed);
					break;
				case PERK_HIGH_FRICTION_MAP:
					PerksToolBar.instance().showArrow(PerkHighFriction);
					break;
				case PERK_SMALL_SIZE_MAP:
					PerksToolBar.instance().showArrow(PerkSmallSize);
					break;
				case PERK_HEAD_WALKER_MAP:
					PerksToolBar.instance().showArrow(PerkHeadWalker);
					break;
				case PERK_HIGH_JUMP_MAP:
					PerksToolBar.instance().showArrow(PerkHighJump);
					break;
				case PERK_SLOW_FALL_MAP:
					PerksToolBar.instance().showArrow(PerkSlowFall);
					break;
				case PERK_DOUBLE_JUMP_MAP:
					PerksToolBar.instance().showArrow(PerkDoubleJump);
					break;
				case PERK_TELEPORT_MAP:
					PerksToolBar.instance().showArrow(PerkTeleport);
					break;
				case PERK_REBORN_MAP:
					PerksToolBar.instance().showArrow(PerkReborn);
					break;
				default:
					return;
			}
		}
	}
}