package game.mainGame.entity.editor
{
	import utils.HelperLearningMessage;
	import utils.starling.StarlingAdapterSprite;

	public class HelperLearning extends Helper
	{
		public function HelperLearning():void
		{
			super();
		}

		override public function set message(value:String):void
		{
			if (this.popUp)
				this.popUp.removeFromParent();

			_message = value;

			if (!value || value == "")
				return;
			this.popUp = new StarlingAdapterSprite(new HelperLearningMessage(value), true);
			this.popUp.x = -this.popUp.width + 5;
			this.popUp.y = -this.popUp.height - 35;
			addChildStarling(this.popUp);
		}

		override protected function init():void
		{
			var view: StarlingAdapterSprite = new StarlingAdapterSprite(new ShamanIcon());
			view.y = -view.height + 21;
			view.x = -view.width / 2;
			addChildStarling(view);
		}
	}
}