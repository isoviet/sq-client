package game.mainGame.gameEvent
{
	import game.mainGame.SquirrelGame;
	import game.mainGame.gameNet.GameMapNet;

	import by.blooddy.crypto.serialization.JSON;

	public class GameMapZombieNet extends GameMapNet
	{
		public function GameMapZombieNet(game:SquirrelGame)
		{
			super(game);
		}

		override public function serialize():*
		{
			var result:Array = by.blooddy.crypto.serialization.JSON.decode(super.serialize());

			var zombieData:Array = [];
			for each (var hero:Hero in this.game.squirrels.players)
			{
				if (hero is HeroZombie)
					zombieData.push([hero.player['id'], (hero as HeroZombie).isZombie, (hero as HeroZombie).timerZombie]);
			}
			result.push({'zombieData': zombieData});
			return by.blooddy.crypto.serialization.JSON.encode(result);
		}

		override public function deserialize(data:*):void
		{
			var result:Array = by.blooddy.crypto.serialization.JSON.decode(data);
			var zombieData:Object = result.pop();
			if ("zombieData" in zombieData)
			{
				for each (var squirrelData:Array in zombieData["zombieData"])
				{
					var hero:HeroZombie = game.squirrels.get(squirrelData[0]) as HeroZombie;
					if (!hero)
						continue;
					hero.isZombie = squirrelData[1];
					hero.timerZombie = squirrelData[2];
				}
			}

			super.deserialize(by.blooddy.crypto.serialization.JSON.encode(result));
		}
	}
}