package statuses
{
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.text.StyleSheet;
	import flash.utils.Timer;

	import game.gameData.VIPManager;

	public class StatusShamanExp extends Status
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #1B120E;
			}
		]]>).toString();

		private var currentExpirience:int;
		private var timer:Timer = new Timer(1000);

		private var text:GameField;
		private var imageBottle:DisplayObject;

		private var imageExp:DisplayObject;

		public function StatusShamanExp(owner:DisplayObject):void
		{
			super(owner);
			init();
		}

		public function setExpirience(currentExpirience:int):void
		{
			this.currentExpirience = currentExpirience;
			updateText();
		}

		public function updateText():void
		{
			var VIPString:String = "";
			var expirienceStatus:String = (this.currentExpirience < 0 ? gls("    Ты достиг максимального уровня.") : gls("    До следующего уровня:  <b>{0}</b> опыта.", this.currentExpirience));

			this.imageBottle.visible = VIPManager.haveVIP;
			this.imageBottle.y = this.imageBottle.visible ? 23 : 0;
			if (this.imageBottle.visible)
			{
				VIPString += gls("\n    VIP-статус действует<br/>    ещё <B> {0}</B>.", VIPManager.durationString);

				if (!this.timer.running)
					resetTimer();
			}
			else
			{
				if (this.timer.running)
					this.timer.stop();
			}

			VIPString += gls("\n\nШаман получает опыт за каждую белку, которой\nпомог добраться до дупла. Уровень шамана\nповышается, когда он наберёт достаточное\nколичество очков опыта.");

			this.text.htmlText = "<body>" + expirienceStatus + VIPString + "</body>";
			draw();
		}

		private function init():void
		{
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(CSS);

			this.text = new GameField("", 2, 2, style);
			addChild(this.text);

			this.imageExp = new ImageIconShamanExp();
			this.imageExp.scaleX = this.imageExp.scaleY = 0.6;
			this.imageExp.x = 4;
			this.imageExp.y = 4;
			addChild(this.imageExp);

			this.imageBottle = new ImageIconVIP();
			this.imageBottle.scaleX = this.imageBottle.scaleY = 0.6;
			this.imageBottle.x = 4;
			this.imageBottle.y = 25;
			addChild(this.imageBottle);

			this.timer.addEventListener(TimerEvent.TIMER, onTimerTick);

			updateText();
			draw();
		}

		private function onTimerTick(e:TimerEvent = null):void
		{
			updateText();
		}

		private function resetTimer():void
		{
			this.timer.reset();
			this.timer.start();
		}
	}
}