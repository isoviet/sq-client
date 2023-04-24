package dialogs
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import fl.controls.CheckBox;

	import buttons.ButtonBase;

	import interfaces.IDispose;

	import utils.FieldUtils;

	public class DialogInfo extends Dialog implements IDispose
	{
		static private const MIN_WIDTH:int = 250;

		protected var content:GameField;

		protected var checkBox:CheckBox;

		private var succesFunction:Function;
		private var hasCancelButton:Boolean;
		private var widthField:int = 0;
		private var format:TextFormat;

		private var hasEffectOpen:Boolean;

		public var data:Object;

		public function DialogInfo(caption:String, message:String, hasCancelButton:Boolean = false, success:Function = null, width:int = 0, textFormat:TextFormat = null, hasEffectOpen:Boolean = true, addCheckBox:Boolean = false):void
		{
			super(caption);

			this.succesFunction = success;
			this.hasCancelButton = hasCancelButton;
			this.widthField = width;

			if (textFormat != null)
				this.format = textFormat;
			else
			{
				this.format = new TextFormat(null, 14, 0x1f1f1f);
				this.format.align = TextFormatAlign.CENTER;
			}

			this.hasEffectOpen = hasEffectOpen;

			init(message, addCheckBox);
		}

		public function dispose():void
		{
			this.succesFunction = null;
		}

		public function replaceSign(replaces:Array):void
		{
			FieldUtils.multiReplaceSign(this.content, replaces);
		}

		override public function show():void
		{
			if (this.checkBox && checkBox.selected && this.succesFunction != null)
			{
				this.succesFunction();
				hide();
				return;
			}
			super.show();
		}

		override protected function effectOpen():void
		{
			if (!this.hasEffectOpen)
				return;

			super.effectOpen();
		}

		override protected function initClose():void
		{
			super.initClose();

			if (!this.hasCancelButton)
			{
				if (this.succesFunction != null)
				{
					super.buttonClose.removeEventListener(MouseEvent.CLICK, hide);
					super.buttonClose.addEventListener(MouseEvent.CLICK, onSuccess, false, 0, true);
				}
			}
		}

		protected function init(message:String, addCheckBox:Boolean):void
		{
			this.content = new GameField(message, 0, 10, this.format);
			this.content.width = this.widthField ? this.widthField : Math.max(MIN_WIDTH, this.content.textWidth + 5);
			this.content.wordWrap = true;
			this.content.multiline = true;
			addChild(this.content);

			if (addCheckBox)
			{
				this.checkBox = new CheckBox();
				this.checkBox.y = this.content.y + this.content.textHeight;
				this.checkBox.width = MIN_WIDTH;
				this.checkBox.label = gls("Больше не спрашивать");
				this.checkBox.selected = false;
				addChild(this.checkBox);
			}

			var okButton:ButtonBase = new ButtonBase(gls("Ок"));
			okButton.addEventListener(MouseEvent.CLICK, hide);
			if (this.succesFunction != null)
				okButton.addEventListener(MouseEvent.CLICK, onSuccess, false, 0, true);

			if (!this.hasCancelButton)
				place(okButton);
			else
			{
				var cancelButton:ButtonBase = new ButtonBase(gls("Отмена"));
				cancelButton.width += 13;
				cancelButton.height += 5;
				cancelButton.addEventListener(MouseEvent.CLICK, hide, false, 0, true);

				cancelButton.height = okButton.height;
				cancelButton.scaleX = cancelButton.scaleY;
				place(okButton, cancelButton);
			}

			this.height = this.topOffset + this.content.y + this.content.height + this.bottomOffset + okButton.height + (addCheckBox ? 30 : 20);
			this.content.x = int((this.width - this.content.width) / 2) - this.leftOffset;

			if (addCheckBox)
				this.checkBox.x = this.content.x + int((this.widthField - this.content.textWidth) * 0.5) - 2;
		}

		protected function onSuccess(e:MouseEvent):void
		{
			hide();

			this.succesFunction();
		}
	}
}