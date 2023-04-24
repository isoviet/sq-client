package tape
{
	public class TapeEditData extends TapeData
	{
		public function TapeEditData(collection:Array):void
		{
			super();

			setData(collection);
		}

		override public function setData(collection:Array):void
		{
			for each (var className:Class in collection)
				addObject(new TapeEditElement(className));
		}
	}
}