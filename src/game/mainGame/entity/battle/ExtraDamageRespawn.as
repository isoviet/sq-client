package game.mainGame.entity.battle
{
	import game.FlyingObjectAnimation;
	import game.mainGame.gameBattleNet.HeroBattle;
	import game.mainGame.gameBattleNet.achieves.AchievementMessageAnimation;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;

	public class ExtraDamageRespawn extends ItemRespawn
	{
		static private const RESPAWN_TIME:int = 40000;

		public function ExtraDamageRespawn():void
		{
			super();

			this.timeRespawn = RESPAWN_TIME;
		}

		override protected function initView():void
		{
			this.view = new FlyingObjectAnimation(new ExtraDamageImage());
			this.view.x = -18;
			this.view.y = -15;
			addChildStarling(this.view);
		}

		override protected function canPickUp(e:DetectHeroEvent):Boolean
		{
			return (e.hero is HeroBattle);
		}

		override protected function editorEffect(e:DetectHeroEvent):void
		{
			new AchievementMessageAnimation(gls("ДВОЙНОЙ УРОН"), e.hero.game.squirrels, e.hero.x + 15, e.hero.y - 42);
			(e.hero as HeroBattle).extraDamage = true;
		}

		override protected function gameEffect(hero:HeroBattle):void
		{
			if(hero && hero.game && hero.game.squirrels)
			{
				new AchievementMessageAnimation(gls("ДВОЙНОЙ УРОН"), hero.game.squirrels, hero.x + 15, hero.y - 42);
				hero.extraDamage = true;
			}
		}

		override protected function pickUpCommand(e:DetectHeroEvent):void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'GetExtraDamage': [this.id, e.hero.id]}));
		}

		override protected function respawnCommand():void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'RespawnExtraDamage': [this.id]}));
		}

		override protected function pickUpData(data:Object):Array
		{
			if ('GetExtraDamage' in data)
				return data['GetExtraDamage'];
			return null;
		}

		override protected function respawnData(data:Object):Array
		{
			if ('RespawnExtraDamage' in data)
				return data['RespawnExtraDamage'];
			return null;
		}
	}
}