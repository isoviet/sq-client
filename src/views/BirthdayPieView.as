package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import events.GameEvent;
	import game.gameData.ExpirationsManager;
	import statuses.Status;

	public class BirthdayPieView extends Sprite
	{
		private var image:DisplayObject = null;
		private var status:Status = null;

		public function BirthdayPieView():void
		{
			//this.image = new BirthdayPieMovie();
			addChild(this.image);

			this.visible = ExpirationsManager.haveExpiration(ExpirationsManager.BIRTHDAY_2015);

			this.status = new Status(this, "", false, true);

			ExpirationsManager.addEventListener(GameEvent.EXPIRATIONS_CHANGE, onExpirations);
			ExpirationsManager.addEventListener(GameEvent.ON_CHANGE, onChange);

			onChange(null);
		}

		private function onChange(e:GameEvent):void
		{
			this.status.setStatus("<body><span class='center'>" + gls("<b>С праздником!</b>\nИзумительный торт в честь\nДня Рождения любимой игры!\nКаждый получает угощение!\nТвоя энергия бесконечна еще:\n<b>{0}</b>", ExpirationsManager.getDurationString(ExpirationsManager.BIRTHDAY_2015)) + "</span></body>");
		}

		private function onExpirations(e:GameEvent):void
		{
			if (e.data['type'] != ExpirationsManager.BIRTHDAY_2015)
				return;
			this.visible = ExpirationsManager.haveExpiration(ExpirationsManager.BIRTHDAY_2015);
		}
	}
}