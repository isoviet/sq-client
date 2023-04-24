package game.mainGame.gameQuests
{
	import flash.display.DisplayObject;
	import flash.text.TextFormat;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.GameMap;
	import game.mainGame.SquirrelCollection;
	import game.mainGame.SquirrelGame;
	import game.mainGame.gameNet.GameMapNet;
	import game.mainGame.gameRopedNet.SquirrelCollectionRopedNet;
	import screens.ScreenGame;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundHollow;
	import protocol.packages.server.PacketRoundWorld;

	public class GameQuest
	{
		static private const SIZE:int = 2;
		static private const AFFECTION_RADIUS:int = 16;
		static private const WITHOUT_HELP_RADIUS:int = 4;
		static private const PATIENCE_MIN_TIME:int = 10;
		static private const PATIENCE_MAX_TIME:int = 15;

		static private const NONE:int = -1;
		static private const AFFECTION:int = 0;
		static private const FASTER:int = 1;
		static private const WITHOUT_PITY:int = 2;
		static private const INTUITION:int = 3;
		static private const WILD_ACORNS:int = 4;
		static private const EXCAVATION:int = 5;
		static private const GREED:int = 6;
		static private const PATIENCE:int = 7;
		static private const RAIN:int = 8;
		static private const LUCK:int = 9;
		static private const WITHOUT_HELP:int = 10;
		static private const SUPERIORITY:int = 11;
		static private const FEAR:int = 12;
		static private const IMMORTALITY:int = 13;

		static private const AFFECTION_TIME:Number = 10.0;
		static private const FASTER_TIME:Array = [60, 60, 90, 160, 80, 90];
		static private const WITHOUT_HELP_TIME:Number = 10.0;
		static private const INTUITION_PLACE:int = 8;
		static private const WILD_ACORNS_PLACE:int = 5;
		static private const WILD_ACORNS_COUNT:int = 3;
		static private const GREED_PLACE:int = 5;

		private var id:int = -1;

		private var _timeLeft:Number = 0;
		private var _otherId:int = -1;

		private var patienceTime:Number = 0;

		private var questObjects:Vector.<QuestObject>;

		private var timerView:QuestTimerBack = new QuestTimerBack();
		private var arrowView:DisplayObject;
		private var fieldTimer:GameField = null;

		public function GameQuest(id:int):void
		{
			this.id = id;

			this.timerView.y = -70;

			Connection.listen(onPacket, [PacketRoundCommand.PACKET_ID, PacketRoomRound.PACKET_ID,
				PacketRoundWorld.PACKET_ID, PacketRoundHollow.PACKET_ID, PacketRoundDie.PACKET_ID]);
		}

		static public function get perkAvaliable():Boolean
		{
			switch (DailyQuestManager.currentQuest)
			{
				case INTUITION:
				case EXCAVATION:
					return true;
			}
			return false;
		}

		public function update(timeStep:Number):void
		{
			if (!SquirrelGame.instance || !SquirrelCollection.instance)
				return;
			switch (this.id)
			{
				case NONE:
					return;
				case AFFECTION:
					var hero:Hero = SquirrelCollection.instance.get(this.otherId);
					if (!hero || hero.isDead || hero.inHollow || !Hero.self || Hero.self.isDead || Hero.self.inHollow)
						break;
					var pos:b2Vec2 = Hero.self.position.Copy();
					pos.Subtract(hero.position);
					if (pos.Length() > AFFECTION_RADIUS)
						this.timeLeft -= timeStep;
					break;
				case FASTER:
					this.timeLeft -= timeStep;
					break;
				case PATIENCE:
					this.patienceTime -= timeStep;
					if (this.patienceTime > 0)
						return;
					this.patienceTime = PATIENCE_MIN_TIME + Math.random() * (PATIENCE_MAX_TIME - PATIENCE_MIN_TIME);
					Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'questFactor': -1}));
					break;
				case WITHOUT_HELP:
					if (!Hero.self || Hero.self.shaman || Hero.self.isDead)
						break;
					for each (hero in SquirrelCollection.instance.getShamans())
					{
						pos = Hero.self.position.Copy();
						pos.Subtract(hero.position);
						if (pos.Length() <= WITHOUT_HELP_RADIUS)
							this.timeLeft -= timeStep;
					}
					break;
			}

			if (this.fieldTimer && this.timeLeft <= 0)
			{
				this.timerView.removeChild(this.fieldTimer);
				this.fieldTimer = null;
				if (this.timerView.parent)
					this.timerView.parent.removeChild(this.timerView);
			}

			if (this.fieldTimer)
			{
				this.fieldTimer.text = this.timeLeft.toFixed(1);
				this.fieldTimer.x = -int(this.fieldTimer.textWidth * 0.5) - 3;
				if (SquirrelGame.instance && SquirrelCollection.instance && Hero.self)
				{
					this.timerView.scaleX = Hero.self.scale > 0 ? 1 : -1;
					this.timerView.y = SquirrelCollection.instance.selfCollected ? -100 : -70;
					this.timerView.visible = Hero.selfAlive;
				}
			}

			if (this.arrowView)
			{
				var other:Hero = SquirrelCollection.instance.get(this.otherId);
				this.arrowView.visible = other && !other.isDead && !other.inHollow;
			}
		}

		public function dispose():void
		{
			Connection.forget(onPacket, [PacketRoundCommand.PACKET_ID, PacketRoomRound.PACKET_ID,
				PacketRoundWorld.PACKET_ID, PacketRoundHollow.PACKET_ID, PacketRoundDie.PACKET_ID]);
		}

		private function checkFinish():void
		{
			var value:int = 1;
			var count:int = 0;
			for (var i:int = 0; i < this.questObjects.length; i++)
				if (this.questObjects[i].activated)
					count++;

			switch (this.id)
			{
				case AFFECTION:
				case FASTER:
				case WITHOUT_HELP:
					if (this.timeLeft < 0)
						return;
					break;
				case WITHOUT_PITY:
					if (!(SquirrelCollection.instance is SquirrelCollectionRopedNet))
						return;
					if ((SquirrelCollection.instance as SquirrelCollectionRopedNet).roped.length != 0)
						return;
					break;
				case SUPERIORITY:
					if (this.otherId == -1)
						return;
					break;
				case WILD_ACORNS:
					if (count < WILD_ACORNS_COUNT)
						return;
					break;
				case RAIN:
					if ((this.questObjects[0] as ObjectRain).count == 0)
						return;
					value = (this.questObjects[0] as ObjectRain).count;
					break;
				case EXCAVATION:
				case LUCK:
				case FEAR:
					if (count == 0)
						return;
					break;
				case INTUITION:
				case GREED:
				case IMMORTALITY:
					if (count == 0)
						return;
					value = count;
					break;
			}

			DailyQuestManager.onProgress(this.id, value);
		}

		private function initValues():void
		{
			switch (this.id)
			{
				case AFFECTION:
					this.timeLeft = AFFECTION_TIME;
					break;
				case SUPERIORITY:
					var ids:Vector.<int> = SquirrelCollection.instance.getIds();
					for (var i:int = 0; i < ids.length; i++)
					{
						var hero:Hero = SquirrelCollection.instance.get(ids[i]);
						if (hero && !hero.isHare && !hero.shaman && ids[i] != Game.selfId)
							continue;
						ids.splice(i, 1);
						i--;
					}
					this.otherId = (ids.length != 0) ? ids[int(Math.random() * ids.length)] : -1;
					break;
				case FASTER:
					this.timeLeft = FASTER_TIME[DailyQuest.getLocationId(ScreenGame.location)];
					break;
				case WITHOUT_HELP:
					this.timeLeft = Hero.self.shaman || (SquirrelCollection.instance.getShamans().length == 0) ? 0 : WITHOUT_HELP_TIME;
					break;
				case PATIENCE:
					this.patienceTime = PATIENCE_MIN_TIME + Math.random() * (PATIENCE_MAX_TIME - PATIENCE_MIN_TIME);
					break;
				default:
					return;
			}
		}

		private function get otherId():int
		{
			return this._otherId;
		}

		private function set otherId(value:int):void
		{
			this._otherId = value;

			if (this.arrowView)
			{
				if (this.arrowView.parent)
					this.arrowView.parent.removeChild(this.arrowView);
				this.arrowView = null;
			}

			if (value != -1)
			{
				this.arrowView = this.id == AFFECTION ? new QuestArrowGreen() : new QuestArrowRed();
				this.arrowView.y = -70;
				SquirrelCollection.instance.get(this.otherId).addChild(this.arrowView);
			}
			else
				this.timeLeft = 0;
		}

		private function get timeLeft():Number
		{
			return this._timeLeft;
		}

		private function set timeLeft(value:Number):void
		{
			this._timeLeft = value;

			if (!this.fieldTimer)
			{
				this.fieldTimer = new GameField("", 0, -3, new TextFormat(null, 14, 0xffffff, true));
				this.timerView.addChild(this.fieldTimer);
			}
			if (Hero.self && !this.timerView.parent)
				Hero.self.addChildAt(this.timerView, 0);
		}

		private function createElements():void
		{
			this.questObjects = new Vector.<QuestObject>();

			var count:int = 1;
			var objectClass:Class = null;
			switch (this.id)
			{
				case INTUITION:
					count = INTUITION_PLACE;
					objectClass = ObjectIntuition;
					break;
				case WILD_ACORNS:
					count = WILD_ACORNS_PLACE;
					objectClass = ObjectWildNut;
					break;
				case EXCAVATION:
					objectClass = ObjectExcavation;
					break;
				case GREED:
					count = GREED_PLACE;
					objectClass = ObjectGreed;
					break;
				case RAIN:
					objectClass = ObjectRain;
					break;
				case LUCK:
					objectClass = ObjectLuck;
					break;
				case FEAR:
					objectClass = ObjectFear;
					break;
				default:
					return;
			}

			var places:Array = (GameMap.instance as GameMapNet).getFreePosition(SIZE, SIZE, count);
			for (var i:int = 0; i < places.length; i++)
			{
				var object:QuestObject = new objectClass(Hero.self);
				object.position = places[i];
				GameMap.instance.add(object);

				this.questObjects.push(object);
			}
		}

		private function onDie(packet:PacketRoundDie):void
		{
			switch (this.id)
			{
				case WITHOUT_PITY:
					if (!(SquirrelCollection.instance is SquirrelCollectionRopedNet))
						return;
					var roped:Array = (SquirrelCollection.instance as SquirrelCollectionRopedNet).roped;
					if (roped.indexOf(packet.playerId) == -1)
						return;
					roped.splice(roped.indexOf(packet.playerId), 1);
					break;
				case IMMORTALITY:
					if (packet.playerId == Game.selfId)
						return;
					var object:QuestObject = new ObjectImmortality(Hero.self);
					object.position = new b2Vec2(packet.posX, packet.posY);
					GameMap.instance.add(object);

					this.questObjects.push(object);
					break;
			}
		}

		private function onHollow(packet:PacketRoundHollow):void
		{
			switch (this.id)
			{
				case SUPERIORITY:
					if (packet.playerId == this.otherId)
						this.otherId = -1;
					break;
			}
			if (Game.selfId == packet.playerId)
				checkFinish();
		}

		private function onPacket(packet:AbstractServerPacket):void
		{
			if (packet.packetId != PacketRoundCommand.PACKET_ID && this.id == NONE)
				return;
			switch (packet.packetId)
			{
				case PacketRoundCommand.PACKET_ID:
					var command: PacketRoundCommand = packet as PacketRoundCommand;
					var data:Object = command.dataJson;
					if (!("questFactor" in data))
						return;
					var hero:Hero = SquirrelCollection.instance.get(command.playerId);
					if (hero)
						hero.questFactor *= data['questFactor'];
					break;
				case PacketRoomRound.PACKET_ID:
					if ((packet as PacketRoomRound).type != PacketServer.ROUND_START)
						return;
					initValues();
					createElements();
					break;
				case PacketRoundWorld.PACKET_ID:
					var state:int = (GameMap.instance as GameMapNet).gameState;
					if (state != PacketServer.ROUND_PLAYING && state != PacketServer.ROUND_START)
						break;
					initValues();
					createElements();
					break;
				case PacketRoundDie.PACKET_ID:
					onDie(packet as PacketRoundDie);
					break;
				case PacketRoundHollow.PACKET_ID:
					if ((packet as PacketRoundHollow).success != 0)
						return;
					onHollow(packet as PacketRoundHollow);
					break;
			}
		}
	}
}