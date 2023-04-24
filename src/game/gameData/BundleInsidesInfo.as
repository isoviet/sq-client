package game.gameData
{
	public class BundleInsidesInfo
	{
		private var _imageClass: Class = null;
		private var _description: String = null;

		public function BundleInsidesInfo(imageClass: Class, description: String)
		{
			_imageClass = imageClass;
			_description = description;
		}

		public function get imageClass(): Class
		{
			return _imageClass;
		}

		public function get description(): String
		{
			return _description;
		}
	}
}