package tape
{
	import game.mainGame.ISerialize;
	import game.mainGame.entity.EntityFactory;
	import tape.TapeShamanView;

	public class TapeShamaning extends TapeShamanView implements ISerialize
	{
		public function TapeShamaning(collection:Array):void
		{
			super(16, 2, 32, 8, false);

			loadItems(collection);
		}

		public function getIds():Array
		{
			var result:Array = [];

			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				var element:TapeShamaningElement = this.data.objects[i] as TapeShamaningElement;
				var className:Class = element.className;
				if (!element.state)
					continue;
				var id:int = EntityFactory.getId(className);
				result.push(id);
			}

			return result;
		}

		public function reset():void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				var element:TapeShamaningElement = this.data.objects[i] as TapeShamaningElement;
				element.state = false;
			}
		}

		public function load(ids:Array):void
		{
			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				var element:TapeShamaningElement = this.data.objects[i] as TapeShamaningElement;
				element.state = false;
				for (var j:int = 0; j < ids.length; j++)
				{
					var className:Class = EntityFactory.getEntity(ids[j]);
					if (className != element.className)
						continue;

					element.state = true;
				}
			}

			placeButtons();
			update();
		}

		public function serialize():*
		{
			return getIds();
		}

		public function deserialize(data:*):void
		{}

		public function loadItems(collection:Array):void
		{
			setData(new TapeShamaningData(collection));
		}
	}
}