package game.mainGame.perks.clothes
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateBanshee;
	import game.mainGame.entity.magic.TornadoPharaon;

	public class PerkClothesPharaon extends PerkClothes
	{
		private var tornado:TornadoPharaon;
		private var view:MovieClip;

		private var stateBanshee:StateBanshee;

		public function PerkClothesPharaon(hero:Hero):void
		{
			super(hero);

			this.activateSound = "tornado";
			this.stateBanshee = new StateBanshee(0);
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get totalCooldown():Number
		{
			return 60;
		}

		override public function get activeTime():Number
		{
			return 5;
		}

		override public function get available():Boolean
		{
			return (super.available && (this.active ? true : !this.hero.heroView.fly));
		}

		override protected function activate():void
		{
			super.activate();

			var sprite:Sprite = new Sprite();
			this.view = new PharaonMagicView();
			this.view.addFrameScript(this.view.totalFrames - 1, onMovieEnd);
			this.view.play();
			sprite.addChild(this.view);

			this.hero.changeView(sprite);
			this.hero.behaviourController.addState(this.stateBanshee);

			this.hero.body.SetLinearVelocity(new b2Vec2());
			this.hero.angle = 0;
			this.hero.rotation = 0;

			this.hero.isStoped = true;
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (this.view)
				this.view.stop();
			this.view = null;

			if (!this.hero || !this.hero.game)
				return;

			this.hero.isStoped = false;
			this.hero.behaviourController.removeState(this.stateBanshee);
			this.hero.changeView();
		}

		private function onMovieEnd():void
		{
			if (this.view)
				this.view.stop();
			this.view = null;

			if (!this.hero)
				return;

			this.hero.isStoped = false;

			if (this.hero.isDead || this.hero.inHollow || this.hero.shaman)
				return;

			this.hero.changeView(new Sprite());

			if (!this.hero.game || this.hero.id != Game.selfId)
				return;
			this.tornado = new TornadoPharaon();
			this.tornado.playerId = this.hero.id;

			var dirX:b2Vec2 = this.hero.rCol1;
			var dirY:b2Vec2 = this.hero.rCol2;
			dirY.Multiply(-5);
			dirX.Add(dirY);
			this.tornado.position = b2Math.AddVV(this.hero.position, dirX);
			this.hero.game.map.createObjectSync(this.tornado, true);
		}
	}
}