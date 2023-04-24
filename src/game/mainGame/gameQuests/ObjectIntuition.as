package game.mainGame.gameQuests
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	public class ObjectIntuition extends QuestObject
	{
		static private const RADIUS:int = 12;
		static private var scanView:MovieClip = null;

		private var explode:MovieClip = null;

		public function ObjectIntuition(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectExcavationView();
			this.view.x = -12;
			this.view.y = -16;
			addChild(this.view);

			this.visible = false;
			this.hero.addEventListener(Hero.EVENT_PERK_QUEST, onEvent);
		}

		override public function dispose():void
		{
			this.hero.removeEventListener(Hero.EVENT_PERK_QUEST, onEvent);

			super.dispose();
		}

		private function onEnd(e:Event):void
		{
			if (this.hero)
				this.hero.changeView();
			scanView.removeEventListener(Event.CHANGE, onEnd);
			scanView = null;
		}

		private function onEvent(e:Event):void
		{
			var pos:b2Vec2 = this.hero.position.Copy();
			pos.Subtract(this.position);

			if (!scanView)
			{
				scanView = new IconIntuitionView();
				scanView.y -= 20;
				scanView.addEventListener(Event.CHANGE, onEnd);
				this.hero.addView(scanView, true);
			}

			if (pos.Length() >= RADIUS)
				return;
			this.visible = true;
			this.activated = true;

			this.explode = new QuestItemExplode();
			this.explode.addEventListener(Event.CHANGE, onChange);
			addChild(this.explode);

			this.hero.removeEventListener(Hero.EVENT_PERK_QUEST, onEvent);
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