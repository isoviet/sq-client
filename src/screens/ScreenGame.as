package screens
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import chat.ChatDead;
	import chat.ChatDeadServiceMessage;
	import dialogs.DialogBattleWinners;
	import dialogs.DialogDepletionEnergy;
	import dialogs.DialogRoundTime;
	import dialogs.DialogVIPGame;
	import events.GameEvent;
	import events.ShamanEvent;
	import footers.FooterGame;
	import game.gameData.EducationQuestManager;
	import game.gameData.FlagsManager;
	import game.gameData.PowerManager;
	import game.gameData.RatingManager;
	import game.mainGame.ActiveBodiesCollector;
	import game.mainGame.IScore;
	import game.mainGame.ITeams;
	import game.mainGame.ReportView;
	import game.mainGame.SquirrelGame;
	import game.mainGame.events.CastEvent;
	import game.mainGame.gameBattleNet.SquirrelGameBattleNet;
	import game.mainGame.gameDesertNet.SquirrelGameDesertNet;
	import game.mainGame.gameEvent.SquirrelGameVolcanoNet;
	import game.mainGame.gameEvent.SquirrelGameZombieNet;
	import game.mainGame.gameIceland.SquirrelGameIcelandNet;
	import game.mainGame.gameNet.SquirrelCollectionNet;
	import game.mainGame.gameNet.SquirrelGameNet;
	import game.mainGame.gameRopedNet.SquirrelGameRopedNet;
	import game.mainGame.gameSurvivalNet.SquirrelGameSurvivalNet;
	import game.mainGame.gameTwoShamansNet.SquirrelGameTwoShamansNet;
	import headers.HeaderShort;
	import sounds.GameSounds;
	import tape.list.ListElement;
	import tape.list.ListFragsElement;
	import views.GameEventListView;
	import views.LoadGameAnimation;
	import views.RoundStartingView;

	import protocol.Connection;
	import protocol.Flag;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketChatMessage;
	import protocol.packages.server.PacketPlayWith;
	import protocol.packages.server.PacketRoom;
	import protocol.packages.server.PacketRoomJoin;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundElement;
	import protocol.packages.server.PacketRoundHollow;

	import utils.GuardUtil;
	import utils.starling.StarlingAdapterSprite;
	import utils.starling.TextureEx;
	import utils.starling.collections.DisplayObjectManager;

	public class ScreenGame extends Screen
	{
		static private const BATTLE_STARTING_DELAY:int = 15;

		static private var _instance:ScreenGame = null;

		static private var mapIds:Array = [];

		static public var location:int;
		static public var mode:int = 0;
		static public var subLocation:int = 0;

		private var waitField:GameField = null;
		private var gameTimer:Timer = new Timer(1000);

		private var reportView:ReportView;

		private var playingSprite:Sprite = new Sprite();
		private var waitingSprite:Sprite = new Sprite();
		private var roomSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

		private var showDialogResult:Boolean = false;

		private var dialogWinners:DialogBattleWinners = null;

		private var squirrelGame:SquirrelGameNet = null;

		private var isPlaying:Boolean = false;
		private var isChangingRoom:Boolean = false;
		private var waitingField:GameField = null;

		private var _squirrelsCount:int;
		private var onLeaveBlocking:Boolean = false;

		private var gamePlayed:Boolean = false;

		private var myFriends:Array = [];

		private var mapId:int = 0;

		private var state:int = -1;

		private var showWinnersAfterLeave:Boolean = false;

		private var playersIds:Vector.<int> = new Vector.<int>();

		private var inited:Boolean = false;

		private var cheaterId:int = 0;

		private var leaveOnResult:Boolean = false;

		public function ScreenGame():void
		{
			_instance = this;

			super();
		}

		static public function resetReportCount():void
		{
			if (!_instance)
				return;
			_instance.reportView.reportCount = 0;
		}

		static public function squirrelShaman(id:int):Boolean
		{
			if (_instance.squirrelGame == null)
				return false;
			var hero:Hero = _instance.squirrelGame.squirrels.get(id);
			return (hero && hero.shaman && !hero.isDead);
		}

		static public function squirrelHare(id:int):Boolean
		{
			if (_instance.squirrelGame == null)
				return false;
			var hero:Hero = _instance.squirrelGame.squirrels.get(id);
			return (hero && hero.isHare);
		}

		static public function squirrelExist(id:int):Boolean
		{
			if (_instance.squirrelGame == null)
				return false;
			var hero:Hero = _instance.squirrelGame.squirrels.get(id);
			return (hero != null);
		}

		static public function squirrelTeam(id:int):int
		{
			if (_instance && _instance.squirrelGame && _instance.squirrelGame.squirrels && _instance.squirrelGame.squirrels.get(id))
				return _instance.squirrelGame.squirrels.get(id).team;
			return 0;
		}

		static public function get roundTime():int
		{
			return (_instance.state == PacketServer.ROUND_PLAYING || _instance.state == PacketServer.ROUND_START) && _instance.gameTimer.running ? _instance.gameTimer.currentCount : -1;
		}

		static public function get cheaterId():int
		{
			return _instance.cheaterId;
		}

		static public function start(id:int, playWith:Boolean = false, isSpy:Boolean = false, subLocationId:int = 0):void
		{
			if (!_instance.inited)
				_instance.init();

			subLocation = 0;
			mode = 0;

			_instance.leaveOnResult = false;
			_instance.cheaterId = 0;

			if (!_instance.isChangingRoom)
			{
				FlagsManager.find(Flag.NOT_BE_SHAMAN).setValue(int(Game.notBecomeShaman));
				DailyQuestManager.currentQuest = -1;
			}

			if (isSpy)
			{
				_instance.cheaterId = id;
				Connection.sendData(PacketClient.SPY_FOR, id);
				_instance.isPlaying = false;
				return;
			}

			if (!playWith && !PowerManager.isEnoughEnergy(id))
			{
				if (_instance.isChangingRoom)
				{
					Screens.show(Screens.screenToComeback);
					_instance.isChangingRoom = false;
				}

				DialogDepletionEnergy.show(id);

				_instance.isPlaying = false;
				return;
			}

			if (playWith)
			{
				Connection.sendData(PacketClient.PLAY_WITH, id);
				return;
			}

			Connection.sendData(PacketClient.PLAY, id, subLocation);

			location = id;
			subLocation = subLocationId;
		}

		static public function startPrivateRoom(roomId:int, locationId:int):void
		{
			if (!_instance.inited)
				_instance.init();

			mode = 0;
			_instance.cheaterId = 0;

			if (!PowerManager.isEnoughEnergy(locationId))
			{
				DialogDepletionEnergy.show(locationId);
				return;
			}

			FlagsManager.find(Flag.NOT_BE_SHAMAN).setValue(int(Game.notBecomeShaman));
			DailyQuestManager.currentQuest = -1;
			Connection.sendData(PacketClient.PLAY_ROOM, roomId);

			location = locationId;
		}

		static public function refuse():void
		{
			Connection.sendData(PacketClient.PLAY_CANCEL);

			_instance.isPlaying = false;
		}

		static public function toggleResults():void
		{
			if (_instance.squirrelGame)
				_instance.squirrelGame.toggleResultVisible();
		}

		static public function sendMessage(playerId:int, text:String, type:int = 0):void
		{
			ChatDead.instance.sendMessage(playerId, text, type);
		}

		static public function stopChangeRoom():void
		{
			_instance.isChangingRoom = false;
		}

		static public function changeRoom():void
		{
			if (_instance.isChangingRoom)
				return;
			_instance.isChangingRoom = true;

			Connection.sendData(PacketClient.LEAVE);
		}

		override public function show():void
		{
			super.show();

			LoadGameAnimation.instance.open();

			Logger.add("this.squirrelGame - show", location);
			switch (location)
			{
				case Locations.BATTLE_ID:
					this.dialogWinners = new DialogBattleWinners();
					this.showDialogResult = false;
					this.squirrelGame = new SquirrelGameBattleNet();
					break;
				case Locations.DESERT_ID:
					this.squirrelGame = new SquirrelGameDesertNet();
					break;
				case Locations.WILD_ID:
					switch (mode)
					{
						case Locations.ZOMBIE_MODE:
							this.squirrelGame = new SquirrelGameZombieNet();
							break;
						case Locations.VOLCANO_MODE:
							this.squirrelGame = new SquirrelGameVolcanoNet();
							break;
						default:
							this.squirrelGame = new SquirrelGameNet();
							break;
					}
					break;
				default:
					this.squirrelGame = new SquirrelGameNet();
					break;
			}
			setTimeScale();

			this.roomSprite.addChildStarling(this.squirrelGame);
			this.roomSprite.addChild(this.squirrelGame);

			FooterGame.listenShaman(onShaman);
			GuardUtil.checkId();
		}

		override public function hide():void
		{
			super.hide();

			clear();

			RoundStartingView.instance.dispose();

			this.state = -1;

			this.myFriends = [];

			GameSounds.stopAll();

			ChatDead.instance.clearMessages();

			if (this.squirrelGame != null)
			{
				if (this.roomSprite.containsStarling(this.squirrelGame))
					this.roomSprite.removeChildStarling(this.squirrelGame);
				this.squirrelGame.dispose();
				this.squirrelGame = null;
				AnimationDataCollector.clearBitmapData(true);
				BitmapPhotoCollector.clearBitmapData(true);
				ActiveBodiesCollector.clear();
			}

			Experience.showDialogs();
			ShamanExperience.showDialogs();
			FooterGame.removeListenerShaman(onShaman);

			if (PowerManager.isEnoughEnergy(location))
			{
				if (this.dialogWinners != null)
				{
					this.dialogWinners.close();
					this.dialogWinners = null;
				}
				return;
			}

			if (this.showWinnersAfterLeave)
				this.dialogWinners.show();

			this.dialogWinners = null;

			DialogDepletionEnergy.show(location);
		}

		private function init():void
		{
			this.inited = true;

			this.reportView = new ReportView();

			this.gameTimer.addEventListener(TimerEvent.TIMER, onTickGame);
			this.gameTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompleteGame);

			this.roomSprite.graphics.beginFill(0x1f1717, 0);
			this.roomSprite.graphics.drawRect(0, 0, Config.GAME_WIDTH, Game.ROOM_HEIGHT);
			this.roomSprite.graphics.endFill();
			ScreenStarling.upLayer.addChild(this.roomSprite.getStarlingView());

			addChild(this.roomSprite);

			addChild(new RoundStartingView);
			addChild(new GameEventListView);

			var image:DialogBaseBackground = new DialogBaseBackground();
			image.scaleX = 0.7;
			image.scaleY = 0.5;
			image.alpha = 0.5;
			this.playingSprite.addChild(image);
			this.playingSprite.visible = false;

			image = new DialogBaseBackground();
			image.scaleX = 0.7;
			image.scaleY = 0.5;
			image.alpha = 0.5;
			this.waitingSprite.addChild(image);
			this.waitingSprite.visible = false;

			var newRoundField:GameField = new GameField(gls("Через             начнется новый раунд и ты присоединишься к другим белкам"), 0, 0, new TextFormat(null, 16, 0x432104, null, null, null, null, null, "center"));
			newRoundField.width = 210;
			newRoundField.multiline = true;
			newRoundField.wordWrap = true;
			newRoundField.x = int((this.playingSprite.width - newRoundField.width) / 2);
			newRoundField.y = int((this.playingSprite.height - newRoundField.height) / 2);
			this.playingSprite.addChild(newRoundField);

			this.waitingField = new GameField(gls("Сейчас на Солнечной Долине ты один. Подожди прихода других белок."), 0, 0, new TextFormat(null, 16, 0x432104, null, null, null, null, null, "center"));
			this.waitingField.width = 210;
			this.waitingField.multiline = true;
			this.waitingField.wordWrap = true;
			this.waitingField.autoSize = TextFieldAutoSize.CENTER;
			this.waitingField.x = int((this.waitingSprite.width - this.waitingField.width) / 2);
			this.waitingField.y = int((this.waitingSprite.height - this.waitingField.height) / 2);
			this.waitingSprite.addChild(this.waitingField);

			this.waitField = new GameField("", newRoundField.x + 76, newRoundField.y, new TextFormat(null, 16, 0x1B7E06, true));
			this.playingSprite.addChild(this.waitField);

			this.playingSprite.x = 10;
			this.playingSprite.y = 50;
			addChild(this.playingSprite);

			this.waitingSprite.x = Game.starling.stage.stageWidth - this.waitingSprite.width;
			this.waitingSprite.y = 50;
			addChild(this.waitingSprite);

			addChild(new ChatDead);

			RatingManager.addEventListener(GameEvent.SEASON_CHANGED, onSeason);
			Connection.listen(onPacket, [PacketRoom.PACKET_ID, PacketRoomLeave.PACKET_ID, PacketRoomRound.PACKET_ID,
				PacketRoomJoin.PACKET_ID, PacketRoundHollow.PACKET_ID, PacketRoundDie.PACKET_ID,
				PacketChatMessage.PACKET_ID, PacketPlayWith.PACKET_ID,
				PacketRoundElement.PACKET_ID]);
			FullScreenManager.instance().addEventListener(FullScreenManager.CHANGE_FULLSCREEN, onChangeScreenSize);

			TextureEx.dispatcher.addEventListener(TextureEx.TEXTURE_ERROR, onErrorConvert);
		}

		private function onErrorConvert(e:Event):void
		{
			this.onLeaveBlocking = true;
			Connection.sendData(PacketClient.LEAVE);
		}

		private function onChangeScreenSize(e: Event): void
		{
			this.waitingSprite.x = Game.starling.stage.stageWidth - this.waitingSprite.width;
		}

		private function setTime(delay:int):void
		{
			if (this.gameTimer.running && Hero.selfAlive)
			{
				DialogRoundTime.instance.timeLeft = delay;
				DialogRoundTime.instance.show();
			}

			this.gameTimer.stop();
			this.gameTimer.repeatCount = delay;
			this.gameTimer.reset();
			this.gameTimer.start();
		}

		private function hollow(playerId:int):void
		{
			if (playerId != Game.selfId)
				return;

			GameEventListView.show();

			if (location != Locations.SWAMP_ID)
				return;
			if (!EducationQuestManager.done(EducationQuestManager.SWAMP))
				return;
			Connection.sendData(PacketClient.LEAVE);
			ScreenGame.stopChangeRoom();
		}

		private function onShaman(e:ShamanEvent):void
		{
			if (this.squirrelGame == null)
				return;

			this.squirrelGame.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, e.className));
		}

		private function showDialogWinners():void
		{
			var results:Array = (this.squirrelGame as IScore).getScore();

			var redTeam:Vector.<Hero> = new Vector.<Hero>;
			var blueTeam:Vector.<Hero> = new Vector.<Hero>;

			var redTeamIds:Vector.<int> = (this.squirrelGame.squirrels as ITeams).redTeamIds;
			var blueTeamIds:Vector.<int> = (this.squirrelGame.squirrels as ITeams).blueTeamIds;

			for (var i:int = 0; i < redTeamIds.length; i++)
			{
				if (!this.squirrelGame.squirrels.get(redTeamIds[i]))
					continue;
				redTeam.push(this.squirrelGame.squirrels.get(redTeamIds[i]));
			}

			for (i = 0; i < blueTeamIds.length; i++)
			{
				if (!this.squirrelGame.squirrels.get(blueTeamIds[i]))
					continue;
				blueTeam.push(this.squirrelGame.squirrels.get(blueTeamIds[i]));
			}

			var redFragsData:Vector.<ListElement> = new Vector.<ListElement>;
			for each(var hero:Hero in redTeam)
				redFragsData.push(new ListFragsElement(hero.player, hero.frags, Hero.TEAM_RED));

			var blueFragsData:Vector.<ListElement> = new Vector.<ListElement>;
			for each(hero in blueTeam)
				blueFragsData.push(new ListFragsElement(hero.player, hero.frags, Hero.TEAM_BLUE));

			if (ScreenGame.cheaterId != 0)
				return;

			this.dialogWinners.setFrags(redFragsData, blueFragsData);
			this.dialogWinners.setScore(results, Hero.self.team);
			this.dialogWinners.show();
		}

		private function initRoom(packet: PacketRoom):void
		{
			if (_instance.isPlaying)
				return;
			_instance.isPlaying = true;

			if (this.isChangingRoom)
			{
				this.isChangingRoom = false;
				Screens.reshow(this);
				Connection.sendData(PacketClient.COUNT, PacketClient.CHANGE_ROOM);
			}

			location = packet.locationId;
			subLocation = packet.subLocation;
			this.playersIds = packet.players;

			Screens.show(this);

			HeaderShort.setGameLocation(location);

			if (this.squirrelGame.squirrels is SquirrelCollectionNet)
				(this.squirrelGame.squirrels as SquirrelCollectionNet).locationId = location;

			//this.squirrelGame.squirrels.removeEventListener(SquirrelGameEvent.UPDATE_BONUS, updateBonus);

			initSquirrels();
		}

		private function initSquirrelGame():void
		{
			var experienceBonus:int = 0;
			var shamanExpBonus:int = 0;
			var manaBonus:int = 0;
			var acornsBonus:int = 0;

			if (this.squirrelGame != null)
			{
				if (this.squirrelGame.squirrels is SquirrelCollectionNet)
				{
					experienceBonus = (this.squirrelGame.squirrels as SquirrelCollectionNet).experienceBonus;
					shamanExpBonus = (this.squirrelGame.squirrels as SquirrelCollectionNet).shamanExpBonus;
					manaBonus = (this.squirrelGame.squirrels as SquirrelCollectionNet).manaBonus;
					acornsBonus = (this.squirrelGame.squirrels as SquirrelCollectionNet).nutsBonus;
				}

				if (this.roomSprite.containsStarling(this.squirrelGame))
					this.roomSprite.removeChildStarling(this.squirrelGame);
				this.squirrelGame.dispose();
				this.squirrelGame = null;
			}

			Logger.add("this.squirrelGame - initSquirrelGame", location);

			if (mode == Locations.SNOWMAN_MODE)
				this.squirrelGame = new SquirrelGameIcelandNet();

			else switch (location)
			{
				case Locations.BATTLE_ID:
					this.squirrelGame = new SquirrelGameBattleNet();
					break;
				case Locations.DESERT_ID:
					this.squirrelGame = new SquirrelGameDesertNet(mode == Locations.ROPED_MODE);
					break;
				case Locations.WILD_ID:
					switch (mode)
					{
						case Locations.ZOMBIE_MODE:
							this.squirrelGame = new SquirrelGameZombieNet();
							break;
						case Locations.VOLCANO_MODE:
							this.squirrelGame = new SquirrelGameVolcanoNet();
							break;
						default:
							this.squirrelGame = new SquirrelGameNet();
							break;
					}
					break;
				default:
					switch (mode)
					{
						case Locations.ROPED_MODE:
							this.squirrelGame = new SquirrelGameRopedNet();
							break;
						case Locations.SNAKE_MODE:
							this.squirrelGame = new SquirrelGameRopedNet(true);
							break;
						case Locations.TWO_SHAMANS_MODE:
							this.squirrelGame = new SquirrelGameTwoShamansNet();
							break;
						case Locations.BLACK_SHAMAN_MODE:
							this.squirrelGame = new SquirrelGameSurvivalNet();
							break;
						default:
							this.squirrelGame = new SquirrelGameNet();
							break;
					}
					break;
			}
			setTimeScale();

			this.roomSprite.addChild(this.squirrelGame);
			this.roomSprite.addChildStarling(this.squirrelGame);

			if (this.squirrelGame.squirrels is SquirrelCollectionNet)
			{
				(this.squirrelGame.squirrels as SquirrelCollectionNet).locationId = location;
				(this.squirrelGame.squirrels as SquirrelCollectionNet).experienceBonus = experienceBonus;
				(this.squirrelGame.squirrels as SquirrelCollectionNet).shamanExpBonus = shamanExpBonus;
				(this.squirrelGame.squirrels as SquirrelCollectionNet).manaBonus = manaBonus;
				(this.squirrelGame.squirrels as SquirrelCollectionNet).nutsBonus = acornsBonus;
			}

			//this.squirrelGame.squirrels.addEventListener(SquirrelGameEvent.UPDATE_BONUS, updateBonus);

			initSquirrels();
		}

		private function setTimeScale():void
		{
			switch (location)
			{
				case Locations.ISLAND_ID:
				case Locations.SANDBOX_ID:
				case Locations.MOUNTAIN_ID:
				case Locations.SWAMP_ID:
				case Locations.BATTLE_ID:
					this.squirrelGame.timescale = SquirrelGame.TIMESCALE_NEWBIE;
					break;
			}
		}

		private function initSquirrels():void
		{
			if (ScreenGame.cheaterId != 0)
			{
				if (this.squirrelGame.squirrels is SquirrelCollectionNet)
					(this.squirrelGame.squirrels as SquirrelCollectionNet).set(this.playersIds.slice());
				else
					this.squirrelGame.squirrels.set(this.playersIds);

				this.squirrelGame.squirrels.hide();
				this.squirrelsCount = this.playersIds.length;
				return;
			}

			if (this.squirrelGame.squirrels is SquirrelCollectionNet)
			{
				this.playersIds.push(Game.selfId);
				(this.squirrelGame.squirrels as SquirrelCollectionNet).set(this.playersIds);
			}
			else
			{
				this.squirrelGame.squirrels.set(this.playersIds);
				this.squirrelGame.squirrels.add(Game.selfId);
			}
			this.squirrelGame.squirrels.hide();
			this.squirrelsCount = this.playersIds.length + 1;
		}

		private function round(packet: PacketRoomRound):void
		{
			if (!this.squirrelGame)
			{
				this.onLeaveBlocking = true;
				Connection.sendData(PacketClient.LEAVE);
				return;
			}
			this.state = packet.type;

			if (this.state == PacketServer.ROUND_RESULTS && this.leaveOnResult)
			{
				Connection.sendData(PacketClient.LEAVE);
				return;
			}

			if (this.state != PacketServer.ROUND_CUT && this.gamePlayed)
				FPSCounter.sendStat(this.mapId);

			if (this.state == PacketServer.ROUND_START)
			{
				if (mapIds.indexOf(this.mapId) == -1)
					mapIds.push(this.mapId);
				else
					Connection.sendData(PacketClient.COUNT, PacketClient.MAP_DUPLICATE, location);
			}

			this.mapId = (packet.mapId > 0 ? packet.mapId : this.mapId);
			var modeIdNew:int = Locations.getGameMode((packet.mode > 0 ?  packet.mode : mode));

			if (mode != modeIdNew)
			{
				mode = modeIdNew;
				initSquirrelGame();
			}

			this.gameTimer.stop();

			this.squirrelGame.round(packet);

			HeaderShort.setMap(this.mapId);
			if (this.state == PacketServer.ROUND_CUT)
			{
				setTime(packet.delay);
				return;
			}

			DialogRoundTime.instance.hide();

			this.playingSprite.visible = false;

			HeaderShort.clear();

			setFocus();

			waitingStatus(this.state == PacketServer.ROUND_WAITING);
			ChatDead.instance.visible = this.state != PacketServer.ROUND_STARTING && this.state != PacketServer.ROUND_WAITING;

			switch (this.state)
			{
				case PacketServer.ROUND_WAITING:

					if (this.dialogWinners)
					{
						if (!this.dialogWinners.visible && this.showDialogResult)
							showDialogWinners();

						this.showDialogResult = false;
					}
					startDelayTimer(packet.delay);
					break;
				case PacketServer.ROUND_STARTING:

					if (Logger.traceTextureEnabled)
						DisplayObjectManager.getInstance().length;

					if (Locations.getLocation(location).teamMode && (packet.delay == BATTLE_STARTING_DELAY) && this.showDialogResult && (ScreenGame.cheaterId == 0))
						showDialogWinners();

					startDelayTimer(packet.delay);

					DialogVIPGame.show();
					break;
				case PacketServer.ROUND_PLAYING:
					this.playingSprite.visible = true;

					startPlay(packet.delay);
					showPlayingFriends(this.squirrelGame.squirrels.getIds());
					this.showDialogResult = true;

					if (Locations.getLocation(location).teamMode)
					{

						HeaderShort.setTeams((this.squirrelGame.squirrels as ITeams).redTeamIds, (this.squirrelGame.squirrels as ITeams).blueTeamIds);
						//TODO remove
						this.dialogWinners.setPrize(30, 5);
						break;
					}

					HeaderShort.setSquirrels(this.squirrelGame.squirrels.getIds());
					break;
				case PacketServer.ROUND_START:
					GuardUtil.startRound();
					FPSCounter.startStat();

					AnimationDataCollector.clearBitmapData();
					BitmapPhotoCollector.clearBitmapData();
					GameEventListView.hide();

					this.showDialogResult = true;
					this.gamePlayed = true;
					startPlay(packet.delay);

					showMyFriends(this.squirrelGame.squirrels.getIds());

					if (Locations.getLocation(location).teamMode)
					{
						HeaderShort.setTeams((this.squirrelGame.squirrels as ITeams).redTeamIds, (this.squirrelGame.squirrels as ITeams).blueTeamIds);
						//TODO remove
						this.dialogWinners.setPrize(30, 5);
						this.dialogWinners.hide();
						break;
					}
					HeaderShort.setSquirrels(this.squirrelGame.squirrels.getIds());
					break;
			}
		}

		private function showMyFriends(ids:Vector.<int>):void
		{
			for (var i:int = 0; i < this.myFriends.length; i++)
			{
				if (ids.indexOf(this.myFriends[i]) != -1)
					continue;
				this.myFriends.splice(i, 1);
			}

			for (i = 0; i < ids.length; i++)
			{
				if (Game.friendsIds.indexOf(ids[i]) == -1 && Game.isFriend(ids[i]) != true)
					continue;

				if (this.myFriends.indexOf(ids[i]) != -1)
					continue;

				ChatDead.instance.sendMessage(ids[i], "", ChatDeadServiceMessage.MY_FRIENDS);
				this.myFriends.push(ids[i]);
			}
		}

		private function showPlayingFriends(ids:Vector.<int>):void
		{
			for (var i:int = 0; i < ids.length; i++)
			{
				if (Game.friendsIds.indexOf(ids[i]) == -1 && Game.isFriend(ids[i]) != true)
					continue;
				if (this.myFriends.indexOf(ids[i]) != -1)
					continue;
				ChatDead.instance.sendMessage(ids[i], "", ChatDeadServiceMessage.PLAYING_FRIENDS);
			}
		}

		private function showWaitingFriend(id:int):void
		{
			if (Game.isFriend(id) || Game.friendsIds.indexOf(id) != -1)
				ChatDead.instance.sendMessage(id, "", ChatDeadServiceMessage.FRIEND_JOIN_WAITING);
		}

		private function setFocus():void
		{
			if (Game.chat.hasFocus())
				return;
			Game.stage.focus = Game.stage;
		}

		private function waitingStatus(value:Boolean):void
		{
			clear();

			this.waitingSprite.visible = value;
			if (!value)
				return;
			switch(location)
			{
				case Locations.ISLAND_ID:
				case Locations.SANDBOX_ID:
					this.waitingField.text = gls("Сейчас на Солнечной Долине ты один. Подожди прихода других белок.");
					break;
				case Locations.MOUNTAIN_ID:
					this.waitingField.text = gls("Сейчас на Снежных хребтах ты один. Подожди прихода других белок.");
					break;
				case Locations.SWAMP_ID:
					this.waitingField.text = gls("Сейчас на Топях ты один. Подожди прихода других белок.");
					break;
				case Locations.DESERT_ID:
					this.waitingField.text = gls("Сейчас в Пустыне ты один. Подожди прихода других белок.");
					break;
				case Locations.ANOMAL_ID:
					this.waitingField.text = gls("Сейчас в Аномальной зоне ты один. Подожди прихода других белок.");
					break;
				case Locations.HARD_ID:
					this.waitingField.text = gls("Сейчас на Испытании ты один. Подожди прихода других белок.");
					break;
				case Locations.BATTLE_ID:
					var left:int = Math.max(Locations.BATTLE_MIN_PLAYERS - this.squirrelsCount, 0);
					this.waitingField.text = (left != 0 ? gls("Для начала новой Битвы нужно подождать еще {0} {1}.", left, squirrelLeftString(left)) : "");
					break;
				case Locations.STORM_ID:
					this.waitingField.text = gls("Для начала игры в Шторме не хватает игроков");
					break;
				case Locations.WILD_ID:
					this.waitingField.text = gls("Сейчас на Диких Землях ты один. Подожди прихода других белок.");
					break;
			}
		}

		private function leaveSelf():void
		{
			this.onLeaveBlocking = false;
			this.isPlaying = false;

			Game.chat.hide();

			this.gameTimer.stop();

			this.showWinnersAfterLeave = ((this.dialogWinners != null) && this.dialogWinners.visible);

			Connection.sendData(PacketClient.COUNT, PacketClient.PLANET_SHOW, this.isChangingRoom);

			if (!this.isChangingRoom)
				Screens.show(Screens.screenToComeback is ScreenLearning ? "Location" : Screens.screenToComeback);
			else
				start(location);

			if (!this.gamePlayed)
				return;

			this.gamePlayed = false;
			FPSCounter.sendStat(this.mapId);
		}

		private function startDelayTimer(delay:int):void
		{
			RoundStartingView.instance.show(delay);
		}

		private function onTickGame(e:TimerEvent):void
		{
			updateWaitField(this.gameTimer.repeatCount - e.currentTarget.currentCount);
		}

		private function onCompleteGame(e:Event):void
		{
			HeaderShort.clear();
		}

		private function updateWaitField(value:int):void
		{
			/*if ((value == TIME_STATUS_HIDE) && (DialogGameStatus.instance.status != DialogGameStatus.RESPAWN_VIP_STATUS))
			{
				DialogGameStatus.instance.roundContinue = false;
				DialogGameStatus.instance.hide();
			}*/

			HeaderShort.updateTimer(value);
			this.waitField.text = HeaderShort.getTime();
		}

		private function get squirrelsCount():int
		{
			return this._squirrelsCount;
		}

		private function set squirrelsCount(value:int):void
		{
			if (this._squirrelsCount == value)
				return;
			this._squirrelsCount = value;

			if ((this.state != PacketServer.ROUND_WAITING) || !Locations.getLocation(location).teamMode)
				return;
			var left:int = Math.max(Locations.BATTLE_MIN_PLAYERS - this.squirrelsCount, 0);
			this.waitingField.text = (left != 0 ? gls("Для начала нового раунда нужно подождать еще {0} {1}.", left, squirrelLeftString(left)) : "");
		}

		private function squirrelLeftString(count:int):String
		{
			return count % 10 == 1 ? gls("белку") : gls("белок");
		}

		private function startPlay(seconds:int):void
		{
			clear();

			this.gameTimer.repeatCount = seconds;
			this.gameTimer.reset();
			this.gameTimer.start();

			this.reportView.reportsClear();

			updateWaitField(seconds);
			GameSounds.play('round_begin');
		}

		private function clear():void
		{
			RoundStartingView.instance.hide();

			HeaderShort.clear();
			DialogVIPGame.hide();
		}

		private function getHero(id:int):Hero
		{
			if (this.squirrelGame == null)
				return null;
			return this.squirrelGame.squirrels.get(id);
		}

		private function onSeason(e:GameEvent):void
		{
			this.leaveOnResult = true;
		}

		private function onPacket(packet: AbstractServerPacket):void
		{
			if (this.onLeaveBlocking && (packet.packetId != PacketRoomLeave.PACKET_ID))
				return;

			switch (packet.packetId)
			{
				case PacketRoom.PACKET_ID:
					initRoom((packet as PacketRoom));
					break;
				case PacketRoomLeave.PACKET_ID:
					var roomLeave:PacketRoomLeave = packet as PacketRoomLeave;
					var leavedIndex:int = this.playersIds.indexOf(roomLeave.playerId);
					if (leavedIndex != -1)
						this.playersIds.splice(leavedIndex, 1);
					if (roomLeave.playerId == Game.selfId)
						leaveSelf();
					this.squirrelsCount--;
					FPSCounter.sendAlterAnalytics();
					break;
				case PacketRoomRound.PACKET_ID:
					round((packet as PacketRoomRound));
					TagManager.onShow();
					break;
				case PacketRoomJoin.PACKET_ID:
					var roomJoint: PacketRoomJoin = packet as PacketRoomJoin;
					if (this.playersIds.indexOf(roomJoint.playerId) == -1)
						this.playersIds.push(roomJoint.playerId);

					if (this.state == PacketServer.ROUND_PLAYING || this.state == PacketServer.ROUND_START)
						showWaitingFriend(roomJoint.playerId);
					this.squirrelsCount++;
					break;
				case PacketRoundHollow.PACKET_ID:
					var roundHollow: PacketRoundHollow = packet as PacketRoundHollow;
					if (roundHollow.success == 1)
						return;
					hollow(roundHollow.playerId);

					if (roundHollow.playerId == Game.selfId)
					{
						FPSCounter.sendAlterAnalytics();
						DialogRoundTime.instance.hide();
						TagManager.onUse();
					}
					break;
				case PacketRoundDie.PACKET_ID:
					if (!(Screens.active is ScreenGame) || (packet as PacketRoundDie).playerId != Game.selfId)
						return;
					DialogRoundTime.instance.hide();
					TagManager.onUse();
					break;
				case PacketChatMessage.PACKET_ID:
					var chatMessage: PacketChatMessage = packet as PacketChatMessage;

					if (!(Screens.active is ScreenGame))
						return;
					if (chatMessage.chatType != PacketClient.CHAT_ROOM)
						return;
					if (IgnoreList.isIgnored(chatMessage.playerId))
						break;
					var hero:Hero = getHero(chatMessage.playerId);
					if (hero && !hero.isDead)
						hero.heroView.sendMessage(chatMessage.message);

					ScreenGame.sendMessage(chatMessage.playerId, chatMessage.message, chatMessage.chatType);
					break;
				case PacketPlayWith.PACKET_ID:
					this.isPlaying = false;
					break;
				case PacketRoundElement.PACKET_ID:
					var roundElement:PacketRoundElement = packet as PacketRoundElement;
					var heroCollector:Hero = getHero(roundElement.playerId);
					if (heroCollector == null)
						return;
					heroCollector.heroView.showCollectionAnimation(roundElement.unsignedElementId, roundElement.kind);
					break;
			}
		}
	}
}