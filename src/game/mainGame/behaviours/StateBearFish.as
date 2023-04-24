package game.mainGame.behaviours
{
	import game.mainGame.gameBattleNet.BuffRadialView;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class StateBearFish extends HeroState
	{
		protected var buff:BuffRadialView = null;
		protected var showBuff:Boolean = true;

		protected var speedBonus:Number = 0;

		protected var bonus:Number = 0;

		protected var _active:Boolean = false;
		protected var effect: ParticlesEffect;

		public function StateBearFish(time:Number, bonus:Number, showBuff:Boolean = true)
		{
			super(time);

			this.bonus = bonus;
			this.showBuff = showBuff;
		}

		public function set active(value:Boolean):void
		{
			if (value == this._active)
				return;
			this._active = value;

			if (value)
			{
				this.effect = this.hero.applyEffect(CollectionEffects.EFFECT_BEAR_SWIM);
			}
			else
			{
				this.hero.disableEffect(CollectionEffects.EFFECT_BEAR_SWIM);
				this.effect = null;
			}
		}

		override public function set hero(value:Hero):void
		{
			if (value == null && this.hero != null)
			{
				this.hero.swimFactor -= this.speedBonus;

				if (this.showBuff)
					this.hero.removeBuff(this.buff);
				this.active = false;
			}
			else
			{
				this.speedBonus = value.swimFactor * this.bonus;

				value.swimFactor += this.speedBonus;

				if (!this.buff)
					this.buff = new BuffRadialView(new IconPerkAquaMan(), 0.9, 0, gls("Увеличение скорости в воде"), 18, 18);
				if (this.showBuff)
					value.addBuff(this.buff);
			}

			super.hero = value;
		}

		override public function update(timestep:Number):void
		{
			super.update(timestep);

			this.active = this.hero.swim;
		}
	}
}