package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	public class PerkClothesDeadpool extends PerkClothes
	{
		static public var count:int = 0;
		private var deadpoolView:MovieClip = null;

		public function PerkClothesDeadpool(hero:Hero)
		{
			super(hero);

			this.activateSound = "deadpool";
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return true;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function get totalCooldown():Number
		{
			return 5;
		}

		override public function dispose():void
		{
			super.dispose();

			if (this.deadpoolView != null && this.deadpoolView.parent != null)
				this.deadpoolView.parent.removeChild(this.deadpoolView);
			this.deadpoolView = null;
		}

		override protected function activate():void
		{
			super.activate();

			if (this.deadpoolView == null)
				this.deadpoolView = new DeadpoolPerkView();

			this.deadpoolView.mouseEnabled = false;
			this.deadpoolView.mouseChildren = false;
			this.deadpoolView.scaleX = count % 2 == 0 ? 1 : -1;
			this.deadpoolView.x = count % 2 == 0 ? 0 : 900;

			if (!Game.gameSprite.contains(this.deadpoolView))
				Game.gameSprite.addChild(this.deadpoolView);

			count++;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.deadpoolView != null && this.deadpoolView.parent != null)
				this.deadpoolView.parent.removeChild(this.deadpoolView);
			this.deadpoolView = null;
		}
	}
}