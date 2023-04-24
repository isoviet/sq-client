package utils.anchorHelp
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public final class AnchorHelpManager
	{
		private static var _instance: AnchorHelpManager = null;
		private var anchors: Object = {};
		private var clearPoints: Point = new Point();

		public static function get instance(): AnchorHelpManager
		{
			if (!_instance)
				_instance = new AnchorHelpManager();

			return _instance;
		}

		public function AnchorHelpManager()
		{
		}

		public function addAnchorObject(anchorName: AnchorEnum, obj: DisplayObject): void
		{
			anchors[anchorName.toString()] = obj;
		}

		public function getAnchorPosition(anchorName: AnchorEnum): Point
		{
			var item: * = anchors[anchorName.toString()];
			clearPoints.setTo(0, 0);
			if (item)
				return (item as DisplayObject).localToGlobal(clearPoints);

			return clearPoints;
		}

		public function removeAnchorObject(anchorName: AnchorEnum): void
		{
			if (anchors[anchorName.toString()])
				delete anchors[anchorName.toString()];
		}

	}
}