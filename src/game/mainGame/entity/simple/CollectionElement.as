package game.mainGame.entity.simple
{
	import flash.display.DisplayObject;

	import game.FlyingObjectAnimation;
	import game.gameData.CollectionManager;
	import game.gameData.CollectionsData;
	import game.gameData.HolidayManager;
	import sensors.events.DetectHeroEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.packages.server.PacketRoundElement;

	import utils.GuardUtil;
	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class CollectionElement extends Element
	{
		static public const KIND_COLLECTION:int = 0;
		static public const KIND_HOLIDAY:int = 1;

		static protected const MAX_COUNT:int = 100;

		private var effect:ParticlesEffect;

		private var _itemId:int = -1;
		public var kind:int = 0;

		public function CollectionElement():void
		{
			super(CollectionsData.getIconClass(1));
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.itemId, this.index, this.kind]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.kind = data[2][2];
			this.itemId = data[2][0];
			this.index = data[2][1];
		}

		override protected function get packets():Array
		{
			return [PacketRoundElement.PACKET_ID];
		}

		public function set index(value:int):void
		{
			this._index = value;
		}

		public function get itemId():int
		{
			return this._itemId;
		}

		public function set itemId(value:int):void
		{
			if (this._itemId == value)
				return;

			this._itemId = value;

			var play:Boolean = this.view.isPlaying;

			removeChildStarling(this.view);

			var iconClass:Class = this.kind == KIND_COLLECTION ? CollectionsData.getIconClass(this.itemId) : HolidayManager.images[this.itemId];
			var icon:DisplayObject = new iconClass();

			this.view = new FlyingObjectAnimation(icon);
			this.view.x = -15;
			this.view.y = -15;
			this.view.scaleXY(0.5);
			if (this.kind == KIND_HOLIDAY)
			{
				this.effect = CollectionEffects.instance.getEffectByName(CollectionEffects.EFFECT_HOLIDAY);
				this.effect.view.visible = true;
				this.effect.view.emitterX = -5;
				this.effect.view.emitterY = -5;
				this.effect.start();
				addChildStarling(this.effect.view);
			}
			addChildStarling(this.view);

			if (!play)
				return;
			this.view.play();
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

			var maxCount:Boolean = this.kind == KIND_COLLECTION ? (CollectionManager.regularItems[this.itemId].count >= MAX_COUNT) : false;

			if (this.sended || maxCount || this.gameInst.squirrels.selfCollected)
				return;

			if (!e.hero.isHare)
			{
				var soundIndex:int = Math.random() * SoundConstants.ACORN_SOUNDS.length;
				GameSounds.play(SoundConstants.ACORN_SOUNDS[soundIndex]);
			}

			GuardUtil.incCollecting();
			Connection.sendData(PacketClient.ROUND_ELEMENT, this.index);
			this.sended = true;
		}

		override protected function onPacket(packet:PacketRoundElement):void
		{
			if (this.body == null)
				return;
			if (this.index != packet.index)
				return;
			destroy();
		}

		override protected function destroy():void
		{
			super.destroy();

			if (!this.effect)
				return;
			this.effect.stop();
			CollectionEffects.instance.removeEffect(this.effect);
			this.effect = null;
		}
	}
}