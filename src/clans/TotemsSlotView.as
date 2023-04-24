package clans
{
	import flash.display.Sprite;

	import clans.Clan;
	import dialogs.DialogInfo;
	import dialogs.clan.DialogChangeTotem;
	import dialogs.clan.DialogClanDonate;
	import events.TotemEvent;
	import views.TotemPlace;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketBuy;

	public class TotemsSlotView extends Sprite
	{
		static private const TOTEM_WIDTH:int = 100;
		static private const X_OFFSET:int = 10;
		static private const SLOT_COST_PER_SQUIRRELS:int = 60;

		private var dialogChangeTotem:DialogChangeTotem = null;
		private var dialogBuySlot:DialogInfo = null;
		private var selectSlot:int = 0;
		private var clan:Clan = null;
		private var slotCost:int = 0;

		private var isLeader:Boolean = false;

		public var slotData:Vector.<TotemPlace> = new Vector.<TotemPlace>();

		public function TotemsSlotView():void
		{
			init();
			Connection.listen(onPacket, PacketBuy.PACKET_ID);
		}

		public function setClan(clan:Clan):void
		{
			for (var i:int = 0; i < this.slotData.length; i++)
			{
				if (!TotemsData.isSlotAvailable(i, clan.level))
					continue;

				this.slotData[i].unblockSlot();
			}

			this.clan = clan;

			this.slotCost = this.clan.size * SLOT_COST_PER_SQUIRRELS;

			this.dialogBuySlot = new DialogInfo(gls("Купить новый слот"), gls("Купить новый слот за {0}\nна 24 часа?", this.slotCost), true, buySlot);
			var image:ImageIconNut = new ImageIconNut();
			image.x = 203 + this.slotCost.toString().length * 3;
			image.y = 12;
			this.dialogBuySlot.addChild(image);

			if (this.dialogChangeTotem)
				this.dialogChangeTotem.updateTotems();

			setTotemsData();
		}

		public function clearSlot():void
		{
			for each (var slot:TotemPlace in this.slotData)
				slot.blockSlot();
		}

		public function toggleClanLeaderItems(isLeader:Boolean):void
		{
			this.isLeader = isLeader;
		}

		private function init():void
		{
			var x:int = 0;

			for (var i:int = 0; i < TotemsData.SLOT_COUNT; i++)
			{
				this.slotData[i] = new TotemPlace(i);
				this.slotData[i].x = x;
				this.slotData[i].setStatusBlock(TotemsData.getSlotLevel(i));
				this.slotData[i].addEventListener(TotemEvent.BUY_SLOT, onSlotChanged);
				this.slotData[i].addEventListener(TotemEvent.CHANGE_TOTEM, onSlotChanged);
				addChild(this.slotData[i]);

				x += TOTEM_WIDTH + X_OFFSET;
			}
		}

		private function setTotemsData():void
		{
			for each (var slot:Object in this.clan.totemsSlot.slotData)
			{
				this.slotData[slot['slot_id']].expires = slot['expires'] + this.clan.totemsSlot.lastUpdate;
				this.slotData[slot['slot_id']].id = slot['totem_id'];

				if (slot['totem_id'] < 0)
					continue;

				var totem:Object = this.clan.totems.getTotemData(slot['totem_id']);

				if (totem == null)
					continue;

				this.slotData[slot['slot_id']].bonus = totem['bonus'];
				this.slotData[slot['slot_id']].setLevel(totem['level'], totem['exp'], totem['max_exp']);
			}

			if (this.dialogChangeTotem)
				this.dialogChangeTotem.updateTotems();
		}

		private function buySlot():void
		{
			if (Game.self['clan_duty'] == Clan.DUTY_LEADER || Game.self['clan_duty'] == Clan.DUTY_SUBLEADER)
			{
				if (ClanManager.getClan(Game.self['clan_id']).acorns < this.slotCost)
				{
					new DialogClanDonate(gls("Недостаточно монет"), gls("У вашего клана недостаточно денег      \nдля покупки слота.\nПополните бюджет вашего клана.")).show();
					return;
				}

				Connection.sendData(PacketClient.BUY, PacketClient.BUY_CLAN_TOTEM, 0, this.slotCost, 0, this.selectSlot);
				return;
			}

			Game.buy(PacketClient.BUY_CLAN_TOTEM, 0, this.slotCost, 0, this.selectSlot);
		}

		private function onSlotChanged(e:TotemEvent):void
		{
			switch (e.type)
			{
				case TotemEvent.BUY_SLOT:
					this.dialogBuySlot.show();
					this.selectSlot = e.number;
					break;
				case TotemEvent.CHANGE_TOTEM:
					if (this.dialogChangeTotem == null || this.dialogChangeTotem.isRefresh)
						this.dialogChangeTotem = new DialogChangeTotem(e.number, this.clan, this.isLeader);

					if (this.dialogChangeTotem.currentSlotId != e.number)
						this.dialogChangeTotem.changeSlot(e.number);

					this.dialogChangeTotem.show();
					break;
			}
		}

		private function onPacket(packet:PacketBuy):void
		{
			switch (packet.goodId)
			{
				case PacketClient.BUY_CLAN_TOTEM:
					if (packet.status != PacketServer.BUY_SUCCESS)
						break;

					ClanManager.request(this.clan.id, true, ClanInfoParser.TOTEMS);
					break;
			}
		}
	}
}