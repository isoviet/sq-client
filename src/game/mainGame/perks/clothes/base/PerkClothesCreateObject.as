package game.mainGame.perks.clothes.base
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.simple.GameBody;
	import game.mainGame.perks.clothes.PerkClothes;

	public class PerkClothesCreateObject extends PerkClothes
	{
		public function PerkClothesCreateObject(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
			this.soundOnlyHimself = true;
		}

		protected function get objectClass():Class
		{
			return null;
		}

		protected function get dX():Number
		{
			return 0;
		}

		protected function get dY():Number
		{
			return 1;
		}

		protected function setObjectParams(castObject:GameBody):void
		{}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused)
			{
				this._active = false;
				return;
			}

			super.activate();

			if (!this.isSelf)
				return;

			var castObject:GameBody = new this.objectClass();
			castObject.angle = this.hero.angle;
			var dirX:b2Vec2 = this.hero.rCol1;
			dirX.Multiply(this.hero.heroView.direction ? -this.dX : this.dX);
			var dirY:b2Vec2 = this.hero.rCol2;
			dirY.Multiply(this.dY);
			dirX.Add(dirY);
			castObject.position = b2Math.AddVV(this.hero.position, dirX);
			castObject.playerId = this.hero.id;
			setObjectParams(castObject);
			this.hero.game.map.createObjectSync(castObject, true);
		}
	}
}