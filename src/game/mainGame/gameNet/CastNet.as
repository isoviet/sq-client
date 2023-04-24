package game.mainGame.gameNet
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.Cast;
	import game.mainGame.CastItem;
	import game.mainGame.ISerialize;
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.cast.DragTool;
	import game.mainGame.entity.cast.ICastDrawable;
	import game.mainGame.entity.cast.ICastTool;
	import game.mainGame.entity.joints.JointRevolute;
	import game.mainGame.entity.simple.BalloonBody;
	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.entity.simple.WeightBody;
	import game.mainGame.perks.shaman.PerkShamanHelium;
	import game.mainGame.perks.shaman.PerkShamanWeight;
	import sounds.GameSounds;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.RecorderCollection;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundCastBegin;
	import protocol.packages.server.PacketRoundCastEnd;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundShaman;

	import utils.starling.StarlingAdapterSprite;

	public class CastNet extends Cast
	{
		private var castType:int = 0;
		private var lastCastedId:int = -1;

		protected var castObjects:Object = {};
		protected var castingSprite:StarlingAdapterSprite = new StarlingAdapterSprite();

		public function CastNet(game:SquirrelGame):void
		{
			super(game);

			addChildStarling(this.castingSprite);

			Connection.listen(onPacket, [PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID,
				PacketRoundShaman.PACKET_ID, PacketRoundCastBegin.PACKET_ID, PacketRoundCastEnd.PACKET_ID], 1);
		}

		override public function round(packet:PacketRoomRound):void
		{
			switch (packet.type)
			{
				case PacketServer.ROUND_CUT:
					break;
				case PacketServer.ROUND_START:
				case PacketServer.ROUND_PLAYING:
				case PacketServer.ROUND_STARTING:
				case PacketServer.ROUND_WAITING:
				case PacketServer.ROUND_RESULTS:
					clear();
					break;
			}
		}

		override public function dispose():void
		{
			clear();

			super.dispose();

			Connection.forget(onPacket, [PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID,
				PacketRoundShaman.PACKET_ID, PacketRoundCastBegin.PACKET_ID, PacketRoundCastEnd.PACKET_ID]);
		}

		public function sendData():void
		{
			this.castType = (Hero.self.shaman ? PacketClient.CAST_SHAMAN : PacketClient.CAST_SQUIRREL);
			sendPacket(PacketClient.ROUND_CAST_BEGIN);
		}

		override protected function onCastStart(e:MouseEvent):Boolean
		{
			if (!super.onCastStart(e))
				return false;

			sendData();

			return true;
		}

		override protected function onCastCancel(e:MouseEvent = null):void
		{
			super.onCastCancel(e);

			sendPacket(PacketClient.ROUND_CAST_END, 0);
		}

		override protected function onCastComplete(e:TimerEvent = null):void
		{
			sendPacket(PacketClient.ROUND_CAST_END, 1);

			this.casting = false;

			for each (var listener:Function in this.listeners)
				listener(CAST_COMPLETE);

			if (this.castObject && Hero.self)
				Hero.self.castStop(true);

			dropObject();
		}

		override protected function onCastDrawableComplete(e:MouseEvent):void
		{
			onCastComplete(null);
		}

		override protected function castDrawable():void
		{
			sendData();
			sendPacket(PacketClient.ROUND_CAST_END, 1);
		}

		protected function onRemoteCastBegin(packet: PacketRoundCastBegin):void
		{
			var bodyClass:Class;
			var data:Array;
			var playerId:int = packet.playerId;
			var player:Hero = this.game.squirrels.get(playerId);
			if (player == null)
			{
				if (RecorderCollection.has(playerId))
					this.castObjects[playerId] = {};
				return;
			}

			try
			{
				data = packet.dataJson as Array;
			}
			catch(error: Error)
			{
				Logger.add('CastNet->onRemoteCastBegin: ' + error.message);
				return;
			}

			if (this.game.squirrels.get(playerId).shaman)
				bodyClass = EntityFactory.getEntity(data[1][0]);
			else
				bodyClass = CastItemsData.getClass(data[1][0]);

			if (bodyClass == null)
				return;

			if (playerId != Game.selfId)
				player.castStart();

			if (playerId == Game.selfId && bodyClass == DragTool)
				return;

			if (!(playerId in this.castObjects))
				this.castObjects[playerId] = {};

			if (!('body' in this.castObjects[playerId]))
				this.castObjects[playerId]['body'] = new bodyClass();

			var body:IGameObject = this.castObjects[playerId]['body'];

			if (!(body is DragTool) && !(body is ICastDrawable) && playerId != Game.selfId)
				player.position = new b2Vec2(data[0][0], data[0][1]);

			if (body is ICastTool)
				(body as ICastTool).game = this.game;

			if (body is ISerialize)
				(body as ISerialize).deserialize(data[1][1]);

			(body as DisplayObject).alpha = (playerId == Game.selfId) ? 0 : 0.5;

			if (body is DragTool)
			{
				(body as DragTool).owner = player;
				(body as DragTool).alpha = 1;
			}
			this.castingSprite.addChild(body as DisplayObject);
			if (body is StarlingAdapterSprite)
				this.castingSprite.addChildStarling(body as StarlingAdapterSprite);

			if (!('2' in data))
				return;

			var joint:JointRevolute = new (EntityFactory.getEntity(data[2][0]) as Class) as JointRevolute;
			joint.deserialize(data[2][1]);
			joint.body = (body as GameBody);
			this.castObjects[playerId]['joint'] = joint;
			(body as Sprite).addChild(joint);
		}

		protected function onRemoteCastEnd(playerId: int, castType: int, itemId: int, success: int):void
		{
			if (playerId == Game.selfId && (success == 1))
				if (PacketClient.CAST_SQUIRREL == castType)
					updateSquirrelCastItems(itemId);

			if (!this.castObjects || !(playerId in this.castObjects))
				return;

			if (playerId != Game.selfId && this.game && this.game.squirrels && this.game.squirrels.get(playerId))
				this.game.squirrels.get(playerId).castStop(true);

			if (success == 1 && this.castObjects[playerId] && this.castObjects[playerId]['body'])
			{
				GameSounds.playCasted(this.castObjects[playerId]['body']);

				if (this.castObjects[playerId] && this.castObjects[playerId]['body'] && this.castingSprite.contains(this.castObjects[playerId]['body']))
					this.castingSprite.removeChildStarling(this.castObjects[playerId]['body'], false);

				if (this.castObjects[playerId] && this.castObjects[playerId]['body'] && this.castingSprite.containsStarling(this.castObjects[playerId]['body']))
					this.castingSprite.removeChildStarling(this.castObjects[playerId]['body'], false);

				(this.castObjects[playerId]['body'] as DisplayObject).alpha = 1;
				this.game.map.add(this.castObjects[playerId]['body']);

				if (this.castObjects[playerId]['body'] is GameBody)
				{
					(this.castObjects[playerId]['body'] as GameBody).castType = castType;
					(this.castObjects[playerId]['body'] as GameBody).playerId = playerId;
				}

				this.castObjects[playerId]['body'].build(this.game.world);

				if ("joint" in this.castObjects[playerId])
				{
					this.game.map.add(this.castObjects[playerId]['joint']);
					this.castObjects[playerId]['joint'].build(this.game.world);
				}

				if ((this.castObjects[playerId]['body'] is BalloonBody) && (playerId in PerkShamanHelium.heliumBonuses))
				{
					(this.castObjects[playerId]['body'] as BalloonBody).velocityLimit *= (1 + PerkShamanHelium.heliumBonuses[playerId]['power'] / 100);
					if (PerkShamanHelium.heliumBonuses[playerId]['doubleCast'])
						(this.castObjects[playerId]['body'] as BalloonBody).duplicate();
				}

				if (this.castObjects[playerId]['body'] is WeightBody && playerId in PerkShamanWeight.weightBonuses)
				{
					(this.castObjects[playerId]['body'] as WeightBody).mass *= (1 + PerkShamanWeight.weightBonuses[playerId]['weight'] / 100);
					if ("lifeTime" in PerkShamanWeight.weightBonuses[playerId])
					{
						(this.castObjects[playerId]['body'] as WeightBody).aging = true;
						(this.castObjects[playerId]['body'] as WeightBody).lifeTime = PerkShamanWeight.weightBonuses[playerId]['lifeTime'];
					}
				}
			}
			else
			{
				if (this.castObjects[playerId] && this.castObjects[playerId]['body'])
					this.castObjects[playerId]['body'].dispose();

				if (this.castObjects[playerId] && ("joint" in this.castObjects[playerId]))
					this.castObjects[playerId]['joint'].dispose();
			}

			if (this.castObjects[playerId])
				delete this.castObjects[playerId];
		}

		private function clear():void
		{
			this.castObject = null;

			for (var playerId:String in this.castObjects)
			{
				if ("body" in this.castObjects[playerId])
					this.castObjects[playerId]['body'].dispose();

				if ("joint" in this.castObjects[playerId])
					this.castObjects[playerId]['joint'].dispose();

				delete this.castObjects[playerId];
			}

			while (this.castingSprite.numChildren > 0)
			{
				this.castingSprite.removeChildStarlingAt(0, false);
				this.castingSprite.removeChildAt(0);
			}
		}

		protected function updateSquirrelCastItems(id:int):void
		{
			if (!Hero.self || !Hero.self.castItems)
				return;
			var isAmmo:Boolean = CastItemsData.isAmmo(id);

			Hero.self.castItems.add(new CastItem(CastItemsData.getClass(id), isAmmo ? CastItem.TYPE_ROUND : CastItem.TYPE_SQUIRREL, -1));

			if (isAmmo || !Game.selfCastItems)
				return;

			var castItem:CastItem = Hero.self.castItems.getItem(CastItemsData.getClass(id), CastItem.TYPE_SQUIRREL);
			Game.selfCastItems[id] = Math.max(castItem == null ? 0 : castItem.count, 0);
		}

		protected function sendPacket(type:int, success:int = 0):void
		{
			var id:int = -1;
			if (!Hero.self)
				id = this.lastCastedId;
			else
			{
				if (!this.castObject)
					return;
				if (!Hero.self.shaman)
					id = CastItemsData.getId(this.castObject);
				else
					id = EntityFactory.getId(this.castObject);
			}

			switch(type)
			{
				case PacketClient.ROUND_CAST_BEGIN:
					{
						this.lastCastedId = id;

						var result:Array = [];

						result.push([Hero.self.position.x, Hero.self.position.y]);
						if (this.castObject is ISerialize)
							result.push([id, (this.castObject as ISerialize).serialize()]);
						if (this.currentPin is ISerialize && this.currentPin != null)
							result.push([EntityFactory.getId(this.currentPin), (this.currentPin as ISerialize).serialize()]);

						Connection.sendData(PacketClient.ROUND_CAST_BEGIN, id, by.blooddy.crypto.serialization.JSON.encode(result));
					}
					break;
				case PacketClient.ROUND_CAST_END:
					Connection.sendData(PacketClient.ROUND_CAST_END, this.castType, id, success);
					break;
			}
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundDie.PACKET_ID:
					onRemoteCastEnd((packet as PacketRoundDie).playerId, 0, 0, 0);
					break;
				case PacketRoomLeave.PACKET_ID:
					onRemoteCastEnd((packet as PacketRoomLeave).playerId, 0, 0, 0);
					break;
				case PacketRoundShaman.PACKET_ID:
					var shaman: PacketRoundShaman = packet as PacketRoundShaman;
					if (shaman.playerId.length <= 0)
						return;
					if (shaman.playerId[0] == Game.selfId || shaman.playerId.length > 1 && shaman.playerId[1] == Game.selfId)
					{
						if (Hero.self && Hero.self.shaman)
							return;
						if (this.casting)
							onCastCancel();
						dropObject();
					}
					break;
				case PacketRoundCastBegin.PACKET_ID:
					onRemoteCastBegin((packet as PacketRoundCastBegin));
					break;
				case PacketRoundCastEnd.PACKET_ID:
					var castEnd:PacketRoundCastEnd = packet as PacketRoundCastEnd;
					onRemoteCastEnd(castEnd.playerId, castEnd.castType, castEnd.itemId, castEnd.success);
					break;
			}
		}
	}
}