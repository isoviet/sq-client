package
{
	import flash.utils.getDefinitionByName;

	import utils.IControlAnimation;
	import utils.starling.StarlingAdapterMovie;
	import utils.starling.StarlingAdapterSprite;

	public class AlternativeView extends StarlingAdapterSprite implements IControlAnimation
	{
		private var viewRun:StarlingAdapterMovie;
		private var viewStand:StarlingAdapterMovie;

		private var _state:int = -2;

		public function AlternativeView(views:Array)
		{
			super();

			var className:Class = getDefinitionByName(views[0]) as Class;
			this.viewRun = new StarlingAdapterMovie(new className());

			className = getDefinitionByName(views[1]) as Class;
			this.viewStand = new StarlingAdapterMovie(new className());

			addChildStarling(this.viewStand);
			addChildStarling(this.viewRun);

			this.setState(Hero.STATE_REST);
		}

		public function setState(value:int, frame:int = 0):void
		{
			if (this._state == value && value == Hero.STATE_STOPED)
				return;

			this._state = value;

			if (this.viewStand)
				this.viewStand.stop();

			if (this.viewRun)
				this.viewRun.stop();

			if (value == Hero.STATE_STOPED)
				return;
			if (this.viewStand)
				this.viewStand.visible = false;

			if (this.viewRun)
				this.viewRun.visible = false;

			switch (this._state)
			{
				case Hero.STATE_SHAMAN:
				case Hero.STATE_REST:
					this.viewStand.visible = true;
					this.viewStand.gotoAndPlay(0);
					break;
				case Hero.STATE_RUN:
					this.viewRun.visible = true;
					this.viewRun.gotoAndPlay(0);
					break;
				case Hero.STATE_JUMP:
					this.viewRun.visible = true;
					this.viewRun.gotoAndStop(5);
					break;
			}
		}
	}
}