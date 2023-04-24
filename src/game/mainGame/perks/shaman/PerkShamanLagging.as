package game.mainGame.perks.shaman
{
	import flash.utils.setTimeout;

	import game.mainGame.perks.clothes.PerkClothesFactory;
	import game.mainGame.perks.dragon.PerkRebornDragon;
	import game.mainGame.perks.mana.PerkFactory;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomLeave;
	import protocol.packages.server.PacketRoundDie;
	import protocol.packages.server.PacketRoundHollow;
	import protocol.packages.server.PacketRoundRespawn;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkShamanLagging extends PerkShamanPassive
	{
		static private const SQUIRRELS_LEFT_COUNT:int = 1;

		static private var affectedHeroes:Object = {};

		static private var bonuses:Object = {};

		private var heroId:int;
		private var allow:Boolean = false;

		public function PerkShamanLagging(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_LAGGING;
			this.heroId = hero.id;
		}

		static private function getBonus():Number
		{
			var maxBonus:Number = 0;

			for each (var bonus:Number in bonuses)
				maxBonus = (maxBonus < bonus) ? bonus: maxBonus;

			return maxBonus;
		}

		static private function getPerformer():int
		{
			var minId:int = int.MAX_VALUE;

			for (var id:String in bonuses)
			{
				if (int(id) < minId)
					minId = int(id);
			}

			return minId;
		}

		override public function resetRound():void
		{
			super.resetRound();

			this.allow = false;
		}

		override protected function activate():void
		{
			super.activate();

			resetSquirrelsBonus();

			bonuses[this.heroId] = countBonus();

			setSquirrelsBonus();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!(this.heroId in bonuses))
				return;

			resetSquirrelsBonus();

			delete bonuses[this.heroId];

			setSquirrelsBonus();
		}

		override protected function get packets():Array
		{
			return [PacketRoundHollow.PACKET_ID, PacketRoundDie.PACKET_ID, PacketRoomLeave.PACKET_ID,
				PacketRoundRespawn.PACKET_ID, PacketRoundSkill.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (!this.hero || !this.hero.game)
				return;

			switch (packet.packetId)
			{
				case PacketRoundHollow.PACKET_ID:
					var hollow: PacketRoundHollow = packet as PacketRoundHollow;
					if (hollow.success == 1 || hollow.playerId == this.hero.id)
						return;

					this.allow = true;

					checkSquirrelsCount();
					break;
				case PacketRoomLeave.PACKET_ID:
					if ((packet as PacketRoomLeave).playerId == this.hero.id)
						return;

					checkSquirrelsCount();
					break;
				case PacketRoundDie.PACKET_ID:
					if ((packet as PacketRoundDie).playerId == this.hero.id)
						return;

					checkSquirrelsCount();
					break;
				case PacketRoundSkill.PACKET_ID:
					var skill: PacketRoundSkill = packet as PacketRoundSkill;

					if (skill.playerId == this.hero.id)
						return;

					if (skill.state != PacketServer.SKILL_ACTIVATE)
						return;

					/*if (skill.type != PerkClothesFactory.PERK_SKELETON_REBORN &&
						skill.type != PerkClothesFactory.PERK_ANGEL_REBORN &&
						skill.type != PerkClothesFactory.PERK_ARCHANGEL_REBORN &&
						skill.type != PerkFactory.getId(PerkRebornDragon))
						return;*/

					setTimeout(checkSquirrelsCount, 1000);
					break;
				case PacketRoundRespawn.PACKET_ID:
					var respawn: PacketRoundRespawn = packet as PacketRoundRespawn;

					if (respawn.status != PacketServer.RESPAWN_SUCCESS)
						return;

					if (respawn.playerId == this.hero.id)
						return;

					setTimeout(checkSquirrelsCount, 1000);
					break;
			}
		}

		private function checkSquirrelsCount():void
		{
			if (!this.allow || !this.active || !this.hero)
				return;

			if (getPerformer() != this.hero.id)
				return;

			resetSquirrelsBonus();

			setSquirrelsBonus();
		}

		private function setSquirrelsBonus():void
		{
			if (!this.hero || !this.hero.game || !this.allow || getBonus() == 0)
				return;

			var squirrels:Array = this.hero.game.squirrels.getActiveSquirrels();

			if (squirrels.length > SQUIRRELS_LEFT_COUNT || squirrels.length == 0)
				return;

			for each (var hero:Hero in squirrels)
			{
				if (!checkHero(hero))
					continue;

				var jumpBonus:int = hero.jumpVelocity * getBonus() / 100;
				var speedBonus:Number = hero.runSpeed * getBonus() / 100;

				affectedHeroes[hero.id] = {'jump': jumpBonus, 'speed': speedBonus};

				hero.jumpVelocity += affectedHeroes[hero.id]['jump'];
				hero.runSpeed += affectedHeroes[hero.id]['speed'];

				hero.heroView.showActiveAura();
				hero.addBuff(this.buff);
			}
		}

		private function resetSquirrelsBonus():void
		{
			if (!this.hero || !this.hero.game)
				return;

			for (var id:String in affectedHeroes)
			{
				var hero:Hero = this.hero.game.squirrels.get(int(id));
				if (!hero)
					continue;

				hero.jumpVelocity -= affectedHeroes[id]['jump'];
				hero.runSpeed -= affectedHeroes[id]['speed'];
				hero.removeBuff(buff);
				delete affectedHeroes[id];
			}

			affectedHeroes = {};
		}

		private function checkHero(hero:Hero):Boolean
		{
			return !(!hero || !hero.isExist || hero.shaman || hero.isDead || hero.inHollow || hero.isHare || hero.isDragon);
		}
	}
}