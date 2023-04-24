package game.mainGame.gameQuests
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.gameNet.GameMapNet;

	import utils.FiltersUtil;

	public class ObjectExcavation extends QuestObject
	{
		static private const COUNT:int = 3;

		private var objects:Vector.<QuestObject> = new Vector.<QuestObject>();
		private var explode:MovieClip = null;

		public function ObjectExcavation(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectExcavationView();
			this.view.x = -12;
			this.view.y = -16;
			this.view.filters = FiltersUtil.GREY_FILTER;
			addChild(this.view);

			this.hero.addEventListener(Hero.EVENT_PERK_QUEST, onEvent);
		}

		override public function dispose():void
		{
			this.hero.removeEventListener(Hero.EVENT_PERK_QUEST, onEvent);

			super.dispose();
		}

		private function onEvent(e:Event):void
		{
			var pos:b2Vec2 = this.hero.position.Copy();
			var object:ObjectExcavationPart = new ObjectExcavationPart(null);
			object.position = pos;
			(this.hero.game.map as GameMapNet).add(object);

			for (var i:int = 0; i < this.objects.length; i++)
				object.drawLine(this.objects[i].x - object.x, this.objects[i].y - object.y);
			this.objects.push(object);

			if (this.objects.length < COUNT)
				return;
			this.hero.removeEventListener(Hero.EVENT_PERK_QUEST, onEvent);

			for (i = 0; i < this.objects.length; i++)
			{
				var point1:b2Vec2 = this.objects[i].position;
				var point2:b2Vec2 = this.objects[(i + 1) % COUNT].position;
				var point3:b2Vec2 = this.objects[(i + 2) % COUNT].position;

				var value1:Number = (point2.x - point1.x) * (this.position.y - point1.y) - (point2.y - point1.y) * (this.position.x - point1.x);
				var value2:Number = (point2.x - point1.x) * (point3.y - point1.y) - (point2.y - point1.y) * (point3.x - point1.x);

				if (value1 * value2 <= 0)
					return;
			}
			this.activated = true;
			this.view.filters = [];

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