package chat
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	import buttons.ButtonTab;
	import clans.Clan;
	import clans.ClanManager;
	import dialogs.DialogInfo;
	import events.ButtonTabEvent;
	import sounds.GameSounds;
	import statuses.Status;
	import views.BlackListView;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.EditField;
	import utils.StringUtil;

	public class ClanChat extends ChatTabs
	{
		static private const FORMAT:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 12, 0x857653);

		private var inputBG:DisplayObject;
		private var buttonSend:Sprite;

		private var newsSprite:Sprite;
		private var blacklistSprite:Sprite;
		private var newsEditButton:EditClanNewsButton = new EditClanNewsButton();
		private var newsRemoveButton:RemoveClanNewsButton = new RemoveClanNewsButton();
		private var newsAcceptButton:AcceptClanNewsButton = new AcceptClanNewsButton();
		private var newsLabel:EditField = null;

		private var chatTab:ButtonTab = new ButtonTab(new ButtonClanChatLong());
		private var feeTab:ButtonTab = new ButtonTab(new ButtonClanChatLong());
		private var feeSelfTab:ButtonTab = new ButtonTab(new ButtonClanChatLong());
		private var newsTab:ButtonTab = new ButtonTab(new ButtonClanChatLong());
		private var blacklistTab:ButtonTab = new ButtonTab(new ButtonClanChatShort());
		private var dialogNewsLength:DialogInfo = null;

		private var _viewRect:Rectangle = null;

		public function ClanChat(inputBox:TextField, inputBoxBG:DisplayObject, buttonSend:*, viewRect:Rectangle, backGround:DisplayObject, newsLabel:EditField):void
		{
			this.maxInputChars = 80;
			this.inputFormat = new TextFormat(GameField.DEFAULT_FONT, 13, 0x000000);
			this.inputBG = inputBoxBG;
			this.inputBox = inputBox;
			this.inputBox.text = "";
			this.inputBox.wordWrap = false;
			this.inputBox.multiline = false;

			super();

			this.scrollPane.verticalScrollBar.pageScrollSize = 19;
			this.scrollPane.verticalScrollBar.lineScrollSize = 19;
			this.scrollPane.verticalLineScrollSize = 13;

			this.viewRect = viewRect;

			this.newsSprite = new Sprite();
			this.newsSprite.x = 600;
			this.newsSprite.y = 353;
			this.newsSprite.visible = false;

			this.newsLabel = newsLabel;
			this.newsSprite.addChild(this.newsLabel);

			this.blacklistSprite = new Sprite();
			this.blacklistSprite.x = 600;
			this.blacklistSprite.y = 353;
			this.blacklistSprite.visible = false;

			this.dialogNewsLength = new DialogInfo(gls("Изменение новости"), gls("Ты не можешь сохранить эту новость, т.к. она занимает больше 10-и строк\n "));

			new Status(this.newsEditButton, gls("Изменить новость"));
			this.newsEditButton.x = this.newsLabel.x + this.newsLabel.width;
			this.newsEditButton.y = this.newsLabel.y + this.newsLabel.height - 12;
			this.newsEditButton.addEventListener(MouseEvent.CLICK, onEditNews);
			this.newsEditButton.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			this.newsEditButton.addEventListener(MouseEvent.ROLL_OVER, soundOver);

			this.newsRemoveButton.visible = false;
			this.newsRemoveButton.x = this.newsEditButton.x - 10;
			this.newsRemoveButton.y = this.newsEditButton.y + 20;
			this.newsRemoveButton.addEventListener(MouseEvent.CLICK, onEditNewsCancel);
			this.newsRemoveButton.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			this.newsRemoveButton.addEventListener(MouseEvent.ROLL_OVER, soundOver);

			this.newsAcceptButton.visible = false;
			this.newsAcceptButton.x = this.newsRemoveButton.x - 30;
			this.newsAcceptButton.y = this.newsRemoveButton.y;
			this.newsAcceptButton.addEventListener(MouseEvent.CLICK, onEditNews);
			this.newsAcceptButton.addEventListener(MouseEvent.MOUSE_DOWN, soundClick);
			this.newsAcceptButton.addEventListener(MouseEvent.ROLL_OVER, soundOver);

			this.newsSprite.addChild(this.newsEditButton);
			this.newsSprite.addChild(this.newsAcceptButton);
			this.newsSprite.addChild(this.newsRemoveButton);

			addChild(this.newsSprite);
			addChild(this.blacklistSprite);

			this.buttonSend = buttonSend;
			this.buttonSend.addEventListener(MouseEvent.CLICK, onSend);

			var buttonsArray:Array = [this.chatTab, this.feeTab, this.feeSelfTab, this.newsTab, this.blacklistTab];
			var names:Array = [gls("Чат клана"), gls("Казна"), gls("Казна"), gls("Новости"), gls("ЧС")];

			for (var i :int = 0; i < buttonsArray.length; i ++)
			{
				var field:GameField = new GameField(names[i], 0, 13, FORMAT);
				field.mouseEnabled = false;
				field.x = int((buttonsArray[i].width - field.textWidth) * 0.5);
				buttonsArray[i].addChild(field);
			}

			this.chatTab.x = 460;
			this.chatTab.y = 256;

			this.feeTab.x = this.chatTab.x + this.chatTab.width + 5;
			this.feeTab.y = this.chatTab.y;

			this.feeSelfTab.x = this.feeTab.x;
			this.feeSelfTab.y = this.feeTab.y;

			this.newsTab.x = this.feeTab.x + this.feeTab.width + 5;
			this.newsTab.y = this.chatTab.y;

			this.blacklistTab.x = this.newsTab.x + this.newsTab.width + 5;
			this.blacklistTab.y = this.chatTab.y;

			this.tabs.x = 55;
			this.tabs.y = -5;
			this.tabs.insert(this.chatTab);
			this.tabs.insert(this.feeTab);
			this.tabs.insert(this.feeSelfTab);
			this.tabs.insert(this.newsTab);
			this.tabs.insert(this.blacklistTab);

			this.feeSelfTab.visible = false;
			backGround.parent.addChildAt(this.tabs, 0);

			this.tabs.addEventListener(ButtonTabEvent.SELECT, onTabSelect);
			this.tabs.setSelected(this.newsTab);
		}

		public function clearChats():void
		{
			for (var i:int = 0; i < this.chats.length; i++)
				this.chats[i].dispose();

			this.scrollPane.update();
			this.tabs.setSelected(this.newsTab);
		}

		public function toggleNewsEditButton(value:Boolean):void
		{
			this.newsEditButton.visible = this.newsEditButton.visible && value;
		}

		public function set viewRect(value:Rectangle):void
		{
			this._viewRect = value;

			this.scrollPane.x = value.x;
			this.scrollPane.y = value.y;
			this.scrollPane.width = value.width;
			this.scrollPane.height = value.height;

			if (this.currentChat)
				this.currentChat.setWidth(value.width - 20);
		}

		public function set leader(value:Boolean):void
		{
			this.feeTab.visible = value;
			this.blacklistTab.visible = value;
			this.feeSelfTab.visible = !value;
		}

		public function toggleEditNews(edit:Boolean):void
		{
			this.newsLabel.background = edit;
			this.newsLabel.border = edit;

			this.newsAcceptButton.visible = edit;
			this.newsRemoveButton.visible = edit;

			this.newsEditButton.visible = !edit;

			if (edit)
				this.newsLabel.type = TextFieldType.INPUT;
			else
				this.newsLabel.type = TextFieldType.DYNAMIC;
		}

		override protected function sendMessage(message:String):void
		{
			this.currentChat.sendMessage(message);
		}

		override protected function onNewMessage(e:Event):void
		{
			super.onNewMessage(e);
			try
			{
				if (this.scroll > 19 * 5)
					return;

				this.scroll = 0;
			}
			catch (e:Error)
			{}
		}

		override protected function onTabSelect(e:ButtonTabEvent):void
		{
			this.blacklistSprite.visible = this.scrollPane.visible = this.newsSprite.visible = this.inputBox.visible = this.inputBG.visible = this.buttonSend.visible = false;
			switch (e.button)
			{
				case this.chatTab:
					this.scrollPane.visible = this.inputBox.visible = this.inputBG.visible = this.buttonSend.visible = true;
					this.currentChat = this.chats[0];
					this.scrollPane.height = this._viewRect.height;
					break;
				case this.feeTab:
				case this.feeSelfTab:
					this.currentChat = this.chats[1];
					this.scrollPane.height = this._viewRect.height + 30;
					this.scrollPane.visible = true;
					break;
				case this.newsTab:
					this.newsSprite.visible = true;
					break;
				case this.blacklistTab:
					if (this.blacklistSprite.numChildren == 0)
						this.blacklistSprite.addChild(new BlackListView());
					this.blacklistSprite.visible = true;
					break;
			}
			super.onTabSelect(e);
		}

		private function onEditNewsCancel(e:MouseEvent):void
		{
			this.newsLabel.text = (ClanManager.selfClanNews ? ClanManager.selfClanNews : "");
			onEditNews(e);
		}

		private function soundClick(e:MouseEvent):void
		{
			GameSounds.play("click");
		}

		private function soundOver(e:MouseEvent):void
		{

		}

		private function onEditNews(e:MouseEvent):void
		{
			if (this.newsLabel.type == TextFieldType.DYNAMIC)
			{
				toggleEditNews(true);
				return;
			}

			if ((ClanManager.selfClanNews != null) && (Game.self['clan_duty'] != Clan.DUTY_LEADER) && (Game.self['clan_duty'] != Clan.DUTY_SUBLEADER))
			{
				this.newsLabel.text = ClanManager.selfClanNews;
				return;
			}

			this.newsLabel.text = StringUtil.trim(this.newsLabel.text);
			this.newsLabel.text = StringUtil.removeHtmlTags(this.newsLabel.text);

			if (this.newsLabel.textHeight > 148)
			{
				this.dialogNewsLength.show();
				return;
			}

			toggleEditNews(false);

			if (ClanManager.selfClanNews == null || ClanManager.selfClanNews == this.newsLabel.text)
				return;

			Connection.sendData(PacketClient.CLAN_NEWS, this.newsLabel.text);
		}

		private function onSend(e:MouseEvent):void
		{
			if (this.blockChat)
				return;

			var message:String = this.inputBox.text;
			this.inputBox.text = "";
			processMessage(message);
		}
	}
}