package game.mainGame.perks.clothes.base
{
	import flash.events.Event;
	import flash.utils.setTimeout;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.entity.simple.GameBody;

	import protocol.Connection;
	import protocol.PacketClient;

	public class PerkClothesSavePoint extends PerkClothesCreateObject
	{
		protected var savePoint:b2Vec2 = null;

		public function PerkClothesSavePoint(hero:Hero)
		{
			super(hero);

			this.hero.addEventListener(Hero.EVENT_DEADLY_CONTACT, onDeadlyContact);
		}

		override public function get totalCooldown():Number
		{
			return 25;
		}

		override protected function setObjectParams(castObject:GameBody):void
		{
			this.savePoint = castObject.position.Copy();
		}

		private function onDeadlyContact(e:Event):void
		{
			if (this.savePoint == null)
				return;
			if (this.hero.immortal)
				return;
			if (!this.hero.isSquirrel || this.hero.isDead)
				return;

			setTimeout(teleportDead, 0);
			this.hero.simpleRespawn();

			Connection.sendData(PacketClient.ROUND_SKILL_ACTION, this.code, this.hero.id);
		}

		private function teleportDead():void
		{
			this.hero.teleportTo(this.savePoint);
			this.savePoint = null;
		}
	}
}