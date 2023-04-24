package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateSpeed;

	public class PerkClothesLogan extends PerkClothes
	{
		static private const negative: b2Vec2 = new b2Vec2(20, 0);
		static private const positive: b2Vec2 = new b2Vec2(-20, 0);

		private var stateSpeed:StateSpeed = null;
		private var view:MovieClip = null;

		public function PerkClothesLogan(hero: Hero):void
		{
			super(hero);

			this.activateSound = "logan";
			this.view = new LoganPerkView();
			this.view.addFrameScript(this.view.totalFrames - 1, onEnd);
			this.view.scaleX = this.view.scaleY = 0.5;
			this.view.y = -21;
			this.view.stop();
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 20;
		}

		override public function get activeTime():Number
		{
			return 10;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.active || !this.hero.heroView.running)
				return;
			findVictims();
		}

		override protected function activate():void
		{
			super.activate();

			this.stateSpeed = new StateSpeed(0, 0.2);
			this.hero.behaviourController.addState(this.stateSpeed);
		}

		override protected function deactivate():void
		{
			super.deactivate();

			this.hero.behaviourController.removeState(this.stateSpeed);
			this.stateSpeed = null;
		}

		private function findVictims():void
		{
			for each (var hero:Hero in this.hero.game.squirrels.players)
			{
				if (hero.id == this.hero.id || hero.isDead || hero.inHollow)
					continue;
				var pos:b2Vec2 = this.hero.position.Copy();
				pos.Subtract(hero.position);
				if (pos.Length() > 2)
					continue;
				hero.body.SetLinearVelocity(this.hero.body.GetWorldVector(this.hero.heroView.direction ? negative : positive));
				this.hero.body.SetLinearVelocity(this.hero.body.GetWorldVector(this.hero.heroView.direction ? positive : negative));

				if (!this.view.isPlaying)
				{
					this.hero.addView(this.view);
					this.view.play();
				}
			}
		}

		private function onEnd():void
		{
			if (this.view)
				this.view.stop();
			if (this.hero && this.view)
				this.hero.changeView();
		}
	}
}