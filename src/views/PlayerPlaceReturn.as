package views
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import statuses.Status;

	import com.api.Player;

	public class PlayerPlaceReturn extends PlayerPlace
	{
		private var _selected:Boolean = false;
		private var buttonSelect:SimpleButton;
		private var isGone:Boolean = false;
		private var status:Status = null;

		public function PlayerPlaceReturn(placeButton:DisplayObject)
		{
			super(placeButton);

			this.buttonSelect = new ButtonReturnSelect();
			this.buttonSelect.x = 41;
			this.buttonSelect.y = 36;
			this.buttonSelect.addEventListener(MouseEvent.MOUSE_UP, onClick);
			addChild(this.buttonSelect);

			this.status = new Status(this, "", true);
		}

		override public function isPlayerChanged(player:Player):Boolean
		{
			if (super.isPlayerChanged(player))
				return true;

			if (player['is_gone'] && this.isGone != Boolean(player['is_gone']))
				return true;

			return false;
		}

		override public function setPlayer(player:Player):void
		{
			super.setPlayer(player);

			this.levelField.visible = false;

			if ('is_gone' in player)
				this.isGone = (player['is_gone'] == 1);

			this.status.setStatus(player['name']);
		}

		override public function onClick(e:MouseEvent):void
		{
			this.selected = !this.selected;
		}

		public function set selected(value:Boolean):void
		{
			this._selected = value;

			this.buttonSelect.visible = value;
			dispatchEvent(new Event("TOGGLE_SELECTED"));
		}

		public function get selected():Boolean
		{
			return this._selected;
		}
	}
}