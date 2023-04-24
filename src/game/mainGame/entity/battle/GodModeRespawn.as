package game.mainGame.entity.battle
{
	import game.FlyingObjectAnimation;
	import game.mainGame.gameBattleNet.HeroBattle;
	import game.mainGame.gameBattleNet.achieves.AchievementMessageAnimation;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;

	public class GodModeRespawn extends ItemRespawn
	{
		static private const RESPAWN_TIME:int = 40000;

		public function GodModeRespawn():void
		{
			super();

			this.timeRespawn = RESPAWN_TIME;
		}

		override protected function initView():void
		{
			this.view = new FlyingObjectAnimation(new GodModeImage());
			this.view.x = -12;
			this.view.y = -15;
			addChildStarling(this.view);
		}

		override protected function canPickUp(e:DetectHeroEvent):Boolean
		{
			return (e.hero is HeroBattle);
		}

		override protected function editorEffect(e:DetectHeroEvent):void
		{
			new AchievementMessageAnimation(gls("НЕУЯЗВИМОСТЬ"), e.hero.game.squirrels, e.hero.x + 15, e.hero.y - 42);
			(e.hero as HeroBattle).godMode = true;
		}

		override protected function gameEffect(hero:HeroBattle):void
		{
			if (hero && hero.game)
			{
				new AchievementMessageAnimation(gls("НЕУЯЗВИМОСТЬ"), hero.game.squirrels, hero.x + 15, hero.y - 42);
				hero.godMode = true;
			}
		}

		override protected function pickUpCommand(e:DetectHeroEvent):void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'GetGodMode': [this.id, e.hero.id]}));
		}

		override protected function respawnCommand():void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'RespawnGodMode': [this.id]}));
		}

		override protected function pickUpData(data:Object):Array
		{
			if ('GetGodMode' in data)
				return data['GetGodMode'];
			return null;
		}

		override protected function respawnData(data:Object):Array
		{
			if ('RespawnGodMode' in data)
				return data['RespawnGodMode'];
			return null;
		}
	}
}