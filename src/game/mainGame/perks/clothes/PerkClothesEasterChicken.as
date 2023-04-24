package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;

	import game.mainGame.entity.magic.EasterChicken;

	public class PerkClothesEasterChicken extends PerkClothes
	{
		private var view:MovieClip;

		public function PerkClothesEasterChicken(hero:Hero):void
		{
			super(hero);
			this.code = PerkClothesFactory.PERK_CHICKEN;
		}

		override public function get totalCooldown():Number
		{
			return 15;
		}

		override protected function activate():void
		{
			if (!this.hero.game || this.hero.game.paused || this.hero.isDead || this.hero.inHollow)
			{
				this.active = false;
				return;
			}

			super.activate();

			if (this.hero.id != Game.selfId)
				return;

			var size:Point = this.hero.game.map.size;
			var points:Array = [];
			for (var i:int = 0; i < 3; i++)
				for (var j:int = 0; j < 2; j++)
					points.push(new Point(size.x * (i + Math.random()) / 3, size.y * (j + Math.random()) / 2));
			points.sort(sort);

			this.view = new EasterChickenCreate();
			this.view.addEventListener(Event.COMPLETE, onChange);
			this.hero.heroView.addChild(this.view);

			var castObject:EasterChicken = new EasterChicken();
			castObject.position = this.hero.position.Copy();
			castObject.points = points;
			castObject.playerId = this.hero.id;
			this.hero.game.map.createObjectSync(castObject, true);

			this.active = false;
		}

		private function onChange(e:Event = null):void
		{
			if (this.view && this.view.parent)
			{
				this.view.removeEventListener(Event.CHANGE, onChange);
				this.view.parent.removeChild(this.view);
			}
			this.view = null;
		}

		private function sort(a:Point, b:Point):int
		{
			return (Math.sin(a.x) > Math.sin(b.x)) ? 1 : -1;
		}
	}
}