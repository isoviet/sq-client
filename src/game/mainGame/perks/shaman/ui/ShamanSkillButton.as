package game.mainGame.perks.shaman.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;

	import game.gameData.ShamanTreeManager;
	import game.mainGame.perks.shaman.PerkShaman;
	import game.mainGame.perks.shaman.PerkShamanActive;
	import game.mainGame.perks.shaman.PerkShamanFactory;
	import game.mainGame.perks.ui.ToolButtonOld;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.AbstractServerPacket;
	import protocol.packages.server.PacketRoomRound;
	import protocol.packages.server.PacketRoundSkillShaman;
	import protocol.packages.server.structs.PacketLoginShamanInfo;

	public class ShamanSkillButton extends ToolButtonOld
	{
		private var isSend:Boolean = false;

		private var description:String = "";

		public function ShamanSkillButton(perkClass:Class):void
		{
			super(perkClass, PerkShamanFactory.perkData[perkClass]);

			this.button.scaleX = this.button.scaleY = 0.7;

			this.costView.visible = false;

			updateDescr();

			setSector();

			Connection.listen(onPacket, [PacketRoundSkillShaman.PACKET_ID, PacketRoomRound.PACKET_ID]);
		}

		override public function clone():ToolButtonOld
		{
			var answer:ShamanSkillButton = new ShamanSkillButton(this.perkClass);
			answer.hero = this.hero;
			return answer;
		}

		override public function set hero(value:Hero):void
		{
			if (!checkHero(value))
				return;

			this.isSend = false;

			for each (var perk:PerkShaman in value.perkController.perksShaman)
			{
				if (getQualifiedClassName(perk) != getQualifiedClassName(this.perkClass))
					continue;

				this.perkInstance = perk;
				this.perkInstance.addEventListener("STATE_CHANGED", updateState);

				updateState();
				return;
			}

			this.gray = true;
		}

		override public function onClick(e:Event = null):void
		{
			if (this.isSend)
				return;

			if (!this.perkInstance || !this.perkInstance.available)
				return;

			if (!checkClick())
				return;

			this.isSend = true;
			Connection.sendData(PacketClient.ROUND_SKILL_SHAMAN, (this.perkInstance as PerkShamanActive).code, !this.perkInstance.active);

			if (this.perkInstance.active)
				this.gray = true;

			this.glow = this.perkInstance.active;
		}

		override public function updateState(e:Event = null):void
		{
			super.updateState();

			this.status.setStatus(gls("<B>«{0}»</B>\n{1}", this.perkData['name'], this.description + this.hotKeyText));
		}

		public function dispose():void
		{
			this.perkInstance = null;
			this.status.remove();

			removeEventListener(MouseEvent.CLICK, onClick);
			Connection.forget(onPacket, [PacketRoundSkillShaman.PACKET_ID, PacketRoomRound.PACKET_ID]);
		}

		public function updateDescr():void
		{
			var skillId:int = PerkShamanFactory.getId(this.perkClass);
			var data:Vector.<PacketLoginShamanInfo> = Game.self['shaman_skills'];
			var item: PacketLoginShamanInfo;

			this.description = "";
			for (var i:int = 0, len: int = data.length; i < len; i++)
			{
				item = data[i];
				if (item.skillId != skillId)
					continue;

				this.description = PerkShamanFactory.getDescriptionById(
					skillId, PerkShamanFactory.TOTAL_BONUS_DESCRIPTION,
					[item.levelFree, ShamanTreeManager.paidScoreAvailable(item.levelFree, item.levelPaid)]);
				break;
			}
			if (this.description == "")
				this.description = PerkShamanFactory.getDescriptionById(skillId, PerkShamanFactory.DEFAULT_DESCRIPTION, [0, 0]);

			updateState();
		}

		override protected function setSector():void
		{
			super.setSector();

			this.sector.radius = 18;
			this.sector.x = this.sector.radius;
			this.sector.y = this.sector.radius;
		}

		protected function onPacket(packet:AbstractServerPacket):void
		{
			switch (packet.packetId)
			{
				case PacketRoundSkillShaman.PACKET_ID:
					var shaman: PacketRoundSkillShaman = packet as PacketRoundSkillShaman;

					if (this.perkInstance == null || this.hero == null)
						return;
					if (shaman.playerId != this.hero.id)
						return;
					var code:int = (this.perkInstance as PerkShamanActive).code;
					if (shaman.type != code)
						return;
					this.isSend = false;
					break;
				case PacketRoomRound.PACKET_ID:
					if ((packet as PacketRoomRound).type == PacketServer.ROUND_START)
						updateState();
					break;
			}
		}
	}
}