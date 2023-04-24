package game.mainGame.gameIceland
{
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.iceland.NYSnowGenerator;
	import game.mainGame.gameNet.GameMapNet;

	public class GameMapIcelandNet extends GameMapNet
	{
		public var snowGenerators:Array = [];

		public function GameMapIcelandNet(game:SquirrelGame):void
		{
			super(game);
		}

		override protected function otherCheck(object:*):void
		{
			if (!(object is NYSnowGenerator))
				return;
			(object as NYSnowGenerator).index = this.snowGenerators.length;
			this.snowGenerators.push(object);
		}

		override public function deserialize(data:*):void
		{
			this.snowGenerators = [];

			super.deserialize(data);
		}

		protected function offerElements():void
		{}
	}
}