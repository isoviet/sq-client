package tape
{
	import flash.events.MouseEvent;

	import sounds.GameSounds;
	import sounds.SoundConstants;

	public class TapeInviteFriends extends TapeObject
	{
		public function TapeInviteFriends():void
		{
			super();

			var button:InviteTapeButton = new InviteTapeButton();
			button.addEventListener(MouseEvent.CLICK, _onClick);
			addChild(button);
		}

		private function _onClick(event:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);
			Game.inviteFriends();
		}

		override public function listen(listener:Function):void
		{}

		override public function forget(listener:Function):void
		{}
	}
}