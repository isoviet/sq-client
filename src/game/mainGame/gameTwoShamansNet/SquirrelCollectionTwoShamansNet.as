package game.mainGame.gameTwoShamansNet
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.GameMap;
	import game.mainGame.gameNet.SquirrelCollectionNet;

	public class SquirrelCollectionTwoShamansNet extends SquirrelCollectionNet
	{
		public function SquirrelCollectionTwoShamansNet():void
		{
			super();

			this.heroClass = HeroTwoShamans;
		}

		override public function place():void
		{
			if (!GameMap.instance)
				return;

			var position:Vector.<b2Vec2> = GameMap.instance.squirrelsPosition;
			var index:int = 0;

			if (position.length > 0)
			{
				for each (var player:Hero in this.players)
				{
					if (!(player is Hero) || player.shaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}
			if (this.shamans && this.shamans.length > 0)
			{
				if ((GameMap.instance as GameMapTwoShamansNet).redShamansPosition)
				{
					position = (GameMap.instance as GameMapTwoShamansNet).redShamansPosition;
					this.players[this.shamans[0]].position = position[0];
				}

				if ((GameMap.instance as GameMapTwoShamansNet).blueShamansPosition)
				{
					position = (GameMap.instance as GameMapTwoShamansNet).blueShamansPosition;
					this.players[this.shamans[1]].position = position[0];
				}
			}
		}

		override public function getPositionRebornSkill(heroId:int, team:int):b2Vec2
		{
			if (heroId || team) {/*unused*/}

			var shamansIds:Vector.<int> = this.shamans.slice();

			while (shamansIds.length > 0)
			{
				var index:int = Math.random() * shamansIds.length;
				if (get(shamansIds[index]) && !get(shamansIds[index]).isDead && !checkDie(get(shamansIds[index])))
					return get(shamansIds[index]).position;
				shamansIds.splice(index, 1);
			}

			return GameMap.instance.squirrelsPosition[0];
		}

		override protected function showShamanDeadAnimation():void
		{}
	}
}