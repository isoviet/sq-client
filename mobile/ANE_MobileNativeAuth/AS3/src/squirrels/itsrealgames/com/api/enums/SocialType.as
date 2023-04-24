package squirrels.itsrealgames.com.api.enums
{
	/**
	 * ...
	 * @author Sprinter
	 */
	public class SocialType
	{
		private static var SOCIAL_NAME_VK: String = 'VK';
		private static var SOCIAL_NAME_OK: String = 'OK';
		private static var SOCIAL_NAME_NATIVE_UUID: String = 'nativeUUID';

		private var _strSocialType: String = '';

		public function SocialType(strSocial: String)
		{
			_strSocialType = strSocial;
		}

		public static function get socialVK(): SocialType
		{
			return new SocialType(SOCIAL_NAME_VK);
		}

		public static function get socialOK(): SocialType
		{
			return new SocialType(SOCIAL_NAME_OK);
		}

		public static function get socialNativeUUID(): SocialType
		{
			return new SocialType(SOCIAL_NAME_NATIVE_UUID);
		}

		public function toString(): String
		{
			return _strSocialType;
		}
	}
}
