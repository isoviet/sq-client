package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.SquirrelCollection;
	import game.mainGame.behaviours.StateCthulhu;
	import sounds.GameSounds;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCommand;

	public class PerkClothesCthulhu extends PerkClothes

	{
		static private const RADIUS:Number = 120 / Game.PIXELS_TO_METRE;

		private var squirrels:SquirrelCollection = null;

		public function PerkClothesCthulhu(hero:Hero):void
		{
			super(hero);

			this.activateSound = "cthulhu_call";
			this.soundOnlyHimself = true;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundCommand.PACKET_ID]);
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused || this.hero.isDead || this.hero.inHollow)
			{
				this.active = false;
				return;
			}

			super.activate();

			if (this.hero.id != Game.selfId)
				return;

			var ids:Array = [];
			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero.shaman || hero.isHare || hero.isDead || hero.inHollow || hero.hover || hero.isStoped)
					continue;
				if (hero.id == this.hero.id)
					continue;
				var pos:b2Vec2 = this.hero.position.Copy();
				pos.Subtract(hero.position);
				if (pos.Length() > RADIUS)
					continue;
				ids.push(hero.id);
			}
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({"cthulhu": [this.hero.id, ids]}));
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundCommand.PACKET_ID:
					var data:Object = (packet as PacketRoundCommand).dataJson;
					if (!('cthulhu' in data))
						return;
					if (!this.hero || this.hero.isDead || data['cthulhu'][0] != this.hero.id)
						return;
					var ids:Array = data['cthulhu'][1];
					this.squirrels = this.hero.game.squirrels;
					for each (var hero:Hero in this.squirrels.players)
					{
						if (ids.indexOf(hero.id) == -1)
							continue;
						if (hero.shaman || hero.isHare || hero.isDead || hero.inHollow || hero.hover)
							continue;
						if (hero.isSquirrel && hero.perkController.getPerkLevel(PerkClothesFactory.CTHULHU_MAN) != -1)
							continue;

						GameSounds.play(SOUND_ACTIVATE);
						hero.behaviourController.addState(new StateCthulhu(7.0));
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}