package game.mainGame.gameNet
{
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;

	import chat.ChatDead;
	import chat.ChatDeadServiceMessage;
	import controllers.ControllerHeroLocal;
	import controllers.ControllerHeroRemote;
	import dialogs.DialogTotemBonus;
	import events.GameEvent;
	import footers.FooterGame;
	import game.gameData.CollectionsData;
	import game.gameData.OutfitData;
	import game.gameData.PowerManager;
	import game.mainGame.GameMap;
	import game.mainGame.KickButton;
	import game.mainGame.ShamanDeathAnimation;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.events.SquirrelGameEvent;
	import game.mainGame.gameQuests.GameQuest;
	import screens.ScreenGame;
	import sounds.GameSounds;
	import sounds.SoundConstants;
	import views.GameBonusImageView;
	import views.GameBonusValueView;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketBalance;
	import protocol.packages.server.PacketClanTotemBonus;
	import protocol.packages.server.PacketRoom;
	import protocol.packages.server.PacketRoomJoin;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundBeasts;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundCompensation;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundElement;
	import protocol.packages.server.PacketRoundHollow;
	import protocol.packages.server.PacketRoundNut;
	import protocol.packages.server.PacketRoundRespawn;
	import protocol.packages.server.PacketRoundShaman;
	import protocol.packages.server.PacketRoundSkills;
	import protocol.packages.server.PacketRoundSynchronizer;
	import protocol.packages.server.PacketShamanExperience;

	import utils.CastUtil;
	import utils.ImageUtil;

	public class SquirrelCollectionNet extends SquirrelCollection
	{
		static private var _instance:SquirrelCollectionNet;

		private var _nutsBonus:uint = 0;
		private var _experienceBonus:uint = 0;
		private var _shamanExpBonus:uint = 0;
		private var _manaBonus:uint = 0;

		private var hares:Vector.<int> = new Vector.<int>();
		private var dragons:Vector.<int> = new Vector.<int>();

		private var shamanSoulAnimation:ShamanDeathAnimation = null;
		private var gums:Object = {};

		private var reportSquirrels:Array;
		private var kickButton:KickButton = null;
		private var kickButtonKlicked:Boolean = false;

		private var gameQuest:GameQuest = null;

		public var VIPRespawnCount:int = 0;
		public var respawn:int = 0;
		public var hardRespawnCount:int = 0;

		protected var shamans:Vector.<int> = new Vector.<int>();
		protected var teams:Object = {};

		public var locationId:int = -1;

		public function SquirrelCollectionNet():void
		{
			_instance = this;

			super();

			onSendAlive();
			this.aliveTimer.start();

			var shamanDead:ShamanDead = new ShamanDead();
			var shamanBmp:Bitmap = ImageUtil.convertToRastrImage(shamanDead, shamanDead.width, shamanDead.height);
			shamanBmp.smoothing = true;
			shamanBmp.blendMode = BlendMode.SCREEN;

			this.shamanSoulAnimation = new ShamanDeathAnimation(shamanBmp, 20);
			this.shamanSoulAnimation.addEventListener("Finished", removeShamanSoul);

			this.mouseChildren = true;
			this.mouseEnabled = true;

			this.kickButton = new KickButton();
			this.kickButton.addEventListener(MouseEvent.CLICK, onKickButton);

			this.gameQuest = new GameQuest(DailyQuestManager.currentQuest);

			Experience.addEventListener(GameEvent.EXPERIENCE_CHANGED, onExperience);
			PowerManager.addEventListener(GameEvent.MANA_CHANGED, onMana);
			PowerManager.addEventListener(GameEvent.ENERGY_CHANGED, onEnergy);
			Connection.listen(onPacket, [PacketRoom.PACKET_ID, PacketRoomLeave.PACKET_ID, PacketRoundSynchronizer.PACKET_ID,
				PacketRoundShaman.PACKET_ID, PacketRoundBeasts.PACKET_ID, PacketRoundNut.PACKET_ID,
				PacketRoundHollow.PACKET_ID, PacketRoundCompensation.PACKET_ID, PacketRoomJoin.PACKET_ID,
				PacketRoundDie.PACKET_ID, PacketRoundCommand.PACKET_ID, PacketRoundRespawn.PACKET_ID,
				PacketRoundElement.PACKET_ID, PacketBalance.PACKET_ID, PacketShamanExperience.PACKET_ID,
				PacketClanTotemBonus.PACKET_ID, PacketRoundSkills.PACKET_ID], 1);
		}

		static public function get countVIPRespawn():int
		{
			return _instance ? _instance.VIPRespawnCount : 0;
		}

		static public function get bonusAcorns():int
		{
			return _instance ? _instance.nutsBonus : 0;
		}

		static public function get bonusExperience():int
		{
			return _instance ? _instance.experienceBonus : 0;
		}

		static public function get bonusShamanExp():int
		{
			return _instance ? _instance.shamanExpBonus : 0;
		}

		static public function get bonusMana():int
		{
			return _instance ? _instance.manaBonus : 0;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.gameQuest)
				this.gameQuest.update(timeStep);
		}

		override public function round(packet:PacketRoomRound):void
		{
			switch (packet.type)
			{
				case PacketServer.ROUND_STARTING:
					this.kickButton.visible = false;
					this.shamans = new Vector.<int>();
					this.hares = new Vector.<int>();
					this.dragons = new Vector.<int>();
					this.teams = {};
				case PacketServer.ROUND_WAITING:
				case PacketServer.ROUND_PLAYING:
				case PacketServer.ROUND_RESULTS:
					hide();
					break;
				case PacketServer.ROUND_START:
					if (ScreenGame.cheaterId == 0)
						ControllerHeroLocal.doKick = false;
					this.gums = {};

					this.kickButton.visible = false;
					this.kickButtonKlicked = false;
					this.kickButton.reset();

					this.VIPRespawnCount = 0;
					this.hardRespawnCount = 0;
					this.respawn = 0;
					this.selfCollected = false;

					FooterGame.roundStarted = false;

					reset();
					initSquirrels();
					initCastItems();
					place();
					show();

					FooterGame.roundStarted = true;

					this.nutsBonus = 0;
					this.experienceBonus = 0;
					this.shamanExpBonus = 0;
					this.manaBonus = 0;
					break;
			}
		}

		override public function checkSquirrelsCount(resetAvailable:Boolean = true):void
		{
			this.reportSquirrels = super.getActiveSquirrels();

			if (this.reportSquirrels.length == 1 && (this.reportSquirrels[0].id != Game.selfId) && (!this.kickButtonKlicked))
			{
				this.kickButton.visible = true;
				this.reportSquirrels[0].addViewButton(this.kickButton);
			}
			else if (resetAvailable)
			{
				if (this.kickButtonKlicked)
				{
					ScreenGame.resetReportCount();
					this.kickButtonKlicked = false;
				}
				this.kickButton.visible = false;
			}
		}

		public function get experienceBonus():int
		{
			return this._experienceBonus;
		}

		public function set experienceBonus(value:int):void
		{
			this._experienceBonus = value;
			dispatchEvent(new SquirrelGameEvent(SquirrelGameEvent.UPDATE_BONUS));
		}

		public function get shamanExpBonus():int
		{
			return this._shamanExpBonus;
		}

		public function set shamanExpBonus(value:int):void
		{
			this._shamanExpBonus = value;
			dispatchEvent(new SquirrelGameEvent(SquirrelGameEvent.UPDATE_BONUS));
		}

		public function get manaBonus():uint
		{
			return this._manaBonus;
		}

		public function set manaBonus(value:uint):void
		{
			this._manaBonus = value;
			dispatchEvent(new SquirrelGameEvent(SquirrelGameEvent.UPDATE_BONUS));
		}

		public function get nutsBonus():int
		{
			return this._nutsBonus;
		}

		public function set nutsBonus(value:int):void
		{
			this._nutsBonus = value;
			dispatchEvent(new SquirrelGameEvent(SquirrelGameEvent.UPDATE_BONUS));
		}

		override public function createGum(self:int, other:int):Boolean
		{
			if (other in this.gums)
				return false;
			if (findGum(self, other))
				return false;

			this.gums[other] = true;
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'GumWith': [self, other]}));
			return true;
		}

		override public function getShamans():Array
		{
			var result:Array = [];
			for each (var id:int in this.shamans)
			{
				if (get(id) == null)
					continue;
				result.push(get(id));
			}
			return result;
		}

		override public function add(id:int):void
		{
			super.add(id);

			if (id != Game.selfId)
				return;
			initCastItems();
			FooterGame.hero = Hero.self;
		}

		override public function remove(id:int):void
		{
			super.remove(id);

			if (this.count > 1 || !GameMap.instance)
				return;

			(GameMap.instance as GameMapNet).syncCollection.doSync = false;
		}

		override public function dispose():void
		{
			super.dispose();

			_instance = null;

			if (shamanSoulAnimation)
			{
				this.shamanSoulAnimation.removeEventListener("Finished", removeShamanSoul);
				removeShamanSoul();
				this.shamanSoulAnimation = null;
			}

			if (this.gameQuest)
			{
				this.gameQuest.dispose();
				this.gameQuest = null;
			}

			FooterGame.hero = null;

			PowerManager.removeEventListener(GameEvent.MANA_CHANGED, onMana);
			PowerManager.removeEventListener(GameEvent.ENERGY_CHANGED, onEnergy);
			Connection.forget(onPacket, [PacketRoom.PACKET_ID, PacketRoomLeave.PACKET_ID, PacketRoundSynchronizer.PACKET_ID,
				PacketRoundShaman.PACKET_ID, PacketRoundBeasts.PACKET_ID, PacketRoundNut.PACKET_ID,
				PacketRoundHollow.PACKET_ID, PacketRoundCompensation.PACKET_ID, PacketRoomJoin.PACKET_ID,
				PacketRoundDie.PACKET_ID, PacketRoundCommand.PACKET_ID, PacketRoundRespawn.PACKET_ID,
				PacketRoundElement.PACKET_ID, PacketBalance.PACKET_ID, PacketShamanExperience.PACKET_ID,
				PacketClanTotemBonus.PACKET_ID, PacketRoundSkills.PACKET_ID]);
		}

		override protected function onSelfDie(e:SquirrelEvent = null):void
		{
			Connection.sendData(PacketClient.ROUND_DIE, Hero.self.position.x, Hero.self.position.y, Hero.self.dieReason);
		}

		override protected function setController(id:int):void
		{
			if (id <= 0)
				return;

			if (id == Game.selfId)
				new ControllerHeroLocal(this.players[id], true);
			else
				new ControllerHeroRemote(this.players[id], id);
		}

		override public function setShamans(shamans: Vector.<int>, withReset:Boolean = true):void
		{
			resetTeams();

			super.setShamans(shamans, withReset);
		}

		protected function initCastItems():void
		{
			if (!Hero.self)
				return;
			Hero.self.castItems.set(CastUtil.squirrelCastItems(DiscountManager.freeItems(Game.selfCastItems)));
		}

		protected function initSquirrels():void
		{
			setShamans(this.shamans);
			setHares(this.hares);
			setDragons(this.dragons);
		}

		protected function resetTeams():void
		{
			for each (var hero:Hero in this.players)
				hero.team = Hero.TEAM_NONE;
			for (var id:String in this.teams)
			{
				hero = get(int(id));
				if (!hero)
					continue;
				hero.team = this.teams[id];
			}
		}

		protected function showShamanDeadAnimation():void
		{
			if (this.shamans && this.shamans.length > 0 && get(this.shamans[0]))
			{
				EnterFrameManager.addListener(animationNewShaman);

				if (get(this.shamans[0]).id != Game.selfId)
				{
					var soundIndex:int = Math.random() * SoundConstants.NEW_SHAMAN_SOUNDS.length;
					GameSounds.playUnrepeatable(SoundConstants.NEW_SHAMAN_SOUNDS[soundIndex]);
				}

				if (!contains(this.shamanSoulAnimation))
				{
					this.shamanSoulAnimation.setPosition(get(this.shamans[0]).x + 30, get(this.shamans[0]).y - 40);
					addChild(this.shamanSoulAnimation);
				}
			}
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoom.PACKET_ID:
					set((packet as PacketRoom).players);
					add(Game.selfId);
					hide();
					break;
				case PacketRoomLeave.PACKET_ID:
					var leave: PacketRoomLeave = packet as PacketRoomLeave;
					var hero:Hero = get(leave.playerId);
					if (hero == null)
						return;

					var playerIsNew:Boolean = hero.isNew;
					hero.dispatchEvent(new SquirrelEvent(SquirrelEvent.LEAVE, hero));
					remove(leave.playerId);

					if (Hero.selfAlive && this.activeSquirrelCount == 1 && Hero.self.isHare)
					{
						Logger.add("SquirrelCollectionNet.onPacket ROOM_LEAVE, send ROUND_HOLLOW");
						Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
						Connection.sendData(PacketClient.ROUND_HOLLOW, 0);
					}
					if (!playerIsNew)
						this.checkSquirrelsCount(false);
					break;
				case PacketRoundSynchronizer.PACKET_ID:
					setSynchronizer((packet as PacketRoundSynchronizer).playerId);
					break;
				case PacketRoundShaman.PACKET_ID:
					var roundShaman: PacketRoundShaman = packet as PacketRoundShaman;

					showShamanDeadAnimation();

					this.shamans = roundShaman.playerId;
					this.teams = {};
					for (i = 0; i < roundShaman.playerId.length; i++)
						this.teams[roundShaman.playerId[i]] = roundShaman.teams[i];
					setShamans(this.shamans, false);

					for each (var shamanId:int in roundShaman.playerId)
						ScreenGame.sendMessage(shamanId, "", ChatDeadServiceMessage.SHAMAN);

					this.checkSquirrelsCount();
					break;
				case PacketRoundBeasts.PACKET_ID:
					var roundBeast: PacketRoundBeasts = packet as PacketRoundBeasts;

					for (var i:int = 0, len: int = roundBeast.items.length; i < len; i++)
						switch (roundBeast.items[i].beastType)
						{
							case PacketServer.BEAST_DRAGON:
								this.dragons = roundBeast.items[i].ids;
								setDragons(this.dragons);
								break;
							case PacketServer.BEAST_HARE:
								this.hares = roundBeast.items[i].ids;
								setHares(this.hares);
								break;
						}
					break;
				case PacketRoundNut.PACKET_ID:
					var roundNut: PacketRoundNut = packet as PacketRoundNut;

					hero = get(roundNut.playerId);
					if (hero == null)
						return;
					hero.setMode(roundNut.state == PacketClient.NUT_PICK ? Hero.NUT_MOD : Hero.NUDE_MOD);
					break;
				case PacketRoundHollow.PACKET_ID:
					var roundHollow: PacketRoundHollow = packet as PacketRoundHollow;
					if (roundHollow.success == 1)
						return;

					hero = get(roundHollow.playerId);
					if (hero != null && !hero.isSelf)
						hero.onHollow(roundHollow.hollowType);

					if (Hero.self)
					{
						ControllerHeroLocal.doKick = !Hero.self.isHare;
						if (Hero.self.isHare && !this.hasActiveSquirrel(false))
						{
							Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
							Connection.sendData(PacketClient.ROUND_HOLLOW, 0);
						}
					}
					if (roundHollow.playerId == Game.selfId && this.locationId == Locations.SANDBOX_ID && this.hasActiveSquirrel(false))
						ScreenGame.changeRoom();
					this.checkSquirrelsCount();
					break;
				case PacketRoundCompensation.PACKET_ID:
					var roundComp: PacketRoundCompensation = packet as PacketRoundCompensation;
					onPlayerShamanCompensation(roundComp.type, roundComp.amount);
					break;
				case PacketRoomJoin.PACKET_ID:
					var roomJoin: PacketRoomJoin = packet as PacketRoomJoin;
					add(roomJoin.playerId);

					if (roomJoin.isPlaying == PacketServer.JOIN_PLAYING)
						get(roomJoin.playerId).hide();

					if (Hero.self != null && (Hero.self.position.x != 0 && Hero.self.position.y != 0))
						Hero.self.sendLocation();
					break;
				case PacketRoundDie.PACKET_ID:
					var roundDie: PacketRoundDie = packet as PacketRoundDie;

					this.checkSquirrelsCount();

					if (roundDie.playerId == Game.selfId)
						break;

					hero = get(roundDie.playerId);
					if (hero == null)
						return;

					hero.position = new b2Vec2(roundDie.posX, roundDie.posY);
					hero.dieReason = roundDie.reason;
					hero.dead = true;

					if (hero.isHare)
						GameSounds.play(SoundConstants.DEATH_SOUNDS_HARE[int(Math.random() * SoundConstants.DEATH_SOUNDS_HARE.length)]);

					if (Hero.self && !this.hasActiveSquirrel(false) && Hero.self.isHare)
					{
						Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
						Connection.sendData(PacketClient.ROUND_HOLLOW, 0);
						break;
					}
					this.checkSquirrelsCount();
					if (!hero.isHare && this.hares.length > 0 && this.get(this.hares[0]) && !this.get(this.hares[0]).isDead)
						GameSounds.playUnrepeatable("hare_killer", HareView.SOUND_PROBABILITY);
					break;
				case PacketRoundCommand.PACKET_ID:
					var data:Object = (packet as PacketRoundCommand).dataJson;
					if ("GumWith" in data)
					{
						if (data['GumWith'][0] == Game.selfId)
							delete this.gums[data['GumWith'][1]];

						super.createGum(data['GumWith'][0], data['GumWith'][1]);
					}
					break;
				case PacketRoundRespawn.PACKET_ID:
					var roundRespawn: PacketRoundRespawn = packet as PacketRoundRespawn;

					hero = get(roundRespawn.playerId);
					if (hero == null)
						return;
					if (!hero.isDead || roundRespawn.status == PacketServer.RESPAWN_FAIL)
						break;

					switch (roundRespawn.respawnType)
					{
						case PacketServer.RESPAWN_DRAGON:
							hero.teleport(Hero.TELEPORT_DESTINATION_SHAMAN);
							break;
						case PacketServer.RESPAWN_HEAVENS_GATE:
							break;
						default:
							if (roundRespawn.playerId == Game.selfId && roundRespawn.respawnType == PacketServer.RESPAWN_VIP)
								this.VIPRespawnCount++;
							if (roundRespawn.playerId == Game.selfId && roundRespawn.respawnType == PacketServer.RESPAWN_FREE_HARD)
								this.hardRespawnCount++;

							this.respawn++;
							hero.shaman = false;
							hero.teleport(Hero.TELEPORT_DESTINATION_RESPAWN);

							setTimeout(respawnHero, 0, hero);
							break;
					}
					break;
				case PacketRoundElement.PACKET_ID:
					var roundElement: PacketRoundElement = packet as PacketRoundElement;
					var id:int = roundElement.unsignedElementId;

					if (roundElement.playerId == Game.selfId)
						this.selfCollected = true;
					if (roundElement.playerId != Game.selfId && !Game.self['moderator'])
						break;
					var nameElement:String = roundElement.kind == CollectionElement.KIND_HOLIDAY ? gls("Семечко") : CollectionsData.regularData[id]['tittle'];
					ScreenGame.sendMessage(roundElement.playerId, nameElement, ChatDeadServiceMessage.COLLECTION_ELEMENT);
					break;
				case PacketBalance.PACKET_ID:
					var balance: PacketBalance = packet as PacketBalance;

					if (balance.reason != PacketServer.REASON_NURSE_AWARDING &&
						balance.reason != PacketServer.REASON_HIPSTER_AWARDING &&
						balance.reason != PacketServer.REASON_LEPRECHAUN_AWARDING &&
						balance.reason != PacketServer.REASON_SHAMAN_RESCUING &&
						balance.reason != PacketServer.REASON_WINNING &&
						balance.reason != PacketServer.REASON_SHAMAN_SURRENDER)
						break;

					if (balance.reason == PacketServer.REASON_SHAMAN_RESCUING && Hero.self && Hero.self.inHollow)
						break;

					var nuts:int = balance.nuts - Game.self.nutsOld;
					this.nutsBonus += nuts;

					if (balance.reason == PacketServer.REASON_LEPRECHAUN_AWARDING)
						break;

					showAwardAcorns(nuts);
					Game.self.nutsOld = balance.nuts;
					break;
				case PacketShamanExperience.PACKET_ID:
					var shamanExp:uint = (packet as PacketShamanExperience).shamanExp - Game.self['shaman_exp'];
					this.shamanExpBonus += shamanExp;
					showAwardShaman(shamanExp);
					break;
				case PacketClanTotemBonus.PACKET_ID:
					var totemBonus: PacketClanTotemBonus = packet as PacketClanTotemBonus;
					NotifyQueue.show(new DialogTotemBonus(totemBonus.bonus, totemBonus.totemId));
					break;
				case PacketRoundSkills.PACKET_ID:
					var packetSkills:PacketRoundSkills = packet as PacketRoundSkills;
					for (i = 0; i < packetSkills.items.length; i++)
					{
						hero = get(packetSkills.items[i].playerId);
						if (!hero)
							continue;
						for (var j:int = 0; j < packetSkills.items[i].characters.length; j++)
						{
							if (packetSkills.items[i].characters[j].character != OutfitData.CHARACTER_SQUIRREL)
								continue;
							hero.initClothesPerks(packetSkills.items[i].characters[j].skills);
						}
					}
					break;
			}
		}

		private function onPlayerShamanCompensation(type:int, amount:int = 0):void
		{
			switch (type)
			{
				case PacketServer.SHAMAN_COMPENSATION:
					showAwardAcorns(amount);
					ChatDead.instance.sendServiceMessage(Game.selfId, "", ChatDeadServiceMessage.SHAMAN_COMPENSATION, amount);
					break;
				case PacketServer.DRAGON_COMPENSATION:
					ScreenGame.sendMessage(Game.selfId, "", ChatDeadServiceMessage.DRAGON_COMPENSATION);
					break;
			}
		}

		private function onExperience(e:GameEvent):void
		{
			if (e.data['reason'] == PacketServer.REASON_TRAINING)
				return;

			this.experienceBonus += e.data['delta'];
			showAwardExp(e.data['delta']);
		}

		private function onEnergy(e:GameEvent):void
		{
			if (e.data['reason'] == PacketServer.REASON_ENERGY_RETURN)
				showAwardEnergy(e.data['delta']);
		}

		private function onMana(e:GameEvent):void
		{
			if (!e.data)
				return;
			switch (e.data['reason'])
			{
				case PacketServer.REASON_RABBIT_KILLING:
				case PacketServer.REASON_WINNING:
				case PacketServer.REASON_SHAMAN_KILLING:
				case PacketServer.REASON_LEPRECHAUN_AWARDING:
				case PacketServer.REASON_DISCOUNT:
					break;
				default:
					return;
			}
			this.manaBonus += e.data['delta'];

			if (e.data['reason'] != PacketServer.REASON_LEPRECHAUN_AWARDING)
				showAwardMana(e.data['delta']);
		}

		private function animationNewShaman():void
		{
			if (this.shamans.length <= 0 || !get(this.shamans[0]))
			{
				removeShamanSoul();
				return;
			}

			this.shamanSoulAnimation.motionTo(new Point(get(this.shamans[0]).x, get(this.shamans[0]).y - 15));
		}

		private function removeShamanSoul(e:Event = null):void
		{
			if (this.shamanSoulAnimation && contains(this.shamanSoulAnimation))
				removeChild(this.shamanSoulAnimation);
			EnterFrameManager.removeListener(animationNewShaman);
		}

		private function showAward(amount:int, imageClass:Class, shiftX:int = 0, toX:int = -1, toY:int = -1, scale:Number = 0.7):void
		{
			if (amount == 0 || !Hero.self)
				return;

			var image:DisplayObject = new imageClass();
			image.scaleX = image.scaleY = scale;

			var valueView:GameBonusValueView = new GameBonusValueView(amount, Hero.self.x + SquirrelGame.instance.shift.x + shiftX, Hero.self.y + SquirrelGame.instance.shift.y);
			Game.gameSprite.addChild(valueView);

			var imageView:GameBonusImageView = new GameBonusImageView(image, valueView.x + int(valueView.width)+ 1, valueView.y, toX, toY);
			Game.gameSprite.addChild(imageView);
		}

		private function showAwardAcorns(nuts:int):void
		{
			showAward(nuts, ImageIconNut, 55, 158, 7);
		}

		private function showAwardExp(exp:int):void
		{
			showAward(exp, ImageIconExp);
		}

		private function showAwardMana(mana:uint):void
		{
			showAward(mana, ImageIconMana, -40);
		}

		private function showAwardShaman(shamanExp:uint):void
		{
			showAward(shamanExp, ImageIconShamanExp, -3);
		}

		private function showAwardEnergy(energy:uint):void
		{
			showAward(energy, ImageIconEnergy, 90, 115, 5);
		}

		private function onKickButton(e:MouseEvent):void
		{
			this.kickButton.visible = false;
			this.kickButtonKlicked = true;

			if (this.reportSquirrels.length == 0)
				return;

			var data:Object = {'reportedPlayerId': this.reportSquirrels[0].id, 'targetPlayerId': Game.selfId};

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode(data));
		}

		private function respawnHero(hero:Hero):void
		{
			if (hero)
				hero.respawn(hero.healedByDeath ? Hero.RESPAWN_NONE : Hero.RESPAWN_HARD);
		}
	}
}