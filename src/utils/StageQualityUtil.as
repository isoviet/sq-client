package utils
{
	public class StageQualityUtil
	{

		static public function toggleQuality(value:String):void
		{
			if (Game.stage.quality.toLocaleLowerCase() == value)
				return;
			Game.stage.quality = value;
		}
	}
}