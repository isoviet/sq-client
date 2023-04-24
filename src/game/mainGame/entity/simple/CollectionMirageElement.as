package game.mainGame.entity.simple
{
	import game.gameData.CollectionManager;
	import game.mainGame.gameDesertNet.MirageView;
	import game.mainGame.perks.clothes.PerkClothesFactory;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundCommand;

	public class CollectionMirageElement extends CollectionElement
	{
		private var mirageView:MirageView = null;

		public function CollectionMirageElement():void
		{
			super();

			if (Hero.self.perkController.getPerkLevel(PerkClothesFactory.PHARAON_WOMAN) != -1)
			{
				this.getStarlingView().alpha = 0.5;
				this.alpha = 0.5;
				this.filters = [];
			}

			Connection.listen(collectMirage, PacketRoundCommand.PACKET_ID);
		}

		override public function dispose():void
		{
			super.dispose();

			Connection.forget(collectMirage, PacketRoundCommand.PACKET_ID);

			if (this.mirageView)
				this.mirageView.dispose();
		}

		override protected function onHeroDetected(e:DetectHeroEvent):void
		{
			if (e.hero.id != Game.selfId && e.hero.id > 0)
				return;

			if (!this.available)
				return;

			if (e.hero.isDead || e.hero.shaman)
				return;

			if (this.itemId < 0)
				return;

			if (CollectionManager.regularItems[this.itemId].count >= MAX_COUNT || this.sended || CollectionManager.haveCollection)
				return;

			if (!e.hero.isHare)
			{
				var soundIndex:int = Math.random() * SoundConstants.ACORN_SOUNDS.length;
				GameSounds.play(SoundConstants.ACORN_SOUNDS[soundIndex]);
			}

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'CollectMirage': [this.id, e.hero.id]}));
			this.sended = true;
		}

		override protected function destroy():void
		{
			this.alpha = 0;

			this.mirageView = new MirageView(this.itemId, super.destroy);
			//this.mirageView.x = -15;
			//this.mirageView.y = -15;
			this.mirageView.alpha = 0.2;
			addChildStarling(this.mirageView);
		}

		private function collectMirage(packet:PacketRoundCommand):void
		{
			var data:Object = packet.dataJson;
			if (!('CollectMirage' in data))
				return;

			if (data['CollectMirage'][0] != this.id)
				return;

			var hero:Hero = this.gameInst.squirrels.get(data['CollectMirage'][1]);

			if (!(!hero || hero.isDead || hero.inHollow))
				hero.heroView.showMirageAnimation(hero, this.itemId);

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}