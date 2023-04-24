package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	public class RastrButton extends SimpleButton 
	{
		private var _overState:DisplayObject;
		private var _downState:DisplayObject;
		private var _upState:DisplayObject;

		public function RastrButton() 
		{
			super();

			this._overState = this.overState;
			this._downState = this.downState;
			this._upState = this.upState;

			update();
		}

		private function draw(from:DisplayObject):BitmapData
		{
			var sprite:Sprite = new Sprite();
			var bitmapData:BitmapData;
			sprite.addChild(from);
			bitmapData = new BitmapData(sprite.width, sprite.height, true, 0x00000000);
			bitmapData.draw(sprite);

			return bitmapData;
		}

		private function update():void 
		{
			this.overState = new Bitmap(draw(this._overState));
			this.downState = new Bitmap(draw(this._downState));
			this.upState = new Bitmap(draw(this._upState));
			this.hitTestState = this.overState;
		}

		override public function get width():Number 
		{
			return _overState.width;
		}

		override public function set width(value:Number):void 
		{
			_overState.width = value;
			_upState.width = value;
			_downState.width = value;

			update();
		}

		override public function get height():Number 
		{
			return _overState.height;
		}

		override public function set height(value:Number):void 
		{
			_overState.height = value;
			_upState.height = value;
			_downState.height = value;

			update();
		}

		override public function get scaleX():Number 
		{
			return _overState.scaleX;
		}

		override public function set scaleX(value:Number):void 
		{
			_overState.scaleX = value;
			_upState.scaleX = value;
			_downState.scaleX = value;

			update();
		}

		override public function get scaleY():Number 
		{
			return _overState.scaleY;
		}

		override public function set scaleY(value:Number):void 
		{
			_overState.scaleY = value;
			_upState.scaleY = value;
			_downState.scaleY = value;

			update();
		}
	}
}