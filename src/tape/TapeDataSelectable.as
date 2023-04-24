package tape
{
	import tape.events.TapeElementEvent;

	public class TapeDataSelectable extends TapeData
	{
		public function TapeDataSelectable(objectClass:Class = null):void
		{
			super(objectClass);
		}

		override public function addObject(data:TapeObject):void
		{
			super.addObject(data);

			if (data is TapeSelectableObject)
				data.addEventListener(TapeElementEvent.STICKED, onStick);
		}

		override public function insertObject(data:TapeObject, index:int = 0):void
		{
			super.insertObject(data, index);

			if (data is TapeSelectableObject)
				data.addEventListener(TapeElementEvent.STICKED, onStick);
		}

		override public function pushObject(data:TapeObject):void
		{
			super.pushObject(data);

			if (data is TapeSelectableObject)
				data.addEventListener(TapeElementEvent.STICKED, onStick);
		}

		protected function onStick(e:TapeElementEvent):void
		{
			dispatchEvent(new TapeElementEvent(e.element, TapeElementEvent.STICKED));
		}
	}
}