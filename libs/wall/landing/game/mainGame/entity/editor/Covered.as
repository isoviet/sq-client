package landing.game.mainGame.entity.editor
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;

	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import landing.game.mainGame.entity.EntityFactory;
	import landing.game.mainGame.entity.simple.GameBody;

	import utils.ImageUtil;

	public class Covered extends GameBody
	{
		private var cover:Sprite = new Sprite();

		protected var coverId:int = -1;

		public function Covered():void
		{
			addChild(this.cover);
		}

		public function setCover(cover:Cover):void
		{
			this.coverId = EntityFactory.getId(cover);

			drawCover();
		}

		public function getCoverId():int
		{
			return this.coverId;
		}

		override public function build(world:b2World):void
		{
			for (var fixture:b2Fixture = this.body.GetFixtureList(); fixture; fixture = fixture.GetNext())
			{
				if (EntityFactory.getEntity(this.coverId) == CoverIce)
					fixture.SetFriction(0.1);
			}

			super.build(world);
		}

		protected function drawCover(width2:int = 0):void
		{
			if (this.coverId == -1)
				return;

			var coverClass:Class = EntityFactory.getImage(this.coverId);
			var coverImage:BitmapData = ImageUtil.getBitmapData(new coverClass());
			this.cover.graphics.clear();
			this.cover.graphics.beginBitmapFill(coverImage, null, true, true);
			var shiftPoint:Point = getShiftPoint();
			this.cover.graphics.drawRect(0, 0, (width2 == 0 ? this.width : width2), coverImage.height);
			this.cover.graphics.endFill();
			this.cover.x = shiftPoint.x;
			this.cover.y = shiftPoint.y;
			addChild(this.cover);
		}

		protected function getShiftPoint():Point
		{
			return new Point(0, 0);
		}
	}
}