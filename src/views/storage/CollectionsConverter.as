package views.storage
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import buttons.ButtonBase;
	import game.gameData.CollectionManager;
	import statuses.Status;

	import utils.FiltersUtil;

	public class CollectionsConverter extends Sprite
	{
		static private const STATE_AVAILABLE:int = 0;
		static private const STATE_BLOCKED:int = 1;
		static private const STATE_HIDDEN:int = 2;

		private var id:int;

		private var convertButton:ButtonBase = null;

		private var _state:int = -1;
		private var _blocked:Boolean = false;

		private var statusBlocked:Status = null;
		private var blockReason:String;

		public function CollectionsConverter(id:int):void
		{
			super();

			this.id = id;

			init();
		}

		public function setBlocked(value:Boolean, reason:String = ""):void
		{
			this._blocked = value;

			if (value)
			{
				this.blockReason = reason;
				this.statusBlocked.setStatus(this.blockReason);
			}

			this.state = value ? STATE_BLOCKED : STATE_AVAILABLE;
		}

		public function set available(value:Boolean):void
		{
			this.state = value ? this._state : STATE_HIDDEN;
		}

		public function set waitingForResponse(value:Boolean):void
		{
			this.mouseEnabled = !value;
			this.mouseChildren = !value;
		}

		private function init():void
		{
			this.convertButton = new ButtonBase(gls("Собрать"));
			this.convertButton.addEventListener(MouseEvent.CLICK, onConvert);
			addChild(this.convertButton);

			this.statusBlocked = new Status(this, "", false, true);
		}

		private function set state(value:int):void
		{
			if (this._state == value)
				return;

			if (this._state == STATE_HIDDEN)
				return;

			this._state = value;

			if (value == STATE_HIDDEN)
			{
				this.visible = false;
				this.statusBlocked.remove();
				return;
			}

			this.convertButton.filters = (value == STATE_BLOCKED) ? FiltersUtil.GREY_FILTER : [];
			this.convertButton.enabled = value != STATE_BLOCKED;

			this.statusBlocked.alpha = (value == STATE_BLOCKED) ? 1 : 0;
		}

		private function onConvert(e:MouseEvent):void
		{
			CollectionManager.collectTrophy(this.id);
			this.waitingForResponse = true;
		}
	}
}