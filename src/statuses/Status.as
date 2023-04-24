package statuses
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;

	public class Status extends Sprite
	{
		static private const CSS:String = (<![CDATA[
			body {
				font-family: "Droid Sans";
				font-size: 12px;
				color: #000000;
			}
			.small {
				font-family: "Droid Sans";
				font-size: 10px;
				color: #FF0000;
			}
			.green {
				color: #1B5B08;
				font-weight: bold;
			}
			.red {
				color: #CC0000;
				font-weight: bold;
			}
			.center {
				text-align: center;
			}
			.leftstr, .rightstr {
				float: left;
				width: 50%;
			}
			.rightstr {
				text-align: right;
			}
		]]>).toString();

		private var bold:Boolean = false;
		protected var isHtml:Boolean = false;
		protected var owner:DisplayObject = null;

		public var field:GameField = null;
		public var maxWidth:int = 185;

		public function Status(owner:DisplayObject, status:String = "", bold:Boolean = false, isHtml:Boolean = false):void
		{
			super();

			this.owner = owner;
			this.visible = false;
			this.bold = bold;
			this.isHtml = isHtml;
			init(status);

			if (this.owner is Sprite)
				(this.owner as Sprite).buttonMode = true;
		}

		public function remove():void
		{
			this.owner.removeEventListener(MouseEvent.MOUSE_OVER, onShow);
			this.owner.removeEventListener(MouseEvent.MOUSE_UP, onShow);
			this.owner.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.owner.removeEventListener(MouseEvent.MOUSE_OUT, close);
			this.owner.removeEventListener(Event.REMOVED_FROM_STAGE, onOwnerHide);

			close();
		}

		public function setStatus(data:String):void
		{
			if (this.field.text == data)
				return;

			this.field.text = data;
			this.field.width = this.maxWidth;
			this.field.width = this.field.textWidth + 6;

			draw();
		}

		public function setStyle(style:StyleSheet):void
		{
			this.field.styleSheet = style;
			this.field.htmlText = this.field.text;
			changeHeightBy(-12);
		}

		public function changeHeightBy(height:int):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 0.9);
			this.graphics.drawRoundRectComplex(0, 0, this.width + 10, this.height + 4 + height, 5, 5, 5, 5);
			this.graphics.endFill();
		}

		protected function onShow(e:MouseEvent):void
		{
			var gamePoint:Point = Game.gameSprite.globalToLocal(new Point(e.stageX, e.stageY));

			this.x = gamePoint.x + 13;
			this.y = gamePoint.y + 10;

			if (this.x + this.width > Config.GAME_WIDTH)
				this.x = gamePoint.x - this.width;

			if (this.y + this.height > Config.GAME_HEIGHT)
				this.y = gamePoint.y - this.height;

			if (e.type == MouseEvent.MOUSE_UP && Game.gameSprite.contains(this))
				Game.gameSprite.removeChild(this);

			if (Game.gameSprite.contains(this))
				return;
			Game.gameSprite.addChild(this);

			this.visible = true;
		}

		protected function onMove(e:MouseEvent):void
		{
			var gamePoint:Point = Game.gameSprite.globalToLocal(new Point(e.stageX, e.stageY));

			this.x = gamePoint.x + 13;
			this.y = gamePoint.y + 10;

			if (this.x + this.width > Config.GAME_WIDTH)
				this.x = gamePoint.x - this.width;

			if (this.y + this.height > Config.GAME_HEIGHT)
				this.y = gamePoint.y - this.height;
		}

		protected function close(e:MouseEvent = null):void
		{
			this.visible = false;

			if (!Game.gameSprite.contains(this))
				return;
			Game.gameSprite.removeChild(this);
		}

		protected function update():void
		{
			draw();
		}

		protected function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 0.9);
			this.graphics.drawRoundRectComplex(0, 0, this.width + 10, this.height + 4, 5, 5, 5, 5);
			this.graphics.endFill();
		}

		protected function get baseFormat():TextFormat
		{
			return new TextFormat(null, 12, 0x000000, this.bold);
		}

		private function init(status:String):void
		{
			if (this.isHtml)
			{
				var style:StyleSheet = new StyleSheet();
				style.parseCSS(CSS);
			}
			this.field = new GameField("", 5, 2, this.isHtml ? style : this.baseFormat);
			this.field.wordWrap = true;
			addChild(this.field);

			this.owner.addEventListener(MouseEvent.MOUSE_OVER, onShow);
			this.owner.addEventListener(MouseEvent.MOUSE_UP, onShow);
			this.owner.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.owner.addEventListener(MouseEvent.MOUSE_OUT, close);
			this.owner.addEventListener(Event.REMOVED_FROM_STAGE, onOwnerHide);

			setStatus(status);
		}

		private function onOwnerHide(e:Event):void
		{
			if (!this.visible)
				return;

			close();
		}
	}
}