package tape
{
	public class TapeShamaningData extends TapeData
	{
		public function TapeShamaningData(collection:Array):void
		{
			super();

			setData(collection);
		}

		override public function setData(collection:Array):void
		{
			for each (var className:Class in collection)
				addObject(new TapeShamaningElement(className));
		}
	}
}