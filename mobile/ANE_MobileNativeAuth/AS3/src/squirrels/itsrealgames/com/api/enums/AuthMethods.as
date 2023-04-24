package squirrels.itsrealgames.com.api.enums
{
	/**
	 * ...
	 * @author Sprinter
	 */
	public class AuthMethods
	{
		private static var METHOD_NAME_LOGIN: String = 'login';
		private static var METHOD_NAME_LOGOUT: String = 'logout';

		private var _strMethod: String = '';

		public function AuthMethods(strMethod: String)
		{
			_strMethod = strMethod;
		}

		public static function get login(): AuthMethods
		{
			return new AuthMethods(METHOD_NAME_LOGIN);
		}

		public static function get logout(): AuthMethods
		{
			return new AuthMethods(METHOD_NAME_LOGOUT);
		}

		public function toString(): String
		{
			return _strMethod;
		}
	}
}
