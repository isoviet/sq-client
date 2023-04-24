package game.mainGame.perks.dragon
{
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.simple.DragonFlamer;

	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundCommand;
	import protocol.packages.server.PacketRoundHero;

	public class PerkFire extends PerkDragon
	{
		public function PerkFire(hero:Hero):void
		{
			super(hero);

			this.code = 11;
		}

		override public function get available():Boolean
		{
			return super.available && !this.hero.swim;
		}

		override protected function activate():void
		{
			super.activate();

			this.hero.isStoped = true;
			spitFire();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.hero == null)
				return;

			(this.hero.heroView.dragonView as DragonView).fire = false;
			this.hero.isStoped = false;
		}

		override protected function get packets():Array
		{
			return [PacketRoundHero.PACKET_ID, PacketRoundCommand.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundHero.PACKET_ID:
					var pktHero: PacketRoundHero = packet as PacketRoundHero;

					if (!this.hero || (pktHero.playerId != this.hero.id))
						return;

					if (pktHero.keycode == this.code)
						this.active = true;

					if (pktHero.keycode == -this.code)
						this.active = false;
					break;
				case PacketRoundCommand.PACKET_ID:
					if (!this.active)
						return;

					var data:Object = (packet as PacketRoundCommand).dataJson;
					if (!('Create' in data))
						return;

					if (data['Create'][0] != EntityFactory.getId(DragonFlamer))
						return;

					if (data['Create'][1][1][0] != this.hero.id)
						return;

					(this.hero.heroView.dragonView as DragonView).fire = true;
					setTimeout(setDeactive, 1300);
					break;
			}
		}

		private function spitFire():void
		{
			if (this.charge != 100)
				return;

			if (this.hero == null)
				return;

			if (!this.hero.isSelf)
				return;

			var dragonFire:DragonFlamer = new DragonFlamer();
			dragonFire.playerId = Game.selfId;
			dragonFire.angle = (this.hero.heroView.direction ? 0 : Math.PI) + this.hero.angle;
			var dirX:b2Vec2 = this.hero.rCol1;
			dirX.Multiply(this.hero.heroView.direction ? (-5 * this.hero.scale) : (5 * this.hero.scale));
			var dirY:b2Vec2 = this.hero.rCol2;
			dirY.Multiply(-1 * this.hero.scale);
			dirX.Add(dirY);
			dragonFire.position = b2Math.AddVV(this.hero.position, dirX);
			dragonFire.scale = this.hero.scale;

			this.hero.game.map.createObjectSync(dragonFire, true);
		}

		private function setDeactive():void
		{
			this.active = false;
			this.charge = 0;
		}
	}
}