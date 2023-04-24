package game.mainGame.behaviours
{
	import game.mainGame.gameBattleNet.BuffRadialView;
	import game.mainGame.perks.clothes.PerkClothesFactory;

	import protocol.Connection;
	import protocol.packages.server.PacketRoundSkillAction;

	public class StateBanana extends HeroState
	{
		static public const BONUS:Number = 0.1;

		protected var speedBonus:Number = 0;

		protected var main:Boolean = false;
		protected var buff:BuffRadialView = null;

		public function StateBanana(time:Number, main:Boolean = false)
		{
			super(time);

			this.main = main;
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.runSpeed -= this.speedBonus;

				this.hero.removeBuff(this.buff);

				if (this.main)
					Connection.forget(onPacket, [PacketRoundSkillAction.PACKET_ID]);
			}
			else
			{
				this.speedBonus = value.runSpeed * BONUS;

				value.runSpeed += this.speedBonus;

				if (!this.buff)
					this.buff = new BuffRadialView(new IconPerkBanana, 0.9, 0, gls("Скорость увеличена"), 18, 18);
				value.addBuff(this.buff);

				if (this.main)
					Connection.listen(onPacket, [PacketRoundSkillAction.PACKET_ID]);
			}

			super.hero = value;
		}

		private function onPacket(packet:PacketRoundSkillAction):void
		{
			if (packet.type != PerkClothesFactory.MINION)
				return;
			if (!this.hero || this.hero.id != packet.targetId)
				return;
			this.hero.runSpeed -= this.speedBonus;
			this.speedBonus += this.hero.runSpeed * BONUS;
			this.hero.runSpeed += this.speedBonus;
		}
	}
}