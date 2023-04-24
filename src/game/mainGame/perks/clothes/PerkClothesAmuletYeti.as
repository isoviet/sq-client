package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateStun;

	public class PerkClothesAmuletYeti extends PerkClothes
	{
		static private const LEVEL_TO_RADIUS:int = 1;
		static private const LEVEL_TO_EXTRA_USE:int = 2;

		static private const RADIUS:Number = 8.0;
		static private const RADIUS_LARGE:int = 12.0;

		static private const COUNT:int = 1;
		static private const COUNT_EXTRA:int = 2;

		private var view:MovieClip;

		public function PerkClothesAmuletYeti(hero:Hero)
		{
			super(hero);

			this.activateSound = SOUND_APPEARANCE;

			this.view = new NewYearYetiView();
			this.view.stop();
			this.view.scaleX = this.view.scaleY = 1.2;
			this.view.addEventListener("Stomp", onStomp);
			this.view.addEventListener(Event.CHANGE, onEnd);
		}

		override public function get maxCountUse():int
		{
			return (this.hero && this.perkLevel >= LEVEL_TO_EXTRA_USE) ? COUNT_EXTRA : COUNT;
		}

		override public function get totalCooldown():Number
		{
			return 90;
		}

		override public function get available():Boolean
		{
			return super.available && !this.active && !this.hero.heroView.fly;
		}

		override public function dispose():void
		{
			super.dispose();

			this.view = null;
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game || this.hero.game.paused)
			{
				this.active = false;
				return;
			}

			var position:Point = this.hero.getPosition();
			this.view.x = position.x;
			this.view.y = position.y + 20;
			this.hero.game.map.userBottomSprite.addChild(this.view);

			this.view.gotoAndPlay(0);

			this.active = false;
		}

		private function onStomp(e:Event):void
		{
			if (!this.hero || !this.hero.game || !this.hero.game.squirrels)
				return;
			var radius:Number = (this.hero && this.perkLevel >= LEVEL_TO_RADIUS) ? RADIUS_LARGE : RADIUS;

			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero == this.hero)
					continue;
				var pos:b2Vec2 = hero.position.Copy();
				pos.Subtract(new b2Vec2(this.view.x / Game.PIXELS_TO_METRE, this.view.y / Game.PIXELS_TO_METRE));
				if (pos.Length() > radius)
					continue;

				hero.behaviourController.addState(new StateStun(3));
			}
		}

		private function onEnd(e:Event):void
		{
			if (!this.view)
				return;

			this.view.stop();

			if (this.hero.game.map.userBottomSprite.contains(this.view))
				this.hero.game.map.userBottomSprite.removeChild(this.view);
		}
	}
}