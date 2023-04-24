package statuses
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import game.mainGame.GameMap;

	import utils.FieldUtils;

	public class StatusIcons extends StatusPerk
	{
		private static const OFFSET_Y:Number = 5;
		private static const OFFSET_X:Number = 8;
		private static const PADDING:Number = 5;

		private var _iconsList:Array = null;
		private var _fixedWidth:Number;

		private var _fixed:Point = null;

		public function StatusIcons(owner:DisplayObject, fixedWidth:Number, status:String = "", bold:Boolean = false, fixedPoint:Point = null, insertIcons:Array = null)
		{
			super(owner, status, bold, this.isHtml);

			this._fixed = fixedPoint;
			this._fixedWidth = fixedWidth;

			this._iconsList = [];
			this.field.y += 4;

			if (insertIcons != null)
				updateIcons(insertIcons);

			if (isFixed)
				setPosition(this._fixed.x, this._fixed.y);
		}

		public function get isFixed():Boolean
		{
			return this._fixed != null;
		}

		public function setPosition(_x:Number, _y:Number):void
		{
			this.x = _x;
			this.y = _y;

			if (this.x < 10)
				this.x = 10;
			if (this.y < 10)
				this.y = 10;

			if (this.x + this.width > GameMap.gameScreenWidth - 10)
				this.x = GameMap.gameScreenWidth - this.width - 10;

			if (this.y + this.height > GameMap.gameScreenHeight - 10)
				this.y = GameMap.gameScreenHeight - this.height - 10;

			this.fixed = new Point(this.x, this.y);
		}

		override protected function onShow(e:MouseEvent):void
		{
			if(!this.isFixed)
			{
				var gamePoint:Point = Game.gameSprite.globalToLocal(new Point(e.stageX, e.stageY));
				this.x = gamePoint.x + 13;
				this.y = gamePoint.y + 10;
				if (this.x + this.width > Config.GAME_WIDTH)
					this.x = gamePoint.x - this.width;
				if (this.y + this.height > Config.GAME_HEIGHT)
					this.y = gamePoint.y - this.height;
			}

			if (e.type == MouseEvent.MOUSE_UP && Game.gameSprite.contains(this))
				Game.gameSprite.removeChild(this);

			if (Game.gameSprite.contains(this))
				return;
			Game.gameSprite.addChild(this);

			this.visible = true;
		}

		public function updateIcons(values:Array, max_height:Number=20):void
		{
			var _x:Number = this._fixedWidth;
			for each(var image:DisplayObject in this._iconsList)
				if(this.contains(image)) removeChild(image);

			for each(image in values)
			{
				if(image.height > max_height)
					image.scaleY = image.scaleX = max_height / image.height;
				addChild(image);

				image.x = _x - image.width * image.scaleX - PADDING;
				image.y = OFFSET_Y;

				_x = image.x;

				this._iconsList.push(image);
			}
			update();
		}

		public function hide():void
		{
			close();
		}

		override protected function draw():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF, 0.9);
			this.graphics.drawRoundRectComplex(0, 0, this.width + 10, this.height + 7, 5, 5, 5, 5);
			this.graphics.endFill();
		}

		public function addOnceIcon(image:DisplayObject, scale:Number, shiftX:Number, shiftY:Number):void
		{
			addChild(image);
			image.scaleX = image.scaleY = scale;
			image.x = shiftX;
			image.y = shiftY;
			update();
		}

		public function replaceSign(image:Class, replace:String, scale:Number, shiftX:Number, shiftY:Number):void
		{
			FieldUtils.replaceSign(this.field, replace, image, scale, scale, shiftX, shiftY, this.isHtml, true);
			update();
		}

		public function get fixed():Point
		{
			return this._fixed;
		}

		public function set fixed(value:Point):void
		{
			if(value)
				this.owner.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			else
				this.owner.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this._fixed = value;
		}
	}
}