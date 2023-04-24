package squirrels.itsrealgames.com.api.enums
{
	/**
	 * ...
	 * @author Sprinter
	 */
	public class UserMethods
	{
		private static var ACTION_GET_USER: String = "getUser";

		private var _strMethod: String = '';

		public function UserMethods(strMethod: String)
		{
			_strMethod = strMethod;
		}

		public static function get getUser(): UserMethods
		{
			return new UserMethods(ACTION_GET_USER);
		}

		public function toString(): String
		{
			return _strMethod;
		}


	}
}
