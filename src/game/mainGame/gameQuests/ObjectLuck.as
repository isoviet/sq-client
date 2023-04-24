package game.mainGame.gameQuests
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.GlowFilter;

	import Box2D.Common.Math.b2Vec2;

	public class ObjectLuck extends QuestObject
	{
		static private const RADIUS:int = 8;
		static private const MAX_RADIUS:int = 40;

		static private var compassView:MovieClip = null;
		static private var filter:GlowFilter = null;

		private var explode:MovieClip = null;

		public function ObjectLuck(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectExcavationView();
			this.view.x = -12;
			this.view.y = -16;
			addChild(this.view);

			if (!compassView)
			{
				compassView = new IconLuckView();
				compassView.x = -19;
				compassView.y = -80;

				filter = new GlowFilter(0x0000ff, 1, 10, 10, 8, 1, true);
				compassView.filters = [filter];
			}

			this.visible = false;
			this.hero.addChild(compassView);
		}

		override public function dispose():void
		{
			this.hero.removeChild(compassView);

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.activated)
				return;

			var pos:b2Vec2 = this.hero.position.Copy();
			pos.Subtract(this.position);

			var value:Number = Math.min(MAX_RADIUS, pos.Length()) / MAX_RADIUS;
			filter.color = 255 * value + int((1 - value) * 255) * 256 * 256;
			compassView.filters = [filter];
			compassView.visible = !this.hero.isDead && !this.hero.inHollow;

			if (pos.Length() >= RADIUS)
				return;
			this.visible = true;
			this.activated = true;
			compassView.visible = false;

			this.explode = new QuestItemExplode();
			this.explode.addEventListener(Event.CHANGE, onChange);
			addChild(this.explode);
		}

		private function onChange(e:Event):void
		{
			if (!this.explode || !contains(this.explode))
				return;
			this.explode.removeEventListener(Event.CHANGE, onChange);
			removeChild(this.explode);
			this.explode = null;
		}
	}
}