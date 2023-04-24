package landing.game.mainGame.entity.editor
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.IDispose;
	import landing.game.mainGame.entity.IGameObject;

	public class Cover extends Sprite implements IDispose, IGameObject
	{
		private var coveredBody:Covered;

		public function Cover():void
		{
			initImage();
			WallShadow.stage.addEventListener(MouseEvent.CLICK, onPutCover);
		}

		public function dispose():void
		{
			if (this.parent != null)
				this.parent.removeChild(this);
			WallShadow.stage.removeEventListener(MouseEvent.CLICK, onPutCover);
			this.coveredBody = null;
		}

		public function get position():b2Vec2
		{
			return null;
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * WallShadow.PIXELS_TO_METRE;
			this.y = value.y * WallShadow.PIXELS_TO_METRE;
		}

		public function getImage():BitmapData
		{
			return null;
		}

		public function set angle(value:Number):void
		{}

		public function build(world:b2World):void
		{}

		public function get angle():Number
		{
			return NaN;
		}

		protected function initImage():void
		{}

		private function onPutCover(e:MouseEvent):void
		{
			dispose();

			var target:Covered = null;

			if (e.target.parent != null)
				target = e.target.parent as Covered;
			else if (target == null)
				target = e.target as Covered;
			if (target == null)
				return;
			if (!hitTestObject(target))
				return;

			if (!(target is Covered))
				return;

			target.setCover(this);
			this.coveredBody = target;
		}
	}
}