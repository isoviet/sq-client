package dialogs
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import fl.controls.ComboBox;
	import fl.data.DataProvider;

	import game.mainGame.gameEditor.EditorFooter;
	import menu.MenuProfile;

	import com.api.Player;

	import protocol.Connection;
	import protocol.PacketClient;
	import protocol.PacketServer;

	import utils.ComboBoxUtil;
	import utils.EditField;
	import utils.HtmlTool;

	public class DialogMapInfo extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 14px;
				color: #000000;
				line-height: 1.5;
			}
			a {
				text-decoration: underline;
			}
		]]>).toString();

		static private const OFFSET_X:int = 5;

		static private var _instance:DialogMapInfo = null;

		private var fieldMinutes:EditField;
		private var fieldSeconds:EditField;
		private var numberField:GameField;
		private var authorField:GameField;
		private var editorField:GameField;
		private var positiveRatingField:GameField;
		private var negativeRatingField:GameField;
		private var exitRatingField:GameField;
		private var playsCountField:GameField;
		private var modeField:GameField;

		private var formatEditTime:TextFormat = new TextFormat(GameField.DEFAULT_FONT, 10, 0x000000);

		private var location:int = 0;
		private var modeId:int = 0;
		private var subId:int = 0;
		private var authorId:int = 0;
		private var editorId:int = 0;
		private var footer:EditorFooter;
		private var oldCheckBoxIndex:int = 0;

		public var folderComboBox:ComboBox = null;
		public var locationComboBox:ComboBox = null;
		public var modeComboBox:ComboBox = null;
		public var subComboBox:ComboBox = null;
		public var editing:Boolean = false;

		public function DialogMapInfo(footer:EditorFooter):void
		{
			super("");

			this.footer = footer;
			_instance = this;
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			var captionField:GameField = new GameField(gls("Информация о карте"), OFFSET_X, 0, new TextFormat(null, 16, 0x663C0D, true));
			captionField.x = OFFSET_X + int((250 - captionField.width) / 2);
			addChild(captionField);

			addChild(new GameField(gls("Локация: "), OFFSET_X, 47, new TextFormat(null, 14, 0x000000, true)));

			addChild(new GameField(gls("Режим: "), OFFSET_X, 82, new TextFormat(null, 14, 0x000000, true)));

			this.modeField = new GameField(gls("Нет режима"), 92, 85, new TextFormat(null, 12, 0x000000));
			addChild(this.modeField);

			var fieldNumber:GameField = addChild(new GameField(gls("Номер: "), OFFSET_X, 102, new TextFormat(null, 14, 0x000000, true))) as GameField;

			this.numberField = new GameField("", OFFSET_X + 55, 102, new TextFormat(null, 14, 0x000000));
			addChild(this.numberField);

			var fieldAuthor:GameField = addChild(new GameField(gls("Автор: "), OFFSET_X, 122, new TextFormat(null, 14, 0x000000, true))) as GameField;

			this.authorField = new GameField("", OFFSET_X + 55, 122, style);
			this.authorField.width = 200;
			this.authorField.addEventListener(MouseEvent.MOUSE_DOWN, onLink);

			addChild(this.authorField);

			var fieldEditor:GameField = addChild(new GameField(gls("Редактор: "), OFFSET_X, 222, new TextFormat(null, 14, 0x000000, true))) as GameField;

			this.editorField = new GameField("", OFFSET_X + 75, 222, style);
			this.editorField.width = 200;
			this.editorField.addEventListener(MouseEvent.MOUSE_DOWN, onLink);
			if (Game.editor_access > 0)
				addChild(this.editorField);

			var fieldTime:GameField = addChild(new GameField(gls("Время: "), OFFSET_X, 142, new TextFormat(null, 14, 0x000000, true))) as GameField;
			var fieldAward:GameField = addChild(new GameField(gls("Награда: "), OFFSET_X, 162, new TextFormat(null, 14, 0x000000, true))) as GameField;

			var ratingCaption:GameField = new GameField(gls("Оценка карты: "), OFFSET_X, 182, new TextFormat(null, 14, 0x000000, true));
			if (Game.editor_access > 0)
				addChild(ratingCaption);
			var countCaption:GameField = new GameField(gls("Количество игр: "), OFFSET_X, 202, new TextFormat(null, 14, 0x000000, true));
			if (Game.editor_access > 0)
				addChild(countCaption);

			this.positiveRatingField = new GameField("", ratingCaption.x + ratingCaption.width, 182, new TextFormat(null, 14, 0x45B000, true));
			if (Game.editor_access > 0)
				addChild(this.positiveRatingField);

			this.negativeRatingField = new GameField("", this.positiveRatingField.x + this.positiveRatingField.width + 10, 182, new TextFormat(null, 14, 0xFF0000, true));
			if (Game.editor_access > 0)
				addChild(this.negativeRatingField);

			this.exitRatingField = new GameField("", this.negativeRatingField.x + this.negativeRatingField.width + 10, 182, new TextFormat(null, 14, 0x0033CC, true));
			if (Game.editor_access > 0)
				addChild(this.exitRatingField);

			this.playsCountField = new GameField("", countCaption.x + countCaption.width, 202, new TextFormat(null, 14, 0x000000, true));
			if (Game.editor_access > 0)
				addChild(this.playsCountField);

			var fieldClear:GameField = new GameField(<body><a href='event:#'>Сброс</a></body>, OFFSET_X + 210, this.playsCountField.y - 15, style);
			fieldClear.addEventListener(MouseEvent.CLICK, clearRating);
			if (Game.editor_access == PacketServer.EDITOR_FULL)
				addChild(fieldClear);

			this.folderComboBox = new ComboBox();
			this.folderComboBox.dropdownWidth = 150;
			this.folderComboBox.width = 140;
			this.folderComboBox.height = 20;
			this.folderComboBox.x = OFFSET_X + 75;
			this.folderComboBox.y = 24;
			this.folderComboBox.addEventListener(Event.CHANGE, changeFolder);
			this.folderComboBox.addItem({'label': gls("Релиз"), 'value': Locations.RELEASE_FOLDER_ID});
			this.folderComboBox.addItem({'label': gls("Готовы к релизу"), 'value': Locations.PRE_RELEASE_FOLDER_ID});
			this.folderComboBox.selectedIndex = 0;
			this.folderComboBox.visible = (Game.editor_access == PacketServer.EDITOR_FULL);
			addChild(this.folderComboBox);

			this.locationComboBox = new ComboBox();
			this.locationComboBox.dropdownWidth = 150;
			this.locationComboBox.width = 140;
			this.locationComboBox.height = 20;
			this.locationComboBox.rowCount = 8;
			this.locationComboBox.x = OFFSET_X + 75;
			this.locationComboBox.y = 44;
			this.locationComboBox.addEventListener(Event.CHANGE, changeHandler);
			addChild(this.locationComboBox);

			this.subComboBox = new ComboBox();
			this.subComboBox.dropdownWidth = 150;
			this.subComboBox.width = 140;
			this.subComboBox.height = 20;
			this.subComboBox.x = OFFSET_X + 75;
			this.subComboBox.y = 64;
			this.subComboBox.addEventListener(Event.CHANGE, changeSub);
			addChild(this.subComboBox);

			this.modeComboBox = new ComboBox();
			this.modeComboBox.dropdownWidth = 150;
			this.modeComboBox.width = 140;
			this.modeComboBox.height = 20;
			this.modeComboBox.x = OFFSET_X + 75;
			this.modeComboBox.y = 84;
			this.modeComboBox.addEventListener(Event.CHANGE, changeMode);
			addChild(this.modeComboBox);

			this.fieldMinutes = new EditField("", 64, 144, 33, 16, this.formatEditTime, null, 2);
			this.fieldMinutes.restrict = "0-9";
			this.fieldMinutes.addEventListener(FocusEvent.FOCUS_OUT, onFocusTime, false, 0, true);
			this.addChild(this.fieldMinutes);

			this.fieldSeconds = new EditField("", 106, 144, 33, 16, this.formatEditTime, null, 2);
			this.fieldSeconds.restrict = "0-9";
			this.fieldSeconds.addEventListener(FocusEvent.FOCUS_OUT, onFocusTime, false, 0, true);
			this.addChild(this.fieldSeconds);

			place();

			this.width = 250 + this.leftOffset + this.rightOffset + 2 * OFFSET_X;

			if (Game.editor_access == 0)
			{
				fieldNumber.visible = false;
				this.numberField.visible = false;
				fieldAuthor.visible = false;
				this.authorField.visible = false;
				fieldEditor.visible = false;
				this.editorField.visible = false;
				fieldTime.y = 108;
				this.fieldMinutes.y = 110;
				this.fieldSeconds.y = 110;
				fieldAward.visible = false;
			}
			else
			{
				this.height += 40;
				this.editorField.visible = Game.editor_access == PacketServer.EDITOR_FULL;
				fieldEditor.visible = Game.editor_access == PacketServer.EDITOR_FULL;
				fieldAward.visible = Game.editor_access == PacketServer.EDITOR_FULL || Game.editor_access == PacketServer.EDITOR_SUPER;
			}
		}

		static public function get minutes():int
		{
			return _instance.minutes;
		}

		static public function get seconds():int
		{
			return _instance.seconds;
		}

		static public function get location():int
		{
			return _instance.location;
		}

		static public function get mode():int
		{
			return _instance.mode;
		}

		static public function get folder():int
		{
			return _instance.folderComboBox.selectedItem['value'];
		}

		override public function hide(e:MouseEvent = null):void
		{
			super.hide(e);

			Game.stage.focus = Game.stage;
		}

		public function clearMapFields():void
		{
			this.authorField.text = "";
			this.editorField.text = "";
			this.numberField.text = "";
		}

		public function changeHandler(e:Event):void
		{
			if (this.visible && this.locationComboBox.selectedItem['value'] == Locations.TENDER && Game.editor_access != PacketServer.EDITOR_FULL)
			{
				this.locationComboBox.selectedIndex = this.oldCheckBoxIndex;
				return;
			}

			this.oldCheckBoxIndex = this.locationComboBox.selectedIndex;
			this.location = this.locationComboBox.selectedItem['value'];

			this.locationComboBox.enabled = !(this.location == Locations.TENDER && Game.editor_access != PacketServer.EDITOR_FULL);

			updateListSub();
			updateListMode();

			var shamanningItems:Array = this.footer.currentShamaningTape.getIds();

			this.modeId = this.modeComboBox.visible ? this.modeComboBox.selectedItem['value'] : 0;
			this.subId = this.subComboBox.visible ? this.subComboBox.selectedItem['value'] : 0;

			for (var type:String in this.footer.tapesObjects)
			{
				if (!this.footer.isOpen("objects_" + type))
					continue;
				this.footer.openObjects(null);
				break;
			}
			for (type in this.footer.tapesPlatforms)
			{
				if (!this.footer.isOpen("platforms_" + type))
					continue;
				this.footer.openPlatforms(null);
				break;
			}
			for (type in this.footer.tapesDecorations)
			{
				if (!this.footer.isOpen("decorations_" + type))
					continue;
				this.footer.openDecoration(null);
				break;
			}
			for (type in this.footer.tapesFonts)
			{
				if (!this.footer.isOpen("background_" + type))
					continue;
				this.footer.openFons(null);
				break;
			}
			if (this.footer.isOpen("joints") || this.footer.isOpen("jointsAnomal") || this.footer.isOpen("jointsStorm"))
				this.footer.openFixing(null);
			if (this.footer.isOpen("heroObjectsBattle") || this.footer.isOpen("heroObjects") || this.footer.isOpen("heroObjectsTwoShamans") || this.footer.isOpen("heroObjectsSurvival") || this.footer.isOpen("heroObjectsAll"))
				this.footer.openSqSh(null);
			if (this.footer.isOpen("shaman") || this.footer.isOpen("shamanTwoShamans"))
				this.footer.openForShaman(null);

			this.footer.loadShamaningTape(shamanningItems);
		}

		public function changeSub(e:Event = null):void
		{
			this.subId = this.subComboBox.selectedItem['value'];
		}

		public function changeMode(e:Event = null):void
		{
			var shamanningItems:Array = this.footer.currentShamaningTape.getIds();

			this.modeId = this.modeComboBox.selectedItem['value'];

			if (this.footer.isOpen("heroObjects") || this.footer.isOpen("heroObjectsTwoShamans") || this.footer.isOpen("heroObjectsSurvival") || this.footer.isOpen("heroObjectsAll"))
				this.footer.openSqSh(null);
			if (this.footer.isOpen("shaman") || this.footer.isOpen("shamanTwoShamans"))
				this.footer.openForShaman(null);
			if (this.footer.isOpen("joints") || this.footer.isOpen("jointsAnomal") || this.footer.isOpen("jointsStorm"))
				this.footer.openFixing(null);

			this.footer.loadShamaningTape(shamanningItems);
		}

		public function changeFolder(e:Event = null):void
		{
			updateListLocation();
			this.locationComboBox.selectedIndex = 0;
			changeHandler(e);
		}

		public function updateListLocation():void
		{
			var provider:DataProvider = new DataProvider();
			for each (var locations:Location in Locations.list)
			{
				if (!checkFolder(locations.id) || !checkLocation(locations.id) || !commonAccess(locations.id) || (Game.editor_access == PacketServer.EDITOR_APPROVAL || Game.editor_access == PacketServer.EDITOR_APPROVAL_PLUS) && (locations.id == Locations.NONAME_ID || locations.id == Locations.BATTLE_ID) && this.editing)
					continue;
				provider.addItem({'label': locations.name, 'value': locations.id});
			}

			this.locationComboBox.dataProvider = provider;
			this.locationComboBox.drawNow();

			updateListSub();
			updateListMode();
		}

		private function clearRating(e:MouseEvent):void
		{
			if (this.numberField.text == "")
				return;
			rating(0, 0, 0, 0, 0);
			Connection.sendData(PacketClient.MAPS_CLEAR_RATING, int(this.numberField.text));
		}

		private function updateListSub():void
		{
			this.subComboBox.visible = Locations.getLocation(this.location).subs != null;
			this.subId = 0;

			if (!this.subComboBox.visible)
				return;

			var provider:DataProvider = new DataProvider();

			var selectedItem:Object = null;
			for (var i:int = 0; i < Locations.getLocation(this.location).subs.length; i++)
			{
				var item:Object = {'label': Locations.getLocation(this.location).subs[i]['name'], 'value': i};
				provider.addItem(item);
				if (i == this.subId)
					selectedItem = item;
			}

			this.subComboBox.dataProvider = provider;
			this.subComboBox.selectedIndex = selectedItem ? provider.getItemIndex(selectedItem) : 0;
		}

		private function updateListMode():void
		{
			var mods:Array = Locations.getLocation(this.location).subs != null ?  Locations.getLocation(this.location).subs[this.subId]['modes'] : Locations.getLocation(this.location).mapModes;
			this.modeComboBox.visible = mods != null;
			this.modeField.visible = !this.modeComboBox.visible;

			if (!this.modeComboBox.visible)
				return;

			var provider:DataProvider = new DataProvider();
			var selectedItem:Object = null;

			for each (var index:int in mods)
			{
				var item:Object = {'label': Locations.MODES[index].name, 'value': index};
				if (index == this.modeId)
					selectedItem = item;
				provider.addItem(item);
			}

			this.modeComboBox.dataProvider = provider;
			this.modeComboBox.selectedIndex = selectedItem ? provider.getItemIndex(selectedItem) : 0;
		}

		public function get minutes():int
		{
			return int(this.fieldMinutes.text);
		}

		public function get seconds():int
		{
			return int(this.fieldSeconds.text);
		}

		public function setTime(seconds:int):void
		{
			this.fieldMinutes.text = String(int(seconds / 60));
			var remain:int = seconds % 60;
			this.fieldSeconds.text = (remain < 10 ? "0" : "") + String(remain);
		}

		public function get author():int
		{
			return this.authorId;
		}

		public function set editor(id:int):void
		{
			if (id == 0)
			{
				this.editorField.text = "";
				return;
			}
			this.editorId = id;

			var player:Player = Game.getPlayer(id);

			this.editorField.text = "<body>" + styleNameLink(player) + "</body>";
		}

		public function set author(id:int):void
		{
			this.authorId = id;

			var player:Player = Game.getPlayer(id);

			this.authorField.text = "<body>" + styleNameLink(player) + "</body>";
			this.authorField.userData = id;
		}

		public function set map(mapNumber:int):void
		{
			this.numberField.text = String(mapNumber);
		}

		public function set mode(id:int):void
		{
			this.modeId = id;

			ComboBoxUtil.selectValue(this.modeComboBox, this.modeId);
		}

		public function get mode():int
		{
			return this.modeId;
		}

		public function set sub(id:int):void
		{
			this.subId = id;

			ComboBoxUtil.selectValue(this.subComboBox, this.subId);
		}

		public function get sub():int
		{
			return this.subId;
		}

		public function rating(positiveVotes:int, negativeVotes:int, exitVotes:int, exitDeads:int, playsCount:int):void
		{
			this.positiveRatingField.text = (positiveVotes > 0 ? "+" : "") + String(positiveVotes);
			this.negativeRatingField.text = (negativeVotes > 0 ? "-" : "") + String(negativeVotes);
			this.exitRatingField.text = (exitVotes > 0 ? "-" : "") + String(exitVotes) + "/"+ exitDeads;
			this.playsCountField.text = playsCount.toString();
			this.negativeRatingField.x = this.positiveRatingField.x + this.positiveRatingField.width + 10;
			this.exitRatingField.x = this.negativeRatingField.x + this.negativeRatingField.width + 10;
		}

		private function checkLocation(id:int):Boolean
		{
			if (id == Locations.PRE_RELEASE_ID)
				return false;

			if (Game.editor_access != PacketServer.EDITOR_APPROVAL && Game.editor_access != PacketServer.EDITOR_APPROVAL_PLUS)
				return true;

			switch (id)
			{
				case Locations.BATTLE_ID:
				case Locations.NONAME_ID:
					return true;
				case Locations.APPROVED_ID:
					return this.editing;
			}

			return (Game.editor_access == PacketServer.EDITOR_APPROVAL_PLUS && id == Locations.TENDER);
		}

		private function commonAccess(id:int):Boolean
		{
			if (Game.editor_access)
				return true;

			switch (id)
			{
				case Locations.ISLAND_ID:
				case Locations.MOUNTAIN_ID:
				case Locations.SWAMP_ID:
				case Locations.DESERT_ID:
				case Locations.ANOMAL_ID:
				case Locations.HARD_ID:
				case Locations.BATTLE_ID:
				case Locations.STORM_ID:
				case Locations.WILD_ID:
					return true;
			}

			return false;
		}

		private function checkFolder(locationId:int):Boolean
		{
			if (this.folderComboBox.selectedItem['value'] == Locations.RELEASE_FOLDER_ID)
				return true;

			return Locations.getLocation(locationId).game;
		}

		private function styleNameLink(player:Player):String
		{
			var name:String = player.name;
			if (player.id == Game.selfId)
				return name;

			return HtmlTool.anchor(player.name, "event:" + player.id);
		}

		private function onLink(e:MouseEvent):void
		{
			var playerId:int = int(GameField(e.currentTarget).userData);
			if (Game.selfId == playerId)
				return;

			MenuProfile.showMenu(playerId);
		}

		private function onFocusTime(e:FocusEvent):void
		{
			var seconds:int = int(this.fieldSeconds.text);
			var minutes:int = int(this.fieldMinutes.text);

			var time:int = minutes * 60 + seconds;

			if ((time > Game.ROUND_DEFAULT_TIME || time < Game.ROUND_MIN_TIME) && Game.editor_access == PacketServer.EDITOR_NONE)
			{
				var newValue:int = (time > Game.ROUND_DEFAULT_TIME) ? Game.ROUND_DEFAULT_TIME : Game.ROUND_MIN_TIME;
				setTime(newValue);
				this.fieldSeconds.setTextFormat(this.formatEditTime);
				this.fieldMinutes.setTextFormat(this.formatEditTime);
				return;
			}

			if (e.currentTarget == this.fieldSeconds)
			{
				if (seconds == 0)
				{
					this.fieldSeconds.text = "00";
					this.fieldSeconds.setTextFormat(this.formatEditTime);
					return;
				}

				if (seconds > 60)
					seconds = 60;
				setTime(minutes * 60 + seconds);
				this.fieldSeconds.setTextFormat(this.formatEditTime);
			}

			if (e.currentTarget == this.fieldMinutes)
			{
				if (minutes == 0)
				{
					this.fieldMinutes.setTextFormat(this.formatEditTime);
					return;
				}
				if (minutes > int(Game.ROUND_DEFAULT_TIME / 60) && Game.editor_access == PacketServer.EDITOR_NONE)
					setTime(Game.ROUND_DEFAULT_TIME / 60);
				this.fieldMinutes.setTextFormat(this.formatEditTime);
			}
		}
	}
}