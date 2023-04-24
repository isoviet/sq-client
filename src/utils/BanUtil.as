package utils
{
	import game.gameData.GameConfig;

	public class BanUtil
	{
		static public function get reasons():Array
		{
			return GameConfig.banList;
		}

		static public function getReasonById(id:int):String
		{
			return reasons[id]['title'];
		}
	}
}