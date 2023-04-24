package tape.list
{
	public class ListPlayersView extends ListView
	{
		public function ListPlayersView():void
		{
			super(17);
		}

		override protected function updateSprite():void
		{
			super.updateSprite();

			if (this.data == null)
				return;

			var counter:int = 1;

			for (var i:int = 0; i < this.data.objects.length; i++)
			{
				if (!this.data.objects[i].canAdd)
					continue;

				(this.data.objects[i] as INumbered).number = counter;

				counter++;
			}
		}
	}
}