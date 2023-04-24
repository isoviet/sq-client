package mobile.view.settings
{
	public class SettingsMobileItemStyle
	{
		private static const STYLE_CHECK: String = 'check';
		private static const STYLE_BUTTON: String = 'button';

		private var _value: String = null;

		public function SettingsMobileItemStyle(value: String)
		{
			_value = value;
		}

		public static function get CHECK(): SettingsMobileItemStyle
		{
			return new SettingsMobileItemStyle(STYLE_CHECK);
		}

		public static function get BUTTON(): SettingsMobileItemStyle
		{
			return new SettingsMobileItemStyle(STYLE_BUTTON);
		}

		public function toString(): String
		{
			return _value;
		}

		public function equals(value: SettingsMobileItemStyle): Boolean
		{
			trace(value.toString(), _value);
			return _value == value.toString();
		}
	}
}