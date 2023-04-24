package tape
{
	public class TapeViralityQuestView extends TapeView
	{
		public function TapeViralityQuestView(socialType:String)
		{
			super(1, 6, 240, 0, 10, 8, 445, 50);

			setData(new TapeViralityQuestData(socialType));
		}

		public function get selfData():TapeViralityQuestData
		{
			return this.data as TapeViralityQuestData;
		}

		public function updateStep(id:uint, complete:Boolean):void
		{
			this.selfData.updateStep(id, complete);
		}

		override protected function placeButtons():void
		{}

		override protected function updateButtons():void
		{}
	}
}