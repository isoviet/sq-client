package game.mainGame.entity.editor
{
	import Box2D.Common.Math.b2Vec2;

	import utils.starling.StarlingAdapterMovie;

	public class ButtonSensor extends SensorRect
	{
		private var upView:StarlingAdapterMovie = new StarlingAdapterMovie(new ButtonScriptUp());
		private var _down:Boolean = false;

		public function ButtonSensor():void
		{
			super();

			this.upView.y = -10;
			addChildStarling(this.upView);

			this.contactsCount = 0;
			this.size = new b2Vec2();
			this.visible = true;
			this.checkContacts = true;
			this.upView.loop = false;
			this.upView.stop();
		}

		override public function set showDebug(value:Boolean):void
		{
			super.showDebug = value;
			this.visible = true;
		}

		override public function set size(value:b2Vec2):void
		{
			if (value) {/*unused*/}
			super.size = new b2Vec2(4.4, 1.6);
		}

		override public function get contactsCount():int
		{
			return super.contactsCount;
		}

		override public function set contactsCount(value:int):void
		{
			super.contactsCount = value;
			this.down = this.contactsCount > 0;
		}

		public function get down():Boolean
		{
			return this._down;
		}

		override protected function draw():void
		{}

		public function set down(value:Boolean):void
		{
			if (this._down == value)
				return;

			this._down = value;
			if (value)
				this.upView.playAndStop(0, 10);
			else
				this.upView.playAndStop(11, 21);
		}
	}
}