package game.mainGame.entity.editor
{
	import flash.display.InteractiveObject;

	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import sensors.ISensor;

	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class PartitionsPlatform extends PlatformGroundBody implements ISensor
	{
		static protected const HEIGHT:Number = 23.6;

		protected var swampSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var leftClassStarling: StarlingAdapterMovie;
		protected var rightClassStarling: StarlingAdapterMovie;
		protected var placeSprite: StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var middleSprite:StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var middleWidthBlock: Number = 0;
		protected var leftWidthBlock: Number = 0;
		protected var rightWidthBlock: Number = 0;

		public function PartitionsPlatform(redraw: Boolean = true)
		{
			super();

			while (numChildren > 0)
				removeChildStarlingAt(0);

			middleWidthBlock = new middleClass().width;
			leftWidthBlock = new leftClass().width;
			rightWidthBlock = new rightClass().width;

			leftClassStarling = new StarlingAdapterMovie(new this.leftClass());
			rightClassStarling = new StarlingAdapterMovie(new this.rightClass());
			leftClassStarling.loop = true;
			leftClassStarling.play();
			rightClassStarling.loop = true;
			rightClassStarling.play();

			this.swampSprite.addChildStarling(placeSprite);
			this.swampSprite.addChildStarling(leftClassStarling);
			this.swampSprite.addChildStarling(rightClassStarling);
			rightClassStarling.x = 0;
			addChildStarling(this.swampSprite);
			if (redraw)
			{
				draw();
			}
		}

		override public function build(world:b2World):void
		{
			if (!this.body) {
				this.body = world.CreateBody(BODY_DEF);
				this.body.SetUserData(this);

				var shape:b2PolygonShape = b2PolygonShape.AsOrientedBox(((this.swampSprite.width) / 2) / Game.PIXELS_TO_METRE, (HEIGHT / 2) / Game.PIXELS_TO_METRE, new b2Vec2((this.swampSprite.width / 2)/ Game.PIXELS_TO_METRE, (HEIGHT / 2) / Game.PIXELS_TO_METRE));
				var fixtureDef:b2FixtureDef = new b2FixtureDef(shape, this, friction, restitution, density, this.categories, this.maskBits, 0);
				this.body.CreateFixture(fixtureDef);
			}

			super.build(world);
		}

		public function beginContact(contact:b2Contact):void
		{}

		public function endContact(contact:b2Contact):void
		{}

		public function preSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{}

		public function postSolve(contact:b2Contact, impulse:b2ContactImpulse):void
		{}

		override protected function resize(width:int, height:int):void
		{
			height = this.heightAll;
			width = Math.max(int(width / this.middleWidthBlock) * this.middleWidthBlock, this.leftWidthBlock + this.rightWidthBlock);
			super.resize(width, height);
		}

		override protected function draw():void
		{
			while (middleSprite.numChildren > 0) {
				middleSprite.getChildStarlingAt(0).stop();
				middleSprite.getChildStarlingAt(0).removeFromParent(true);
				middleSprite.removeChildStarlingAt(0);
			}

			while (this.placeSprite.numChildren > 0) {
				this.placeSprite.removeChildStarlingAt(0, true);
			}

			var len: int = Math.ceil((this._width - this.leftWidthBlock) / this.middleWidthBlock) - 1;
			for (var i:int = 0; i < len; i++)
			{
				var newMiddle: StarlingAdapterMovie = new StarlingAdapterMovie(new middleClass());
				newMiddle.loop = true;
				newMiddle.play();
				newMiddle.x = i * this.middleWidthBlock;
				middleSprite.addChildStarling(newMiddle);
			}

			middleSprite.x = this.leftWidthBlock;

			if (middleSprite.width && middleSprite.height)
				this.placeSprite.addChildStarling(middleSprite);

			rightClassStarling.x = middleSprite.x + middleSprite.width;

			initDoubleClick();
		}

		protected function initDoubleClick():void
		{
			for (var i:int = 0; i < this.swampSprite.numChildren; i++)
				if (this.swampSprite.getChildStarlingAt(i) is InteractiveObject)
					(this.swampSprite.getChildStarlingAt(i) as InteractiveObject).doubleClickEnabled = true;
		}

		protected function get leftClass():Class
		{
			return null;
		}

		protected function get middleClass():Class
		{
			return null;
		}

		protected function get rightClass():Class
		{
			return null;
		}

		protected function get heightAll():Number
		{
			return HEIGHT;
		}
	}
}