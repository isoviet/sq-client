package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateChaos;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesLeopardRoar extends PerkClothes

	{
		static private const RADIUS:Number = 150 / Game.PIXELS_TO_METRE;

		public function PerkClothesLeopardRoar(hero:Hero)
		{
			super(hero);

			this.activateSound = "leopard_roar";
		}

		override public function get json():String
		{
			if (this.active)
				return "";
			var ids:Array = [];
			for each(var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero.isSelf || hero.isDead || hero.inHollow || hero.shaman)
					continue;
				var pos:b2Vec2 = this.hero.position.Copy();
				pos.Subtract(hero.position);
				if (pos.Length() > RADIUS)
					continue;
				ids.push(hero.id);
			}
			return by.blooddy.crypto.serialization.JSON.encode(ids);
		}

		override public function get totalCooldown():Number
		{
			return 30;
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

					if (roundSkill.state == PacketServer.SKILL_ACTIVATE)
					{
						var ids:Array = roundSkill.scriptJson as Array;
						for (var i:int = 0; i < ids.length; i++)
							this.hero.game.squirrels.get(ids[i]).behaviourController.addState(new StateChaos(10));
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}

		override protected function activate():void
		{
			super.activate();
		}
	}
}