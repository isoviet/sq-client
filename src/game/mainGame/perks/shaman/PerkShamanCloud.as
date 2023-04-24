package game.mainGame.perks.shaman
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.shaman.DeathCloud;

	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundDie;

	public class PerkShamanCloud extends PerkShamanPassive
	{
		static private var bonuses:Object = {};
		static private var extraBonuses:Object = {};

		static private var cloudsCount:int = 0;

		private var heroId:int;

		public function PerkShamanCloud(hero:Hero, levels:Array):void
		{
			super(hero, levels);

			this.code = PerkShamanFactory.PERK_CLOUD;
			this.heroId = hero.id;
		}

		static private function getBonus():Number
		{
			var maxBonus:Number = 0;

			for each (var bonus:Number in bonuses)
				maxBonus = (maxBonus < bonus) ? bonus: maxBonus;

			return maxBonus;
		}

		static private function getExtraBonus():Number
		{
			var maxBonus:Number = 0;

			for each (var bonus:Number in extraBonuses)
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

		override protected function activate():void
		{
			if (!this.hero.game)
			{
				this.active = false;
				return;
			}

			super.activate();

			bonuses[this.heroId] = countBonus();
			extraBonuses[this.heroId] = countExtraBonus();

			cloudsCount = getBonus();
		}

		override protected function deactivate():void
		{
			super.deactivate();

			delete bonuses[this.heroId];
			delete extraBonuses[this.heroId];

			cloudsCount = getBonus();
		}

		override protected function get packets():Array
		{
			return [PacketRoundDie.PACKET_ID];
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			var die: PacketRoundDie = packet as PacketRoundDie;

			if (!this.hero || !this.hero.game || !this.active || cloudsCount == 0)
				return;

			if (die.playerId == this.hero.id)
				return;

			var hero:Hero = this.hero.game.squirrels.get(die.playerId);

			if (!hero || hero.isHare || hero.shaman)
				return;

			if (getPerformer() != this.hero.id)
				return;

			cloudsCount--;

			if (!this.hero.isSelf)
				return;

			var cloud:DeathCloud = new DeathCloud();
			cloud.angle = hero.angle;
			cloud.lifeTime = getExtraBonus() * 1000;
			cloud.perkLevel = this.levelPaid;
			var dirY:b2Vec2 = this.hero.rCol2;
			dirY.Multiply(2);
			cloud.position = b2Math.AddVV(hero.position, dirY);
			this.hero.game.map.createObjectSync(cloud, true);
		}
	}
}