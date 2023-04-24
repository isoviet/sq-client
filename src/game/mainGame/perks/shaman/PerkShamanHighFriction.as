package game.mainGame.perks.shaman
{
	import game.mainGame.events.SquirrelEvent;
	import game.mainGame.gameBattleNet.BuffRadialView;

	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomJoin;

	public class PerkShamanHighFriction extends PerkShamanPassive
	{
		static private var bonuses:Object = {};
		static private var squirrels:Object = {};
		static private var heroBuff:BuffRadialView = null;

		private var heroId:int;

		public function PerkShamanHighFriction(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_HIGH_FRICTION;
			this.heroId = this.hero.id;
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
			var maxBonus:Number = 0;
			var perfomerId:int;

			for (var id:String in bonuses)
			{
				if (bonuses[id] > maxBonus)
				{
					maxBonus = bonuses[id];
					perfomerId = int(id);
				}
			}

			return perfomerId;
		}

		override protected function get packets():Array
		{
			return [PacketRoomJoin.PACKET_ID];
		}

		override protected function activate():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			resetSquirrelsFriction();

			bonuses[this.heroId] = countBonus();

			setSquirrelsFriction();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!(this.heroId in bonuses))
				return;

			resetSquirrelsFriction();

			delete bonuses[this.heroId];

			setSquirrelsFriction();
		}

		override protected function onPacket(packet: AbstractServerPacket):void
		{
			var join: PacketRoomJoin = packet as PacketRoomJoin;

			if (this.hero == null || !this.active)
				return;

			if (join.isPlaying == PacketServer.JOIN_PLAYING)
				return;

			if (getPerformer() != this.hero.id)
				return;

			var hero:Hero = this.hero.game.squirrels.get(join.playerId);

			if (hero && squirrels && this.buff)
			{
				hero.friction += getBonus();
				hero.addBuff(this.buff);

				squirrels[hero.id] = getBonus();
			}
		}

		private function setSquirrelsFriction():void
		{
			if (!this.hero || !this.hero.game)
				return;

			var friction:Number = getBonus();

			if (friction == 0)
				return;

			if (getPerformer() == this.hero.id)
				heroBuff = this.buff;

			var _squirrels:Object = this.hero.game.squirrels.players;
			var bonus:int = 0;

			for each (var hero:Hero in _squirrels)
			{
				if (!checkHero(hero))
					continue;

				bonus = (hero.id == this.hero.id) ? countBonus() : friction;
				squirrels[hero.id] = bonus;
				hero.friction += bonus;

				if (!hero.isDead)
					hero.heroView.showActiveAura();

				if (!(hero.id in bonuses))
				{
					hero.addBuff(heroBuff);
					hero.addEventListener(SquirrelEvent.SHAMAN, resetHero);
				}
			}
		}

		private function resetSquirrelsFriction():void
		{
			if (!this.hero || !this.hero.game)
				return;

			var friction:Number = getBonus();

			if (friction == 0)
				return;

			for (var id:String in squirrels)
			{
				var hero:Hero = this.hero.game.squirrels.get(int(id));

				if (!(hero && hero.isExist))
					continue;

				hero.friction -= squirrels[id];
				if (!(hero.id in bonuses))
					hero.removeBuff(heroBuff);

				hero.removeEventListener(SquirrelEvent.SHAMAN, resetHero);
			}

			squirrels = {};
		}

		private function checkHero(hero:Hero):Boolean
		{
			return hero && hero.isExist && !hero.isHare && !hero.isDragon && !hero.inHollow && (hero.shaman && ((hero.id == this.hero.id) || (hero.id in bonuses))|| !hero.shaman);
		}

		private function resetHero(e:SquirrelEvent):void
		{
			var hero:Hero = e.player;

			if (!(hero && hero.isExist) || !(hero.id in squirrels) || !hero.shaman)
				return;

			hero.friction -= getBonus();
			hero.removeBuff(heroBuff);

			hero.removeEventListener(SquirrelEvent.SHAMAN, resetHero);

			delete squirrels[hero.id];
		}
	}
}