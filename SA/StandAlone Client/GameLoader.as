package  
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.Security;

	public class GameLoader extends Sprite 
	{
		static private const V_OFFSET:int = 10;

		private var games:Vector.<GameSprite> = new Vector.<GameSprite>();

		public function GameLoader()
		{
			SAMain.execute("getAppList", { }, onList);
		}

		private function onList(data:*):void 
		{
			for each (var appId:int in data)
			{
				addGame(appId);
			}
		}

		private function addGame(appId:int):void 
		{
			var gameSprite:GameSprite = new GameSprite(appId);
			this.games.push(gameSprite);
			addChild(gameSprite);
			place();
		}

		private function place():void 
		{
			var y:int = 0;
			for each(var game:GameSprite in this.games)
			{
				game.y = y;
				y += game.height + V_OFFSET;
			}
		}
	}
}