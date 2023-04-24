package views
{
	import flash.display.DisplayObject;

	public class LavaExplosionView extends ExplosionView
	{
		private var baseAngle:Number;
		private var maxDif:Number;

		public function LavaExplosionView(baseAngle:Number, maxDif:Number):void
		{
			this.baseAngle = baseAngle;
			this.maxDif = maxDif;
			super(null);
		}

		override protected function init():void
		{
			for (var i:int = 0; i < 1; i++)
			{
				var partBoom:DisplayObject = new LavaParticle1();
				partBoom.rotation = baseAngle + (maxDif * (Math.random() * 2 - 1));
				partBoom.scaleX = partBoom.scaleY = 1 + Math.random() * 3;
				partBoom.addEventListener("Complete", removeSelf);
				addChild(partBoom);
			}

			for (i = 0; i < 1; i++)
			{
				partBoom = new LavaParticle2();
				partBoom.rotation = baseAngle + (maxDif * (Math.random() * 2 - 1));
				partBoom.scaleX = partBoom.scaleY = 1 + Math.random() * 3;
				partBoom.addEventListener("Complete", removeSelf);
				addChild(partBoom);
			}
		}
	}
}