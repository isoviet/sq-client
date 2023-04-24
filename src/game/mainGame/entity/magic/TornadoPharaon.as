package game.mainGame.entity.magic
{
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateBanshee;
	import game.mainGame.entity.simple.Tornado;
	import sensors.events.DetectHeroEvent;

	public class TornadoPharaon extends Tornado
	{
		public var lifeTime:Number = 10.0;

		public function TornadoPharaon()
		{
			super();
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			var owner:Hero = this.gameInst.squirrels.get(this.playerId);
			if (owner == null || owner.isDead || owner.inHollow || owner.shaman || owner.behaviourController.getState(StateBanshee) == null)
				this.lifeTime = 0;
			else
			{
				var dirX:b2Vec2 = owner.rCol1;
				var dirY:b2Vec2 = owner.rCol2;
				dirY.Multiply(-5);
				dirX.Add(dirY);
				this.position = b2Math.AddVV(owner.position, dirX);
			}

			if (this.lifeTime <= 0)
				death();
			else
				this.lifeTime -= timeStep;
		}

		override public function serialize():*
		{
			var result:Array = super.serialize();

			result.push([this.playerId, this.lifeTime]);

			return result;
		}

		override public function deserialize(data:*):void
		{
			super.deserialize(data);

			this.playerId = data[2][0];
			this.lifeTime = data[2][1];
		}

		override protected function onHeroDetected(e:DetectHeroEvent):void
		{
			var hero:Hero = e.hero;

			if (this.squirrels[hero.id] != null || hero.isDead || hero.inHollow || this.playerId == hero.id)
				return;

			commandPinSquirrel(hero.id);
		}

		private function death():void
		{
			if (this.body == null)
				return;

			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}