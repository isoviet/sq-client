package game.mainGame.entity.editor
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.ISerialize;
	import game.mainGame.entity.IGameObject;

	import interfaces.IDispose;

	import utils.PopUpMessage;
	import utils.starling.StarlingAdapterSprite;

	public class Helper extends StarlingAdapterSprite implements IGameObject, ISerialize, IDispose
	{
		protected var popUp: StarlingAdapterSprite = null;

		protected var _message:String = "";
		private var _toggle:Boolean = false;

		public function Helper():void
		{
			init();
		}

		public function get position():b2Vec2
		{
			return new b2Vec2(this.x / Game.PIXELS_TO_METRE, this.y / Game.PIXELS_TO_METRE);
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
		}

		public function get angle():Number
		{
			return this.rotation * Game.D2R;
		}

		public function set angle(value:Number):void
		{
			this.rotation = value / (Game.D2R);
		}

		public function get toggle():Boolean
		{
			return this._toggle;
		}
		public function set toggle(value:Boolean):void
		{
			this._toggle = value;
		}

		public function build(world:b2World):void {}

		public function serialize():*
		{
			return [[this.position.x, this.position.y], this.angle, this.message];
		}

		public function deserialize(data:*):void
		{
			this.position = new b2Vec2(data[0][0], data[0][1]);
			this.angle = data[1];
			this.message = data[2];
		}

		public function dispose():void
		{
			while (this.numChildren > 0)
				this.removeChildStarlingAt(0);

			this.removeFromParent();

			if (this.popUp)
				this.popUp.removeFromParent();

			if (this.parentStarling)
				this.removeFromParent();

			this.popUp = null;
		}

		public function get message():String
		{
			return _message;
		}

		public function set message(value:String):void
		{
			if (this.popUp)
				this.popUp.removeFromParent();

			_message = value;

			if (!value || value == "")
				return;
			this.popUp = new StarlingAdapterSprite(new PopUpMessage(value, this.toggle), true);
			this.popUp.x = -this.popUp.width - 21;
			this.popUp.y = -this.popUp.height + 26;
			addChildStarling(this.popUp);
		}

		protected function init():void
		{
			addChildStarling(new StarlingAdapterSprite(new HelperImage()));
		}
	}
}