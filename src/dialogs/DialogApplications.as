package dialogs
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import buttons.ButtonBase;
	import clans.Clan;
	import clans.ClanApplication;
	import clans.ClanManager;
	import clans.ClanRoom;
	import clans.ui.ApplicationList;
	import dialogs.clan.DialogClanDonate;
	import events.ApplicationsUpdateEvent;
	import views.ClanLevelLimiterView;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;
	import protocol.packages.server.PacketClanApplication;
	import protocol.packages.server.structs.PacketClanApplicationItems;

	import utils.FieldUtils;

	public class DialogApplications extends Dialog
	{
		static public const PACKET_PER_COIN:int = 5;
		static public const SQUIRRELS_PACKET_SIZE:int = 5;
		static public const MAX_PRICE:int = 100;

		static private var placeCost:int = 0;

		private var applicationsList:ApplicationList = null;

		private var dialogClanBlocked:DialogInfo;

		private var buttonBuyPlaces:ButtonBase = null;

		private var imagesIcons:Vector.<DisplayObject> = new Vector.<DisplayObject>;

		public function DialogApplications():void
		{
			super(gls("Заявки на вступление в клан"));

			init();
			Connection.listen(onPacket, PacketClanApplication.PACKET_ID);
		}

		override public function clear():void
		{
			super.clear();

			this.applicationsList.clear();
		}

		public function addData(data:Vector.<PacketClanApplicationItems>):void
		{
			var applications:Vector.<ClanApplication> = new Vector.<ClanApplication>;

			for (var i:int = 0; i < data.length; i++)
				applications.push(new ClanApplication(data[i].playerId, data[i].time));

			this.applicationsList.addData(applications);
		}

		private function init():void
		{
			this.dialogClanBlocked = new DialogInfo(gls("Клан заблокирован"), gls("Ты не можешь принимать или отклонять заявки,\nт.к. твой клан заблокирован."));

			this.applicationsList = new ApplicationList();
			this.applicationsList.x = 15;
			this.applicationsList.y = 24;
			this.applicationsList.addEventListener(ApplicationsUpdateEvent.NAME, onApplicationsChanged);
			addChild(this.applicationsList);

			var button:ButtonBase = new ButtonBase(gls("Принять"));
			button.x = 80;
			button.y = this.applicationsList.y + this.applicationsList.height - 30;
			button.addEventListener(MouseEvent.CLICK, admit);
			addChild(button);

			var buttonRefuse:ButtonBase = new ButtonBase(gls("Отказать"));
			buttonRefuse.x = 185;
			buttonRefuse.y = this.applicationsList.y + this.applicationsList.height - 30;
			buttonRefuse.addEventListener(MouseEvent.CLICK, refuse);
			addChild(buttonRefuse);

			var buyPlaceBg:BuyPlaceBackground = new BuyPlaceBackground();
			buyPlaceBg.x = 10;
			buyPlaceBg.y = buttonRefuse.y + buttonRefuse.height + 10;
			addChild(buyPlaceBg);

			var format:TextFormat = new TextFormat(null, 14, 0x47342A, false);
			format.align = TextFormatAlign.CENTER;
			format.leading = 2.5;

			var buyDescription:GameField = new GameField("", buyPlaceBg.x + 20, buyPlaceBg.y + 10, format);
			buyDescription.text = gls("Получая новый уровень клана, ты можешь\nдобавлять  больше участников,\nтакже ты можешь купить места за монетки");
			addChild(buyDescription);

			this.buttonBuyPlaces = new ButtonBase(gls("Купить {0} мест за {1}", SQUIRRELS_PACKET_SIZE, 5) + " -   ", 200);
			this.buttonBuyPlaces.x = 75;
			this.buttonBuyPlaces.y = buyDescription.y + 65;
			this.buttonBuyPlaces.addEventListener(MouseEvent.CLICK, buySquirrels);
			addChild(this.buttonBuyPlaces);

			if (Game.self['clan_duty'] == Clan.DUTY_LEADER)
			{
				var clanLevelLimiter:ClanLevelLimiterView = new ClanLevelLimiterView();
				clanLevelLimiter.x = buyPlaceBg.x;
				clanLevelLimiter.y = buyPlaceBg.y + buyPlaceBg.height + 10;
				clanLevelLimiter.minLevel = ClanManager.getClan(Game.self['clan_id']).levelLimiter;
				addChild(clanLevelLimiter);
			}

			place();

			this.height += 60;
			this.width += 26;
		}

		public function setPlaceCost(placeCount:int):void
		{
			placeCost = Math.min(MAX_PRICE, PACKET_PER_COIN * (placeCount / SQUIRRELS_PACKET_SIZE + 1));

			this.buttonBuyPlaces.field.text = gls("Купить {0} мест за {1}", SQUIRRELS_PACKET_SIZE, placeCost) + " -   ";
			this.buttonBuyPlaces.redraw();

			while (this.imagesIcons.length > 0)
			{
				var image:DisplayObject = this.imagesIcons.shift();
				image.parent.removeChild(image);
			}
			this.imagesIcons = FieldUtils.replaceSign(this.buttonBuyPlaces.field, "-", ImageIconCoins, 0.7, 0.7, -this.buttonBuyPlaces.field.x, -3, false, false);
		}

		private function buySquirrels(e:MouseEvent):void
		{
			if (ClanManager.getClan(Game.self['clan_id']).state == PacketServer.CLAN_STATE_BANNED)
			{
				this.dialogClanBlocked.show();
				return;
			}

			if (ClanManager.getClan(Game.self['clan_id']).coins < placeCost && (Game.self['clan_duty'] == Clan.DUTY_LEADER || Game.self['clan_duty'] == Clan.DUTY_SUBLEADER))
			{
				new DialogClanDonate(gls("Недостаточно монет"), gls("У вашего клана недостаточно денег      \nдля покупки дополнительных мест.\nПополните бюджет вашего клана.")).show();
				return;
			}

			if (Game.self['clan_duty'] == Clan.DUTY_LEADER || Game.self['clan_duty'] == Clan.DUTY_SUBLEADER)
				Connection.sendData(PacketClient.BUY, PacketClient.BUY_CLAN_PLACE, placeCost, 0);
			else
				Game.buy(PacketClient.BUY_CLAN_PLACE, placeCost, 0);

		}

		private function admit(e:MouseEvent):void
		{
			if (ClanManager.getClan(Game.self['clan_id']).state == PacketServer.CLAN_STATE_BANNED)
			{
				this.dialogClanBlocked.show();
				return;
			}

			this.applicationsList.inviteSelected();
		}

		private function refuse(e:MouseEvent):void
		{
			if (ClanManager.getClan(Game.self['clan_id']).state == PacketServer.CLAN_STATE_BANNED)
			{
				this.dialogClanBlocked.show();
				return;
			}

			this.applicationsList.refuseSelected();
		}

		private function onApplicationsChanged(e:ApplicationsUpdateEvent):void
		{
			dispatchEvent(new ApplicationsUpdateEvent(e.count));
		}

		private function onPacket(packet:PacketClanApplication):void
		{
			if (!ClanRoom.requestApplications)
				return;
			addData(packet.items);
		}
	}
}