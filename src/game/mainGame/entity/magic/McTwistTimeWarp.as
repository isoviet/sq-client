package game.mainGame.entity.magic
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;

	import game.mainGame.behaviours.StateTimeWarp;
	import game.mainGame.entity.ILifeTime;
	import game.mainGame.entity.simple.InvisibleBody;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;

	import utils.starling.particleSystem.CollectionEffects;
	import utils.starling.particleSystem.ParticlesEffect;

	public class McTwistTimeWarp extends InvisibleBody implements ILifeTime
	{
		static public const RADIUS:Number = 10;

		private var _aging:Boolean = true;
		private var _lifeTime:Number = 3 * 1000;

		private var disposed:Boolean = false;

		private var effect:ParticlesEffect;

		public function McTwistTimeWarp()
		{}

		override public function build(world:b2World):void
		{
			super.build(world);

			if (this.effect)
				CollectionEffects.instance.removeEffect(this.effect);

			this.effect = CollectionEffects.instance.getEffectByName(CollectionEffects.EFFECT_TIME_WARP);
			this.effect.view.visible = true;
			this.effect.view.emitterX = this.x;
			this.effect.view.emitterY = this.y;
			this.effect.view.maxRadius = RADIUS * Game.PIXELS_TO_METRE;
			this.effect.view.minRadius = RADIUS * Game.PIXELS_TO_METRE* 0.95;
			this.effect.start();

			Hero.self.getStarlingView().parent.addChild(this.effect.view);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (!this.aging || this.disposed)
				return;

			searchSquirrel();

			this.lifeTime -= timeStep * 1000;

			if (lifeTime <= 0)
				destroy();
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.aging, this.lifeTime, this.playerId]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.aging = Boolean(data[1][0]);
			this.lifeTime = data[1][1];
			this.playerId = data[1][2];
		}

		override public function dispose():void
		{
			super.dispose();

			removeEffect();
		}

		public function get aging():Boolean
		{
			return this._aging;
		}

		public function set aging(value:Boolean):void
		{
			this._aging = value;
		}

		public function get lifeTime():Number
		{
			return this._lifeTime;
		}

		public function set lifeTime(value:Number):void
		{
			this._lifeTime = value;
		}

		private function searchSquirrel():void
		{
			if (!this.gameInst || !this.gameInst.squirrels || !this.gameInst.squirrels.players)
				return;
			for each (var hero:Hero in this.gameInst.squirrels.players)
			{
				if (hero.id == this.playerId)
					continue;
				var dis:b2Vec2 = hero.position.Copy();
				dis.Subtract(this.position);
				if (dis.Length() > RADIUS)
					continue;
				hero.behaviourController.addState(new StateTimeWarp(0.25, 0.6));
			}
		}

		private function destroy():void
		{
			if (this.disposed)
				return;

			if (this.effect)
			{
				var tween:Tween = new Tween(this.effect.view, 2, Transitions.EASE_IN);
				tween.animate("alpha", 0);
				tween.onComplete = removeEffect;
				Starling.juggler.add(tween);
			}

			this.disposed = true;
			this.gameInst.map.destroyObjectSync(this, true);
		}

		private function removeEffect():void
		{
			if (!this.effect)
				return;
			this.effect.stop();
			CollectionEffects.instance.removeEffect(this.effect);
			this.effect = null;
		}
	}
}