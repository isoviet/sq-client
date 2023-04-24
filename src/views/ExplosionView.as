package views
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class ExplosionView extends Sprite
	{
		private var starClass:Class = null;

		public function ExplosionView(starClass:Class):void
		{
			super();

			this.starClass = starClass;

			init();
		}

		protected function init():void
		{
			for (var i:int = 0; i < 40; i++)
			{
				var partBoom:DisplayObject = new partGo();
				partBoom.rotation = Math.random() * 360;
				partBoom.scaleX = partBoom.scaleY = 1 + Math.random() * 3;
				partBoom.addEventListener("Complete", removeSelf);
				addChild(partBoom);
			}

			for (i = 0; i < 10; i++)
			{
				partBoom = new this.starClass();
				partBoom.rotation = Math.random() * 360;
				partBoom.scaleX = partBoom.scaleY = 1 + Math.random() * 3;
				partBoom.addEventListener("Complete", removeSelf);
				addChild(partBoom);
			}
		}

		protected function removeSelf(e:Event):void
		{
			e.target.removeEventListener("Complete", removeSelf);

			if (this.contains((e.target as DisplayObject)))
				this.removeChild((e.target as DisplayObject));

			if ((this.numChildren != 0) && parent != null && parent.contains(this))
				parent.removeChild(this);
		}
	}
}