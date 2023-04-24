package game.mainGame.gameRecord
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import Box2D.Common.Math.b2Vec2;

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
	import game.mainGame.gameNet.CastNet;
	import game.mainGame.perks.shaman.PerkShamanHelium;
	import game.mainGame.perks.shaman.PerkShamanWeight;
	import sounds.GameSounds;

	import protocol.packages.server.PacketRoundCastBegin;

	import utils.starling.StarlingAdapterSprite;

	public class CastRecord extends CastNet
	{
		public function CastRecord(game:SquirrelGame):void
		{
			super(game);
		}

		override protected function setHint():void
		{
			this.castHint.visible = false;
		}

		override protected function onRemoteCastBegin(packet:PacketRoundCastBegin):void
		{
			var playerId:int = packet.playerId;
			var player:Hero = this.game.squirrels.get(playerId);

			var data:Array = packet.dataJson as Array;
			var bodyClass:Class;

			if (this.game.squirrels.get(playerId).shaman)
				bodyClass = EntityFactory.getEntity(data[1][0]) as Class;
			else
				bodyClass = CastItemsData.getClass(data[1][0]);

			if (playerId != Game.selfId)
				player.castStart();

			if (bodyClass == DragTool)
				return;

			if (!(playerId in this.castObjects))
				this.castObjects[playerId] = {};

			if (!('body' in this.castObjects[playerId]))
				this.castObjects[playerId]['body'] = new bodyClass();

			var body:IGameObject = this.castObjects[playerId]['body'];

			if (!(body is DragTool) && !(body is ICastDrawable))
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

		override protected function onRemoteCastEnd(playerId: int, castType: int, itemId: int, success: int):void
		{
			if (!(playerId in this.castObjects))
				return;

			if (playerId != Game.selfId)
				this.game.squirrels.get(playerId).castStop(true);

			if (success == 1)
			{
				GameSounds.playCasted(this.castObjects[playerId]['body']);

				if (this.castingSprite.contains(this.castObjects[playerId]['body']))
					this.castingSprite.removeChildStarling(this.castObjects[playerId]['body'], false);

				if (this.castingSprite.containsStarling(this.castObjects[playerId]['body']))
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
				this.castObjects[playerId]['body'].dispose();

				if ("joint" in this.castObjects[playerId])
					this.castObjects[playerId]['joint'].dispose();
			}

			delete this.castObjects[playerId];
		}
	}
}