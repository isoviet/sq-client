package game.mainGame.entity.editor
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;

	public class PlatformIceGroundBody extends PartitionsPlatform
	{
		static private const LEFT_WIDTH:Number = 32;
		static private const RIGHT_WIDTH:Number = 32;
		static private const MIDDLE_WIDTH:Number = 32;

		public function PlatformIceGroundBody():void
		{
			super(false);
			leftWidthBlock -= 2;
			draw();
		}

		override protected function resize(width:int, height:int):void
		{
			width = Math.max(int(width / MIDDLE_WIDTH) * MIDDLE_WIDTH, LEFT_WIDTH + RIGHT_WIDTH);

			super.resize(width, height);
		}

		override public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		override protected function get leftClass():Class
		{
			return IceGroundLeft;
		}

		override protected function get middleClass():Class
		{
			return IceGroundMiddle;
		}

		override protected function get rightClass():Class
		{
			return IceGroundRight;
		}
	}
}