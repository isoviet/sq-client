package game.mainGame.gameQuests
{
	public class ObjectExcavationPart extends QuestObject
	{
		public function ObjectExcavationPart(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectExcavationPartView();
			addChild(this.view);
		}

		public function drawLine(x:int, y:int):void
		{
			this.graphics.lineStyle(5, 0xFF3333, 0.5);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(x, y);
		}
	}
}