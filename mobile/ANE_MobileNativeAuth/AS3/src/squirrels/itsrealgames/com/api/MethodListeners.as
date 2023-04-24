package squirrels.itsrealgames.com.api
{
	/**
	 * ...
	 * @author Sprinter
	 */
	public class MethodListeners
	{
		private static var _instance:MethodListeners = null;

		private var listeners:Object = {};

		public function MethodListeners()
		{

		}

		public static function get instance():MethodListeners
		{
			if (_instance == null)
				_instance = new MethodListeners();
			return _instance;
		}

		private function addOnceListener(method:String, onSuccess:Function, onFail:Function):void
		{
			if (!(listeners[method] is Array))
			{
				listeners[method] = [];
			}
			listeners[method].push({onSuccess: onSuccess, onFail: onFail});
		}

		public function callMethod(method:String, value: String, success: Boolean = true): void
		{
			var arrayCallback: Array = listeners[method];

			if (arrayCallback && arrayCallback.length > 0)
			{
				for (var i: int = 0, len: int = arrayCallback.length; i < len; i++)
				{
					if (success == true)
					{
						if (arrayCallback[i].onSuccess != null)
						{
							arrayCallback[i].onSuccess(value);
						}
					}
					else
					{
						if (arrayCallback[i].onFail != null)
						{
							arrayCallback[i].onFail(value);
						}
					}
				}

			}

			listeners[method] = {};
		}

		public static function addOnceListener(method: String, onSuccess: Function, onFail: Function): void
		{
			instance.addOnceListener(method, onSuccess, onFail)
		}

		public static function callMethod(method: String, value: String, success: Boolean = true): void
		{
			instance.callMethod(method, value, success);
		}
	}
}
