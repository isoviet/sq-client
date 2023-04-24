package views.dialogEvents
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	import events.PostEvent;
	import sounds.GameSounds;
	import sounds.SoundConstants;

	public class PostElementView extends Sprite
	{
		static private const CSS:String = (<![CDATA[
		body {
			font-family: "Droid Sans";
			font-size: 13px;
			color: #000000;
		}
		a {
			color: #0063CE;
			text-decoration: underline;
		}
		a:hover {
			text-decoration: none;
			color: #0063CE;
		}
		.greenMes {
			font-size: 16px;
			color: #26A30A;
			text-align: center;
			font-weight: bold;
		}
		.orange {
			color: #C94900;
			font-weight: bold;
		}
		.blackSmall {
			color: #000000;
			font-size: 11px;
			line-height: 1;
		}
		]]>).toString();

		static protected var style:StyleSheet = null;

		protected var timeField:GameField = null;
		protected var buttonClose:SimpleButton = null;

		public var eventId:int = -1;
		public var index:int = -1;
		public var time:uint = 0;
		public var type:int = -1;

		public function PostElementView(id:int, type:int, time:uint):void
		{
			if (style == null)
			{
				style = new StyleSheet();
				style.parseCSS(CSS);
			}
			this.eventId = id;
			this.time = time;
			this.type = type;
		}

		public function onShow():void
		{
			if (this.timeField != null)
				return;

			var back:PostElementBack = new PostElementBack()
			back.x = 80;
			back.y = 5;
			addChild(back);

			this.timeField = new GameField(this.timeString, 630, 10, new TextFormat(null, 14, 0x63421B, true));
			this.timeField.x = 660 - int(this.timeField.textWidth * 0.5);
			addChild(this.timeField);

			this.buttonClose = new ButtonCross();
			this.buttonClose.x = 715;
			this.buttonClose.y = 7;
			this.buttonClose.addEventListener(MouseEvent.CLICK, onRemove);
			addChild(this.buttonClose);
		}

		protected function onRemove(e:MouseEvent):void
		{
			GameSounds.play(SoundConstants.BUTTON_CLICK);
			dispatchEvent(new PostEvent(this.eventId));
		}

		protected function get timeString():String
		{
			var date:Date = new Date(this.time * 1000);
			var day:String = formatTime(date.getDate());
			var month:String = formatTime(date.getMonth() + 1);
			var year:String = formatTime(date.getFullYear());

			return day + "." + month + "." + year;
		}

		protected function formatTime(time:int):String
		{
			var timeString:String = String(time);
			if (timeString.length < 2)
				timeString = "0" + timeString;
			return timeString;
		}
	}
}