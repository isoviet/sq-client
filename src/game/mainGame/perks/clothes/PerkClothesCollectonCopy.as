package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.CollectionMirageElement;
	import game.mainGame.entity.simple.Element;
	import game.mainGame.gameNet.GameMapNet;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesCollectonCopy extends PerkClothes
	{
		public function PerkClothesCollectonCopy(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_ACTIVATE;
			this.soundOnlyHimself = true;
		}

		override public function get maxCountUse():int
		{
			return 1;
		}

		override public function get json():String
		{
			if (this.active)
				return "";

			var mirages:Array = [];
			var positions:Array = [];
			var indexes:Array = [];
			for each (var element:Element in this.hero.game.map.elements)
			{
				if (element.sensor == null)
					continue;
				if (!(element is CollectionElement) || (element as CollectionElement).kind != CollectionElement.KIND_COLLECTION)
					continue;
				var itemMirage:CollectionMirageElement = new CollectionMirageElement();
				itemMirage.itemId = (element as CollectionElement).itemId;
				itemMirage.index = element.index;

				mirages.push(itemMirage);
				positions.push(element.position.Copy());
				indexes.push(element.index);
			}

			positions = positions.concat((this.hero.game.map as GameMapNet).getFreePosition(2, 2, mirages.length));

			for (var i:int = 0; i < indexes.length; i++)
				indexes[i] = {'index': indexes[i], 'position': positions.splice(int(Math.random() * positions.length), 1)[0]};

			while (mirages.length > 0)
			{
				itemMirage = mirages.pop();
				indexes.push({'mirageId': itemMirage.itemId, 'mirageIndex': itemMirage.index, 'position': positions.splice(int(Math.random() * positions.length), 1)[0]});
			}

			return by.blooddy.crypto.serialization.JSON.encode(indexes);
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkill.PACKET_ID:
					var roundSkill:PacketRoundSkill = packet as PacketRoundSkill;
					if (roundSkill.state == PacketServer.SKILL_ERROR)
						return;
					if (roundSkill.type != this.code || roundSkill.playerId != this.hero.id)
						return;
					this.active = roundSkill.state == PacketServer.SKILL_ACTIVATE;

					if (roundSkill.state != PacketServer.SKILL_ACTIVATE)
						return;
					var indexes:Array = roundSkill.scriptJson as Array;
					for (var i:int = 0; i < indexes.length; i++)
					{
						if ('index' in indexes[i])
							this.hero.game.map.elements[indexes[i]['index']].position = new b2Vec2(indexes[i]['position']['x'], indexes[i]['position']['y']);
						else
						{
							var itemMirage:CollectionMirageElement = new CollectionMirageElement();
							itemMirage.itemId = indexes[i]['mirageId'];
							itemMirage.index = indexes[i]['mirageIndex'];
							itemMirage.position = new b2Vec2(indexes[i]['position']['x'], indexes[i]['position']['y']);

							this.hero.game.map.add(itemMirage);
							itemMirage.build(this.hero.game.world);
						}
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}