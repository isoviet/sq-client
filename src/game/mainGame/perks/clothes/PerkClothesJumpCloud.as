package game.mainGame.perks.clothes
{
	import flash.events.Event;

	import Box2D.Common.Math.b2Vec2;

	import game.mainGame.behaviours.StateNinja;
	import game.mainGame.entity.magic.CloudNinja;

	public class PerkClothesJumpCloud extends PerkClothes
	{
		protected var allowDoubleJump:Boolean = true;
		protected var jumpCooldown:Number = 0;

		protected var stateNinja:StateNinja = null;

		public function PerkClothesJumpCloud(hero : Hero)
		{
			super(hero);

			this.stateNinja = new StateNinja(0);
		}

		override public function get switchable():Boolean
		{
			return true;
		}

		override public function get canTurnOff():Boolean
		{
			return false;
		}

		override public function get totalCooldown():Number
		{
			return 10;
		}

		override public function get activeTime():Number
		{
			return 15;
		}

		protected function get useCooldown():Number
		{
			return 2;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			if (this.jumpCooldown > 0)
			{
				this.jumpCooldown -= timeStep;
				if (this.jumpCooldown <= 0)
					onAllowDoubleJump();
			}
		}

		override protected function deactivate():void
		{
			super.deactivate();

			if (!this.hero.game)
				return;

			this.hero.removeEventListener(Hero.EVENT_DOUBLE_JUMP, onDoubleJump);

			if (this.allowDoubleJump)
				this.hero.maxInAirJumps--;

			this.allowDoubleJump = true;

			this.hero.behaviourController.removeState(this.stateNinja);
		}

		override protected function activate():void
		{
			super.activate();

			if (!this.hero.game)
				return;

			this.hero.maxInAirJumps++;

			this.hero.behaviourController.addState(this.stateNinja);

			this.hero.addEventListener(Hero.EVENT_DOUBLE_JUMP, onDoubleJump);
		}

		protected function onDoubleJump(e:Event):void
		{
			if (!this.hero || !this.allowDoubleJump)
				return;

			this.hero.maxInAirJumps--;

			this.allowDoubleJump = false;

			this.jumpCooldown = this.useCooldown;

			if (this.hero.id != Game.selfId)
				return;

			var castObject:CloudNinja = new CloudNinja();
			castObject.angle = (this.hero.heroView.direction ? 0 : Math.PI) + this.hero.angle;
			castObject.x = this.hero.x;
			castObject.y = this.hero.y + hero.getLocalVector(new b2Vec2(0, 35)).y;
			castObject.playerId = this.hero.id;
			this.hero.game.map.createObjectSync(castObject, true);
		}

		protected function onAllowDoubleJump():void
		{
			if (this.allowDoubleJump || !this.hero)
				return;
			this.allowDoubleJump = true;
			this.hero.maxInAirJumps++;
		}
	}
}