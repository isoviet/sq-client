package game.mainGame.gameNet
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;

	import game.gameData.CollectionManager;
	import game.mainGame.GameMap;
	import game.mainGame.ISerialize;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.IMouseEnabled;
	import game.mainGame.entity.editor.CollectionPoint;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.CollectionMirageElement;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.perks.Perk;
	import game.mainGame.perks.PerkOld;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import syncronize.SyncCollection;
	import syncronize.SyncGameBody;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomJoin;
	import protocol.packages.server.PacketRoomRequestWorld;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundElements;
	import protocol.packages.server.PacketRoundWorld;

	import utils.StringUtil;
	import utils.WorldQueryUtil;

	public class GameMapNet extends GameMap
	{
		static private const COLLECTION_ITEM_SIZE:Number = 2;
		static private const MIRAGES_COUNT:int = 1;

		private var timer:Timer = new Timer(2000, 1);
		private var nextMap:String = null;

		protected var mapTime:int = 0;

		public var gameState:int = -1;

		public var syncCollection:SyncCollection;
		public var createMirages:Boolean = false;

		public function GameMapNet(game:SquirrelGame):void
		{
			super(game);

			this.syncCollection = new SyncCollection(this);

			Connection.listen(onPacket, [PacketRoomRequestWorld.PACKET_ID, PacketRoomJoin.PACKET_ID,
				PacketRoundWorld.PACKET_ID, PacketRoundCommand.PACKET_ID, PacketRoundElements.PACKET_ID], 1);

			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, loadMap);
		}

		override public function round(packet:PacketRoomRound):void
		{
			if (packet.mapData)
				this.nextMap = StringUtil.ByteArrayToMap(packet.mapData);

			if (packet.mapDuration > -1)
				this.mapTime = packet.mapDuration;

			if (packet.type == PacketServer.ROUND_STARTING)
				startDelay();
			else
				loadMap();

			switch (packet.type)
			{
				case PacketServer.ROUND_START:
					this.gameState = packet.type;
					this.syncCollection.startSync();
					CollectionManager.currentCollectionId = -1;
					CollectionManager.currentCollectionKind = -1;
					break;
				case PacketServer.ROUND_WAITING:
				case PacketServer.ROUND_PLAYING:
				case PacketServer.ROUND_RESULTS:
					this.gameState = packet.type;
					this.syncCollection.stopSync();
					break;
				case PacketServer.ROUND_CUT:
					break;
			}
		}

		override public function serialize():*
		{
			var result:Array = by.blooddy.crypto.serialization.JSON.decode(super.serialize());

			var squirrelsData:Array = [];
			for each (var hero:Hero in this.game.squirrels.players)
			{
				var activePerks:Array = [];
				var activePerksClothes:Array = [];
				var activePerksCharacter:Array = [];
				var activePerksShaman:Array = [];

				for each (var perk:Perk in hero.perkController.perksMana)
				{
					if (perk.active)
						activePerks.push(perk.code);
				}
				for each (perk in hero.perkController.perksClothes)
				{
					if (perk.active)
						activePerksClothes.push(perk.code);
				}
				for each (var perkOld:PerkOld in hero.perkController.perksShaman)
				{
					if (perkOld.active)
						activePerksShaman.push(PerkShamanFactory.getId(perkOld));
				}

				squirrelsData.push([hero.player['id'], hero.isDead, hero.inHollow, hero.hasNut, activePerks, activePerksClothes, activePerksCharacter, activePerksShaman]);
			}
			result.push({"playersData": squirrelsData});
			return by.blooddy.crypto.serialization.JSON.encode(result);
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);
			this.cachePool.cacheAsBitmap = true;

			var result:Array = by.blooddy.crypto.serialization.JSON.decode(data);
			var squirrelsData:Object = result.pop();
			if (!("playersData" in squirrelsData))
				return;

			for each (var squirrelData:Array in squirrelsData["playersData"])
			{
				var hero:Hero = game.squirrels.get(squirrelData[0]);
				if (!hero)
					continue;

				hero.isDead = Boolean(squirrelData[1]);
				hero.inHollow = Boolean(squirrelData[2]);
				hero.setMode(squirrelData[3] ? Hero.NUT_MOD : Hero.NUDE_MOD);
				for each (var perk:Perk in hero.perkController.perksMana)
				{
					for each (var perkId:int in squirrelData[4])
					{
						if (perk.code == perkId)
							perk.active = true;
					}
				}
				for each (perk in hero.perkController.perksClothes)
				{
					for each (perkId in squirrelData[5])
					{
						if (perk.code == perkId)
							perk.active = true;
					}
				}
				for each (var perkOld:PerkOld in hero.perkController.perksShaman)
				{
					for each (perkId in squirrelData[7])
					{
						if (PerkShamanFactory.getId(perkOld) == perkId)
							perkOld.active = true;
					}
				}

				if (this.gameState == PacketServer.ROUND_START)
				{
					hero.updateState();
				}
			}
		}

		override public function createObjectSync(object:IGameObject, build:Boolean):void
		{
			var data:Object = {};

			if (object is ISerialize)
				data['Create'] = [EntityFactory.getId(object), (object as ISerialize).serialize(), build];

			var result:String = by.blooddy.crypto.serialization.JSON.encode(data);
			Connection.sendData(PacketClient.ROUND_COMMAND, result);
		}

		override public function destroyObjectSync(object:IGameObject, dispose:Boolean):void
		{
			var data:Object = {};
			data['Destroy'] = [getID(object), dispose];
			var result:String = by.blooddy.crypto.serialization.JSON.encode(data);
			Connection.sendData(PacketClient.ROUND_COMMAND, result);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.syncCollection.update();
		}

		override public function clear():void
		{
			super.clear();

			this.syncCollection.reset();
		}

		override public function set size(value:Point):void
		{
			super.size = value;

			//this.maskLayer.graphics.clear();
			//this.maskBorders.graphics.clear();
			//this.objectSprite.mask = null;

			if (super.size.x >= Config.GAME_WIDTH)
				return;
			//this.maskLayer.graphics.beginFill(0x000000);
			//this.maskLayer.graphics.drawRect((Config.GAME_WIDTH - super.size.x) * 0.5, 0, super.size.x, super.size.y);
			//addChild(this.maskLayer);
			//this.objectSprite.mask = this.maskLayer;

			//this.maskBorders.graphics.beginFill(0x000000, 0.5);
			//this.maskBorders.graphics.drawRect(0, 0, (Config.GAME_WIDTH - super.size.x) * 0.5, super.size.y);
			//this.maskBorders.graphics.drawRect(Config.GAME_WIDTH - (Config.GAME_WIDTH - super.size.x) * 0.5, 0, (Config.GAME_WIDTH - super.size.x) * 0.5, super.size.y);
			addChild(this.maskBorders);
		}

		override public function dispose():void
		{
			super.dispose();

			this.syncCollection.doSync = false;
			this.syncCollection = null;
			this.nextMap = null;
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, loadMap);

			Connection.forget(onPacket, [PacketRoomRequestWorld.PACKET_ID, PacketRoomJoin.PACKET_ID,
				PacketRoundWorld.PACKET_ID, PacketRoundCommand.PACKET_ID, PacketRoundElements.PACKET_ID]);
		}

		override public function add(object:* = null):void
		{
			super.add(object);

			if ((object is Sprite || object is MovieClip) && !(object is IMouseEnabled))
			{
				object.mouseEnabled = false;
				object.mouseChildren = false;
			}

			if (!(object is GameBody))
				return;

			this.syncCollection.register(new SyncGameBody(object as GameBody));
		}

		override public function remove(object:*, doDispose:Boolean = false):void
		{
			if (object is GameBody && this.syncCollection)
				this.syncCollection.remove((object as GameBody).id);

			super.remove(object, doDispose);
		}

		public function createElements():void
		{
			if (!this.game.squirrels.isSynchronizing)
				return;

			if (this.elementsPlacesCount == 0)
				return;
			var places:Array = [];
			var collectionPoints:Array = get(CollectionPoint);
			for (var i:int = 0; i < collectionPoints.length; i++)
				places.push((collectionPoints[i] as CollectionPoint).position);
			while (places.length > this.elementsPlacesCount)
				places.splice(int(Math.random() * places.length), 1);
			if (places.length < this.elementsPlacesCount)
				places = places.concat(getFreePosition(COLLECTION_ITEM_SIZE, COLLECTION_ITEM_SIZE, this.elementsPlacesCount - places.length));
			createCollection(places);
		}

		public function createObject(id:int, object:GameBody):void
		{
			if (!this.game.squirrels.isSynchronizing)
				return;

			var freePositions:Array = getFreePosition(COLLECTION_ITEM_SIZE, COLLECTION_ITEM_SIZE, 1);

			object.position = freePositions[0];
			object.playerId = id;

			createObjectSync(object, true);
		}

		override protected function onHollow(e:HollowEvent):void
		{
			Logger.add("GameMapNet.onHollow");
			if (this.isBrokenWorld)
			{
				Connection.sendData(PacketClient.PING, 3);
				Connection.sendData(PacketClient.LEAVE);
				return;
			}
			Connection.sendData(PacketClient.ROUND_HOLLOW, 0);
		}

		override protected function onAcorn(e:SquirrelEvent):void
		{
			super.onAcorn(e);

			Logger.add("GameMapNet.onNut");
			Connection.sendData(PacketClient.ROUND_NUT, PacketClient.NUT_PICK);
		}

		protected function createCollection(freePositions:Array):void
		{
			if (this.collectionItemsCreated)
				return;

			for (var i:int = 0; i < this.collectionItems.length; i++)
			{
				var item:CollectionElement = new CollectionElement();
				item.kind = this.collectionItems[i].kind;
				item.itemId = this.collectionItems[i].unsignedElementId;
				item.index = i;
				item.position = freePositions.pop();

				createObjectSync(item, true);

				if (!this.createMirages || (item.kind != CollectionElement.KIND_COLLECTION))
					continue;
				for (var j:int = 0; j < MIRAGES_COUNT; j++)
				{
					var itemMirage:CollectionMirageElement = new CollectionMirageElement();
					itemMirage.itemId = this.collectionItems[i].unsignedElementId;
					itemMirage.index = i;
					itemMirage.position = freePositions.pop();
					createObjectSync(itemMirage, true);
				}
			}
		}

		public function getFreePosition(placeWidth:int, placeHeight:int, count:int):Array
		{
			var ty:int = this.size.y - Config.GAME_HEIGHT;
			if (ty < 0)
				ty = 0;

			var beginPosition:Point = new Point(0, -ty);

			var areas:Array = [];

			for (var i:Number = beginPosition.x / Game.PIXELS_TO_METRE; i < (beginPosition.x + this.size.x) / Game.PIXELS_TO_METRE; i += placeWidth)
			{
				for (var j:Number = beginPosition.y / Game.PIXELS_TO_METRE; j < (beginPosition.y + this.size.y) / Game.PIXELS_TO_METRE - 6; j += placeHeight)
				{
					var area:b2AABB = new b2AABB();
					area.upperBound = new b2Vec2(i, j);
					area.lowerBound = new b2Vec2(i + placeWidth, j + placeHeight);

					areas.push(area);
				}
			}

			var emptyPositions:Array = WorldQueryUtil.findEmptyAreas(this.game.world, areas, count);

			var freePositions:Array = [];
			var usedPositions:Array = [];
			for (i = 0; i < count; i++)
			{
				if (emptyPositions.length == 0)
					freePositions.push(this.acornPosition);
				else
				{
					var freePosition:int = Math.random() * emptyPositions.length;
					while (usedPositions.indexOf(freePosition) != -1 && emptyPositions.length >= count)
						freePosition = Math.random() * emptyPositions.length;

					usedPositions.push(freePosition);

					freePositions.push(new b2Vec2(emptyPositions[freePosition].x + placeWidth / 2, emptyPositions[freePosition].y + placeHeight / 2));
				}
			}

			return freePositions;
		}

		protected function get elementsPlacesCount():int
		{
			return this.collectionItems.length + this.collectionItems.length * (this.createMirages ? MIRAGES_COUNT : 0);
		}

		private function loadMap(e:TimerEvent = null):void
		{
			if (this.nextMap)
				deserialize(this.nextMap);

			this.nextMap = null;
			this.timer.stop();
		}

		private function startDelay():void
		{
			this.timer.reset();
			this.timer.start();
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoomRequestWorld.PACKET_ID:
				case PacketRoomJoin.PACKET_ID:
					var playerId:int =  packet is PacketRoomJoin ? (packet as PacketRoomJoin).playerId : (packet as PacketRoomRequestWorld).targetId;

					if (this.isBrokenWorld)
					{
						Connection.sendData(PacketClient.PING, 3);
						Connection.sendData(PacketClient.LEAVE);
						return;
					}
					if ((this.syncCollection.doSync || (this.game.squirrels.activeSquirrelCount == 1 && Hero.selfAlive)) && this.gameState == PacketServer.ROUND_START)
						Connection.sendData(PacketClient.ROUND_WORLD, playerId, StringUtil.MapToByteArray(serialize()));
					break;
				case PacketRoundWorld.PACKET_ID:
					if (this.gameState != PacketServer.ROUND_PLAYING && this.gameState != PacketServer.ROUND_START)
						break;

					deserialize(StringUtil.ByteArrayToMap((packet as PacketRoundWorld).data));
					build(this.game.world);
					break;
				case PacketRoundCommand.PACKET_ID:
					var data:Object = (packet as PacketRoundCommand).dataJson;
					if ("Create" in data)
					{
						var objectClass:Class = EntityFactory.getEntity(data['Create'][0]);
						var object:IGameObject;

						object = new objectClass();
						(object as ISerialize).deserialize(data['Create'][1]);

						if (object is CollectionElement && !(object is CollectionMirageElement))
						{
							var collectionElement:CollectionElement = object as CollectionElement;
							this.elements[collectionElement.index] = object;
							this.collectionItemsCreated = true;
						}

						add(object);

						if (data['Create'][2])
							object.build(this.game.world);
					}

					if ("Destroy" in data)
					{
						remove(this.getObject(data['Destroy'][0]), Boolean(data['Destroy'][1]));
					}
					break;
				case PacketRoundElements.PACKET_ID:
					this.collectionItems = (packet as PacketRoundElements).items;
					this.collectionItemsCreated = false;
					break;
			}
		}
	}
}