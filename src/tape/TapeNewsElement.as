package tape
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	import tape.events.TapeElementEvent;
	import views.TvView;

	public class TapeNewsElement extends TapeObject
	{
		static public const NEWS:int = 0;
		static public const DISCOUNT:int = 1;
		static public const OFFER_OK:int = 2;

		protected var buttonState:Boolean = false;

		protected var backSelected:MovieClip = null;

		protected var _id:int;

		protected var _type:int = 0;

		public function TapeNewsElement(itemId:int, type:int = 0):void
		{
			super();

			this._id = itemId;
			this._type = type;

			this.buttonMode = true;

			init();
		}

		override public function listen(listener:Function):void
		{}

		override public function forget(listener:Function):void
		{}

		public function get id():int
		{
			return this._id;
		}

		public function get type():int
		{
			return this._type;
		}

		public function get isDiscount():Boolean
		{
			return this.type != NEWS;
		}

		public function get selected():Boolean
		{
			return this.buttonState;
		}

		public function set selected(select:Boolean):void
		{
			this.buttonState = select;

			this.backSelected.visible = this.buttonState;
		}

		protected function init():void
		{
			switch (this.type)
			{
				case NEWS:
					imageClass = TvView.getButtonClass(this.id);
					var imageIcon:DisplayObject = new imageClass();
					imageIcon.x = imageIcon.y = 2;
					addChild(imageIcon);
					break;
				case DISCOUNT:
					this.graphics.beginFill(0xFFFFFF);
					this.graphics.drawRect(0, 0, 90, 90);

					var imageClass:Class = DiscountManager.getButtonClass(this.id);
					var imageButton:SimpleButton = new imageClass();
					imageButton.x = 23;
					imageButton.y = 25;
					imageButton.mouseEnabled = false;
					addChild(imageButton);
					break;
			}

			var image:ImageNewsButtonFrame = new ImageNewsButtonFrame();
			image.mouseEnabled = false;
			addChild(image);

			this.backSelected = new ImageNewsButtonSelected();
			this.backSelected.visible = false;
			this.backSelected.mouseEnabled = false;
			this.backSelected.mouseChildren = false;
			addChild(this.backSelected);

			addEventListener(MouseEvent.MOUSE_DOWN, stick);
		}

		protected function stick(e:MouseEvent):void
		{
			dispatchEvent(new TapeElementEvent(this, TapeElementEvent.STICKED));
		}
	}
}