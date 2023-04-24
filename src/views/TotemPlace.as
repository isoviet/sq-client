package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import clans.ClanManager;
	import clans.TotemsData;
	import events.TotemEvent;
	import statuses.Status;
	import statuses.StatusTotem;

	import utils.TotemExperienceBar;

	public class TotemPlace extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
			}
			.bold {
				font-weight: bold;
			}
		]]>).toString();

		private var style:StyleSheet = new StyleSheet();
		private var _id:int = -1;

		private var timeField:GameField = null;
		private var totemTimer:Timer = null;

		private var totemUnBlock:TotemBuy = null;
		private var totemBlock:TotemPlaceBlock = null;
		private var totemImage:DisplayObject = null;

		private var progressBar:TotemExperienceBar = null;

		private var statusTipProgress:Status = null;
		private var statusTipSlot:Status = null;
		private var statusTipTotem:Status = null;

		private var _expires:int = 0;

		private var number:int = 0;
		private var totemBonus:int = 0;

		private var isFreeSlot:Boolean = false;

		public function TotemPlace(number:int):void
		{
			super();

			this.number = number;

			init();
		}

		public function unblockSlot():void
		{
			this.totemBlock.visible = false;
			this.totemUnBlock.visible = true;
		}

		public function blockSlot():void
		{
			this.id = -1;
			this.expires = 0;
			this.totemBlock.visible = true;
			this.totemUnBlock.visible = false;
		}

		public function get id():int
		{
			return this._id;
		}

		public function set id(value:int):void
		{
			if (value >= 0 && this.timerExpires <= 0 && !this.isFreeSlot)
			{
				ClanManager.request(Game.self['clan_id'], true, ClanInfoParser.TOTEMS);
				return;
			}

			if (this._id == value)
				return;

			this._id = value;

			this.totemUnBlock.visible = this._id < 0;
			this.progressBar.visible = this._id >= 0;

			if (this.totemImage && this.totemImage.parent)
			{
				this.totemImage.removeEventListener(MouseEvent.CLICK, changeTotem);
				this.totemImage.parent.removeChild(this.totemImage);
			}

			if (this._id < 0)
			{
				this.timerExpires > 0 ? setStatusSlot(gls("Поставить тотем")) : setStatusSlot(gls("Купить место для тотема на 24 часа"));
				return;
			}

			this.totemImage = TotemsData.getImage(id);
			this.totemImage.addEventListener(MouseEvent.CLICK, changeTotem);
			this.totemImage.scaleX = this.totemImage.scaleY = this.isFreeSlot ? 1 : 0.7;
			this.totemImage.y = this.isFreeSlot ? 10 : 10 + this.totemImage.height * 0.4;
			this.totemImage.x = this.isFreeSlot ? 0 : this.totemImage.width * 0.15;
			addChildAt(this.totemImage, 0);
		}

		public function setStatusBlock(minLevel:int):void
		{
			new Status(this.totemBlock, gls("Требуется {0} уровень клана", minLevel));
		}

		public function setLevel(level:int, exp:int, maxExp:int):void
		{
			this.progressBar.visible = true;
			this.progressBar.setExperience(level, exp, maxExp);
			if (this.statusTipProgress != null)
				this.statusTipProgress.remove();

			this.totemBlock.visible = false;
			this.totemUnBlock.visible = false;

			this.statusTipProgress = new StatusTotem(this.progressBar, TotemsData.getTip(id), id, level, exp, maxExp);
		}

		public function set bonus(bonus:int):void
		{
			this.totemBonus = bonus;
			if (!this.totemImage)
				return;

			if (this.statusTipTotem != null)
				this.statusTipTotem.remove();

			this.statusTipTotem = new Status(this.totemImage, "<body><span class = 'bold'>" + TotemsData.getName(this.id) + "</span>\n" + TotemsData.getDescription(this.id, this.totemBonus) + "</body>");
			this.statusTipTotem.setStyle(this.style);
		}

		public function set expires(value:int):void
		{
			this._expires = value;

			this.totemBlock.visible = false;
			this.totemUnBlock.visible = true;
			this.timeField.visible = this.isFreeSlot ? false : this.timerExpires > 0;

			if (this.isFreeSlot)
				return;

			if (this.timerExpires <= 0)
			{
				if (this.totemTimer)
				{
					this.totemTimer.stop();
					this.totemTimer.removeEventListener(TimerEvent.TIMER, onTimer);
					this.totemTimer = null;
				}

				setStatusSlot(gls("Купить место для тотема на 24 часа"));
				return;
			}

			if (!this.totemTimer)
			{
				this.totemTimer = new Timer(1000);
				this.totemTimer.addEventListener(TimerEvent.TIMER, onTimer);
				this.totemTimer.start();
			}

			setStatusSlot(gls("Поставить тотем"));

			onTimer();
		}

		private function init():void
		{
			this.style.parseCSS(CSS);

			this.isFreeSlot = (this.number == 0);

			this.totemBlock = new TotemPlaceBlock();
			this.totemBlock.scaleX = this.totemBlock.scaleY = this.isFreeSlot ? 1 : 0.7;
			this.totemBlock.y = this.isFreeSlot ? 10 : 10 + this.totemBlock.height * 0.4;
			this.totemBlock.x = this.isFreeSlot ? 0 : this.totemBlock.width * 0.15;
			addChild(this.totemBlock);

			this.totemUnBlock = new TotemBuy();
			this.totemUnBlock.visible = false;
			this.totemUnBlock.scaleX = this.totemUnBlock.scaleY = this.isFreeSlot ? 1 : 0.7;
			this.totemUnBlock.y = this.isFreeSlot ? 10 : 10 + this.totemUnBlock.height * 0.4;
			this.totemUnBlock.x = this.isFreeSlot ? 0 : this.totemUnBlock.width * 0.15;
			this.totemUnBlock.addEventListener(MouseEvent.CLICK, buyTotemPlace);
			setStatusSlot(gls("Купить место для тотема на 24 часа"));
			addChild(this.totemUnBlock);

			this.progressBar = new TotemExperienceBar(84);
			this.progressBar.x = 10;
			this.progressBar.y = 227;
			this.progressBar.visible = false;
			addChild(this.progressBar);

			var formatTime:TextFormat = new TextFormat(null, 12, 0xF5E767, true);

			this.timeField = new GameField("", 30, 210, formatTime);
			this.timeField.filters = [new DropShadowFilter(0, 45, 0x000000, 1, 3, 3, 4.2)];
			this.timeField.visible = false;
			addChild(this.timeField);
		}

		private function setStatusSlot(status:String):void
		{
			if (this.statusTipSlot != null)
				this.statusTipSlot.remove();

			this.statusTipSlot = new Status(this.totemUnBlock, status);
		}

		private function onTimer(e:TimerEvent = null):void
		{
			this.timeField.text = new Date(0, 0, 0, 0, 0, this.timerExpires).toTimeString().slice(0, 8);

			if (this.timerExpires < 0)
				ClanManager.request(Game.self['clan_id'], true, ClanInfoParser.TOTEMS);
		}

		private function get timerExpires():int
		{
			return this._expires - getTimer() / 1000;
		}

		private function buyTotemPlace(e:MouseEvent):void
		{
			if (this.timerExpires <= 0 && !this.isFreeSlot)
				dispatchEvent(new TotemEvent(TotemEvent.BUY_SLOT, this.number));
			else if (this.timerExpires > 0 || this.isFreeSlot)
				dispatchEvent(new TotemEvent(TotemEvent.CHANGE_TOTEM, this.number));
		}

		private function changeTotem(e:MouseEvent):void
		{
			dispatchEvent(new TotemEvent(TotemEvent.CHANGE_TOTEM, this.number));
		}
	}
}