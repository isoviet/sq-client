package game.mainGame.entity.editor
{
	import flash.display.BitmapData;

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.ICover;
	import game.mainGame.entity.IGameObject;

	import interfaces.IDispose;

	import utils.starling.StarlingAdapterSprite;

	public class Cover extends StarlingAdapterSprite implements IDispose, IGameObject, ICover
	{
		private var coveredBody:Covered;

		public function Cover():void
		{
			initImage();
		}

		public function addCoveredObject(target: *): void {
			dispose();
			if (target is Covered)
			{
				(target as Covered).setCover(this);
				this.coveredBody = target as Covered;
			}
		}

		public function dispose():void
		{
			//if (this.parentStarling != null) {
			//	this.parentStarling.removeChildStarling(this, false);
			///}

			this.removeFromParent(true);
			this.coveredBody = null;
		}

		public function get position():b2Vec2
		{
			return null;
		}

		public function set position(value:b2Vec2):void
		{
			this.x = value.x * Game.PIXELS_TO_METRE;
			this.y = value.y * Game.PIXELS_TO_METRE;
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
	}
}