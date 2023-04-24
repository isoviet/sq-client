package utils
{
	import flash.utils.describeType;

	public class ClassUtil
	{
		static public function isImplement(c:Class, intefacename:String):Boolean
		{
			var type:String = String(describeType(c)['factory']['implementsInterface']['@type']);
			return (type.indexOf(intefacename) > -1);
		}
	}
}