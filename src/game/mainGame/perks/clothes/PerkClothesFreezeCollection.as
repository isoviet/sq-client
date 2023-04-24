package game.mainGame.perks.clothes
{
	import chat.ChatDeadServiceMessage;
	import game.mainGame.entity.simple.CollectionElement;
	import game.mainGame.entity.simple.Element;
	import screens.ScreenGame;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoundElement;
	import protocol.packages.server.PacketRoundSkill;

	public class PerkClothesFreezeCollection extends PerkClothes
	{
		private var collectionElement:Element;

		public function PerkClothesFreezeCollection(hero:Hero):void
		{
			super(hero);

			this.activateSound = "snowfall";
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 30;
		}

		override public function get startCooldown():Number
		{
			return 30;
		}

		override public function get activeTime():Number
		{
			return 5;
		}

		override public function get available():Boolean
		{
			return super.available && !(this.hero.heroView.running) && !(this.hero.heroView.fly);
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.collectionElement != null)
				this.collectionElement.freeze(-1);
			this.collectionElement = null;
		}

		override protected function get packets():Array
		{
			return super.packets.concat([PacketRoundElement.PACKET_ID]);
		}

		override protected function deactivate():void
		{
			super.deactivate();
			if (this.hero && this.hero.id == Game.selfId)
				Connection.sendData(PacketClient.ROUND_SKILL, this.code, false, 0, "");

			if (this.collectionElement != null)
				this.collectionElement.freeze(-1);
			this.collectionElement = null;

			this.currentActiveTime = 0;
		}

		override protected function onPacket(packet:AbstractServerPacket):void
		{
			if (isEndGame)
				return;

			switch (packet.packetId)
			{
				case PacketRoundElement.PACKET_ID:
					if (this.collectionElement == null || !(this.collectionElement is CollectionElement) ||
						this.collectionElement.index != (packet as PacketRoundElement).index)
						return;
					this.collectionElement = null;
					this.active = false;
					break;
				case PacketRoundSkill.PACKET_ID:
					var skill:PacketRoundSkill = packet as PacketRoundSkill;

					if (skill.state == PacketServer.SKILL_ERROR)
						return;
					if (this.hero != null && skill.type == this.code && skill.playerId == this.hero.id)
					{
						var index:int = skill.data;
						if (index == -1)
						{
							if (this.hero.id == Game.selfId)
								ScreenGame.sendMessage(this.hero.id, "", ChatDeadServiceMessage.FREEZE_ERROR_PERK);
							return;
						}
						this.active = skill.state == PacketServer.SKILL_ACTIVATE;

						if (!(index in this.hero.game.map.elements))
							return;
						this.collectionElement = this.hero.game.map.elements[index];
						this.collectionElement.freeze(skill.state == PacketServer.SKILL_ACTIVATE ? this.hero.id : -1);

						if (skill.state != PacketServer.SKILL_ACTIVATE)
							return;
						ScreenGame.sendMessage(this.hero.id, "", ChatDeadServiceMessage.FREEZE_PERK);
					}
					break;
				default:
					super.onPacket(packet);
					break;
			}
		}
	}
}