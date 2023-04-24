package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Vec2;

	import game.gameData.OutfitData;

	public class PerkClothesSonic extends PerkClothes
	{
		public function PerkClothesSonic(hero:Hero):void
		{
			super(hero);

			this.soundOnlyHimself = true;
			this.activateSound = SOUND_ACTIVATE;
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 6;
		}

		override public function get activeTime():Number
		{
			return 3;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero || !this.hero.game)
				return;

			this.hero.body.SetLinearVelocity(this.hero.body.GetWorldVector(new b2Vec2(this.hero.heroView.direction ? -75 : 75, -35)));
			this.hero.restitution = 1;
			this.hero.resetRestitution = true;

			if (this.hero.player && 'weared_packages' in this.hero.player)
				this.hero.changeView((this.hero.player['weared_packages'] as Array).indexOf(OutfitData.AMYROSE) != -1 ? new AmyRoseMagicView() : new SonicMagicView());
			else
				this.hero.changeView(new SonicMagicView());
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero)
				return;

			this.hero.restitution = 0.1;
			this.hero.resetRestitution = true;

			this.hero.changeView();
		}
	}
}