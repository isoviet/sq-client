package dialogs.base
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import dialogs.Dialog;

	import utils.ColorMatrix;

	public class DialogIconHeader extends Dialog
	{
		static public const FORMAT_CAPTION_CENTER:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 23,
			0xffffff, null, null, null, null, null, TextFormatAlign.CENTER);

		static private const TEXT_FORMAT_REWARD:TextFormat = new TextFormat(GameField.PLAKAT_FONT, 14, 0x857653,
			null, null, null, null, null, TextFormatAlign.CENTER);

		protected var iconHeader:MovieClip = null;
		private var header:ImageDialogIconHeader = null;
		private var ribborn:ImageRibborn = null;
		protected var isAnimate:Boolean = false;
		protected var textHeader:GameField = null;

		public function DialogIconHeader(iconHeader:Class, textUnderRibborn:String = "", captionDialog:* = null, drawBackground:Boolean = true,
			canClose:Boolean = true, backgroundClass:Class = null, drag:Boolean = true, huiBackdrop:Number = 0,
			huiFraming:Number = -60, huiRibbon:Number = 0)
		{
			captionDialog = gls("Поздравляем!");

			super(captionDialog, drawBackground, canClose, backgroundClass, drag);

			if(iconHeader == null)
				throw new Error("iconHeader not be null!");

			this.iconHeader = new iconHeader();

			if(this.iconHeader.totalFrames > 0)
				this.isAnimate = true;

			this.header = new ImageDialogIconHeader();

			this.header.header.cont.addChild(this.iconHeader);

			var colorMatrix:ColorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(0, 0, 0, huiBackdrop);
			this.header.header.back.filters = [new ColorMatrixFilter(colorMatrix)];

			this.ribborn = new ImageRibborn();
			colorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(0, 0, 0, huiRibbon);
			this.ribborn.filters = [new ColorMatrixFilter(colorMatrix)];

			colorMatrix = new ColorMatrix();
			colorMatrix.adjustColor(5, 32, huiFraming == -60 ? -98 : 0, huiFraming);
			this.header.header.border.filters = [new ColorMatrixFilter(colorMatrix)];

			if(textUnderRibborn != "")
				this.textHeader = new GameField(textUnderRibborn, 0, 33, TEXT_FORMAT_REWARD, 360);

			init();
		}

		override protected function setDefaultSize():void
		{
			this.leftOffset = 15;
			this.rightOffset = 20;
			this.topOffset = 50;
			this.bottomOffset = 0;
		}

		private function init():void
		{
			place();

			this.height = 386;
			this.width = 360;
		}

		override protected function get captionFormat():TextFormat
		{
			return FORMAT_CAPTION_CENTER;
		}

		protected function updateHeaderPosition():void
		{
			this.header.x = 163;
			this.header.y = this.dialogWindow.y - 80;

			this.ribborn.y = this.dialogWindow.y - 33;
			this.ribborn.x = this.dialogWindow.x - 30;

			if(this.buttonClose)
				this.buttonClose.y = this.ribborn.y + 74;

			if(this.fieldCaption)
				this.fieldCaption.y = -this.fieldCaption.height - 63;

			if(this.textHeader)
			{
				this.textHeader.y = this.ribborn.y + 74;
				this.textHeader.x = -this.leftOffset;
			}
		}

		override protected function draw():void
		{
			super.draw();

			if(this.textHeader && !this.contains(this.textHeader))
				this.addChild(this.textHeader);

			if(!this.contains(this.header))
				this.addChild(this.header);
			if(!this.contains(this.ribborn))
				this.addChild(this.ribborn);

			this.setChildIndex(this.header, 0);
			this.setChildIndex(this.dialogWindow, 1);
			this.setChildIndex(this.ribborn, 2);

			updateHeaderPosition();
		}

		/*protected function draw():void
		 {
		 if (!this.drawBackground)
		 return;

		 var origWidth:int = this.dialogWidth;
		 var origHeight:int = this.dialogHeight;

		 if (this.backgroundClass == null)
		 {
		 this.dialogWindow = new DialogBaseBackground();
		 this.dialogWindow.filters = [FILTER_SHADOW];
		 }
		 else
		 this.dialogWindow = new this.backgroundClass();

		 this.dialogWindow.x -= this.leftOffset;
		 this.dialogWindow.y -= this._topOffset;

		 this.dialogWindow.height = origHeight;
		 this.dialogWindow.width = origWidth;
		 addChildAt(this.dialogWindow, 0);
		 }*/

		override protected function initCaption():void
		{
			if (this.caption != "")
			{
				if(this.fieldCaption && this.contains(this.fieldCaption))
					this.removeChild(this.fieldCaption);

				this.fieldCaption = new GameField(this.caption, 0, 0, this.captionFormat);
				this.fieldCaption.filters = [new DropShadowFilter(0, 0, 0x081F3A, 1, 4, 4, 2)];
				this.fieldCaption.width = this.width - this.leftOffset - this.rightOffset;
				this.fieldCaption.multiline = true;
				this.fieldCaption.wordWrap = true;
				addChild(this.fieldCaption);

				if (this.dialogWindow && useCaption) //TODO веселый говнокод.
					this.dialogWindow.y -= this.fieldCaption.height + 5;
				this.fieldCaption.y = -this.fieldCaption.height - 63;
			}

			updateHeaderPosition();
		}

		override protected function initClose():void
		{
			if (!this.canClose)
				return;

			this.buttonClose = new ButtonCross();
			this.buttonClose.x = int(this.width - this.buttonClose.width / 2 - this.rightOffset - this.leftOffset);
			this.buttonClose.y = this.ribborn.y + 74;
			this.buttonClose.addEventListener(MouseEvent.CLICK, hide);
			addChild(this.buttonClose);
		}

		override public function clear():void
		{
			super.clear();

			if(this.header && this.contains(this.header))
				this.removeChild(this.header);
			if(this.ribborn && this.contains(this.ribborn))
				this.removeChild(this.ribborn);
		}

	}
}