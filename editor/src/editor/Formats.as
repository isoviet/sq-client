package editor
{
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	public class Formats
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Arial";
				font-size: 12px;
				color: #313436;
			}
			a {
				text-decoration: underline;
				color: #0877c2;
				font-size: 12px;
			}
			a:hover {
				text-decoration: none;
			}
			.bold {
				color: #e0347e;
				font-weight: bold;
			}
		]]>).toString();

		static private var _style:StyleSheet;

		static public const FORMAT_EDIT:TextFormat = new TextFormat("Arial", 12, 0x313436);
		static public const FORMAT_EDIT_BOLD:TextFormat = new TextFormat("Arial", 12, 0x313436, true);

		static public function get style():StyleSheet
		{
			if (!_style)
			{
				_style = new StyleSheet();
				_style.parseCSS(CSS);
			}

			return _style;
		}
	}
}