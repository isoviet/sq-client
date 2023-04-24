package game.mainGame.gameEvent
{
	import game.gameData.OutfitData;

	public class HeroViewZombie extends HeroView
	{
		private var _isZombie:Boolean = false;

		public function HeroViewZombie(playerId:int)
		{
			super(playerId);
		}

		override public function setClothing(packagesIds:Array, accessoriesIds:Array = null):void
		{
			if (this.isZombie)
			{
				packagesIds = [OutfitData.UNDEAD];
				accessoriesIds = [];
			}

			super.setClothing(packagesIds, accessoriesIds);
		}

		public function set isZombie(value:Boolean):void
		{
			if (value == this.isZombie)
				return;
			this._isZombie = value;

			if (value)
				setClothing([OutfitData.UNDEAD]);
		}

		public function get isZombie():Boolean
		{
			return this._isZombie;
		}
	}
}