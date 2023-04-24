package game.mainGame.entity.magic
{
	import flash.events.Event;

	import game.mainGame.entity.simple.InvisibleBodyTemp;

	import utils.starling.StarlingAdapterMovie;

	public class FarmerField extends InvisibleBodyTemp
	{
		static public var images:Array = null;

		public var type:int = 0;

		public function FarmerField()
		{
			if (!images)
				images = [FarmerPerkView0, FarmerPerkView1, FarmerPerkView2];
			this.type = int(Math.random() * images.length);

			super(null, 0, 0);
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.type]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.type = data[2][0];

			setView();
		}

		private function setView():void
		{
			this.view = new StarlingAdapterMovie(new images[this.type]);
			this.view.play();
			this.view.x = 0;
			this.view.y = 10;
			addChildStarling(this.view);

			if (this.stopInEnd)
				this.view.addEventListener(Event.ENTER_FRAME, onFrame);
		}

		override public function get stopInEnd():Boolean
		{
			return true;
		}
	}
}