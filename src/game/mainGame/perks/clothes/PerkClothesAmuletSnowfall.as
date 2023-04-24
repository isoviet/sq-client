package game.mainGame.perks.clothes
{
	import flash.display.Sprite;

	import game.NewYearFreezeAnimation;
	import sounds.GameSounds;
	import views.SnowView;

	public class PerkClothesAmuletSnowfall extends PerkClothes
	{
		static private const LEVEL_TO_SNOWFALL_20:int = 1;
		static private const LEVEL_TO_FREEZE:int = 2;
		static private const LEVEL_TO_SPEED:int = 3;

		static private const TIME:int = 5;
		static private const TIME_DOUBLE:int = 10;
		static private const SPEED_UP:int = 3;

		static private var freezes:Array = [];
		static private var freezeView:Sprite = null;

		private var speedBoosted:Boolean = false;

		public function PerkClothesAmuletSnowfall(hero:Hero):void
		{
			super(hero);

			this.activateSound = "snowwarior";

			if (freezeView == null)
				freezeView = new NewYearFreezeAnimation();
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get maxCountUse():int
		{
			return 1;
		}

		override public function get startCooldown():Number
		{
			return 30;
		}

		override public function get activeTime():Number
		{
			return this.perkLevel >= LEVEL_TO_SNOWFALL_20 ? TIME_DOUBLE : TIME;
		}

		override public function dispose():void
		{
			if (this.hero != null && this.hero.id == Game.selfId)
			{
				SnowView.fullStop(SnowView.NEW_YEAR_MODE);
				(freezeView as NewYearFreezeAnimation).dispose();
				freezes = [];
			}

			if (this.active)
			{
				SnowView.stop(SnowView.NEW_YEAR_MODE, this.hero.id);
				this.freeze = false;
			}

			super.dispose();
		}

		override protected function activate():void
		{
			super.activate();

			SnowView.start(SnowView.NEW_YEAR_MODE, this.hero.id);
			if (this.perkLevel >= LEVEL_TO_FREEZE)
			{
				this.freeze = true;
				GameSounds.play("snowfreeze");
			}
			else
				GameSounds.play("snowfall");

			if (this.perkLevel >= LEVEL_TO_SPEED)
			{
				this.hero.runSpeed += SPEED_UP;
				this.speedBoosted = true;
			}
		}

		override protected function deactivate():void
		{
			super.deactivate();

			SnowView.stop(SnowView.NEW_YEAR_MODE, this.hero.id);
			if (this.perkLevel >= LEVEL_TO_FREEZE)
				this.freeze = false;
			if (this.speedBoosted)
			{
				this.hero.runSpeed -= SPEED_UP;
				this.speedBoosted = false;
			}
		}

		private function set freeze(value:Boolean):void
		{
			if (value)
				freezes.push(this.hero.id);
			else if (freezes.indexOf(this.hero.id) != -1)
				freezes.splice(freezes.indexOf(this.hero.id), 1);
			if (freezes.length > 0)
				(freezeView as NewYearFreezeAnimation).start();
			else
				(freezeView as NewYearFreezeAnimation).stop();
		}
	}
}