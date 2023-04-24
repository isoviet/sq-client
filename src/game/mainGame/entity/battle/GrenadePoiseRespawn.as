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

	public class GrenadePoiseRespawn extends ItemRespawn
	{
		static private const RESPAWN_TIME:int = 15000;

		static public const SPIKE_INC:int = 2;

		public function GrenadePoiseRespawn():void
		{
			super();

			this.timeRespawn = RESPAWN_TIME;
		}

		override protected function initView():void
		{
			this.view = new FlyingObjectAnimation(new GrenadePoiseImage());
			this.view.x = -17;
			this.view.y = -17;
			this.view.object.filters = [];
			addChildStarling(this.view);
		}

		override protected function canPickUp(e:DetectHeroEvent):Boolean
		{
			var spikeItem:CastItem = e.hero.castItems.getItem(GrenadePoise, CastItem.TYPE_ROUND);
			var maxCount:Boolean = ((spikeItem != null) && (spikeItem.count >= CastItem.getMax(GrenadePoise)));

			return !maxCount;
		}

		override protected function editorEffect(e:DetectHeroEvent):void
		{
			e.hero.castItems.add(new CastItem(GrenadePoise, CastItem.TYPE_ROUND, SPIKE_INC));
			if (this.gameInst.cast.castObject == null)
				this.gameInst.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, GrenadePoise));
		}

		override protected function gameEffect(hero:HeroBattle):void
		{
			if (hero != Hero.self)
				return;
			Hero.self.castItems.add(new CastItem(GrenadePoise, CastItem.TYPE_ROUND, SPIKE_INC));
			if (this.gameInst.cast.castObject == null)
				this.gameInst.cast.onObjectSelect(new CastEvent(CastEvent.SELECT, GrenadePoise));
		}

		override protected function pickUpCommand(e:DetectHeroEvent):void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'GetGrenadePoise': [this.id, e.hero.id]}));
			if (e.hero.id == Game.selfId)
				Connection.sendData(PacketClient.ACHIEVEMENT, Achievements.PICKUP_POISE, 1);
		}

		override protected function respawnCommand():void
		{
			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'RespawnGrenadePoise': [this.id]}));
		}

		override protected function pickUpData(data:Object):Array
		{
			if ('GetGrenadePoise' in data)
				return data['GetGrenadePoise'];
			return null;
		}

		override protected function respawnData(data:Object):Array
		{
			if ('RespawnGrenadePoise' in data)
				return data['RespawnGrenadePoise'];
			return null;
		}
	}
}