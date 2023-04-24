package game.mainGame.perks.clothes
{
	import game.gameData.OutfitData;

	public class PerkClothesBumblebee extends PerkClothesTranfsform
	{
		public function PerkClothesBumblebee(hero:Hero):void
		{
			super(hero);

			this.activateSound = "transform";
		}

		override protected function initMovies():void
		{
			if (this.transformIn && this.transformOut && this.transformView)
				return;
			if (this.hero.player && ('weared_packages' in this.hero.player) && (this.hero.player['weared_packages'] as Array).indexOf(OutfitData.ARCEE) != -1)
			{
				this.transformIn = new ArceeTransformIn();
				this.transformOut = new ArceeTransformOut();
				this.transformView = new ArceeTransformStand();
			}
			else
			{
				this.transformIn = new BumblebeeTransformIn();
				this.transformOut = new BumblebeeTransformOut();
				this.transformView = new BumblebeeTransformStand();
			}
		}
	}
}