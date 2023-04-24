package utils
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.system.Capabilities;

	public class FlashUtil
	{
		static public function get flashVersions():Object
		{
			var versionString:String = Capabilities.version;
			var pattern:RegExp = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/;
			var result:Object = pattern.exec(versionString);

			var versions:Object = {};
			versions['major'] = result[2];
			versions['minor'] = result[3];
			return versions;
		}

		static public function stopAllAnimation(object:MovieClip):void
		{
			for (var i:int = 0; i < object.numChildren; i++)
			{
				var child:DisplayObject = object.getChildAt(i);
				if (!(child is MovieClip))
					continue;
				(child as MovieClip).stop();
				stopAllAnimation(child as MovieClip);
			}
		}
	}
}