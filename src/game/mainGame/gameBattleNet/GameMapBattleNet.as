package game.mainGame.gameBattleNet
{
	import flash.geom.Point;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IGameObject;
	import game.mainGame.entity.editor.BlueTeamBody;
	import game.mainGame.entity.editor.RedTeamBody;
	import game.mainGame.gameNet.GameMapNet;
	import headers.HeaderShort;

	import by.blooddy.crypto.serialization.JSON;

	public class GameMapBattleNet extends GameMapNet
	{
		public function GameMapBattleNet(game:SquirrelGame):void
		{
			super(game);
		}

		public function get redSquirrelsPosition():Vector.<b2Vec2>
		{
			var players:Array = get(RedTeamBody);

			var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var player:IGameObject in players)
				positions.push(player.position);

			return positions;
		}

		public function get blueSquirrelsPosition():Vector.<b2Vec2>
		{
			var players:Array = get(BlueTeamBody);

			var positions:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for each (var player:IGameObject in players)
				positions.push(player.position);

			return positions;
		}

		override public function serialize():*
		{
			var result:Array = by.blooddy.crypto.serialization.JSON.decode(super.serialize());

			var frags:Array = [];

			for each (var hero:Hero in this.game.squirrels.players)
				frags.push([hero.id, hero.frags]);

			result.push({"frags": frags});
			return by.blooddy.crypto.serialization.JSON.encode(result);
		}

		override public function deserialize(data:*):void
		{
			var result:Array = by.blooddy.crypto.serialization.JSON.decode(data);
			var frags:Object = result.pop();
			if (!("frags" in frags))
			{
				super.deserialize(data);
				this.game.shift = new Point(Math.min(-(this.size.x - Config.GAME_WIDTH) / 2, 0), 0);
				return;
			}

			super.deserialize(by.blooddy.crypto.serialization.JSON.encode(result));
			this.game.shift = new Point(Math.min(-(this.size.x - Config.GAME_WIDTH) / 2, 0), 0);

			for each (var fragData:Array in frags["frags"])
			{
				var hero:Hero = game.squirrels.get(fragData[0]);
				if (!hero)
					continue;

				hero.frags = fragData[1];
			}

			HeaderShort.setPlayersFrags(frags["frags"]);
		}
	}
}