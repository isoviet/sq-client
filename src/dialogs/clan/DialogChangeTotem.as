package dialogs.clan
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;

	import fl.containers.ScrollPane;

	import clans.Clan;
	import clans.TotemsData;
	import dialogs.Dialog;
	import statuses.StatusTotem;

	import protocol.Connection;
	import protocol.PacketClient;

	import utils.TotemExperienceBar;

	public class DialogChangeTotem extends Dialog
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				text-align: center;
				color: #000000;
			}
			.bold {
				font-weight: bold;
				font-size: 16px;
			}
			.level {
				font-weight: bold;
			}
		]]>).toString();

		static private const TOTEM_BLOCK:int = 0;
		static private const TOTEM_UNAVAILABLE:int = 1;
		static private const TOTEM_AVAILABLE:int = 2;
		static private const TOTEM_ACTIVE:int = 3;

		static private const ITEM_HEIGHT:int = 85;

		private var style:StyleSheet = new StyleSheet();

		private var id:int = -1;

		private var slotId:int = 0;
		private var scrollPane:ScrollPane = null;

		private var totemsSprite:Sprite = null;
		private var totemImage:DisplayObject = null;

		private var totemsArray:Array = null;

		private var clan:Clan = null;
		private var isLeader:Boolean = false;
		private var needRefresh:Boolean = false;

		public function DialogChangeTotem(slotId:int, clan:Clan, isLeader:Boolean):void
		{
			super("");

			this.slotId = slotId;
			this.clan = clan;
			this.isLeader = isLeader;

			init();
		}

		override public function show():void
		{
			super.show();

			updateTotems();
		}

		public function get isRefresh():Boolean
		{
			return this.needRefresh;
		}

		public function get currentSlotId():int
		{
			return this.slotId;
		}

		public function changeSlot(slotId:int):void
		{
			this.slotId = slotId;
			setTotemId(this.clan.totemsSlot.getTotemId(this.slotId));
		}

		private function init():void
		{
			this.style.parseCSS(CSS);

			setTotemId(this.clan.totemsSlot.getTotemId(this.slotId));

			this.totemsArray = [];

			var scrollItemsSprite:Sprite = new Sprite();

			this.totemsSprite = new Sprite();
			scrollItemsSprite.addChild(this.totemsSprite);

			var totemNumber:int = 0;

			for (var i:int = 0; i < TotemsData.getMaxId(); i++)
			{
				if (i == TotemsData.MAGIC)
				{
					this.totemsArray.push(null);
					continue;
				}
				var itemBackground:TotemDescriptionBG = new TotemDescriptionBG();
				itemBackground.x = 20;
				itemBackground.y = totemNumber * ITEM_HEIGHT;
				itemBackground.addEventListener(MouseEvent.CLICK, changeTotem);
				itemBackground.name = String(i);
				itemBackground.mouseEnabled = (this.isLeader || this.id < 0);
				itemBackground.mouseChildren = (this.isLeader || this.id < 0);
				this.totemsSprite.addChild(itemBackground);

				var totemName:GameField = new GameField("", 94, totemNumber * ITEM_HEIGHT + 2, this.style);
				totemName.text = "<body><span class = 'bold'>" + TotemsData.getName(i) + "</span></body>";
				totemName.width = 225;
				totemName.wordWrap = true;
				totemName.mouseEnabled = false;
				totemName.multiline = true;
				this.totemsSprite.addChild(totemName);

				var totemDescription:GameField = new GameField("", 94, totemNumber * ITEM_HEIGHT + 20, this.style);
				totemDescription.text = "<body>" + TotemsData.getDescription(i) + "</body>";
				totemDescription.width = 225;
				totemDescription.wordWrap = true;
				totemDescription.multiline = true;
				totemDescription.mouseEnabled = false;
				this.totemsSprite.addChild(totemDescription);

				var itemIcon:Sprite = null;
				var availableItem:DisplayObject = TotemsData.getIcon(i);

				var levelTipField:GameField = new GameField("", 94, totemNumber * ITEM_HEIGHT + 68, this.style);
				levelTipField.text = gls("<body>Требуется <span class = 'level'>{0}</span> уровень клана</body>", TotemsData.getLevel(i));
				levelTipField.mouseEnabled = false;
				levelTipField.width = 225;
				levelTipField.wordWrap = true;
				levelTipField.multiline = true;
				this.totemsSprite.addChild(levelTipField);

				var totemData:Object = {};

				var totem:Object = this.clan.totems.getTotemData(i);

				if (totem)
				{
					totemData['state'] = TOTEM_AVAILABLE;
					var totemProgress:TotemExperienceBar = new TotemExperienceBar(205);
					totemProgress.x = 100;
					totemProgress.y = totemNumber * ITEM_HEIGHT + 68;
					totemProgress.visible = false;
					totemProgress.visible = true;
					totemProgress.setExperience(totem['level'], totem['exp'], totem['max_exp']);
					totemData['statusTotem'] = new StatusTotem(totemProgress, TotemsData.getTip(i), i, totem['level'], totem['exp'], totem['max_exp']);
					this.totemsSprite.addChild(totemProgress);
					totemData['totemProgress'] = totemProgress;

					totemDescription.text = "<body>" + TotemsData.getDescription(i, totem['bonus']) + "</body>";

					if (this.clan.totemsSlot.getSlotId(i) > -1)
						totemData['state'] = TOTEM_ACTIVE;
				}

				if (TotemsData.getLevel(i) > this.clan.level)
					totemData['state'] = TOTEM_BLOCK;

				if (!("state" in totemData))
					totemData['state'] = TOTEM_UNAVAILABLE;

				if (totemData['state'] == TOTEM_ACTIVE)
				{
					itemBackground.mouseEnabled = false;
					itemBackground.mouseChildren = false;
				}

				totemData['icon'] = itemIcon;
				totemData['itemBackground'] = itemBackground;
				totemData['availableItem'] = availableItem;
				totemData['tipField'] = levelTipField;

				this.totemsArray.push(totemData);

				updateTotemIcon(i, totemNumber);
				totemNumber++;
			}

			this.scrollPane = new ScrollPane();
			this.scrollPane.setSize(350, 341);
			this.scrollPane.source = scrollItemsSprite;
			this.scrollPane.x = 276;
			this.scrollPane.y = 53;
			addChild(this.scrollPane);

			place();

			this.width = 650;
			this.height = 420;
		}

		public function updateTotems():void
		{
			var totemNumber:int = 0;
			for (var i:int = 0; i < TotemsData.getMaxId(); i++)
			{
				if (i == TotemsData.MAGIC)
					continue;
				var totem:Object = this.clan.totems.getTotemData(i);

				var state:int = TOTEM_UNAVAILABLE;

				if (totem)
				{
					if (!("totemProgress" in this.totemsArray[i]))
					{
						var totemProgress:TotemExperienceBar = new TotemExperienceBar(205);
						totemProgress.x = 100;
						totemProgress.y = totemNumber * ITEM_HEIGHT + 68;
						totemProgress.visible = false;
						totemProgress.visible = true;
						totemProgress.setExperience(totem['level'], totem['exp'], totem['max_exp']);
						if ('statusTotem' in this.totemsArray[i])
							this.totemsArray[i]['statusTotem'].remove();

						this.totemsArray[i]['statusTotem'] = new StatusTotem(totemProgress, TotemsData.getTip(i), i, totem['level'], totem['exp'], totem['max_exp']);
						this.totemsSprite.addChild(totemProgress);
						this.totemsArray[i]['totemProgress'] = totemProgress;
					}
					else
					{
						this.totemsArray[i]['totemProgress'].setExperience(totem['level'], totem['exp'], totem['max_exp']);
						if ('statusTotem' in this.totemsArray[i])
							this.totemsArray[i]['statusTotem'].remove();

						this.totemsArray[i]['statusTotem'] = new StatusTotem(this.totemsArray[i]['totemProgress'], TotemsData.getTip(i), i, totem['level'], totem['exp'], totem['max_exp']);
					}

					state = (this.clan.totemsSlot.getSlotId(i) > -1) ? TOTEM_ACTIVE : TOTEM_AVAILABLE;
				}

				if (TotemsData.getLevel(i) > this.clan.level)
					state = TOTEM_BLOCK;

				if (this.totemsArray[i]['state'] != state)
				{
					this.totemsArray[i]['state'] = state;
					updateTotemIcon(i, totemNumber);
				}
				totemNumber++;
			}
		}

		private function updateTotemIcon(id:int, totemNumber:int):void
		{
			if (this.totemsArray[id] == null)
				return;
			if (this.totemsArray[id]['icon'] && this.totemsSprite.contains(this.totemsArray[id]['icon']))
				this.totemsSprite.removeChild(this.totemsArray[id]['icon']);

			switch (this.totemsArray[id]['state'])
			{
				case TOTEM_BLOCK:
					this.totemsArray[id]['icon'] = new TotemItemCircleBlock();
					this.totemsArray[id]['icon'].x = 35;
					this.totemsArray[id]['icon'].y = totemNumber * ITEM_HEIGHT + 13;
					this.totemsArray[id]['itemBackground'].mouseEnabled = false;
					this.totemsArray[id]['itemBackground'].mouseChildren = false;
					this.totemsArray[id]['tipField'].visible = true;
					this.totemsArray[id]['availableItem'].visible = false;
					break;
				case TOTEM_UNAVAILABLE:
					this.totemsArray[id]['icon'] = new TotemItemCircleImage();
					this.totemsArray[id]['icon'].x = 35;
					this.totemsArray[id]['icon'].y = totemNumber * ITEM_HEIGHT + 13;
					this.totemsArray[id]['itemBackground'].mouseEnabled = false;
					this.totemsArray[id]['itemBackground'].mouseChildren = false;
					this.totemsArray[id]['tipField'].visible = false;
					if (this.totemsArray[id]['availableItem'])
						this.totemsArray[id]['availableItem'].visible = false;
					break;
				case TOTEM_AVAILABLE:
					this.totemsArray[id]['itemBackground'].mouseEnabled = (this.isLeader || this.id < 0);
					this.totemsArray[id]['itemBackground'].mouseChildren = (this.isLeader || this.id < 0);

					this.totemsArray[id]['availableItem'].x = 47;
					this.totemsArray[id]['availableItem'].y = totemNumber * ITEM_HEIGHT + 21;
					this.totemsArray[id]['availableItem'].visible = true;

					this.totemsArray[id]['icon'] = new TotemItemCircleImage();
					this.totemsArray[id]['icon'].x = 35;
					this.totemsArray[id]['icon'].y = totemNumber * ITEM_HEIGHT + 13;
					this.totemsArray[id]['tipField'].visible = false;
					break;
				case TOTEM_ACTIVE:
					this.totemsArray[id]['itemBackground'].mouseEnabled = false;
					this.totemsArray[id]['itemBackground'].mouseChildren = false;

					this.totemsArray[id]['availableItem'].x = 47;
					this.totemsArray[id]['availableItem'].y = totemNumber * ITEM_HEIGHT + 21;
					this.totemsArray[id]['availableItem'].visible = true;

					this.totemsArray[id]['icon'] = new SelectTotemItemCircle();
					this.totemsArray[id]['icon'].x = 31;
					this.totemsArray[id]['icon'].y = totemNumber * ITEM_HEIGHT + 10;
					this.totemsArray[id]['tipField'].visible = false;
					break;
				}

			this.totemsArray[id]['icon'].mouseEnabled = false;
			this.totemsArray[id]['icon'].mouseChildren = false;
			this.totemsSprite.addChild(this.totemsArray[id]['icon']);

			if (this.totemsArray[id]['availableItem'])
			{
				(this.totemsArray[id]['availableItem'] as Sprite).mouseEnabled = false;
				(this.totemsArray[id]['availableItem'] as Sprite).mouseChildren = false;
				this.totemsSprite.addChild(this.totemsArray[id]['availableItem']);
			}
		}

		private function setTotemId(id:int):void
		{
			this.id = id;

			if (this.totemImage && this.totemImage.parent)
				this.totemImage.parent.removeChild(this.totemImage);

			if (this.id >= 0)
				this.totemImage = TotemsData.getImage(this.id);
			else
				this.totemImage = new TotemBuy();

			this.totemImage.x = 80;
			this.totemImage.y = 90;
			(this.totemImage as Sprite).mouseEnabled = false;
			(this.totemImage as Sprite).mouseChildren = false;
			this.totemImage.scaleX = this.totemImage.scaleY = 1.1;
			addChild(this.totemImage);

			if (this.isLeader || !this.totemsArray)
				return;

			var totemNumber:int = 0;
			for (var i:int = 0; i < TotemsData.getMaxId(); i++)
			{
				if (i == TotemsData.MAGIC)
					continue;
				updateTotemIcon(i, totemNumber);
				totemNumber++;
			}
		}

		private function changeTotem(e:MouseEvent):void
		{
			if (this.totemsArray[e.target.name]['state'] == TOTEM_ACTIVE)
				return;

			setTotemId(e.target.name);

			Connection.sendData(PacketClient.CLAN_TOTEM, this.slotId, e.target.name);

			if (this.isLeader)
				return;

			hide();
			this.needRefresh = true;
		}
	}
}