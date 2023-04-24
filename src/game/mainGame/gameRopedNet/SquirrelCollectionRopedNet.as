package game.mainGame.gameRopedNet
{
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.GameMap;
	import game.mainGame.entity.joints.JointRopeToSquirrel;
	import game.mainGame.gameNet.SquirrelCollectionNet;

	public class SquirrelCollectionRopedNet extends SquirrelCollectionNet
	{
		private var isSnake:Boolean;
		private var isRoped:Boolean;

		public var roped:Array;

		public function SquirrelCollectionRopedNet(isSnake:Boolean = false, isRoped:Boolean = true):void
		{
			super();

			this.isSnake = isSnake;
			this.isRoped = isRoped;
		}

		override public function place():void
		{
			if (!this.isRoped)
			{
				super.place();
				return;
			}

			for each (var player:Hero in this.players)
			{
				if (player.shaman)
					continue;

				player.position = GameMap.instance.squirrelsPosition[0];
			}

			var position:Vector.<b2Vec2> = GameMap.instance.shamansPosition;
			var index:int = 0;

			if (position.length != 0)
			{
				for each (player in this.players)
				{
					if (!player.shaman)
						continue;

					player.position = position[index++];
					if (index == position.length)
						index = 0;
				}
			}

			setRopes();
		}

		private function setRopes():void
		{
			this.roped = [];
			var playersIds:Array = [];

			for each (var player:Hero in this.players)
			{
				if (!player.shaman)
					playersIds.push(player.id);
			}

			playersIds.sort(Array.NUMERIC);

			if (this.isSnake)
				for (var i:int = 0; i < playersIds.length; i++)
				{
					get(playersIds[i]).position = GameMap.instance.squirrelsPosition[0];
					if (i + 1 < playersIds.length)
						createRope(playersIds[i], playersIds[i + 1]);
				}
			else
				for (i = 0; i < playersIds.length; i += 2)
				{
					if (i + 1 >= playersIds.length)
						break;

					createRope(playersIds[i], playersIds[i + 1]);

					if (GameMap.instance.squirrelsPosition.length >= 2)
						get(playersIds[i + 1]).position = GameMap.instance.squirrelsPosition[1];
				}
		}

		private function createRope(self:int, other:int):void
		{
			var index: int = 0;

			if (!get(self) || !get(other))
				return;

			var joint:JointRopeToSquirrel = new JointRopeToSquirrel(self == Game.selfId || other == Game.selfId);

			if (self == Game.selfId)
			{
				index =  this.getChildIndex(get(self)) - 1;
				if (index < 0)
					index = 0;

				this.setChildIndex(get(other), index);
				this.roped.push(other);
			}

			if (other == Game.selfId)
			{
				index = this.getChildIndex(get(other)) - 1;
				if (index < 0)
					index = 0;

				this.setChildIndex(get(self), index);
				this.roped.push(self);
			}
			joint.hero0 = get(self);
			joint.hero1 = get(other);
			GameMap.instance.add(joint);
		}
	}
}