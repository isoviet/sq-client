package utils
{
	public class HtmlTool
	{
		static public function image(src:String, id:String = "", width:String = "", height:String = "", align:String = "", hspace:String = "", vspace:String = ""):String
		{
			return tag("img", attr("id", id) + attr("src", src) + attr("width", width) + attr("height", height) + attr("align", align) + attr("hspace", hspace) + attr("vspace", vspace)) + closeTag("img");
		}

		static public function anchor(inside:String, href:String = "", target:String = ""):String
		{
			return tag("a", attr("href", href) + attr("target", target)) + inside + closeTag("a");
		}

		static public function span(inside:String = "", sClass:String = ""):String
		{
			return tag("span", attr("class", sClass)) + inside + closeTag("span");
		}

		static public function tag(name:String, attrib:String = ""):String
		{
			return "<" + name + " " + attrib + ">";
		}

		static public function closeTag(name:String):String
		{
			return "</" + name + ">";
		}

		static public function attr(name:String, value:String):String
		{
			if (value != "")
				return name + "=\"" + value + "\" ";
			return "";
		}
	}
}