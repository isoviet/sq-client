package game.mainGame.gameEvent
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	import Box2D.Dynamics.b2World;

	import game.mainGame.IHealth;

	import protocol.Connection;
	import protocol.PacketClient;

	public class HeroVolcano extends Hero implements IHealth
	{
		static public const MAX_HEALTH:int = 10;

		private var _health:uint;

		private var spriteHealth:Sprite = new Sprite();

		public function HeroVolcano(playerId:int, world:b2World, x:int = 0, y:int = 0)
		{
			super(playerId, world, x, y);
		}

		override public function set dead(value:Boolean):void
		{
			this.inHollow = value;

			super.dead = value;

			if (value)
				this.health = 0;
		}

		override public function update(timeStep:Number = 0):void
		{
			super.update(timeStep);

			this.spriteHealth.scaleX = this.scale > 0 ? 1 : -1;
		}

		override public function sendLocation(keyCode:int = 0):void
		{
			if (this.id != Game.selfId || this.isDead || this.inHollow || !this.sendMove)
				return;

			Connection.sendData(PacketClient.ROUND_HERO, keyCode, this.position.x, this.position.y, this.velocity.x, this.velocity.y, this.health);
		}

		override public function reset():void
		{
			super.reset();

			this.health = MAX_HEALTH;
		}

		override public function respawn(withAnimation:int = RESPAWN_NONE):void
		{
			super.respawn(withAnimation);

			this.health = MAX_HEALTH;
		}

		public function get health():int
		{
			return _health;
		}

		public function set health(value:int):void
		{
			if (this.vitalityTimer.running && (value != MAX_HEALTH))
				return;
			if (value == this.health)
				return;
			this._health = Math.min(Math.max(value, 0), MAX_HEALTH);

			addView(this.spriteHealth, true);
			while (this.spriteHealth.numChildren > 0)
				this.spriteHealth.removeChildAt(0);

			for (var i:int = 0; i < int((this.health + 1) / 2); i++)
			{
				if (this.isSelf)
					var image:MovieClip = (this.health - i * 2) == 1 ? new HitPointRedHalf() : new HitPointRed();
				else
				{
					image = (this.health - i * 2) == 1 ? new HitPointBlueHalf() : new HitPointBlue();
					image.alpha = 0.5;
				}

				image.x = -6 * (int(this.health / 2) - 1) + 12 * i;
				image.y = -75;
				this.spriteHealth.addChild(image);
			}

			sendLocation();
		}
	}
}