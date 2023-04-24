package game.mainGame.gameDesertNet
{
	import game.mainGame.SquirrelGame;
	import game.mainGame.entity.IWaterSource;
	import game.mainGame.events.HollowEvent;
	import game.mainGame.gameNet.GameMapNet;

	import protocol.Connection;
	import protocol.PacketClient;

	public class GameMapDesertNet extends GameMapNet
	{
		public function GameMapDesertNet(game:SquirrelGame):void
		{
			super(game);

			this.createMirages = true;
		}

		override protected function onHollow(e:HollowEvent):void
		{
			super.onHollow(e);

			if (!(e.player is HeroDesert))
				return;
			if (!(e.player as HeroDesert).leaveAura)
				Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.DESERT_AURA, 1);
			if ((e.player as HeroDesert).halfThirst)
				Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.DESERT_ALIVE, 1);
		}

		override public function add(object:* = null):void
		{
			super.add(object);

			if (object is IWaterSource)
				(this.game.squirrels as IThirst).thirstController.add(object);
		}

		override public function remove(object:*, doDispose:Boolean = false):void
		{
			if (object == null)
				return;

			if (object is int)
			{
				if (this.objects[object] == null)
					return;

				var objectInstance:* = this.objects[object];

				if (objectInstance is IWaterSource)
					(this.game.squirrels as IThirst).thirstController.remove(objectInstance);
			}
			else
				if (object is IWaterSource)
					(this.game.squirrels as IThirst).thirstController.remove(object);

			super.remove(object, doDispose);
		}

		override public function clear():void
		{
			for (var i:int = 0, length:int = this.objects.length; i < length; i++)
			{
				if (this.objects[i] is IWaterSource)
					(this.game.squirrels as IThirst).thirstController.remove(this.objects[i]);
			}

			super.clear();
		}
	}
}