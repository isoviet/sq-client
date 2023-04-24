package game.mainGame.entity.magic
{
	import flash.events.Event;

	import game.mainGame.entity.simple.InvisibleBodyTemp;

	public class RapunzelLight extends InvisibleBodyTemp
	{
		public function RapunzelLight()
		{
			super(RapunzelPerkView, 370, 220);
		}

		override public function get stopInEnd():Boolean
		{
			return true;
		}

		override protected function onFrame(e:Event):void
		{
			super.onFrame(e);

			if (this.aging)
				return;
			this.aging = this.view && !view.isPlaying;
		}
	}
}