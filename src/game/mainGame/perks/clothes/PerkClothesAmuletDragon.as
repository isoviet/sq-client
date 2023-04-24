package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	import game.mainGame.entity.magic.IceDragon;

	public class PerkClothesAmuletDragon extends PerkClothes
	{
		static private const LEVEL_TO_REDUCE_CD:int = 1;
		static private const LEVEL_TO_COLLECTION:int = 2;
		static private const LEVEL_TO_SUPER:int = 3;

		static private const CD:int = 60;
		static private const CD_REDUCED:int = 45;
		static private const CD_SUPER:int = 10;

		static private const TIME:Number = 15.0;
		static private const TIME_DOUBLE:Number = 25.0;

		private var view:MovieClip;

		public function PerkClothesAmuletDragon(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;

			this.view = new IceDragonCreateView();
			this.view.scaleX = this.view.scaleY = 0.5;
		}

		override public function get totalCooldown():Number
		{
			if (this.perkLevel >= LEVEL_TO_REDUCE_CD)
				return CD_REDUCED;
			return CD;
		}

		override public function get startCooldown():Number
		{
			if (this.perkLevel >= LEVEL_TO_SUPER)
				return CD_SUPER;
			if (this.perkLevel >= LEVEL_TO_REDUCE_CD)
				return CD_REDUCED;
			return CD;
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused)
			{
				this._active = false;
				return;
			}

			super.activate();

			(this.view as IceDragonCreateView).buttons.visible = this.hero.id == Game.selfId;
			this.hero.addView(this.view, false, false);

			if (this.hero.id != Game.selfId)
				return;

			var castObject:IceDragon = new IceDragon();
			castObject.position = this.hero.position.Copy();
			castObject.playerId = this.hero.id;
			castObject.lifeTime = this.perkLevel >= LEVEL_TO_REDUCE_CD ? TIME_DOUBLE : TIME;
			castObject.canCollection = this.perkLevel >= LEVEL_TO_COLLECTION;
			this.hero.game.map.createObjectSync(castObject, true);

			this.hero.isStoped = true;
		}
	}
}