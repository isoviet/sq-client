package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import landing.game.SquirrelAnimationFactory;

	public class wClothing extends Sprite
	{
		static public const VECTOR_IMAGE:int = 0;
		static public const RASTR_IMAGE:int = 1;

		private var view:Array = new Array();

		private var mappingType:int;

		private var state:int = -1;

		public function wClothing(mappingType:int = VECTOR_IMAGE):void
		{
			this.mappingType = mappingType;
		}

		public function dress(id:int):void
		{
			var item:Object = wClothesData.getItem(id, wClothesData.CATEGORY_CLOTHES);

			for (var i:int = 0; i < this.view.length; i++)
			{
				if (this.view[i]['id'] == id)
				{
					removeChild(this.view[i]['run']);
					removeChild(this.view[i]['stand']);
					this.view.splice(i, 1);

					return;
				}

				if (!wClothes.isCompatible(item['type'], this.view[i]['type']))
				{
					removeChild(this.view[i]['run']);
					removeChild(this.view[i]['stand']);
					this.view.splice(i, 1);
					i--;
				}
			}

			var standDefinition:Object = (item['class'][2]);
			var runDefinition:Object = (item['class'][1]);

			var viewStand:DisplayObject;
			var viewRun:DisplayObject;

			switch(this.mappingType)
			{
				case VECTOR_IMAGE:
						viewStand = new standDefinition();
						viewRun = new runDefinition();
						break;
				case RASTR_IMAGE:
						viewStand = new SquirrelAnimationFactory(new standDefinition());
						viewRun = new SquirrelAnimationFactory(new runDefinition(), SquirrelAnimationFactory.TYPE_RUN);
						break;
			}

			addChild(viewStand);
			addChild(viewRun);

			this.view.push({'id': id, 'type': item['type'], 'run': viewRun, 'stand': viewStand});
		}

		public function getClothesDressed():Array
		{
			var clothesIds:Array = [];

			for each (var item:Object in this.view)
				clothesIds.push(item['id']);

			return clothesIds;
		}

		public function setItems(items:Array):void
		{
			clear();

			var item:Object;
			var standDefinition:Object;
			var runDefinition:Object;
			var viewStand:DisplayObject;
			var viewRun:DisplayObject;
			for each (var id:int in items)
			{
				item = wClothesData.getItem(id, wClothesData.CATEGORY_CLOTHES);
				standDefinition = (item['class'][2]);
				runDefinition = (item['class'][1]);

				switch(this.mappingType)
				{
					case VECTOR_IMAGE:
							viewStand = new standDefinition();
							viewRun = new runDefinition();
							break;
					case RASTR_IMAGE:
							viewStand = new SquirrelAnimationFactory(new standDefinition());
							viewRun = new SquirrelAnimationFactory(new runDefinition(), SquirrelAnimationFactory.TYPE_RUN);
							break;
				}

				addChild(viewStand);
				addChild(viewRun);

				this.view.push({'id': id, 'type': item['type'], 'run': viewRun, 'stand': viewStand});
			}
		}

		public function clear():void
		{
			while (this.view.length > 0) {
				removeChild(this.view[this.view.length-1]['run']);
				removeChild(this.view[this.view.length-1]['stand']);
				this.view.pop();
			}
		}

		public function setPosition(x:int, y:int):void
		{
			this.x = x;
			this.y = y;
		}

		public function setState(state:int, frame:int = 0):void
		{
			hideAll();

			stopAll();

			switch(state)
			{
				case wHero.STATE_REST:
					for each (var item:Object in this.view)
					{
						item['stand'].visible = true;
						item['stand'].gotoAndPlay(frame);
					}
					break;
				case wHero.STATE_RUN:
					for each (item in this.view)
					{
						item['run'].visible = true;
						item['run'].gotoAndPlay(frame);
					}
					break;
				case wHero.STATE_JUMP:
					for each (item in this.view)
					{
						item['run'].visible = true;
						item['run'].gotoAndStop(frame);
					}
					break;
			}
		}

		private function hideAll():void
		{
			for each (var item:Object in this.view)
			{
				item['run'].visible = false;
				item['stand'].visible = false;
			}
		}

		private function stopAll():void
		{
			for each (var item:Object in this.view)
			{
					item['stand'].stop();
					item['run'].stop();
			}
		}
	}
}