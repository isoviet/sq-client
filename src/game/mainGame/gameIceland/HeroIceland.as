package game.mainGame.gameIceland
{
	import Box2D.Dynamics.b2World;

	import game.gameData.OutfitData;

	public class HeroIceland extends Hero
	{
		private var _haveSnow:Boolean = false;

		public function HeroIceland(playerId:int, world:b2World, x:int = 0, y:int = 0):void
		{
			super(playerId, world, x, y);
		}

		public function get haveSnow():Boolean
		{
			return this._haveSnow;
		}

		public function set haveSnow(value:Boolean):void
		{
			this._haveSnow = value;

			if (!this.heroView)
				return;

			if (value)
				this.heroView.setClothing((this.player['weared_packages'] as Array).concat([OutfitData.SNOWBALL]), this.player['weared_accessories']);
			else
				this.heroView.setClothing(this.player['weared_packages'], this.player['weared_accessories']);
		}
	}
}