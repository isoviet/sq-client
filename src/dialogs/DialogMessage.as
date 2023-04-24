package dialogs
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import com.greensock.TweenMax;

	public class DialogMessage extends Dialog
	{
		private var textField:GameField;

		public function DialogMessage():void
		{
			super("");

			init();
		}

		public function setMeassage(message:String):void
		{
			this.textField.text = message;
		}

		override public function show():void
		{
			this.visible = true;

			addToSprite();

			var copyThis:Sprite = this;
			TweenMax.to(this, 1, {'onComplete': function():void
			{
				TweenMax.to(copyThis, 0.5, {'alpha': 0, 'onComplete': function():void
				{
					hide();
				}});
			}});
		}

		override public function hide(e:MouseEvent = null):void
		{
			hideDialog();
		}

		private function init():void
		{
			this.textField = new GameField(gls("Запрос отправлен!"), 20, 25, new TextFormat(null, 16, 0x663C0D, true, null, null, null, null, TextFieldAutoSize.CENTER));
			this.textField.width = 120;
			this.textField.wordWrap = true;
			this.textField.multiline = true;
			addChild(this.textField);

			place();

			this.height += 50;
			this.width += 50;
		}
	}
}