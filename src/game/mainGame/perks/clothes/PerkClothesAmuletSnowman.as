package game.mainGame.perks.clothes
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateRedress;
	import game.mainGame.entity.magic.NewYearSnowman;
	import sounds.GameSounds;

	public class PerkClothesAmuletSnowman extends PerkClothes

	{
		static private const CLOTHES_NEW_YEAR:Array = [69];

		static private const LEVEL_TO_REDUCE_CD:int = 1;
		static private const LEVEL_TO_OBJECT:int = 2;
		static private const LEVEL_TO_DURATION:int = 3;
		static private const LEVEL_TO_MAGIC:int = 4;

		static private const TIME:int = 5;
		static private const TIME_DOUBLE:int = 10;

		static private const CD:int = 60;
		static private const CD_REDUCED:int = 45;

		public function PerkClothesAmuletSnowman(hero:Hero):void
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;
		}

		override public function get totalCooldown():Number
		{
			return (this.hero && this.perkLevel >= LEVEL_TO_REDUCE_CD) ? CD_REDUCED : CD;
		}

		override public function get startCooldown():Number
		{
			return (this.hero && this.perkLevel >= LEVEL_TO_REDUCE_CD) ? CD_REDUCED : CD;
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused)
			{
				this._active = false;
				return;
			}

			super.activate();
			GameSounds.play("blizzard_create");

			this.active = false;

			if (this.perkLevel >= LEVEL_TO_MAGIC)
			{
				for each (var hero:Hero in this.hero.game.squirrels.players)
				{
					if (hero == this.hero || !hero.isSquirrel || hero.isDead || hero.inHollow)
						continue;
					hero.behaviourController.addState(new StateRedress(this.perkLevel >= LEVEL_TO_DURATION ? TIME_DOUBLE : TIME, CLOTHES_NEW_YEAR, true))
				}
			}

			if (this.hero.id != Game.selfId)
				return;

			var castObject:NewYearSnowman = new NewYearSnowman();
			castObject.angle = this.hero.angle;
			var dirX:b2Vec2 = this.hero.rCol1;
			dirX.Multiply(this.hero.heroView.direction ? -5.0 : 5.0);
			var dirY:b2Vec2 = this.hero.rCol2;
			dirY.Multiply(-1);
			dirX.Add(dirY);
			castObject.position = b2Math.AddVV(this.hero.position, dirX);
			castObject.playerId = this.hero.id;
			castObject.lifeTime = this.perkLevel >= LEVEL_TO_DURATION ? TIME_DOUBLE : TIME;
			castObject.isPersonal = this.perkLevel >= LEVEL_TO_OBJECT;
			castObject.size = this.perkLevel >= LEVEL_TO_DURATION ? 6.0 : 5.0;
			this.hero.game.map.createObjectSync(castObject, true);
		}
	}
}