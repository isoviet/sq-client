package game.mainGame.entity.battle
{
	import flash.display.MovieClip;

	import game.FlyingObjectAnimation;
	import game.mainGame.CastItem;
	import game.mainGame.events.CastEvent;
	import game.mainGame.gameBattleNet.HeroBattle;
	import sensors.events.DetectHeroEvent;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;

	public class GhostPoiseRespawn extends ItemRespawn
	{
		static private const RESPAWN_TIME:int = 15000;
		static public const SPIKE_INC:int = 3;

		public function GhostPoiseRespawn():void
		{
			super();

			this.timeRespawn = RESPAWN_TIME;
		}

		override protected function initView():void
		{
			this.view = new FlyingObjectAnimation(new GhostPoiseImage() as MovieClip);
			this.view.x = -16;
			this.view.y = -16;
			this.view.object.filters = [];
			this.view.object.play();
			addChildStarling(this.view);
		}

		override protected function canPickUp(e:DetectHeroEvent):Boolean
		{
			var spikeItem:CastItem = e.hero.castItems.getItem(GhostPoise, CastItem.TYPE_ROUND);
			var maxCount:Boolean = ((spikeItem != null) && (spikeItem.count >= CastItem.getMax(GhostPoise)));

			return !maxCount;
		}

		override protected function editorEffect(e:DetectHeroEvent):void
		{
			e.hero.castItems.add(new CastItem(GhostPoise, CastItem.TYPE_ROUND, SPIKE_INC));
			if (this.gameInst.cast.castObject == null)
				this.gameInst.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, GhostPoise));
		}

		override protected function gameEffect(hero:HeroBattle):void
		{
			if (hero != Hero.self)
				return;
			Hero.self.castItems.add(new CastItem(GhostPoise, CastItem.TYPE_ROUND, SPIKE_INC));
			if (this.gameInst.cast.castObject == null)
				this.gameInst.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, GhostPoise));
		}

		override protected function pickUpCommand(e:DetectHeroEvent):void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'GetGhostPoise': [this.id, e.hero.id]}));
			if (e.hero.id == Game.selfId)
				Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.PICKUP_POISE, 1);
		}

		override protected function respawnCommand():void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'RespawnGhostPoise': [this.id]}));
		}

		override protected function pickUpData(data:Object):Array
		{
			if ('GetGhostPoise' in data)
				return data['GetGhostPoise'];
			return null;
		}

		override protected function respawnData(data:Object):Array
		{
			if ('RespawnGhostPoise' in data)
				return data['RespawnGhostPoise'];
			return null;
		}
	}
}