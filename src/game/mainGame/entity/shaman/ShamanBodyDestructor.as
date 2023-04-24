package game.mainGame.entity.shaman
{
	import game.mainGame.Cast;
	import game.mainGame.entity.cast.BodyDestructor;
	import game.mainGame.entity.cast.ICastChange;

	public class ShamanBodyDestructor extends BodyDestructor implements ICastChange
	{
		private var _cast:Cast = null;
		private var oldCastRadius:Number;

		public function set cast(cast:Cast):void
		{
			this._cast = cast;
		}

		public function setCastParams():void
		{
			this.oldCastRadius = this._cast.castRadius;

			this._cast.castRadius = 0;
		}

		public function resetCastParams():void
		{
			if (!this._cast)
				return;

			this._cast.castRadius = this.oldCastRadius;
		}
	}
}