package game.mainGame.gameQuests
{
	import flash.display.MovieClip;
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import by.blooddy.crypto.serialization.JSON;

	import protocol.Connection;
	import protocol.PacketClient;

	public class ObjectGreed extends QuestObject
	{
		static private var weightView:MovieClip = null;

		private var explode:MovieClip = null;

		public function ObjectGreed(hero:Hero):void
		{
			super(hero);

			this.view = new ObjectGreedView();
			this.view.x = -20;
			this.view.y = -15;
			addChild(this.view);

			if (!weightView)
			{
				weightView = new IconGreedView();
				weightView.x = -14;
				weightView.y = -80;
				weightView.visible = false;
				weightView.stop();
				this.hero.addChild(weightView);
			}
		}

		override public function dispose():void
		{
			if (weightView)
			{
				this.hero.removeChild(weightView);
				weightView = null;
			}

			super.dispose();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			weightView.visible = !this.hero.isDead && !this.hero.inHollow;

			if (this.activated)
				return;

			var pos:b2Vec2 = this.hero.position.Copy();
			pos.Subtract(this.position);

			if (pos.Length() >= 4)
				return;
			this.visible = false;
			this.activated = true;

			weightView.gotoAndStop(weightView.currentFrame + (weightView.visible ? 5 : 0));

			Connection.sendData(PacketClient.ROUND_COMMAND, by.blooddy.crypto.serialization.JSON.encode({'questFactor': 0.9}));

			this.explode = new QuestItemExplode();
			this.explode.y = -20;
			this.explode.addEventListener(Event.CHANGE, onChange);
			this.hero.addView(this.explode, true);
		}

		private function onChange(e:Event):void
		{
			if (!this.explode)
				return;
			this.explode.removeEventListener(Event.CHANGE, onChange);
			this.explode = null;
			if (this.hero)
				this.hero.changeView();
		}
	}
}