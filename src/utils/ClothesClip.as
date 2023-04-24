package utils
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	import utils.starling.StarlingAdapterSprite;

	public class ClothesClip extends StarlingAdapterSprite
	{
		private var nameClip:String = "";

		private var isStarling:Boolean = true;

		public function ClothesClip(isStarling:Boolean = true):void
		{
			super();

			this.isStarling = isStarling;
		}

		override public function getRect(targetCoordinateSpace:DisplayObject):Rectangle
		{
			var rect:Rectangle = super.getRect(targetCoordinateSpace);
			return new Rectangle(rect.x + 25, rect.y, rect.width - 50, rect.height);
		}

		public function get totalFrames():int
		{
			if (this.numChildren > 0)
			{
				if (this.isStarling)
					var child:Object = getChildStarlingAt(0);
				else
					child = getChildAt(0);

				return child.totalFrames;
			}

			return 0;
		}

		public function play():void
		{
			for (var i:int = 0; i < this.numChildren; i++)
			{
				if (this.isStarling)
					var child:Object = getChildStarlingAt(i);
				else
					child = getChildAt(i);

				child.play();
			}
		}

		public function stop():void
		{
			for (var i:int = 0; i < this.numChildren; i++)
			{
				if (this.isStarling)
					var child:Object = getChildStarlingAt(i);
				else
					child = getChildAt(i);

				if (child)
				{
					child.stop();
				}

			}
		}

		public function gotoAndStop(frame:int, scene:String = null):void
		{
			if (scene) {/*unused*/}

			for (var i:int = 0; i < this.numChildren; i++)
			{
				if (this.isStarling)
					var child:Object = getChildStarlingAt(i);
				else
					child = getChildAt(i);

				child.gotoAndStop(frame);
			}
		}

		public function gotoAndPlay(frame:int, scene:String = null):void
		{
			if (scene) {/*unused*/}

			for (var i:int = 0; i < this.numChildren; i++)
			{
				if (this.isStarling)
					var child:Object = getChildStarlingAt(i);
				else
					child = getChildAt(i);
				if (child)
				{
					child.gotoAndPlay(frame);
				}
			}
		}

		public function setName(name:String):void
		{
			this.nameClip = name;
		}

		public function getName():String
		{
			return this.nameClip;
		}
	}
}