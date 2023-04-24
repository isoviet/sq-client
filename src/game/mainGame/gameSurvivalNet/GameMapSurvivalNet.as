package game.mainGame.gameSurvivalNet
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.editor.BlackShamanBody;
	import game.mainGame.gameNet.GameMapNet;

	public class GameMapSurvivalNet extends GameMapNet
	{
		public function GameMapSurvivalNet(game:SquirrelGame):void
		{
			super(game);
		}

		public function get blackShamansPosition():Vector.<b2Vec2>
		{
			var players:Array = get(BlackShamanBody);

			var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var player:IGameObject in players)
				positions.push(player.position);

			return positions;
		}
	}
}