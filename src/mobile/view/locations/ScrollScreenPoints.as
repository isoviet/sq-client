package mobile.view.locations
{
	import starling.display.Sprite;

	public class ScrollScreenPoints extends Sprite
	{
		private var listPoints: Vector.<PointScroll> = new Vector.<PointScroll>();

		public function ScrollScreenPoints()
		{}

		public function appendPoint(state: int = 0): void
		{
			var point: PointScroll = new PointScroll(state);

			listPoints.push(point);
			point.alignPivot();
			point.x = (point.width * 2) * (listPoints.length - 1);
			addChild(point);
		}

		public function changeState(index: int, state: int): void
		{
			if (listPoints.length > index)
				listPoints[index].changeState(state);
		}
	}
}