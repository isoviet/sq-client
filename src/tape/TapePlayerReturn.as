package tape
{
	import flash.events.Event;

	import dialogs.DialogReturnFriends;
	import views.PlayerPlaceReturn;

	public class TapePlayerReturn extends TapePlayer
	{
		public function TapePlayerReturn(playerId:int)
		{
			super(playerId, TapePlayer.TYPE_RETURN);
			(this.playerPlace as PlayerPlaceReturn).addEventListener("TOGGLE_SELECTED", onToggle);
		}

		public function set selected(value:Boolean):void
		{
			(this.playerPlace as PlayerPlaceReturn).selected = value;
		}

		public function get selected():Boolean
		{
			return (this.playerPlace as PlayerPlaceReturn).selected;
		}

		private function onToggle(e:Event):void
		{
			DialogReturnFriends.onSelected(this.playerId, this.selected);
		}
	}
}