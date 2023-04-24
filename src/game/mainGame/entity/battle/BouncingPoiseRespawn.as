package game.mainGame.entity.battle
{
	import game.FlyingObjectAnimation;
	import game.mainGame.CastItem;
	import game.mainGame.events.CastEvent;
	import game.mainGame.gameBattleNet.HeroBattle;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;

	public class BouncingPoiseRespawn extends ItemRespawn
	{
		static private const RESPAWN_TIME:int = 15000;
		static public const SPIKE_INC:int = 5;

		public function BouncingPoiseRespawn():void
		{
			super();
			this.timeRespawn = RESPAWN_TIME;
		}

		override protected function initView():void
		{
			this.view = new FlyingObjectAnimation(new BouncingPoiseRespawnImage());
			this.view.x = -27;
			this.view.y = -17;
			this.view.object.filters = [];
			addChildStarling(this.view);
		}

		override protected function canPickUp(e:DetectHeroEvent):Boolean
		{
			var spikeItem:CastItem = e.hero.castItems.getItem(BouncingPoise, CastItem.TYPE_ROUND);
			var maxCount:Boolean = ((spikeItem != null) && (spikeItem.count >= CastItem.getMax(BouncingPoise)));

			return !maxCount;
		}

		override protected function editorEffect(e:DetectHeroEvent):void
		{
			e.hero.castItems.add(new CastItem(BouncingPoise, CastItem.TYPE_ROUND, SPIKE_INC));
			if (this.gameInst.cast.castObject == null)
				this.gameInst.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, BouncingPoise));
		}

		override protected function gameEffect(hero:HeroBattle):void
		{
			if (hero != Hero.self)
				return;

			Hero.self.castItems.add(new CastItem(BouncingPoise, CastItem.TYPE_ROUND, SPIKE_INC));
			if (this.gameInst.cast.castObject == null)
				this.gameInst.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, BouncingPoise));
		}

		override protected function pickUpCommand(e:DetectHeroEvent):void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'GetBouncingPoise': [this.id, e.hero.id]}));
			if (e.hero.id == Game.selfId)
				Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.PICKUP_POISE, 1);
		}

		override protected function respawnCommand():void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'RespawnBouncingPoise': [this.id]}));
		}

		override protected function pickUpData(data:Object):Array
		{
			if ('GetBouncingPoise' in data)
				return data['GetBouncingPoise'];
			return null;
		}

		override protected function respawnData(data:Object):Array
		{
			if ('RespawnBouncingPoise' in data)
				return data['RespawnBouncingPoise'];
			return null;
		}
	}
}