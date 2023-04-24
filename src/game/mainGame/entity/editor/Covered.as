package game.mainGame.entity.editor
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;

	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2World;

	import game.mainGame.entity.EntityFactory;
	import game.mainGame.entity.ILandSound;
	import game.mainGame.entity.simple.CacheVolatileBody;

	import utils.ImageUtil;
	import utils.starling.StarlingAdapterSprite;

	public class Covered extends CacheVolatileBody implements ILandSound
	{
		protected var coverStarling:StarlingAdapterSprite = new StarlingAdapterSprite();
		protected var cover:Sprite = new Sprite();

		protected var coverId:int = -1;
		protected var defaultLandSound:String = "";

		public function Covered():void
		{
			addChildStarling(coverStarling);
		}

		public function setCover(cover:Cover):void
		{
			this.coverId = EntityFactory.getId(cover);

			drawCover();
		}

		public function get landSound():String
		{
			var cover:Class = EntityFactory.getEntity(this.coverId);
			if (cover == CoverIce)
				return "glass_fall";
			return this.defaultLandSound;
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

			if (coverClass == null)
				return;

			var coverImage:BitmapData = ImageUtil.getBitmapData(new coverClass());
			this.cover.graphics.clear();
			this.cover.graphics.beginBitmapFill(coverImage, null, true, true);
			var shiftPoint:Point = getShiftPoint();
			var roundedWidth: int = Math.ceil((width2 == 0 ? this.width : width2) / 32) * 32;
			this.cover.graphics.drawRect(0, 0, roundedWidth, coverImage.height - 1);
			this.cover.graphics.endFill();
			this.cover.x = shiftPoint.x;
			this.cover.y = shiftPoint.y;

			this.coverStarling.removeFromParent();

			this.coverStarling = new StarlingAdapterSprite(this.cover, true);
			addChildStarling(this.coverStarling);
		}

		protected function getShiftPoint():Point
		{
			return new Point(0, 0);
		}
	}
}