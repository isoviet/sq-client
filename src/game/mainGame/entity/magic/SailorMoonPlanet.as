package game.mainGame.entity.magic
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import game.mainGame.CollisionGroup;
	import game.mainGame.entity.IPersonalObject;
	import game.mainGame.entity.controllers.PlanetControllerPersonal;
	import game.mainGame.entity.editor.PlanetBody;
	import game.mainGame.entity.simple.GameBody;

	public class SailorMoonPlanet extends PlanetBody implements IPersonalObject
	{
		static private const CATEGORIES_BITS:uint = CollisionGroup.OBJECT_CATEGORY;
		static private const MASK_BITS:uint = CollisionGroup.HERO_CATEGORY;

		static private const FIXTURE_DEF:b2FixtureDef = new b2FixtureDef(null, null, 0.8, 0.1, 3, CATEGORIES_BITS, MASK_BITS, 0);

		static public const SPEED:Number = 40 / Game.PIXELS_TO_METRE;

		private var timeStart:Number = 3.0;
		private var timeMove:Number = 3.0;
		private var timeEnd:Number = 3.0;
		private var lifeTime:Number = 9.0;

		private var disposed:Boolean = false;

		public function SailorMoonPlanet()
		{
			super();

			this._size = new b2Vec2(5, 5);
			this._gravity = 50;
			this._invSqr = true;

			this._affectObjects = false;
			this._maxDistance = 50;
			this._disableGlobalGravity = true;
			this.skins = [SailorMoonPlanetView];

			this.fixed = true;
		}

		public function get personalId():int
		{
			return this.playerId;
		}

		public function breakContact(playerId:int):Boolean
		{
			return this.personalId != playerId;
		}

		override protected function get fixture():b2FixtureDef
		{
			return FIXTURE_DEF;
		}

		override public function build(world:b2World):void
		{
			super.build(world);

			(this.controller as PlanetControllerPersonal).playerId = this.playerId;
		}

		override protected function get controllerClass():Class
		{
			return PlanetControllerPersonal;
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

			var index:int = GameBody.isOldStyle(data) ? 4 : 2;

			this.playerId = data[index][0];
			this.lifeTime = data[index][1];

			this.timeEnd = Math.max(Math.min(3.0, this.lifeTime), 0);
			this.timeMove = Math.max(Math.min(3.0, this.lifeTime - this.timeEnd), 0);
			this.timeStart = Math.max(Math.min(3.0, this.lifeTime - this.timeMove - this.timeEnd), 0);
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.timeStart > 0)
			{
				this.timeStart -= timeStep;
				return;
			}
			if (this.timeMove > 0)
			{
				this.position = new b2Vec2(this.position.x, this.position.y - SPEED * timeStep);
				this.timeMove -= timeStep;
				return;
			}
			if (this.timeEnd > 0)
			{
				this.timeEnd -= timeStep;
				return;
			}
			destroy();
		}

		private function destroy():void
		{
			if (this.disposed)
				return;
			this.disposed = true;
			this.gameInst.map.destroyObjectSync(this, true);
		}
	}
}