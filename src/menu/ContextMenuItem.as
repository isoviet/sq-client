package menu
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	public class ContextMenuItem extends Sprite
	{
		static private const HEIGHT:int = 22;

		private var upSprite:Sprite = new Sprite();
		private var downSprite:Sprite = new Sprite();
		private var pasiveSprite:Sprite = new Sprite();

		private var formatActive:TextFormat = new TextFormat(null, 11, 0x000000);
		private var formatPassive:TextFormat = new TextFormat(null, 11, 0x657284);

		private var field:GameField;

		private var imageActive:DisplayObject;
		private var imagePassive:DisplayObject;

		private var isActive:Boolean = true;

		public function ContextMenuItem(value:String, width:int, imageActive:DisplayObject = null, imagePassive:DisplayObject = null):void
		{
			super();

			init(value, width, imageActive, imagePassive);
		}

		public function set active(value:Boolean):void
		{
			this.isActive = value;

			if (this.imagePassive != null)
				this.imagePassive.visible = !value;
			if (this.imageActive != null)
				this.imageActive.visible = value;

			if (value)
				this.field.setTextFormat(this.formatActive);
			else
				this.field.setTextFormat(this.formatPassive);

			this.downSprite.visible = false;

			this.upSprite.visible = value;
			this.pasiveSprite.visible = !value;
		}

		public function show():void
		{
			this.visible = true;
		}

		public function hide():void
		{
			this.visible = false;
		}

		private function init(value:String, width:int, imageActive:DisplayObject, imagePassive:DisplayObject = null):void
		{
			this.field = new GameField(value, 23, 3, this.formatActive);

			this.upSprite.graphics.beginFill(0xd3e2ec);
			this.upSprite.graphics.drawRect(0, 0, width, HEIGHT);
			this.upSprite.graphics.endFill();
			addChild(this.upSprite);

			this.downSprite.graphics.beginFill(0xEFE48A);
			this.downSprite.graphics.drawRect(0, 0, width, HEIGHT);
			this.downSprite.graphics.endFill();
			addChild(this.downSprite);

			this.pasiveSprite.graphics.beginFill(0xB1CBF7);
			this.pasiveSprite.graphics.drawRect(0, 0, width, HEIGHT);
			this.pasiveSprite.graphics.endFill();
			addChild(this.pasiveSprite);

			var lineImage:MenuLineImage = new MenuLineImage();
			lineImage.y = HEIGHT - 0.5;
			addChild(lineImage);

			addChild(field);

			if (imageActive != null)
			{
				this.imageActive = imageActive;
				this.imageActive.x = 5;
				this.imageActive.y = 3;
				addChild(this.imageActive);
			}

			if (imagePassive != null)
			{
				this.imagePassive = imagePassive;
				this.imagePassive.x = 5;
				this.imagePassive.y = 3;
				this.imagePassive.visible = false;
				addChild(this.imagePassive);
			}

			addEventListener(MouseEvent.MOUSE_OVER, over);
			addEventListener(MouseEvent.MOUSE_OUT, out);
			addEventListener(MouseEvent.CLICK, click);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			addEventListener(MouseEvent.MOUSE_UP, over);

			hideAll();

			this.upSprite.visible = true;
		}

		private function over(e:Event):void
		{
			if (!this.isActive)
				return;

			hideAll();

			this.downSprite.visible = true;
		}

		private function out(e:Event):void
		{
			if (!this.isActive)
				return;

			hideAll();

			this.upSprite.visible = true;
		}

		private function click(e:Event):void
		{
			if (!this.isActive)
				return;

			hideAll();

			this.downSprite.visible = true;

			dispatchEvent(new ContextMenuItemEvent(this));
		}

		private function mouseDown(e:Event):void
		{
			if (!this.isActive)
				return;

			hideAll();

			this.downSprite.visible = true;
		}

		private function hideAll():void
		{
			this.upSprite.visible = false;
			this.downSprite.visible = false;
			this.pasiveSprite.visible = false;
		}
	}
}