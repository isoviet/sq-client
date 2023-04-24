package game.mainGame.entity.battle
{
	import game.FlyingObjectAnimation;
	import game.mainGame.gameBattleNet.HeroBattle;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;

	public class MedicKitRespawn extends ItemRespawn
	{
		static private const RESPAWN_TIME:int = 20000;

		static public const HEAL_INC:int = 5;

		public function MedicKitRespawn():void
		{
			super();

			this.timeRespawn = RESPAWN_TIME;
		}

		override protected function initView():void
		{
			this.view = new FlyingObjectAnimation(new MedicKitImage());
			this.view.x = -20;
			this.view.y = -17;
			addChildStarling(this.view);
		}

		override protected function canPickUp(e:DetectHeroEvent):Boolean
		{
			var maxCount:Boolean = (!(e.hero is HeroBattle) || (e.hero as HeroBattle).health >= 10);

			return !maxCount;
		}

		override protected function editorEffect(e:DetectHeroEvent):void
		{
			(e.hero as HeroBattle).health += HEAL_INC;
		}

		override protected function gameEffect(hero:HeroBattle):void
		{
			hero.health += HEAL_INC;
		}

		override protected function pickUpCommand(e:DetectHeroEvent):void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'GetMedicKit': [this.id, e.hero.id]}));
			if (e.hero.id == Game.selfId)
				Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.PICKUP_HEAL, 1);
		}

		override protected function respawnCommand():void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'RespawnMedicKit': [this.id]}));
		}

		override protected function pickUpData(data:Object):Array
		{
			if ('GetMedicKit' in data)
				return data['GetMedicKit'];
			return null;
		}

		override protected function respawnData(data:Object):Array
		{
			if ('RespawnMedicKit' in data)
				return data['RespawnMedicKit'];
			return null;
		}
	}
}